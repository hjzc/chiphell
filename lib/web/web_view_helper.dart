import 'dart:convert';
import 'dart:typed_data';
import 'package:chiphell/common/constants.dart';
import 'package:chiphell/utils/file_save_helper.dart';
import 'package:chiphell/utils/image_save_helper.dart';
import 'package:chiphell/utils/pdf_save_helper.dart';
import 'package:chiphell/common/type_utils.dart';
import 'package:chiphell/utils/utils.dart';
import 'package:chiphell/utils/zs_log.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';
import 'package:vibration/vibration.dart';
import '../data/black_list.dart';
import '../modals/AppState.dart';
import '../modals/WebImages.dart';
import '../modals/zj_Image_cacheManager.dart';
import '../multi_windows/window_util.dart';
import '../net/download_file.dart';
import '../net/net_state.dart';
import '../sites/web_site.dart';
import '../utils/Toast.dart';
import '../utils/ui_utils.dart';
import 'zj_web_notification.dart';

class WebViewHelper {
  InAppWebViewController? _webViewController;
  InAppWebViewController? get webViewController => _webViewController;
  ZjWebNotificationController? _webNotificationController;
  PrintJobController? printJobController;

  Uint8List? _screenshot;
  bool _imageDownloadFlag = true;
  bool get imageDownloadCancelled => _imageDownloadFlag;

  WebImages? webImages;
  int webPageImageCount = 0;

  String webViewUserAgent = '';

  Debouncer<String>? _lastUrlDebouncer;
  String? siteLastUrl;

  //获得webview tab的context
  BuildContext Function()? onCallWebTabContext;
  //向 webview tab，发送事件
  Future<dynamic> Function(int event, String? eventFn, dynamic param)? fnEventCall;
  dynamic Function(int event, String? eventFn, dynamic param)? fnSynEventCall;

  //ios 上可不太可靠，使用iosIsFindInteractionEnabled判断
  bool _isFindInteractionEnabled = false;
  bool get isFindInteractionEnabled => _isFindInteractionEnabled;
  set isFindInteractionEnabled(bool val) {
    if (Utils.isWindows()) {
      return;
    }
    if (val != _isFindInteractionEnabled) {
      _isFindInteractionEnabled = val;
      _updateWebContextEvent(0, eventFn: '_pageOnFindUpdate', param: true);
    }
  }

  BuildContext? context() {
    return onCallWebTabContext != null ? onCallWebTabContext!() : null;
  }

  Future<bool> webViewHasHistory() async {
    bool r = await _webViewController?.canGoBack() == true || await _webViewController?.canGoForward() == true;
    return r;
  }

  Map<String, String>? makeRequestHeader(String? referUrl, String? userAgent, Map<String, String>? orgHeader, {int? stype = -1}) {
    Map<String, String> header = {};
    if (orgHeader != null && orgHeader.isNotEmpty) {
      header.addAll(orgHeader);
    }
    WebSite? w = _getWebSiteSyn();
    if (!header.containsKey(Utils.httpHeaderUserAgent)) {
      header[Utils.httpHeaderUserAgent] = userAgent ?? webViewUserAgent;
    }
    if (!header.containsKey(Utils.httpHeaderReferer)) {
      var rr = referUrl ?? w?.firstUrl(_getWebIsMobileUASyn());
      if (rr != null && rr.isNotEmpty) {
        header[Utils.httpHeaderReferer] = rr;
      }
    }
    if (!header.containsKey(Utils.httpHeaderCookie)) {
      var rr = w?.cookieFromInfo;
      if (rr != null && rr.isNotEmpty) {
        header[Utils.httpHeaderCookie] = rr;
      }
    }
    if (stype == 0) {
      //img  image/avif,image/webp,image/png,image/svg+xml,image/*;q=0.8,*/*;q=0.5
      header[Utils.httpHeaderAccept] = "image/avif,image/webp,image/png,image/svg+xml,image/*;q=0.8,*/*;q=0.5";
    } else if (stype == 1) {
      //zip gzip, deflate, br, zstd
      header[Utils.httpHeaderAccept] = 'gzip, deflate, br, zstd';
    } else if (header.containsKey(Utils.httpHeaderAccept)) {
      header.remove(Utils.httpHeaderAccept);
    }
    return header.isEmpty ? null : header;
  }

  Future<void> handleWebHttpError(bool? isForMainFrame, int? statusCode) async {
    //当服务器的负载超过其处理能力时，会拒绝新的连接请求，从而导致503错误。
    if (statusCode == null || isForMainFrame == null) {
      return;
    }
    if (statusCode == 503) {
      if (isForMainFrame) {
        Toast.toastAtCenter(context(), Constants.kWebRequestError503);
      }
    }
  }

  Future<bool> iosIsFindInteractionEnabled() async {
    return (await isFindNavigatorVisibleOniOS()) ?? false;
  }

  /// 从webview page获得异步 数据
  Future<dynamic> _updateWebContextEvent(int event, {String? eventFn, dynamic param}) async {
    if (fnEventCall != null) {
      return await fnEventCall!(event, eventFn, param);
    } else {
      return null;
    }
  }

  Future<String?> getWebCurrentUrl() async {
    var r = await _updateWebContextEvent(1, eventFn: '_getWebCurrentUrl', param: null);
    return r is String ? r : null;
  }

  /// 从webview page获得同步 数据
  dynamic _getWebContextSynEvent(int event, {String? eventFn, dynamic param}) {
    if (fnSynEventCall != null) {
      return fnSynEventCall!(event, eventFn, param);
    } else {
      return null;
    }
  }

  WebSite? _getWebSiteSyn() {
    var r = _getWebContextSynEvent(0, eventFn: 'site', param: null);
    if (r is WebSite) {
      return r;
    }
    return null;
  }

  bool _getWebIsMobileUASyn() {
    var r = _getWebContextSynEvent(1, eventFn: 'isMobileUA', param: null);
    if (r is bool) {
      return r;
    }
    return false;
  }

  // String? _getWebContextCookie() {
  //   return _getWebContextWebSite()?.cookieFromInfo;
  // }

  Future<bool> webViewOpenUrl(String? url) async {
    bool r = false;
    if (url != null) {
      _webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
      r = true;
    }
    return r;
  }

  Future<bool> hasWebPageImage() async {
    return webPageImageCount > 0;
  }

  Future<List<String>> webPageImageUrls() async {
    await getWebPageImages(null);
    return webImages?.images ?? [];
  }

  ///web controller
  Future<bool> canGoBack() async {
    return await _webViewController?.canGoBack() ?? false;
  }

  Future<bool> goBack() async {
    bool r = false;
    if (await canGoBack()) {
      await _webViewController?.goBack();
      r = true;
    }
    return r;
  }

  Future<bool> canGoForward() async {
    return await _webViewController?.canGoForward() ?? false;
  }

  Future<bool> goForward() async {
    bool r = false;
    if (await canGoForward()) {
      await _webViewController?.goForward();
      r = true;
    }
    return r;
  }

  Future<bool> isLoading() async {
    return await _webViewController?.isLoading() == true;
  }

  Future<bool> stopLoading() async {
    bool r = false;
    if (await isLoading()) {
      _webViewController?.stopLoading();
      r = true;
    }
    return r;
  }

  Future<bool> handlePopBackGesture(bool forceForum) async {
    bool ret = await goBack();
    if (forceForum && !ret) {
      ret = await gotoCurrentForum(false);
    }
    return ret;
  }

  Future<bool> handleBackMenu(bool forceForum) async {
    bool ret = await gotoCurrentForum(forceForum);
    if (forceForum == false && ret == false) {
      ret = await goBack();
    }
    return ret;
  }

  Future<bool> goSiteHome({bool autoEnable = false}) async {
    bool mb = _getWebIsMobileUASyn();
    var v = _getWebSiteSyn()?.homeUrl(mb);
    if (autoEnable && v == null) {
      v = AppState.site.homeUrl(mb);
    }
    return await webViewOpenUrl(v);
  }

  void saveLastUrl(String? urlStr) {
    if (_lastUrlDebouncer == null) {
      WebSite? v = _getWebSiteSyn();
      String? initVal = v?.lastUrl;
      initVal ??= urlStr;
      _lastUrlDebouncer = Debouncer<String>(
        Duration(milliseconds: 3000),
        initialValue: initVal ?? '',
        onChanged: (value) {
          if (siteLastUrl != value) {
            siteLastUrl = value;
            v?.updateLastUrl(value);
          }
        },
      );
    } else {
      _lastUrlDebouncer?.value = urlStr ?? '';
    }
  }

  void Function(int activeMatchOrdinal, int numberOfMatches, bool isDoneCounting)? findResoultCall;

  //find
  FindInteractionController? findController;
  Future<bool?> isFindNavigatorVisibleOniOS() async {
    return await findController?.isFindNavigatorVisible();
  }

  Future<void> dismissFindNavigatorOniOS() async {
    await findController?.dismissFindNavigator();
  }

  Future<void> presentFindNavigatorOniOS() async {
    await findController?.presentFindNavigator();
  }

  void init() {
    //flutter_inappwebview: ^6.2.0-beta.2 ios/mac andriod支持
    //TODO:flutter_inappwebview: ^6.2.0-beta.3 才全平台支持,在windows上有bug，先不支持
    if (Utils.isWindows() == false) {
      findController = FindInteractionController(
        onFindResultReceived: (controller, activeMatchOrdinal, numberOfMatches, isDoneCounting) async {
          if (findResoultCall != null) {
            findResoultCall!(activeMatchOrdinal, numberOfMatches, isDoneCounting);
          }
        },
      );
    }
  }

  void initWebViewController(InAppWebViewController? controller) {
    if (_webViewController != controller) {
      _webViewController = controller;
      _screenshot = null;
      if (controller != null) {
        if (supportNotification) {
          _webNotificationController = ZjWebNotificationController(controller);
          addNotificationJavaScriptHandlers();
        }
      } else {
        _webNotificationController = null;
      }
    }
  }

  Uint8List? get screenshot => _screenshot;
  //web 加载停止，且内容有效
  Future<void> webRequestStop(WebUri? uri, bool docReady) async {
    if (AppState().webNotificationEnable && docReady && uri != null && (_getWebSiteSyn()?.isSite(uri.toString()) == true)) {
      ZjWebNotificationPermission? r = await _webNotificationController?.getPermission();
      if (r != null) {
        if (r == ZjWebNotificationPermission.DEFAULT ||
            (AppState().webChiphellNotificationEnable && r == ZjWebNotificationPermission.DENIED)) {
          await _webNotificationController?.requestPermission();
        } else if (AppState().webChiphellNotificationEnable && r == ZjWebNotificationPermission.GRANTED) {}
      }
    }
  }

  void clean() {
    _lastUrlDebouncer?.cancel();
    _lastUrlDebouncer = null;
    _imageDownloadFlag = false;
    _webViewController = null;
    if (_webNotificationController != null) {
      _webNotificationController?.notifications.clear();
      _webNotificationController = null;
    }
    findResoultCall = null;
    onCallWebTabContext = null;
    fnEventCall = null;
    fnSynEventCall = null;
    findController = null;
    //findController.dispose(isKeepAlive: false);
    _safeCleanPrintJob();
  }

  bool valid() {
    return _webViewController != null;
  }

  Future<String?> outFileName() async {
    String? r = await _webViewController?.getTitle();
    return Utils.sanitizeFilename(r);
  }

  bool suppertOnPageFind() {
    return Utils.isMacOS() || Utils.isIOS() || Utils.isAndroid(); //||
    //(Utils.isWindows() && (WebConstants.webCore().code > 0));
  }

  //android 可以支持打印 导出pdf
  bool suppertPdf() {
    return Utils.isMacOS() || Utils.isIOS() || Utils.isWindows();
  }

  bool suppertPrintJob() {
    return Utils.isMacOS() || Utils.isIOS() || Utils.isWindows();
  }

  ///Supported Platforms:
  ///- iOS - macos -windows
  Future<Uint8List?> createPDF(PDFConfiguration? options) async {
    PDFConfiguration op = options ?? PDFConfiguration(settings: PrintJobSettings());
    return await _webViewController?.createPdf(pdfConfiguration: op);
  }

  //web view tab image
  Future<void> updateScreenshot() async {
    // double x = 0;
    // double y = 0;
    // double h = 0;
    // double w = 0;
    // final RenderBox renderBox =
    //     (widget.key as GlobalKey).currentContext?.findRenderObject()
    //         as RenderBox;
    // h = renderBox.size.height;
    // w = renderBox.size.width;
    // int? cw = await _webViewController?.getContentWidth();
    // if (cw != null && (cw.toDouble() > w)) {
    //   w = cw.toDouble();
    // }
    // int? ch = await _webViewController?.getContentHeight();
    // if (ch != null && (ch.toDouble() > h)) {
    //   h = ch.toDouble();
    // }

    // int? cx = await _webViewController?.getScrollX();
    // if (cx != null && (cx.toDouble() > x)) {
    //   x = cx.toDouble();
    // }
    // int? cy = await _webViewController?.getScrollY();
    // if (cy != null && (cy.toDouble() > y)) {
    //   y = cy.toDouble();
    // }

    _screenshot = await webScreenshot();
  }

  //TODO:在baidu等网站背景色是透明的，设置截图是非PNG的格式，截图背景色会是黑色
  Future<Uint8List?> webScreenshot({bool isPng = true, int jpegQuality = 20}) async {
    return await _webViewController
        ?.takeScreenshot(
          screenshotConfiguration: ScreenshotConfiguration(
            // rect: InAppWebViewRect(x: x, y: y, width: w, height: h),
            compressFormat: isPng ? CompressFormat.PNG : CompressFormat.JPEG,
            quality: jpegQuality,
          ),
        )
        .timeout(const Duration(milliseconds: 1500), onTimeout: () => null);
  }

  Future<void> saveScreenShotToLocal({
    ResultCallback? callback,
    //void Function(bool sucess, String desc)? callBack,
  }) async {
    bool ispng = (Utils.isApple() || Utils.isWindows());
    Uint8List? data = await webScreenshot(isPng: ispng);
    if (data != null) {
      await ImageSaverHelper.saveImageDataToSystem(
        data,
        outFileName: await outFileName(),
        extension: ispng ? CTMimeTypeExe.kMTPng : CTMimeTypeExe.kMTJpeg,
        callback: callback,
      );
    } else if (callback != null) {
      callback(Constants.kWebScreenShotFailed, '', false);
    }
  }

  Future<void> saveWebPdfToLocal({ResultCallback? callback}) async {
    Uint8List? pdfData = await createPDF(null);
    if (pdfData != null) {
      await PdfSaveHelper.savePdfDataToSystem(
        pdfData,
        outFileName: await outFileName(),
        extension: CTMimeTypeExe.kMTPdf,
        callback: callback,
      );
    } else if (callback != null) {
      callback(Constants.kWebExportPdfFailed, '', false);
    }
  }

  void _safeCleanPrintJob() {
    try {
      if (printJobController != null) {
        printJobController?.dispose();
        printJobController = null;
      }
    } catch (e) {
      ZsLog.e('safe clean print job error:$e');
    }
  }

  ///print job
  /// linux 不支持
  Future<void> printJob({ResultCallback? callback}) async {
    _safeCleanPrintJob();

    //TODO: ios/macos 只显示第一页，把numberOfPages设置100页，用户自己修改
    final jobSettings = PrintJobSettings(
      handledByClient: true,
      jobName: "${await _webViewController?.getTitle() ?? ''} - PDF Document",
      colorMode: PrintJobColorMode.MONOCHROME,
      outputType: PrintJobOutputType.GRAYSCALE,
      orientation: PrintJobOrientation.LANDSCAPE,
      numberOfPages: Utils.isApple() ? 100 : 1,
    );

    printJobController = await _webViewController?.printCurrentPage(settings: jobSettings);
    PrintJobInfo? jobInfo;
    printJobController?.onComplete = (completed, error) async {
      String result = '打印完成';
      if (completed) {
        if (Utils.isAndroid()) {
          //无法判断
          result = '';
        }
        ZsLog.d("Print Job Completed");
      } else {
        result = "打印错误";
        ZsLog.d("Print Job Failed $error");
      }
      _safeCleanPrintJob();
      if (callback != null) {
        callback(result, error, completed);
      }
    };
    jobInfo = await printJobController?.getInfo();
    ZsLog.d("print job:${jobInfo ?? "null"}");
  }

  static bool get isSupportNotification => (Utils.isAndroid() || Utils.isIOS());
  bool get supportNotification => WebViewHelper.isSupportNotification;

  void addNotificationJavaScriptHandlers() {
    _webViewController?.addJavaScriptHandler(
      handlerName: 'Notification.requestPermission',
      callback: (arguments) async {
        if (!AppState().webNotificationEnable) {
          return ZjWebNotificationPermission.DEFAULT.name.toLowerCase();
        }
        final permission = await onNotificationRequestPermission();
        return permission.name.toLowerCase();
      },
    );

    _webViewController?.addJavaScriptHandler(
      handlerName: 'Notification.show',
      callback: (arguments) {
        if (AppState().webNotificationEnable && (_webViewController != null)) {
          final notification = ZjWebNotification.fromJson(arguments[0], _webViewController!);
          onShowNotification(notification);
        }
      },
    );

    _webViewController?.addJavaScriptHandler(
      handlerName: 'Notification.close',
      callback: (arguments) {
        final notificationId = arguments[0];
        onCloseNotification(notificationId);
      },
    );
  }

  Future<ZjWebNotificationPermission> onNotificationRequestPermission() async {
    final url = await _webViewController?.getUrl();
    if (url != null) {
      final savedPermission = ZjWebNotificationPermissionDb.getPermission(url.host);
      if (savedPermission != null && savedPermission == ZjWebNotificationPermission.GRANTED) {
        return savedPermission;
      }
    }
    BuildContext? webContext = context();
    if (webContext == null) {
      return ZjWebNotificationPermission.DEFAULT;
    }
    if (!webContext.mounted) {
      return ZjWebNotificationPermission.DEFAULT;
    }
    final permission =
        await showDialog<ZjWebNotificationPermission>(
          context: webContext,
          builder: (context) {
            return AlertDialog(
              title: Text('${url?.host} 想显示通知'), //wants to show notifications'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop<ZjWebNotificationPermission>(context, ZjWebNotificationPermission.DENIED);
                  },
                  child: const Text(Constants.kPermissionDeny),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop<ZjWebNotificationPermission>(context, ZjWebNotificationPermission.GRANTED);
                  },
                  child: const Text(Constants.kPermissionGrant),
                ),
              ],
            );
          },
        ) ??
        ZjWebNotificationPermission.DENIED;

    if (url != null) {
      //var vsite = _getWebSiteSyn();
      if (AppState.site.isSite(url.toString())) {
        AppState().webChiphellNotificationEnable = (permission == ZjWebNotificationPermission.GRANTED);
      }
      await ZjWebNotificationPermissionDb.savePermission(url.host, permission);
    }

    return permission;
  }

  Future<void> onShowNotification(ZjWebNotification notification) async {
    _webNotificationController?.notifications[notification.id] = notification;

    var iconUrl = notification.icon != null ? Uri.tryParse(notification.icon!) : null;
    if (iconUrl != null && !iconUrl.hasScheme) {
      iconUrl = Uri.tryParse((await _webViewController?.getUrl()).toString() + iconUrl.toString());
    }

    final snackBar = SnackBar(
      duration: const Duration(seconds: 5),
      action: SnackBarAction(
        label: '查看', //'Action',
        onPressed: () async {
          await notification.dispatchClick();
        },
      ),
      content: Row(
        children: <Widget>[
          iconUrl != null
              ? Padding(padding: const EdgeInsets.only(right: 10), child: Image.network(iconUrl.toString(), width: 50))
              : Container(),
          // add your preferred text content here
          Expanded(
            child: Text(
              notification.title + (notification.body != null ? '\n${notification.body!}' : ''),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    BuildContext? webContext = context();
    if (webContext != null && webContext.mounted) {
      notification.snackBarController = ScaffoldMessenger.of(webContext).showSnackBar(snackBar);
      notification.snackBarController?.closed.then((value) async {
        notification.snackBarController = null;
        await notification.close();
      });
    }

    final vibrate = notification.vibrate;
    bool hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator && vibrate != null && vibrate.isNotEmpty) {
      if (vibrate.length % 2 != 0) {
        vibrate.add(0);
      }
      final intensities = <int>[];
      for (int i = 0; i < vibrate.length; i++) {
        if (i % 2 == 0 && vibrate[i] > 0) {
          intensities.add(255);
        } else {
          intensities.add(0);
        }
      }
      await Vibration.vibrate(pattern: vibrate, intensities: intensities);
    }
  }

  void onCloseNotification(int id) {
    final notification = _webNotificationController?.notifications[id];
    if (notification != null) {
      final snackBarController = notification.snackBarController;
      if (snackBarController != null) {
        snackBarController.close();
      }
      _webNotificationController?.notifications.remove(id);
    }
  }

  //网站第一次打开，调用请求通知权限 /'Request Notification Permission'
  // Future<void> requestWebNotificationPermission() async {
  //   if (AppState().webNotificationEnable) {
  //     final url = await _webViewController?.getUrl();
  //     if (ChiphellSite.isWebSite(url?.host)) {
  //       await _webNotificationController?.requestPermission();
  //     }
  //   }
  // }

  // //在应用关闭通知后，权限重置
  // Future<void> resetWebNotificationPermission() async {
  //   await _webNotificationController?.resetPermission();
  //   ZjWebNotificationPermissionDb.clearHost(ChiphellSite.webSiteHost());
  // }

  // //查看权限
  // Future<ZjWebNotificationPermission> getPermission() async {
  //   ZjWebNotificationPermission? r = await _webNotificationController
  //       ?.getPermission();
  //   return r ?? ZjWebNotificationPermission.DEFAULT;
  // }

  ///先调用 requestWebNotificationPermission，，同意后，然后在执行下面程序
  Future<void> createWebNotification() async {
    await _webViewController?.evaluateJavascript(
      source: """
          var testNotification = new Notification('Notification Title', {body: 'Notification Body!', icon: 'https://picsum.photos/150?random=' + Date.now(), vibrate: [200, 100, 200]});
          testNotification.addEventListener('show', function(event) {
            console.log('show log');
          });
          testNotification.addEventListener('click', function(event) {
            console.log('click log');
          });
          testNotification.addEventListener('close', function(event) {
            console.log('close log');
          });
        """,
    );
  }

  ///test 'Close Notification'
  Future<void> closeWebNotification() async {
    await _webViewController?.evaluateJavascript(
      source: """
          try {
            if (testNotification != null) {
              testNotification.close();
            }
          } catch {}
        """,
    );
  }

  ///Reset Notification Permissions
  Future<void> resetWebNotificationPerimission() async {
    ZjWebNotificationPermissionDb.clear();
    await _webNotificationController?.resetPermission();
  }

  bool isValidNet() {
    return NetStateQueue().getLastNetState()?.connected == true;
  }

  List<String> imagesUrlQueue = [];
  int imageQueueDownloadTotal = 0;
  int imageQueueDownloadSuccess = 0;
  int imageQueueDownloadFailed = 0;
  bool _imageQueueDownloading = false;
  bool get isImageQueueDownloading => _imageQueueDownloading;
  void setImageDownloading(bool val, int code) {
    if (val != _imageQueueDownloading) {
      _imageQueueDownloading = val;
      if (_imageQueueDownloading) {
        //code =1 忽略
        _startDownloadImage();
      } else {
        String? msg;
        //结束下载
        if (code == 0) {
          //下载完成
          if (imageQueueDownloadTotal == imageQueueDownloadSuccess) {
            msg = '下载完成';
          } else if (imageQueueDownloadSuccess > 0) {
            msg = '下载结束，成功[$imageQueueDownloadSuccess]，失败[$imageQueueDownloadFailed]';
          } else if (imageQueueDownloadFailed > 0) {
            msg = '下载结束，失败[$imageQueueDownloadFailed]';
          } else {
            msg = '下载结束';
          }
        } else if (code == -1) {
          //网络无效，结束下载
          msg = '下载失败，成功[$imageQueueDownloadSuccess]，失败[$imageQueueDownloadFailed]';
        } else if (code == -2) {
          //取消，结束下载
          //msg = '下载取消，成功[$imageQueueDownloadSuccess]，失败[$imageQueueDownloadFailed]';
        } else {}
        if (msg != null) {
          Toast.toastAtBottom(context(), msg);
        }
      }
    }
  }

  int _startDownloadImage() {
    String? url = imagesUrlQueue.isNotEmpty ? imagesUrlQueue.removeAt(0) : null;
    if (url == null) {
      setImageDownloading(false, 0);
      return -1;
    }
    int r = 0;
    downloadWebFile(
      url,
      sugName: null,
      autoSave: true,
      prompt: false,
      finished: (flag, code) async {
        if (!flag) {
          //停止下载
          imageQueueDownloadFailed++;
          if (imageDownloadCancelled) {
            ZsLog.e('图片下载取消');
            setImageDownloading(false, -2);
            return;
          } else if ((code == -1) && !isValidNet()) {
            ZsLog.e('图片下载失败[$url],无效网络');
            setImageDownloading(false, -1);
            return;
          } else {
            ZsLog.e('图片下载失败[$url]');
          }
        } else {
          //成功
          imageQueueDownloadSuccess++;
          ZsLog.d('图片下载成功[$url]');
        }
        await Future.delayed(Duration(milliseconds: 100));
        _startDownloadImage();
      },
    );
    return r;
  }

  //WebImages? web = await _getWebImageInfo();
  Future<void> downloadWebPageAllImageUrls() async {
    List<String> list = await webPageImageUrls();
    if (list.isNotEmpty) {
      ZsLog.d('开始下载页面图片:$list');
      imagesUrlQueue.addAll(list);
      if (isImageQueueDownloading) {
        imageQueueDownloadTotal += list.length;
      } else {
        imageQueueDownloadTotal = list.length;
        imageQueueDownloadFailed = 0;
        imageQueueDownloadSuccess = 0;
      }
      setImageDownloading(true, 1);
    } else {
      ZsLog.d('当前页面无图片');
    }
  }

  //void Function(bool flag, int code)? finished,
  //flag:false下载失败 ,true 成功
  //code: -1 下载失败，-2 下载文件无效，-3 保存失败，1:正在下载，0成功
  Future<void> downloadWebFile(
    String urlStr, {
    String? refererUrl,
    String? userAgent,
    Map<String, String>? orgHeader,
    bool enableHeader = false,
    bool clearCache = false,
    bool ignoreCache = true,
    String? sugName,
    String? sugExtension,
    bool autoSave = true,
    bool prompt = true,
    bool imageOrFiler = true,
    void Function(bool flag, int code)? finished,
  }) async {
    var fileInfo = ignoreCache ? null : await ZjImageCacheManager().getFileFromCache(urlStr);
    if (fileInfo != null) {
      ZsLog.d('cache url:${fileInfo.originalUrl}; local:${fileInfo.file.path}; valid date:${fileInfo.validTill.toIso8601String()} ');
      BuildContext? ctx = context();
      if (autoSave || ctx == null) {
        saveFileInfo(
          ctx?.mounted == true ? ctx : null,
          fileInfo,
          urlStr,
          sugName: sugName,
          sugExtension: sugExtension,
          prompt: prompt,
          imageOrFiler: imageOrFiler,
          finished: finished,
        );
      } else {
        Uiutils.showSnackActionBar(ctx.mounted == true ? ctx : null, Constants.kPopMesgImageDownloaded, Constants.kAlertBtnSave, (
          BuildContext ctx,
        ) async {
          saveFileInfo(
            ctx,
            fileInfo,
            urlStr,
            sugName: sugName,
            sugExtension: sugExtension,
            prompt: prompt,
            imageOrFiler: imageOrFiler,
            finished: finished,
          );
        });
      }
    } else if (AppState().webDownloadQueue.hasItem(urlStr)) {
      ZsLog.d('web url:$urlStr; readly downloading');
      if (finished != null) {
        finished(false, 1);
      }
    } else {
      if (clearCache) {
        await ZjImageCacheManager().removeFile(urlStr);
      }

      Map<String, String>? header = enableHeader ? makeRequestHeader(refererUrl, userAgent, orgHeader, stype: imageOrFiler ? 0 : 1) : null;
      Stream<FileResponse> imageSteam = ZjImageCacheManager().getImageFile(urlStr, withProgress: true, headers: header);

      AppState().webDownloadQueue.addItem(urlStr, imageSteam);

      imageSteam.listen(
        (FileResponse value) {},
        onDone: () async {
          BuildContext? contx = context();
          var vfileInfo = await ZjImageCacheManager().getFileFromCache(urlStr);
          AppState().webDownloadQueue.remove(urlStr);

          if (vfileInfo == null || vfileInfo.file.existsSync() == false || vfileInfo.statusCode != 200) {
            var sc = vfileInfo?.statusCode;
            if (prompt) {
              Uiutils.showSnackBar(context(), imageOrFiler ? Constants.kPopMesgImageDownloadFailed : Constants.kPopMesgFileDownloadFailed);
            }
            if (finished != null) {
              //下载失败
              finished(false, -1);
            }
            ZsLog.e('downloadWebFile 下载文件失败[statusCode=$sc]');
            return;
          }
          if (imageOrFiler) {
            var sc = vfileInfo.statusCode;
            bool img = await Utils.isImageFile(
              vfileInfo.file,
              callFun: (mmt, ex, isImage) {
                sugExtension ??= ex;
              },
            );
            if (!img) {
              String msg = '下载失败';
              if (prompt && autoSave == false) {
                String errContent = vfileInfo.file.readAsStringSync();
                if (errContent.contains('该附件无法读取')) {
                  msg = '抱歉，该附件无法读取';
                }
                Uiutils.showSnackBar(contx?.mounted == true ? contx : null, msg);
              }
              await ZjImageCacheManager().removeFile(urlStr);
              if (finished != null) {
                finished(false, -2);
              }
              ZsLog.e('downloadWebFile 下载文件失败[statusCode=$sc],文件非图片,无效文件[$msg]');
              return;
            }
          }

          if (autoSave || contx == null) {
            saveFileInfo(
              contx?.mounted == true ? contx : null,
              vfileInfo,
              urlStr,
              sugName: sugName,
              sugExtension: sugExtension,
              prompt: prompt,
              imageOrFiler: imageOrFiler,
              finished: finished,
            );
          } else {
            Uiutils.showSnackActionBar(
              contx.mounted == true ? contx : null,
              imageOrFiler ? Constants.kPopMesgImageDownloadComplate : Constants.kPopMesgFileDownloadComplate,
              Constants.kAlertBtnSave,
              (BuildContext ctx) {
                saveFileInfo(
                  ctx,
                  vfileInfo,
                  urlStr,
                  sugName: sugName,
                  sugExtension: sugExtension,
                  prompt: prompt,
                  imageOrFiler: imageOrFiler,
                  finished: finished,
                );
              },
            );
          }
        },
        onError: (e) {
          //AppState().webDownloadQueue.remove(urlStr);
          ZsLog.d('download image url:$urlStr,error:$e');
          // if (prompt) {
          //   Uiutils.showSnackBar(context(), imageOrFiler ? Constants.kPopMesgImageDownloadFailed : Constants.kPopMesgFileDownloadFailed);
          // }
          // if (finished != null) {
          //   //下载失败
          //   finished(false, -1);
          // }
        },
        cancelOnError: !_imageDownloadFlag,
      );
    }
  }

  void saveFileInfo(
    BuildContext? ctx,
    FileInfo? fileInfo,
    String urlStr, {
    String? sugName,
    String? sugExtension,
    bool prompt = true,
    bool imageOrFiler = true,
    void Function(bool flag, int code)? finished,
  }) {
    if (fileInfo == null || fileInfo.file.existsSync() != true) {
      if (prompt) {
        Toast.toastAtBottom(ctx, Constants.kPopMesgSaveFailed);
      }
      if (finished != null) {
        //文件无效
        finished(false, -2);
      }
    } else {
      String? filename = sugName ?? Utils.ableFileName(urlStr);
      filename ??= Utils.ableFileName(fileInfo.file.path);
      if (imageOrFiler) {
        ImageSaverHelper.saveLocalImage(
          fileInfo.file.path,
          filename,
          sugExtension: sugExtension,
          callback: (result, other, success) {
            if (result != null && prompt) {
              Toast.toastAtBottom(ctx, result);
            }
            if (finished != null) {
              //0 成功，-3 保存失败
              finished(success, success ? 0 : -3);
            }
          },
        );
      } else {
        FileSaveHelper.saveFileDataToSystem(
          fileInfo.file,
          outFileName: sugName,
          sugExtension: sugExtension,
          callback: (result, other, success) {
            if (result != null && prompt) {
              Toast.toastAtBottom(ctx, result);
            }
            if (finished != null) {
              //0 成功，-3 保存失败
              finished(success, success ? 0 : -3);
            }
          },
        );
      }
    }
  }

  Future<bool> downloadHttpFile(
    String url, {
    Map<String, String>? orgHeader,
    String? userAgent,
    String? referUrl,
    String? sugFileName,
    String? sugExtension,
    bool? isImageFile = false,
    bool cover = false,
    bool prompt = false,
    ResultCallback? callback,
  }) async {
    String? sg = sugFileName ?? _getWebSiteSyn()?.imageAttachmentSuggestedFileName(url, decoded: true, onlyMode: true);
    if (sg != null && (sugFileName != sg)) {
      //ndu2mtg0mnxkmtdlzta2n3wxnzc4mju0mdk0fdy5ntq5oxwymdqzndyx
      isImageFile = true;
      sugExtension ??= 'jpg';
    }
    return await DownloadFile.downloadHttpFile(
      url,
      header: makeRequestHeader(referUrl, userAgent, orgHeader, stype: isImageFile == null ? -1 : (isImageFile ? 0 : 1)),
      sugFileName: sg,
      sugExtension: sugExtension,
      cover: cover,
      callback: (result, other, success) {
        BuildContext? contx = context();
        if (result != null && prompt) {
          if (success) {
            if (Utils.isIOS()) {
              result = '$result,${Constants.kDownloadSaveFolderGuideIOS}';
            }
          }
          Toast.toastAtBottom(contx, result);
        }
        if (callback != null) {
          //0 成功，-3 保存失败
          callback.call(result, other, success);
        }
      },
    );
  }

  Future<bool> downloadLargeHttpFile(
    String url, {
    Map<String, String>? orgHeader,
    String? userAgent,
    String? referUrl,
    String? sugFileName,
    String? sugExtension,
    bool? isImageFile = false,
    bool cover = false,
    bool prompt = false,
    ResultCallback? callback,
  }) async {
    String? sg = sugFileName ?? _getWebSiteSyn()?.imageAttachmentSuggestedFileName(url, decoded: true, onlyMode: true);
    if (sg != null && (sugFileName != sg)) {
      //ndu2mtg0mnxkmtdlzta2n3wxnzc4mju0mdk0fdy5ntq5oxwymdqzndyx
      isImageFile = true;
      sugExtension ??= 'jpg';
    }
    return await DownloadFile.downloadLargeFile(
      url,
      header: makeRequestHeader(referUrl, userAgent, orgHeader, stype: isImageFile == null ? -1 : (isImageFile ? 0 : 1)),
      sugFileName: sg,
      sugExtension: sugExtension,
      cover: cover,
      callback: (result, other, success) {
        BuildContext? contx = context();
        if (result != null && prompt) {
          if (success) {
            if (Utils.isIOS()) {
              result = '$result,${Constants.kDownloadSaveFolderGuideIOS}';
            }
          }
          Toast.toastAtBottom(contx, result);
        }
        if (callback != null) {
          //0 成功，-3 保存失败
          callback.call(result, other, success);
        }
      },
    );
  }

  Future<int> addBlacklist(String name, {bool prompt = true}) async {
    String? msg;
    int r = await BlackList.apiAddBlacklist(name);
    if (r == 0) {
      //存在
      if (prompt) {
        msg = Constants.kPopMesgReadyExist;
      }
    } else if (r == 2) {
      //插入成功
      if (prompt) {
        msg = Constants.kPopMesgAddsuccess;
      }
    } else {}
    if (prompt && msg != null) {
      Toast.toastAtBottom(context(), msg);
    }
    return r;
  }

  /// gif图片
  void webImageGallerySaver(BuildContext ctx, String urlStr) async {
    BuildContext tempCtx = ctx;
    if (urlStr.isNotEmpty) {
      var fileInfo = await ZjImageCacheManager().getFileFromCache(urlStr);
      if (tempCtx.mounted && (fileInfo != null)) {
        ///TODO:图片可能是无效的
        ZsLog.d(
          'gallery cache url:${fileInfo.originalUrl}; local:${fileInfo.file.path}; valid date:${fileInfo.validTill.toIso8601String()} ',
        );
        saveFileInfo(tempCtx, fileInfo, urlStr);
      }
    }
  }

  Future<WebImages> getWebPageImages(String? imgUrl) async {
    WebImages r = WebImages(url: '', images: []);
    if (_webViewController != null) {
      String source = '''
        webinterfaceWebImagesInfo();
        ''';
      var result = await _webViewController?.evaluateJavascript(source: source);
      if (result != null) {
        // ZsLog.d('image info:$result');
        var dict = jsonDecode(result); // as Map<String, List<String>>;
        List<dynamic> imgMap = dict['images'];
        List<String> imgs = [];

        //List<String> stringList = imgMap.cast<String>();
        //List<String> stringList = imgMap.map((e) => e.toString()).toList();
        //List<String> stringList = imgMap.whereType<String>().map((e) => e).toList();
        //List<String> stringList = imgMap.where((element) => element is String).map((e) => e.toString()).toList();

        for (var item in imgMap) {
          if (item is String) {
            imgs.add(item);
          }
        }
        r = WebImages(url: dict['url'], images: imgs);
      }
    }
    if (imgUrl != null && !r.images.contains(imgUrl)) {
      r.images.insert(0, imgUrl);
    }
    webImages = r;
    return r;
  }

  Future<int> jsWebPageImageCount(String? url) async {
    var r = 0;
    var result = await _webViewController?.evaluateJavascript(source: 'webinterfaceWebImageCount();');
    if (result != null && result is String) {
      int count = int.parse(result);
      if (count >= 0) {
        r = count;
      }
    }
    //js 实现
    // else if (result == null && url != null) {
    //   //判断是否为图片
    //   if (Utils.isImageExtensionUrl(url)) {
    //     r = 1;
    //   }
    // }
    return r;
  }

  //关掉chihell 移动站 图片缩放模式
  Future<void> jsWebViewImageGalleryExit() async {
    webImages = WebImages(url: '', images: []);
    //chiphell 缩放图片组件：zoomerang https://github.com/yyx990803/zoomerang
    if (_webViewController == null) {
      return;
    }

    WebUri? uri = await _webViewController?.getUrl();
    if (uri == null || _getWebSiteSyn()?.isSite(uri.toString()) != true) {
      return;
    }
    bool isMobile = _getWebIsMobileUASyn();
    if (isMobile) {
      //WebUri https://www.chiphell.com/forum.php?mod=viewthread&tid=2730213&aid=11427875&from=album&page=1&mobile=3
      if (uri.query.contains("mobile=3")) {
        if (await _webViewController!.canGoBack()) {
          await _webViewController?.goBack();
        }
      } else if (uri.query.contains("mobile=2")) {
        //mobile=2
        String source = '''
          try { window.Zoomerang.close();}catch(e){}
        ''';
        _webViewController?.evaluateJavascript(source: source);
      }
    } else {
      _webViewController?.evaluateJavascript(source: "try { hideMenu();}catch(e){}");
    }
  }

  //查看webview是否支持通知
  Future<bool> jsWebViewSupportNotification() async {
    bool ret = false;
    if (_webViewController != null) {
      String source = '''
           try { ("Notification" in window) }catch(e){}
        ''';
      var r = _webViewController?.evaluateJavascript(source: source);
      if (r != null && r is bool) {
        ret = r as bool;
      }
    }
    return ret;
  }

  ///NavigationResponse{canShowMIMEType: true,
  ///isForMainFrame: true,
  ///response: URLResponse{expectedContentLength: -1,
  ///headers: {Server: lighttpd/2.0.0, Content-Encoding: gzip, Content-Security-Policy: upgrade-insecure-requests, Age: 0, eo-cache-status: MISS, Content-Type: text/html; charset=utf-8, Cache-Control: no-cache, eo-log-uuid: 13224521377019350946, Vary: Accept-Encoding, Date: Fri, 08 May 2026 06:53:23 GMT},
  ///mimeType: text/html, statusCode: 200,
  ///suggestedFilename: www.chiphell.com.html,
  /// textEncodingName: utf-8, url: https://www.chiphell.com/}}
  bool webViewOnNavigationResponse(NavigationResponse navigationResponse, WebSite? site, void Function(String url)? redirectFn) {
    bool r = true;
    ZsLog.d('-----------------navigationResponse :${navigationResponse.toString()}--------------');
    bool ism = navigationResponse.isForMainFrame;
    bool canshow = navigationResponse.canShowMIMEType;
    URLResponse? res = navigationResponse.response;
    WebUri? uri = navigationResponse.response?.url;
    if (uri == null || res == null) {
      return r;
    } else if (!ism) {
      if (canshow) {
        return r;
      }
    }

    String url = uri.toString();
    if (uri.toString().contains('www.baidu.com') && (res.statusCode != null) && (res.statusCode! >= 300) && (res.statusCode! <= 400)) {
      var rdurl = res.headers?['Location'];
      if (rdurl != null && (rdurl.startsWith("http://", 0))) {
        rdurl = 'https://${rdurl.substring(7)}';
        if (redirectFn != null) {
          redirectFn.call(rdurl);
        }
        r = false;
        return r;
      }
    }

    if (!canshow) {
      // suggestedFilename: BCM94352HMB.zip, 鸿蒙壁纸1.jpg
      // https://bbs.pcbeta.com/forum.php?mod=attachment&aid=NDEwNzAxNHxkMGFjMzViYXwxNzc4MTM0MDYwfDY5NTQ5OXwxODEyNTM1&ck=51c4ad42
      final cd = 'Content-Disposition';
      final aos = 'application/octet-stream';
      final cdValue = 'attachment;';
      final mimeType = res.mimeType;
      String? suggestedFilename = res.suggestedFilename;
      String? sugExtension;
      int contentLength = res.expectedContentLength;
      if (suggestedFilename != null) {
        sugExtension = Utils.pathExtension(suggestedFilename);
        if (sugExtension != null && sugExtension.isEmpty) {
          sugExtension = null;
        }
      }
      sugExtension ??= mimeType != null ? Utils.fileExtensionFromMimeType(mimeType) : null;
      if (sugExtension != null && sugExtension.isEmpty) {
        sugExtension = null;
      }
      bool isSiteAttachement = site?.isAttachment(url) == true;
      bool isStream = mimeType == aos;
      bool isImage = Utils.isImageMimeType(mimeType);
      bool isAttachement = false;
      if (res.headers != null && !isAttachement) {
        //Content-Disposition: attachment; filename="%E5%8D%8E%E4%B8%BA%E9%B8%BF%E8%92%99%E7%94%B5%E8%84%91%E5%86%85%E7%BD%AE%E5%A3%81%E7%BA%B8.zip"; filename*=utf-8''%E5%8D%8E%E4%B8%BA%E9%B8%BF%E8%92%99%E7%94%B5%E8%84%91%E5%86%85%E7%BD%AE%E5%A3%81%E7%BA%B8.zip
        if (res.headers?.containsKey(cd) == true) {
          String? attDes = res.headers?[cd]; //attachment; filename="site.json.zip"
          if (attDes != null && attDes.contains(cdValue)) {
            //https://bbs.pcbeta.com/forum.php?mod=attachment&aid=NDU1OTc4NHxmYmI2OTBlYnwxNzc4MTM4NTM3fDY5NTQ5OXwyMDQyNTM0&ck=3b0d0c5d
            //suggestedFilename: 华为鸿蒙电脑内置壁纸.zip,
            isAttachement = true;
          }
        }
      }

      if (isImage) {
        downloadWebFile(url, sugName: suggestedFilename, sugExtension: sugExtension);
      } else if ((isSiteAttachement && isAttachement) && isStream) {
        downloadWebFile(url, sugName: suggestedFilename, sugExtension: sugExtension, imageOrFiler: false);
      } else {
        if (contentLength <= Utils.sizeMB(5)) {
          //downloadHttpFile
          downloadHttpFile(url, sugFileName: suggestedFilename, sugExtension: sugExtension, prompt: true);
        } else {
          //downloadLargeHttpFile
          downloadLargeHttpFile(url, sugFileName: suggestedFilename, sugExtension: sugExtension, prompt: true);
        }
      }
      r = false;
    }
    return r;
  }

  //内部浏览器打开
  Future<void> innerBrowserOpen(BuildContext? context, String url, {bool newWindow = false, int? windowid}) async {
    if (Utils.isDesktopSystem) {
      if ((((newWindow) && (windowid == null)) || ((newWindow == false) && (windowid != null))) && await WindowUtil.shouldTopWindowOpen()) {
        await WindowUtil.topBrowserOpen(url);
      } else {
        await WindowUtil.pushBrowser(url, windowid: windowid);
      }
    } else if (context?.mounted == true) {
      context?.pushNamed('browser', queryParameters: {'url': url, 'windowid': '${windowid ?? ''}'});
    }
  }

  ///其他浏览器打开指定url
  Future<void> systemBrowserOpenUrl(String? url) async {
    if (url != null) {
      await InAppBrowser.openWithSystemBrowser(url: WebUri(url));
    }
  }

  ///{"fid":"319","url":"https://www.chiphell.com/forum.php?gid=186","src":"https://www.chiphell.com/forum-319-1.html","page":"1","gid":"","tid":"","name":"https://www.chiphell.com/forum.php?gid=186"}
  Future<String?> _getSitePreviousForumUrl() async {
    String? forumUrl;
    var result = await _webViewController?.evaluateJavascript(source: "webinterfaceWebForumInfo()");
    if (result != null) {
      var dict = jsonDecode(result);
      try {
        //String fid = dict['fid'];
        String src = dict['src'];
        String furl = dict['url'];
        if (src.isNotEmpty && furl.isNotEmpty) {
          forumUrl = furl;
        }
      } catch (e) {
        ZsLog.d('error');
      } finally {
        ZsLog.d("操作完成");
      }
    }
    return forumUrl;
  }

  //获得比自己大的block
  Future<bool> _gotoNextBlockFromWebHistory(
    bool checkAllItem,
    WebSite vsite,
    String currentUrl,
    int event, {
    String? nextUrl,
    List<WebHistoryItem>? historyList,
    int? index,
  }) async {
    bool r = false;
    List<WebHistoryItem>? list = historyList;
    var currentIdx = index;
    if (list == null) {
      WebHistory? history = await _webViewController?.getCopyBackForwardList();
      if (history != null) {
        list = history.list;
        currentIdx = history.currentIndex ?? 0;
      }
    }
    currentIdx ??= 0;
    if (list != null && list.length > 1) {
      //优先向小于currentIdx的方向 循环
      int? goIndx = Utils.backOrForwardTraverse(checkAllItem ? 0 : 1, currentIdx, list.length, (i) {
        var mach = false;
        var item = list![i];
        var itemurl = item.url?.toString();
        if (itemurl != null && itemurl.isNotEmpty && itemurl != currentUrl) {
          if (nextUrl == itemurl) {
            // Utils.autoDecodeUrl(url, decoded: decoded);
            mach = true;
          } else if (event == 1 && vsite.isForumUrl(itemurl, onlyMode: true)) {
            //找 forum 链接
            mach = true;
          } else if (event == 2 && vsite.isAreaUrl(itemurl, onlyMode: true)) {
            //找 area 链接
            mach = true;
          } else if (event == 3 && vsite.isHomeUrl(itemurl, onlyMode: true)) {
            //找 home 链接
            mach = true;
          } else if (event == 5) {
            // https://www.chiphell.com/thread-2806235-1-1.html =>  https://www.chiphell.com/
            // https://www.chiphell.com/a/b/thread-2806235-1-1.html =>  https://www.chiphell.com/a/b/
          }
        }
        return mach ? i : null;
      });
      if (goIndx != null) {
        int j = goIndx - currentIdx;
        if (await _webViewController?.canGoBackOrForward(steps: j) != null) {
          _webViewController?.goBackOrForward(steps: j);
          r = true;
        }
      }
    }
    return r;
  }

  /// 当前是帖子，login，等跳到 ->forum，-》area-〉home
  Future<bool> gotoCurrentForum(bool force) async {
    bool ret = false;
    String? nextUrl;
    WebSite? vsite = _getWebSiteSyn();
    String? currentUrl = await getWebCurrentUrl();
    int event = 0;
    if (vsite != null && (vsite.isSite(currentUrl) == true)) {
      if (vsite.isReplyUrl(currentUrl, onlyMode: true)) {
        //回帖
        event = 6;
      } else if (vsite.isPostNewthreadUrl(currentUrl, onlyMode: true)) {
        //发帖
        event = 7;
      } else if (vsite.isLoginUrl(currentUrl, onlyMode: true)) {
        //发帖
        event = 8;
      } else if (vsite.isAuthorUrl(currentUrl, onlyMode: true) ||
          vsite.isAuthorAbout(currentUrl, onlyMode: true) ||
          vsite.isAuthorImageUrl(currentUrl, onlyMode: true)) {
        //发帖
        event = 9;
      } else if (vsite.isContentImageUrl(currentUrl, onlyMode: true)) {
        //发帖
        event = 10;
      } else if (vsite.isSearchUrl(currentUrl, onlyMode: true)) {
        //发帖
        event = 11;
      } else if (vsite.isHomeUrl(currentUrl, onlyMode: true)) {
        //不找链接
        event = -1;
      } else if (vsite.isAreaUrl(currentUrl, onlyMode: true)) {
        //找 home 链接
        event = 3;
      } else if (vsite.isForumUrl(currentUrl, onlyMode: true)) {
        //找 area  链接
        event = 2;
      } else if (vsite.isThreadUrl(currentUrl, onlyMode: true) || vsite.isArticleUrl(currentUrl, onlyMode: true)) {
        event = 1;
      } else if (vsite.isDiscuz()) {
        event = 20; //https://www.chiphell.com/forum.php?mobile=2
      } else {
        event = 4;
      }
      if (event >= 6 && event <= 20) {
        ret = await goBack();
      }
      if (!ret) {
        nextUrl = await _getSitePreviousForumUrl();
        if ((currentUrl != null && currentUrl.isNotEmpty) && (event >= 1 && event < 5)) {
          WebHistory? history = await _webViewController?.getCopyBackForwardList();
          if (history != null) {
            var hlist = history.list;
            if (hlist != null && hlist.length > 1) {
              var i = history.currentIndex ?? 0;
              ret = await _gotoNextBlockFromWebHistory(true, vsite, currentUrl, event, nextUrl: nextUrl, historyList: hlist, index: i);
              if (!ret && event == 4 && nextUrl == null) {
                // https://www.chiphell.com/thread-2806235-1-1.html =>  https://www.chiphell.com/
                // https://www.chiphell.com/a/b/thread-2806235-1-1.html =>  https://www.chiphell.com/a/b/
                Uri u = Uri.parse(currentUrl);
                String origin = u.origin;
                List<String> paths = List.from(u.pathSegments);
                while (paths.length > 1) {
                  paths.removeLast();
                  String tempUrl = '$origin/${paths.join('/')}';
                  ret = await _gotoNextBlockFromWebHistory(force, vsite, currentUrl, 5, nextUrl: tempUrl, historyList: hlist, index: i);
                  if (ret) {
                    break;
                  }
                }
              }
            }
          }
        }
      }
    }
    if (!ret) {
      if (force) {
        if ((nextUrl == null) && vsite != null) {
          //当前是forum，-》area-〉home
          if (event == 2) {
            nextUrl = vsite.areaUrl(_getWebIsMobileUASyn());
          } else if (event == 3) {
            //有些站点area==home
            nextUrl = vsite.homeUrl(_getWebIsMobileUASyn());
          }
        }
      }
      if (nextUrl != null && (nextUrl != currentUrl)) {
        webViewOpenUrl(nextUrl);
        ret = true;
      }
    }
    if (force && !ret && (event == 1)) {
      ret = await goBack();
    }
    return ret;
  }
}
