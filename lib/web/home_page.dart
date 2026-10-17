import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:chiphell/common/constants.dart';
import 'package:chiphell/data/black_list.dart';
import 'package:chiphell/long_press_alert_dialog.dart';
import 'package:chiphell/modals/Adblock.dart';
import 'package:chiphell/modals/AppState.dart';
import 'package:chiphell/data/Favorites.dart';
import 'package:chiphell/modals/web_user.dart';
import 'package:chiphell/modals/WebTextSize.dart';
import 'package:chiphell/modals/zj_Image_cacheManager.dart';
import 'package:chiphell/sites/util_site.dart';
import 'package:chiphell/theme/theme_provider.dart';
import 'package:chiphell/utils/ui_utils.dart';
import 'package:chiphell/utils/utils.dart';
import 'package:chiphell/multi_windows/window_util.dart';
import 'package:chiphell/web/web_more_pop_menu.dart';
import 'package:chiphell/web/web_navigation_bottom_bar.dart';
import 'package:chiphell/web/web_view_find_bar.dart';
import 'package:chiphell/web/web_view_helper.dart';
import 'package:chiphell/web/web_view_http_auth_dialog.dart';
import 'package:chiphell/web/web_view_more_options.dart';
import 'package:chiphell/web/web_constants.dart';
//import 'package:easy_notifications/easy_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:swipe_image_gallery/swipe_image_gallery.dart';

import '../common/type_utils.dart';
import '../modals/WebImages.dart';
import '../modals/web_mode.dart';
import '../overlay_web_image_gallery.dart';

import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../sites/main_site.dart';
import '../sites/site_constants.dart';
import '../net/net_state.dart';
import '../../utils/zs_log.dart';
import '../sites/web_site.dart';
import '../utils/Toast.dart';
import '../utils/util_map.dart';

class HomePage extends StatefulWidget {
  final WebMode webMode;
  const HomePage({required GlobalKey key, required this.webMode}) : super(key: key);

  @override
  State<HomePage> createState() => HomePageState();

  bool supportMultipleWindows() {
    return webMode.multipleWindows;
  }

  HomePageState? getState() {
    return (key as GlobalKey).currentState as HomePageState?;
  }

  void onStateUpdated() {
    webMode.onStateUpdated();
  }

  Uint8List? get screenshot {
    final state = getState();
    return state?.webViewHelper?.screenshot;
  }

  bool? get isSecure {
    final state = getState();
    return state?._isSecure;
  }

  String? get title {
    final state = getState();
    return state?._webPageTitle;
  }

  Favicon? get favicon {
    final state = getState();
    return state?._favicon;
  }

  String? get currentUrl {
    final state = getState();
    return state?._stopUrl ?? state?._startUrl;
  }

  Future<void> updateScreenshot() async {
    final state = getState();
    await state?.webViewHelper?.updateScreenshot();
  }

  Future<void> pause() async {
    final state = getState();
    await state?.pause();
  }

  Future<void> resume() async {
    final state = getState();
    await state?.resume();
  }

  Future<bool> canGoBack() async {
    final state = getState();
    return await state?.canGoBack() ?? false;
  }

  Future<void> goBack() async {
    final state = getState();
    await state?.goBack();
  }

  Future<bool> canGoForward() async {
    final state = getState();
    return await state?.canGoForward() ?? false;
  }

  Future<void> goForward() async {
    final state = getState();
    await state?.goForward();
  }

  Future<bool> isLoading() async {
    final state = getState();
    return await state?.isLoading() ?? false;
  }

  Future<void> stopLoading() async {
    final state = getState();
    await state?.stopLoading();
  }

  Future<void> reload() async {
    final state = getState();
    await state?._reloadWeb();
  }

  Future<void> windowClose(bool userClose) async {
    return await getState()?.windowClose(userClose);
  }

  Future<void> windowFocus() async {
    return await getState()?.windowFocus();
  }

  Future<void> windowBlur() async {
    return await getState()?.windowBlur();
  }

  Future<void> windowMinimize() async {
    return await getState()?.windowMinimize();
  }

  Future<void> windowMenuEvent(int event) async {
    return await getState()?.windowMenuEvent(event);
  }
}

class HomePageState extends State<HomePage> with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  final GlobalKey webViewKey = GlobalKey();
  //final GlobalKey moreBtnKey = GlobalKey();
  InAppWebViewController? _webViewController;
  WebViewHelper? webViewHelper;
  // final TextEditingController _httpAuthUsernameController =
  //     TextEditingController();
  // final TextEditingController _httpAuthPasswordController =
  //     TextEditingController();
  final keepAlive = InAppWebViewKeepAlive();

  //切换页面，如何保持当前页的状态 with AutomaticKeepAliveClientMixin
  @override
  bool get wantKeepAlive => !_isWindowClosed;

  InAppWebViewSettings settings = InAppWebViewSettings(
    useShouldOverrideUrlLoading: true,
    //useShouldInterceptAjaxRequest: true, //打开这个，可能会中断内容加载，附件上传等
    // useShouldInterceptFetchRequest: true,
    //useShouldInterceptRequest: true,
    //useOnLoadResource: true,  //探测页面内容加载。比如图片等，暂时没有使用
    javaScriptEnabled: true,
    isInspectable: kDebugMode,
    mediaPlaybackRequiresUserGesture: true, //false 播放媒体不需要用户交互,自动播放。否则应该设置true
    allowsInlineMediaPlayback: true, // 允许内联媒体播放
    iframeAllow: "camera; microphone", //只有web支持
    iframeAllowFullscreen: true,
    supportMultipleWindows: false,
    javaScriptCanOpenWindowsAutomatically: false,
    allowsLinkPreview: false,
    supportZoom: true,
    //  builtInZoomControls:true,
    //displayZoomControls:false,
    //macos11 效果好. ios14 效果不好，ipad效果不好
    pageZoom: 1.0,

    //android, iphone 适配 document.body.style.textSizeAdjust
    textZoom: 100,

    //allowingReadAccessTo: WebUri('file://$webArchiveDir/'),

    //ios/ macos 页面背景颜色下 网页视图在活动页面后面显示的颜色，当用户滚动到页面边界之外时可见。
    // underPageBackgroundColor: Colors.red,

    ///除linux外都支持 设置为true可使WebView的背景透明。如果你的应用程序有深色主题，这可以防止初始化时出现白色闪光。默认值为false。
    /// ios 上设置为true，在手势后一页的时候上面页面可以透视下面，视觉效果不佳
    //transparentBackground: true,
    useOnDownloadStart: true,
    useHybridComposition: true, // 默认true 使自定义渲染器在Android 11上可用 // 推荐开启，提升兼容性
    //algorithmicDarkeningAllowed: true,
    //forceDark: ForceDark.AUTO,
    //forceDarkStrategy: ForceDarkStrategy.WEB_THEME_DARKENING_ONLY,
    //.WEB_THEME_DARKENING_ONLY, //USER_AGENT_DARKENING_ONLY, //PREFER_WEB_THEME_OVER_USER_AGENT_DARKENING,
    //javaScriptBridgeEnabled:true,
    //scrollMultiplier:1,
    //algorithmicDarkeningAllowed:true,//android 支持自动设置网页暗模式时候有效
    passwordAutosaveEnabled: true,

    //blockNetworkImage:true,
    loadsImagesAutomatically: false,
    mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
    safeBrowsingEnabled: false,
    pinchZoomEnabled: true, //windows 触摸屏 放大缩小
    // windows有效    When this setting is set to false, it disables all accelerator keys that access features specific to a web browser, including but not limited to:
    // Ctrl-F and F3 for Find on Page
    // Ctrl-P for Print
    // Ctrl-R and F5 for Reload
    // Ctrl-Plus and Ctrl-Minus for zooming
    // Ctrl-Shift-C and F12 for DevTools Special keys for browser functions, such as Back, Forward, and Search It does not disable accelerator keys related to movement and text editing, such as:
    // Home, End, Page Up, and Page Down
    // Ctrl-X, Ctrl-C, Ctrl-V
    // Ctrl-A for Select All
    // Ctrl-Z for Undo.
    //Ctrl++/Ctrl-- 放大缩小页面，触发函数 onZoomScaleChanged
    browserAcceleratorKeysEnabled: true, //
    //windows有效，设置true自己处理加速器按键和组合按键,如果不实现browserAcceleratorKeysEnabled对应功能失效
    handleAcceleratorKeyPressed: false,
    // incognito:true, //隐私模式

    // allowsBackForwardNavigationGestures:true,
    // upgradeKnownHostsToHTTPS:true,
    // isSiteSpecificQuirksModeEnabled:true,
    //preferredContentMode:true, //

    //ios/macos 表示在打印内容时是否包含任何背景颜色或图形。
    shouldPrintBackgrounds: true,

    //页内查找
    isFindInteractionEnabled: !Utils.isWindows(),
    //webview 页面后的颜色 上拉下啦后面的颜色
    // underPageBackgroundColor: Colors.red,
    //夜晚模式的时候ios 第一次会白色
    transparentBackground: Utils.isApple(),
    //underPageBackgroundColor: Colors.red,

    //backgroundColor: Utils.isIOS() ? Colors.transparent : null,

    //itpEnabled: true,
    //resourceCustomSchemes: ['zorro_add_filter'],

    /// 一个布尔值，指示是否应显示涉嫌欺诈内容（如网络钓鱼或恶意软件）的警告。根据官方文件，该功能目前在以下地区可用：中国。默认值为true。
    isFraudulentWebsiteWarningEnabled: true,
    //disableLongPressContextMenuOnLinks:true
  );

  PullToRefreshController? pullToRefreshController;

  late ContextMenu contextMenu;
  String _startUrl = '';
  String _stopUrl = '';
  int redirectCount = 0;
  double progress = 0;
  WebThemeSyncState _webThemeReady = WebThemeSyncState.none;
  bool _loadPreUpdateThemeModelToJs = false;
  bool _isWindowClosed = false;
  final FocusNode _focusNode = FocusNode();
  bool _isSecure = false;
  String? _webPageTitle;
  bool _isPopMenu = false;
  DateTime? prePopDateTime;
  //上一次用户右键点击新窗口
  int userClickNewWindowTime = 0;

  int _webPageImageCount = 0;
  bool get hasWebPageImage => _webPageImageCount > 0;

  int _webPageImageLookIndex = 0;
  ImageGalleryController galleryController = ImageGalleryController(initialPage: 3);
  StreamController<Widget>? _overlayController;

  bool get _isTopOfNavigationStack => ModalRoute.of(context)?.isCurrent ?? false;

  bool _updateUserScript = false;
  WebResourceError? _lastWebError;

  Favicon? _favicon;

  //图片加载模式
  int _webImgMode = -1;
  bool _webAutoImageGallery = false;
  int _webBlacklistMode = 0;

  AppState? _appStateNoListen;
  ThemeProvider? _themeProviderNoListen;
  NetStateQueue? _netStateQueueNoListen;
  WebTextSize? _webTextSizeNoListen;

  //webview自动加载图片模式是否可用（只支持android和linux设备）
  final bool _enableLoadsImagesAutomatically = Utils.isAndroid() || Utils.isLinux();
  int loadCount = 0;

  late WebSite _site;
  WebSite get site => _site;
  set site(WebSite? val) {
    if (val != null && (val.host.isNotEmpty)) {
      if (_site.host != val.host) {
        _site = val;
        WebUri? r = _getStopStartWebUri();
        if (r != null) {
          if (!_site.isSite(r.toString())) {
            //site 改变了，需要reset
            if (Utils.isAndroid()) {
              _webViewController?.clearHistory();
            }
            webViewOpenUrl(_site.firstUrl(isMobileUA()));
          }
        }
      }
    } else {
      ZsLog.i('update site[$val] failed!');
    }
  }

  void _checkSiteMode(String? url) {
    String? r = site.cssExtensionName;
    String? c = UtilSite.cssFileNameFromUrl(url);
    if (r != null && r.length > 1) {
      ThemeProvider().asynLoadHostExtension(r, isMobileUA());
    }
    if (c != null && c.length > 1 && (r != c)) {
      ThemeProvider().asynLoadHostExtension(c, isMobileUA());
    }
  }

  set startUrl(String? url) {
    String nu = url ?? '';
    _loadPreUpdateThemeModelToJs = false;
    _webThemeReady = WebThemeSyncState.start;
    if (nu != _startUrl) {
      loadCount++;
      String? oldUrl = _startUrl;
      _startUrl = nu;
      webPageImageCount = 0;
      _webPageImageLookIndex = 0;
      redirectCount = 0;
      _lastWebError = null;
      _favicon = null;
      widget.onStateUpdated.call();
      ZsLog.d('set start load url:$_startUrl, before url:$oldUrl');
      _checkSiteMode(_startUrl);
    } else {
      redirectCount++;
      ZsLog.d('redirect start load url:$_startUrl');
    }
    //url变化时候关闭查找ui
    webViewHelper?.isFindInteractionEnabled = false;
  }

  Future<void> urlMaxLoadCheck() async {
    if ((redirectCount >= WebConstants.kUrlRedirectMax) && (_webViewController != null)) {
      await stopLoading();
    }
  }

  set stopUrl(String? url) {
    ZsLog.d('stop load url:$url, before url $_stopUrl');
    String tmp = url ?? '';
    _loadPreUpdateThemeModelToJs = false;
    if (_stopUrl != tmp) {
      _stopUrl = tmp;
      webPageImageCount = 0;
      _webPageImageLookIndex = 0;
      //_checkSiteMode(_stopUrl);
      saveLastUrl(_stopUrl);
    }
  }

  // Future<String?> _getAbleRefererWebUrl() async {
  //   String? r;
  //   if (await webViewHelper?.webViewHasHistory() == true) {
  //     if (Utils.isValidHttpUrl(_stopUrl)) {
  //       r = _stopUrl;
  //     }
  //   } else if (!await isLoading()) {
  //     r = (await _webViewController?.getUrl()).toString();
  //   }
  //   return r;
  // }

  WebUri? _getStopStartWebUri() {
    WebUri? r;
    if (Utils.isValidHttpUrl(_stopUrl)) {
      r = WebUri(_stopUrl);
    } else if (Utils.isValidHttpUrl(_startUrl)) {
      r = WebUri(_startUrl);
    }
    return r;
  }

  Future<WebUri?> getValidWebUri() async {
    WebUri? r = _getStopStartWebUri();
    if (r == null) {
      WebUri? wr = await _webViewController?.getUrl();
      if (wr?.isValidUri == false) {
        wr = null;
      }
      if ((wr == null) && Utils.isWindows()) {
        wr = await _webViewController?.getOriginalUrl();
        if (wr?.isValidUri == false) {
          wr = null;
        }
      }
    }
    return r;
  }

  Future<String?> getValidWebUrlString() async {
    WebUri? r = await getValidWebUri();
    return (r != null) ? r.toString() : null;
  }

  Future<String?> _getWebCurrentUrl() async {
    return getValidWebUrlString();
  }

  //不应为改变_webPageImageCount,刷新ui,
  void _updateHistoryUrl(String? url) {
    ZsLog.d('_updateHistoryUrl-stop load url:$url');
    String tmp = url ?? '';
    if (_stopUrl != tmp) {
      _stopUrl = tmp;
      _webPageImageCount = 0;
      _webPageImageLookIndex = 0;
      _checkSiteMode(_stopUrl);
      saveLastUrl(_stopUrl);
      widget.onStateUpdated.call();
    }
  }

  set webPageImageCount(int count) {
    if (count != _webPageImageCount) {
      setState(() {
        _webPageImageCount = count;
      });
      if (_webPageImageCount <= _webPageImageLookIndex) {
        _webPageImageLookIndex = 0;
      }
      if (count > 0) {
        ZsLog.d('web page images:$count');
      }
      // _updateImageUITip();
    }
    webViewHelper?.webPageImageCount = count;
  }

  //https 是否安全
  bool get isSecure => _isSecure;
  set isSecure(bool value) {
    if (value != _isSecure) {
      _isSecure = value;
      // setState(() {
      // });
      //notifyListeners();
    }
  }

  Future<void> _reloadWeb() async {
    if (isLoadingSyn() || await isLoading()) {
      await _webViewController?.stopLoading();
    }
    bool ish = await webViewHelper?.webViewHasHistory() == true;
    if (ish == false ||
        _lastWebError != null ||
        (_stopUrl == WebConstants.kNullUrl || !Utils.isValidHttpUrl(_stopUrl)) ||
        (defaultTargetPlatform == TargetPlatform.iOS)) {
      WebUri? w = await getValidWebUri();
      if (w != null) {
        await _webViewController?.loadUrl(urlRequest: URLRequest(url: w));
      } else {
        await _webViewController?.reload();
      }
    } else {
      await _webViewController?.reload();
    }
  }

  void saveLastUrl(String? urlStr) {
    if ((urlStr != null) && Utils.isValidHttpUrl(urlStr) && (urlStr.length > 5)) {
      if (context.mounted) {
        webViewHelper?.saveLastUrl(urlStr);
      }
    }
  }

  /// 检查site是否修改
  void _checkMainSiteChanged() {
    site = AppState.site;
  }

  void _onNetworkChanged() {
    var netQueue = Provider.of<NetStateQueue>(context, listen: false);
    NetState? st = netQueue.getLastNetState();
    if (st != null && st.connected && _lastWebError != null) {
      _reloadWeb();
    }
  }

  void _appStateValuesChanged() {
    _updateWebImageLoadMode();
    _updateWebAutoImageGallery();
    _updateWebBlacklistMode();
    _checkMainSiteChanged();
  }

  void _themeValuesChanged() {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    //更新sdk js 代码中的theme mode
    if ((themeProvider.preUserScript != null) && (_webViewController != null)) {
      _updateSDKJSUserScript(themeProvider);
    }
  }

  void _webTextSizeChanged() {
    var webTextSize = Provider.of<WebTextSize>(context, listen: false);
    //android ios
    int textRealZoom = webTextSize.textRealZoom;
    if (settings.textZoom != textRealZoom) {
      settings.textZoom = textRealZoom;
      webTextSize.updateTextZoom(_webViewController, settings: settings);
    }
    //macos ipad windows
    if (webTextSize.pageZoom != settings.pageZoom) {
      //：要支持 windows 必须修改参考：patch/windows_webview2_patch
      settings.pageZoom = webTextSize.pageZoom;
      _webViewController?.setSettings(settings: settings);
      //android
      webTextSize.updateTextZoom(_webViewController, settings: settings);
    }
  }

  //页内查找
  void _pageOnFindUpdate() async {
    if (Utils.isIOS()) {
      if ((await webViewHelper?.isFindNavigatorVisibleOniOS()) ?? false) {
        await webViewHelper?.dismissFindNavigatorOniOS();
      } else {
        await webViewHelper?.presentFindNavigatorOniOS();
      }
    } else {
      _updateImageUITip();
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _overlayController = StreamController<Widget>.broadcast();
    var appState = Provider.of<AppState>(context, listen: false);
    _site = appState.webSite;

    webViewHelper = WebViewHelper();
    webViewHelper?.init();

    webViewHelper?.onCallWebTabContext = () {
      return context;
    };

    webViewHelper?.fnEventCall = (int event, String? eventFn, dynamic param) async {
      dynamic r;
      if (eventFn == '_pageOnFindUpdate') {
        _pageOnFindUpdate();
      } else if (eventFn == '_getWebCurrentUrl') {
        r = await _getWebCurrentUrl();
      } else {
        r = null;
      }
      return r;
    };

    webViewHelper?.fnSynEventCall = (int event, String? eventFn, dynamic param) {
      dynamic r;
      if (eventFn == 'site') {
        r = site;
      } else if (eventFn == 'isMobileUA') {
        r = isMobileUA();
      } else {
        r = null;
      }
      return r;
    };

    if (widget.webMode.initUa != null && (widget.webMode.initUa!.length > 5)) {
      ZsLog.d('Set webview ua: ${widget.webMode.initUa}');
      settings.userAgent = widget.webMode.initUa;
    } else {
      ZsLog.d('Set webview ua: null');
    }
    //var netQueue = Provider.of<NetStateQueue>(context, listen: false);
    //netQueue.addListener(_onNetworkChanged);

    if (_enableLoadsImagesAutomatically) {
      settings.loadsImagesAutomatically = appState.webImgMode == 0 ? true : false;
    }
    _webImgMode = appState.webImgMode;
    _webAutoImageGallery = appState.autoImageGallery;
    _webBlacklistMode = appState.blackListApply;

    //appState.addListener(_appStateValuesChanged);
    // appState.talMainWebValueChangesCallBack = (int event, AppState object) {
    //   if (event == 0) {
    //     _checkMainSiteChanged();
    //   }
    // };

    _updateUserPreferredContentMode(appState);

    //var themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    //themeProvider.addListener(_themeValuesChanged);

    var webTextSize = Provider.of<WebTextSize>(context, listen: false);
    //webTextSize.addListener(_webTextSizeChanged);

    settings.textZoom = webTextSize.textRealZoom;
    settings.pageZoom = webTextSize.pageZoom;
    settings.supportMultipleWindows = widget.supportMultipleWindows();
    settings.javaScriptCanOpenWindowsAutomatically = widget.supportMultipleWindows();
    ////ios 上设置为true，在手势后一页的时候上面页面可以透视下面，视觉效果不佳
    if (!Utils.isApple()) {
      settings.transparentBackground = true;
    }

    // if (Utils.isWindows()) {
    //   //避免用户右键下载html文件
    //   settings.disableContextMenu = true;
    // }

    // if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    //   //android取消子框架的请求
    //   settings.regexToCancelSubFramesLoading = '';
    // }
    //只有ios和android 有效 需要设置allowsLinkPreview为false
    contextMenu = ContextMenu(
      menuItems: Utils.isDesktopSystem
          ? []
          : [
              ContextMenuItem(
                id: 1,
                title: "Special",
                action: () async {
                  ZsLog.d("Menu item Special clicked!");
                  ZsLog.d(await _webViewController?.getSelectedText());
                  await _webViewController?.clearFocus();
                },
              ),
            ],
      settings: ContextMenuSettings(hideDefaultSystemContextMenuItems: false),
      onCreateContextMenu: (hitTestResult) async {
        ZsLog.d("onCreateContextMenu,hitTestResult:$hitTestResult");
        if (hitTestResult.type == InAppWebViewHitTestResultType.SRC_IMAGE_ANCHOR_TYPE ||
            hitTestResult.type == InAppWebViewHitTestResultType.IMAGE_TYPE) {
          String? imgUrl = hitTestResult.extra;
          if (imgUrl != null && imgUrl.isNotEmpty) {
            String? url = await _getWebCurrentUrl();
            bool isSite = appState.webSite.isSite(url);
            if ((url != null) &&
                isSite &&
                ((appState.webSite.isThreadUrl(url, onlyMode: true)) || appState.webSite.isArticleUrl(url, onlyMode: true))) {
              return;
            }
            showWebImageGallery(imgUrl: imgUrl);
          }
        }
        //ZsLog.d(await _webViewController?.getSelectedText());
      },
      onHideContextMenu: () {
        ZsLog.d("onHideContextMenu");
      },
      onContextMenuActionItemClicked: (contextMenuItemClicked) async {
        //linux 有效
        var id = contextMenuItemClicked.id;
        ZsLog.d("onContextMenuActionItemClicked: $id ${contextMenuItemClicked.title}");
        if (Utils.isLinux()) {
          if (contextMenuItemClicked.title == 'Open Link in New Window') {
            userClickNewWindowTime = DateTime.now().millisecondsSinceEpoch;
          }
        }
      },
    );

    pullToRefreshController = kIsWeb || ![TargetPlatform.iOS, TargetPlatform.android].contains(defaultTargetPlatform)
        ? null
        : PullToRefreshController(
            settings: PullToRefreshSettings(color: Colors.blue),
            onRefresh: () async {
              await _reloadWeb();
            },
          );
    //get ua
    if (Utils.isIOS() || Utils.isMacOS() || Utils.isAndroid()) {
      settings.contentBlockers = AdBlock().contentBlockers;
      if ((appState.webImgMode == 1) && (Utils.isIOS() || Utils.isMacOS())) {
        //imageBlock
        settings.contentBlockers?.add(AdBlock().imageBlock);
      }
    }

    if (Utils.isValidHttpUrl(widget.webMode.initUrl)) {
      startUrl = widget.webMode.initUrl;
    }
  }

  //android linux
  void _startLayzImageMode() {
    bool setChanged = false;
    if ((_webImgMode == 2) && _enableLoadsImagesAutomatically) {
      if (settings.loadsImagesAutomatically == true) {
        settings.loadsImagesAutomatically = false;
        setChanged = true;
      }
    }
    if (setChanged) {
      _webViewController?.setSettings(settings: settings);
    }
  }

  //android
  void _endLazyImageMode() {
    bool setChanged = false;
    if ((_webImgMode == 2) && _enableLoadsImagesAutomatically) {
      if (settings.loadsImagesAutomatically == false) {
        settings.loadsImagesAutomatically = true;
        setChanged = true;
      }
    }
    if (setChanged) {
      _webViewController?.setSettings(settings: settings);
    }
  }

  void _updateWebImageLoadMode() {
    var appState = Provider.of<AppState>(context, listen: false);

    if (_webImgMode != appState.webImgMode) {
      _webImgMode = appState.webImgMode;
      bool cg = false;
      //['默认', '无图', '懒人'];
      if (_webImgMode == 1) {
        if (_enableLoadsImagesAutomatically) {
          if (settings.loadsImagesAutomatically != false) {
            settings.loadsImagesAutomatically = false;
            cg = true;
          }
        } else if (Utils.isMacOS() || Utils.isIOS()) {
          ContentBlocker ib = AdBlock().imageBlock;
          if (settings.contentBlockers == null || !settings.contentBlockers!.contains(ib)) {
            settings.contentBlockers?.add(ib);
            cg = true;
          }
        }
      } else if (_webImgMode == 2) {
        if (_enableLoadsImagesAutomatically) {
          if (settings.loadsImagesAutomatically == true) {
            settings.loadsImagesAutomatically = false;
            cg = true;
          }
        } else if (Utils.isMacOS() || Utils.isIOS()) {
          ContentBlocker ib = AdBlock().imageBlock;
          if (settings.contentBlockers == null || settings.contentBlockers!.contains(ib)) {
            settings.contentBlockers?.remove(ib);
            cg = true;
          }
        }
      } else {
        //0
        if (_enableLoadsImagesAutomatically) {
          if (settings.loadsImagesAutomatically == false) {
            settings.loadsImagesAutomatically = true;
            cg = true;
          }
        } else if (Utils.isMacOS() || Utils.isIOS()) {
          ContentBlocker ib = AdBlock().imageBlock;
          if (settings.contentBlockers == null || settings.contentBlockers!.contains(ib)) {
            settings.contentBlockers?.remove(ib);
            cg = true;
          }
        }
      }
      if (cg) {
        _webViewController?.setSettings(settings: settings);
      }
      String source =
          '''
            webinterfaceWebImageMode(${appState.webImgMode})
            ''';
      _webViewController?.evaluateJavascript(source: source);
    }
  }

  //window/macos root 调用
  Future<void> windowClose(bool userClose) async {
    await willClose();
  }

  //window/macos root 调用
  ////inappwebview 6.2.0-beta.2
  Future<void> windowFocus() async {
    if (Utils.isWindows()) {
      await resumeAll();
    } else {
      setState(() {});
    }
  }

  Future<void> windowBlur() async {
    if (Utils.isWindows()) {
      //鼠标点在webview区域也会收到事件
    } else {
      setState(() {});
    }
  }

  Future<void> windowMinimize() async {
    if (Utils.isWindows()) {
      pauseAll();
    }
  }

  Future<void> windowMenuEvent(int event) async {
    if (event == 2) {
      //隐藏
      if (Utils.isWindows()) {
        pauseAll();
      }
    } else if (event == 1) {
      if (Utils.isWindows()) {
        resumeAll();
      }
    }
    // if (event == 2) {
    //   asyncWindowsHandleInactive(true);
    // }
  }

  void cleanListener() {
    // if (mounted) {
    //   var netQueue = Provider.of<NetStateQueue>(context, listen: false);
    //   netQueue.removeListener(_onNetworkChanged);
    //   var appState = Provider.of<AppState>(context, listen: false);
    //   appState.removeListener(_appStateValuesChanged);
    //   var themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    //   themeProvider.removeListener(_themeValuesChanged);
    //   var webTextSize = Provider.of<WebTextSize>(context, listen: false);
    //   webTextSize.removeListener(_webTextSizeChanged);
    // } else {
    //   AppState().removeListener(_appStateValuesChanged);
    //   NetStateQueue().removeListener(_onNetworkChanged);
    //   ThemeProvider().removeListener(_themeValuesChanged);
    //   WebTextSize().removeListener(_webTextSizeChanged);
    // }
    //AppState().talMainWebValueChangesCallBack = null;
  }

  //上一个widget 调用。
  Future<void> willClose() async {
    if (!_isWindowClosed) {
      _isWindowClosed = true;
      _overlayController?.close();
      _overlayController = null;
      cleanListener();
      webViewHelper?.clean();
      await pauseAll();
      setState(() {});
    } else {
      webViewHelper?.clean();
      await pauseAll();
    }
  }

  @override
  didChangeDependencies() {
    //initState之后调用 不能有刷新页面的操作
    super.didChangeDependencies();
    var appState = Provider.of<AppState>(context, listen: false);
    if (_appStateNoListen != appState) {
      _appStateNoListen?.removeListener(_appStateValuesChanged);
      _appStateNoListen = appState;
      _appStateNoListen?.addListener(_appStateValuesChanged);
    }

    var themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    if (_themeProviderNoListen != themeProvider) {
      _themeProviderNoListen?.removeListener(_themeValuesChanged);
      _themeProviderNoListen = themeProvider;
      _themeProviderNoListen?.addListener(_themeValuesChanged);
    }

    var webTextSize = Provider.of<WebTextSize>(context, listen: false);
    if (_webTextSizeNoListen != webTextSize) {
      _webTextSizeNoListen?.removeListener(_webTextSizeChanged);
      _webTextSizeNoListen = webTextSize;
      _webTextSizeNoListen?.addListener(_webTextSizeChanged);
    }

    var netQueue = Provider.of<NetStateQueue>(context, listen: false);
    if (_netStateQueueNoListen != netQueue) {
      _netStateQueueNoListen?.removeListener(_onNetworkChanged);
      _netStateQueueNoListen = netQueue;
      _netStateQueueNoListen?.addListener(_onNetworkChanged);
    }
    //var webTextSize = Provider.of<WebTextSize>(context, listen: false);
    // webTextSize.sysTextZoom = MediaQuery.of(context).textScaler.textScaleFactor;
    //_lastSize = View.of(context).physicalSize;
  }

  @override
  void dispose() {
    _appStateNoListen?.removeListener(_appStateValuesChanged);
    _themeProviderNoListen?.removeListener(_themeValuesChanged);
    _webTextSizeNoListen?.removeListener(_webTextSizeChanged);
    _netStateQueueNoListen?.removeListener(_onNetworkChanged);

    if (!_isWindowClosed) {
      _isWindowClosed = true;
      cleanListener();
      _overlayController?.close();
    }

    webViewHelper?.clean();
    _webViewController = null;
    pullToRefreshController = null;
    webViewHelper = null;
    _overlayController = null;
    // _httpAuthUsernameController.dispose();
    // _httpAuthPasswordController.dispose();
    _focusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    //linux 无效
    InAppWebViewController.disposeKeepAlive(keepAlive);

    super.dispose();
  }

  @override
  void didChangeTextScaleFactor() {
    super.didChangeTextScaleFactor();
    if (!_isWindowClosed) {
      var webTextSize = Provider.of<WebTextSize>(context, listen: false);
      webTextSize.sysTextZoom = WidgetsBinding.instance.platformDispatcher.textScaleFactor;
    }
  }

  @override
  void didChangeMetrics() {
    // 当设备的度量（如字体缩放）改变时调用此方法
    super.didChangeMetrics();
    if (!_isWindowClosed) {
      var webTextSize = Provider.of<WebTextSize>(context, listen: false);
      webTextSize.sysTextZoom = WidgetsBinding.instance.platformDispatcher.textScaleFactor;
    }

    // setState(() { // 更新状态以反映新的字体缩放因子值
    //textScaleFactor = MediaQuery.of(context).textScaler.textScaleFactor;
    //print('Text Scale Factor changed to: $textScaleFactor');
    //});
  }

  @override
  void didChangePlatformBrightness() {
    //WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged =  _brightnessListener; 被设置了， 这个函数不会调用
    super.didChangePlatformBrightness();
    if (!_isWindowClosed) {
      var tp = Provider.of<ThemeProvider>(context, listen: false);
      bool r = tp.updateSystemDarkTheme();
      if (r) {
        _themeChanged(true);
      }
    }
    // SystemChrome.setSystemUIOverlayStyle(
    //   SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.purple),
    // );
    // //主题变化
    // var appState = Provider.of<AppState>(context, listen: false);
    // appState.isSystemDarkTheme =
    //     MediaQuery.of(context).platformBrightness == Brightness.dark;
  }

  ///fixed
  ////白色切黑色主题的时候，在android 10下，会显示黑色遮罩
  ///主题跟随系统模式下，在黑切白的时候 不会刷新
  Future<void> _themeChanged(bool systemChanged) async {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    var appState = Provider.of<AppState>(context, listen: false);
    var uri = await _webViewController?.getUrl();
    if (await isLoading()) {
      await stopLoading();
      await _reloadWeb();
    } else {
      if (uri != null) {
        _updateWebAutoTheme(appState, themeProvider, uri, false);
        if (Utils.isWindows()) {
          //fixed window webview scrollbar color
          await _webViewController?.evaluateJavascript(source: themeProvider.windowsWebViewScrollBarUpdateJsFn);
        }
      } else {
        ZsLog.i('theme changed: systemChanged[$systemChanged] uri is null');
      }
    }
  }
  // late double _lastTextScaleFactor;
  // @override
  // void didChangeTextScaleFactor() {
  //   super.didChangeTextScaleFactor();
  //   setState(() {
  //     _lastTextScaleFactor =
  //         WidgetsBinding.instance.platformDispatcher.textScaleFactor;
  //   });
  // }

  @override
  void didUpdateWidget(covariant oldWidget) {
    //Mainpage oldWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  void deactivate() {
    //Widget从树中移除时触发
    super.deactivate();
    ZsLog.d('did changd app lifecycle :  deactivate');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    bool isPaused = state == AppLifecycleState.paused;
    bool ishidden = state == AppLifecycleState.hidden;
    if (!_isWindowClosed) {
      //ZsLog.d('did changd app lifecycle state:$state');
      if (_webViewController != null) {
        if (isPaused) {
          AppState().handleExit();
        } else if (ishidden) {
          AppState().handleHidden();
        }
        if (Utils.isAndroid()) {
          if (isPaused) {
            //_handleWebSitePromptMsg();
            pauseAll();
          } else {
            resumeAll();
          }
        } else if (Utils.isWindows()) {}
      }
    }
  }

  //js dom loaded 后，发送回来的web info
  Future<void> _handleWebSiteInfo(AppState? appState, Map val) async {
    if (val is Map<String, dynamic> && val.isNotEmpty) {
      MainSite? ms = MainSite.fromMap(val);
      if (ms != null && ms.valid && ms.isDiscuz) {
        ms.updateSource(MainSiteSourceType.detect);
        ms.updateSiteType(SiteType.discuz);
        await appState?.updateWebSiteFromJs(ms, onlyMain: true, info: val);
      }
    }
  }

  /// 收到web的提醒消息
  Future<void> _updateWebSitePromptMsg(AppState? appState, Map val) async {
    if (context.mounted == false || val.length < 4) {
      return;
    }
    var aps = appState ?? Provider.of<AppState>(context, listen: false);
    try {
      PromptMsg msg = PromptMsg.fromMap(val as Map<String, dynamic>);
      aps.updateWebSitePromptMsg(msg);
    } catch (e) {
      ZsLog.e('update prompt msg error:$e');
    }
    // AppLifecycleState? currentLifecycleState = WidgetsBinding.instance.lifecycleState;
    // if (currentLifecycleState == AppLifecycleState.paused) {
    //   _handleWebSitePromptMsg();
    // }
  }

  // Future<void> _handleWebSitePromptMsg() async {
  //   var aps = Provider.of<AppState>(context, listen: false);
  //   if (aps.webSitePromptMsg.count > 0) {
  //     // await EasyNotifications.scheduleMessage(
  //     //   title: '我的提醒',
  //     //   body: '有新提醒(${aps.webSitePromptMsg.count})',
  //     //   actions: [
  //     //     NotificationAction(
  //     //       id: 'click',
  //     //       title: '查看',
  //     //       onPressed: () {
  //     //         ZsLog.d('我的提醒-click');
  //     //       },
  //     //     ),
  //     //   ],
  //     //   scheduledDate: DateTime.now().add(const Duration(seconds: 5)),
  //     // );
  //   }
  // }

  // Future<void> asyncWindowsHandleInactive(bool force) async {
  //   if (Utils.isDesktopSystem) {
  //     await Future.delayed(Duration(milliseconds: 800));
  //     bool isv = await WindowUtil.isVisible();
  //     bool ismin = await WindowUtil.isMinimized();
  //     if ((force == false) && isv && (ismin == false)) {
  //       ZsLog.d('asyncWindowsHandleInactive not handle');
  //     } else {
  //       await pauseAll();
  //     }
  //   }
  // }

  // @override
  // bool handleStartBackGesture(PredictiveBackEvent backEvent) {
  //   if (Utils.isAndroid()) {
  //     return true;
  //   }
  //   return super.handleStartBackGesture(backEvent);
  // }

  // @override
  // void handleUpdateBackGestureProgress(PredictiveBackEvent backEvent) {
  //   // : implement handleUpdateBackGestureProgress
  //   super.handleUpdateBackGestureProgress(backEvent);
  // }

  // @override
  // void handleCommitBackGesture() {
  //   super.handleCommitBackGesture();
  // }

  // @override
  // void handleCancelBackGesture() {
  //   super.handleCancelBackGesture();
  // }

  Future<void> pauseAll() async {
    // ZsLog.d('webView pauseAll');
    if (Utils.isAndroid() || Utils.isWindows()) {
      await _webViewController?.pause();
    }
    await pauseTimers();
  }

  Future<void> resumeAll() async {
    // ZsLog.d('webView resumeAll');
    if (Utils.isAndroid() || Utils.isWindows()) {
      await _webViewController?.resume();
    }
    await resumeTimers();
  }

  Future<void> pause() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _webViewController?.setAllMediaPlaybackSuspended(suspended: true);
    } else if (Utils.isAndroid() || Utils.isWindows()) {
      await _webViewController?.pause();
    }
  }

  Future<void> resume() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _webViewController?.setAllMediaPlaybackSuspended(suspended: false);
    } else if (Utils.isAndroid() || Utils.isWindows()) {
      await _webViewController?.resume();
    }
  }

  Future<void> pauseTimers() async {
    if (!Utils.isWindows() && !Utils.isLinux()) {
      //windows 不支持
      await _webViewController?.pauseTimers();
    }
  }

  Future<void> resumeTimers() async {
    if (!Utils.isWindows() && !Utils.isLinux()) {
      //windows 不支持
      await _webViewController?.resumeTimers();
    }
  }

  void _updateImageUITip() {
    setState(() {});
  }

  Future<void> webScrollAction(bool topOrDown) async {
    //document.documentElement.scrollTop = 0
    await _webViewController?.evaluateJavascript(
      source: topOrDown ? "window.scrollTo(0, 0);" : "window.scrollTo(0, document.body.scrollHeight);",
    );
  }

  Future<void> openImage(String? imagePath) async {
    if ((Utils.isDesktopSystem) && imagePath != null) {
      final Uri imageUri = Uri.file(imagePath);
      if (await canLaunchUrl(imageUri)) {
        await launchUrl(imageUri);
      } else {
        throw 'Could not launch $imagePath';
      }
    }
  }

  Future<bool> webViewOpenUrl(String? url) async {
    return await webViewHelper?.webViewOpenUrl(url) == true;
  }

  bool _updateUserPreferredContentMode(AppState appState) {
    bool r = false;
    if (Utils.isIOSPad || Utils.isMacOS() || Utils.isAndroidPad) {
      UserPreferredContentMode v = appState.isMobileUA() ? UserPreferredContentMode.MOBILE : UserPreferredContentMode.RECOMMENDED;
      if (v != settings.preferredContentMode) {
        settings.preferredContentMode = v;
        r = true;
      }
    }
    return r;
  }

  bool isMobileUA() {
    var appState = Provider.of<AppState>(context, listen: false);
    return appState.isMobileUA();
  }

  bool isPCUA() {
    var appState = Provider.of<AppState>(context, listen: false);
    return (appState.getSettingUaType() == WVUATypes.uaPC);
  }

  Future<void> toggleUA() async {
    var appState = Provider.of<AppState>(context, listen: false);

    await appState.toggleUa();

    _updateUserPreferredContentMode(appState);

    String? uas = appState.getCurrentUAString();
    // if (kDebugMode) {
    //   String deua = (kIsWeb || Utils.isWindows() || Utils.isLinux())
    //       ? ''
    //       : await InAppWebViewController.getDefaultUserAgent();
    //   ZsLog.i("switch set ua:${uas ?? ''} , device default ua: $deua");
    // }

    settings.userAgent = uas;

    String? webUrl = await _getWebCurrentUrl();
    await _webViewController?.setSettings(settings: settings);

    if (Utils.isAndroid()) {
      await _webViewController?.clearHistory();
    }
    if (webUrl != null) {
      //String reloadUrl = site.convertUrlFromUrl(webUrl);
      var reloadUrl = site.convertUrlFromUrl(webUrl, isPCUA(), isMobileUA());
      ZsLog.d('UA Switch url:$reloadUrl');
      reloadUrl ??= webUrl;
      await _webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri(reloadUrl)));
    }
  }

  Future<void> _getWebUserInfo() async {
    var appState = Provider.of<AppState>(context, listen: false);
    String? url = await _getWebCurrentUrl();
    if (url == null) {
      return;
    }
    WebUri wuri = WebUri(url);
    //cookie 可以获得isHttpOnly: true,
    CookieManager cookieManager = CookieManager.instance();
    List<Cookie> cookies = await cookieManager.getCookies(url: wuri, webViewController: _webViewController);
    String? authCookie;
    String? key = appState.webSite.mainSite?.authCookieFullNameKey;
    if (key == null || key.isEmpty) {
      return;
    }
    String cookieStr = '';
    for (var i = 0; i < cookies.length; i++) {
      var cookie = cookies[i];
      var cv = cookie.value != null ? cookie.value.toString() : '';
      var cn = cookie.name;
      if (cn.isNotEmpty && cv.isNotEmpty) {
        var encodeValue = Uri.encodeQueryComponent(cv);
        if (cookie.name == key) {
          authCookie ??= cv;
        }
        var csp = "${cookie.name}= $encodeValue";
        if (cookieStr.isEmpty) {
          cookieStr = csp;
        } else {
          cookieStr = "$cookieStr; $csp";
        }
      } else {
        ZsLog.i('cookie is invalid; ${cookie.toString()}');
      }
    }
    //Cookie:jqCP_887f_ulastactivity=1778139225%7C0; jqCP_887f_smile=9D1; jqCP_887f_lastcheckfeed=695499%7C1777167426; jqCP_887f_forum_lastvisit=D_571_1774486228D_574_1776505077D_548_1777182224D_563_1777182226D_497_1777470164D_576_1778113024; jqCP_887f_saltkey=b0I3a657; jqCP_887f_lastvisit=1777163821; jqCP_887f_auth=6dfcftstRb9WN18OKCFXIdZHEyBWUGxxpwcPw6li80Bapc8%2B%2BmR%2FzxWDnz3BGjr5NsyrQhn3fdcD%2F2amnhOh8bT8Fpk; jqCP_887f_home_readfeed=1778079306; jqCP_887f_uuid=695499; jqCP_887f_sid=0; jqCP_887f_lastact=1778139226%09home.php%09spacecp; jqCP_887f_st_t=695499%7C1778113024%7C3e57d8f1703edfb7a00e83722f0ff458; jqCP_887f_st_p=695499%7C1778136716%7C9b0a1012f0d716f97839107c1a2d25fc; jqCP_887f_viewid=tid_2070501; jqCP_887f_home_diymode=1
    appState.webSite.updateCookieToInfo(cookieStr);

    // ZsLog.d(
    //   '-------------------------cookie list:$cookies --------------------',
    // );
    bool getjs = appState.webSite.user.cookieAuth != authCookie;
    // appState.loginUser.updateCookieAuth(cookieAuth);
    // bool getjs = userchanged;
    if (getjs == false && appState.webSite.user.isLogin() && !appState.webSite.user.isValidName()) {
      getjs = true;
    } else if (!appState.webSite.user.isLogin()) {
      return;
    }

    if (getjs && site.isSite(url)) {
      var result = await _webViewController?.evaluateJavascript(source: "webinterfaceGetLoginUserInfo()");
      if (result != null) {
        var dict = jsonDecode(result);
        String? name = dict['name'];
        //String? webUrl = dict['src'];
        String? userUrl = dict['url'];
        String? userIcon = dict['icon'];
        String? uid = dict['uid'];
        appState.webSite.updateUserInfo(name: name, userUrl: userUrl, userIcon: userIcon, uid: uid, authCookie: authCookie);
        appState.webSite.save();
        // appState.loginUser.uid = dict['uid'];
        // appState.loginUser.name = name;
        // appState.loginUser.url = userUrl;
        // appState.loginUser.iconUrl = userIcon;
        // appState.loginUser.updateChangFlag();
      }
    }
  }

  Future<bool> isAuthorCurrentPageUrl() async {
    String? webUrl = await _getWebCurrentUrl();
    if (webUrl == null || webUrl.isEmpty) {
      return false;
    }
    return site.isAuthorUrl(webUrl);
  }

  Future<void> addOrDelBlacklist(String? name, bool isExist) async {
    int r = await BlackList.apiAddOrDelBlacklist(name, isExist);
    if (r == -1) {
      return;
    } else if (r == 1) {
      await _webJsUpdateBlackList(name!, false);
    } else if (r == 2) {
      await _webJsUpdateBlackList(name!, true);
    }
  }

  Future<void> addBlacklist(String name, {bool prompt = true}) async {
    int? r = await webViewHelper?.addBlacklist(name, prompt: prompt);
    if (r == null || r == -1) {
      return;
    } else if (r == 1) {
      await _webJsUpdateBlackList(name, false);
    } else if (r == 2) {
      await _webJsUpdateBlackList(name, true);
    }
  }

  Future<void> openCurrentUrlOtherBrowser() async {
    webViewHelper?.systemBrowserOpenUrl(await getValidWebUrlString());
  }

  /*
   *
   * 其他app打开
   */
  Future<void> handleWebOtherHostUrl(String url) async {
    List<OptionButtonItem> list = [];
    list.add((
      label: Utils.isDesktopSystem ? Constants.kUrlNewWindowsOpen : Constants.kUrlInPageOpen,
      onPressed: () {
        webViewHelper?.innerBrowserOpen(mounted ? context : null, url);
      },
    ));
    list.add((
      label: Constants.kSysBrowserOpen,
      onPressed: () {
        webViewHelper?.systemBrowserOpenUrl(url);
      },
    ));
    list.add((
      label: Constants.kCopyLinker,
      onPressed: () {
        Uiutils.copyContentToClipboard(context, url);
      },
    ));
    list.add((label: Constants.kTipCancel, onPressed: () {}));
    Uiutils.simpleSelectOptionsDialog(context, list);
  }

  //js
  Future<void> _updateWebBlacklist() async {
    var url = await _getWebCurrentUrl();
    if ((_webViewController != null) && (url != null) && (url.contains(SiteConstants.kWebSiteHost))) {
      if (mounted) {
        var params = jsonEncode({'list': BlackList.userBlackList});
        String source =
            '''
                webinterfaceSetBlacklist($params)
                ''';
        await _webViewController?.evaluateJavascript(source: source);
      }
    }
  }

  Future<void> _updateWebAutoImageGallery() async {
    var appState = Provider.of<AppState>(context, listen: false);
    if (_webAutoImageGallery != appState.autoImageGallery) {
      _webAutoImageGallery = appState.autoImageGallery;
      var url = await _getWebCurrentUrl();
      if ((_webViewController != null) && (url != null)) {
        if (mounted) {
          var params = appState.autoImageGallery ? '1' : '0';
          String source =
              '''
                webinterfaceAutoImageGallery($params)
                ''';
          await _webViewController?.evaluateJavascript(source: source);
        }
      }
    }
  }

  Future<void> _updateWebBlacklistMode() async {
    var appState = Provider.of<AppState>(context, listen: false);
    if (_webBlacklistMode != appState.blackListApply) {
      _webBlacklistMode = appState.blackListApply;
      var url = await _getWebCurrentUrl();
      if ((_webViewController != null) && (url != null)) {
        if (mounted) {
          var params = '${appState.blackListApply}';
          String source =
              '''
                webinterfaceBlacklistMode($params)
                ''';
          await _webViewController?.evaluateJavascript(source: source);
        }
      }
    }
  }

  Future<void> _updateWebAutoTheme(AppState appState, ThemeProvider themeProvider, WebUri? curl, progressRun) async {
    int stm = themeProvider.isSystemDarkTheme ? 1 : 0;
    int ctm = themeProvider.currentThemeModeCode();
    int uatype = appState.isMobileUA() ? 1 : 2;
    //以后需要增加参数，通过param 包装，js端通过重载_app_sub_ov_updateParam 解析，第一个被autoImageGallery使用了
    List<String> paramList = [appState.autoImageGallery ? '1' : '0', '${appState.blackListApply}'];
    String param = jsonEncode(paramList);
    //webinterfaceThemeMode('2','1','1', '0',"['1']");
    String source =
        '''
          webinterfaceThemeMode($ctm,$stm, $uatype, ${appState.webImgMode},$param)
          ''';
    var r = await _webViewController?.evaluateJavascript(source: source);
    if (progressRun) {
      //{"rc":4,"update":3}
      if (r != null && (r is String)) {
        try {
          var dict = jsonDecode(r);
          if (dict != null) {
            var rc = UtilMap.safeIntForKey(dict, 'rc');
            var update = UtilMap.safeIntForKey(dict, 'update');
            if (rc == 0 || update == 0) {
              //不需要处理了
              _loadPreUpdateThemeModelToJs = true;
            } else {
              //继续处理
              _loadPreUpdateThemeModelToJs = false;
            }
          }
        } catch (e) {
          ZsLog.d('_updateWebAutoTheme error:$e');
        }
      }
    }
  }

  bool _currentUrlIsImage({String? url}) {
    return Utils.isImageExtensionUrl(url ?? (_stopUrl.isNotEmpty ? _stopUrl : _startUrl));
  }

  Future<void> _updateWebImageInfos(AppState appState, ThemeProvider themeProvider, WebUri? url, {void Function()? updateFavor}) async {
    if ((_webViewController != null) && (url != null)) {
      String urlstr = url.toString();
      bool isSite = appState.webSite.isSite(urlstr);

      bool isvalidUrl =
          (appState.webSite.isThreadUrl(urlstr, onlyMode: true) ||
          appState.webSite.isArticleUrl(urlstr, onlyMode: true) ||
          appState.webSite.isForumUrl(urlstr, onlyMode: true) ||
          appState.webSite.isAreaUrl(urlstr, onlyMode: true) ||
          appState.webSite.isHomeUrl(urlstr, onlyMode: true));

      if (isSite && (isvalidUrl || _currentUrlIsImage(url: urlstr))) {
        var count = await webViewHelper?.jsWebPageImageCount(urlstr);
        if (count != null) {
          webPageImageCount = count;
        }
      }
      if (isSite && isvalidUrl) {
        if (updateFavor != null) {
          updateFavor();
        }
      }
    }
  }

  Future<void> _webLoadSiteStop(AppState appState, ThemeProvider themeProvider, WebUri? url) async {
    await _updateWebAutoTheme(appState, themeProvider, url, false);
    if ((_webViewController != null) && (url != null)) {
      String urlstr = url.toString();
      bool isSite = appState.webSite.isSite(urlstr);
      if (isSite) {
        var params = jsonEncode({'list': BlackList.userBlackList});
        String source =
            '''
        webinterfaceSetBlacklist($params)
        ''';
        await _webViewController?.evaluateJavascript(source: source);
      }
      await _getWebUserInfo();
      await _updateWebImageInfos(
        appState,
        themeProvider,
        url,
        updateFavor: () async {
          await Favorites().updateLookUrl(urlstr, _webPageTitle);
        },
      );
    }
    _endLazyImageMode();
  }

  Future<void> showWebImageGallery({String? imgUrl}) async {
    WebImages? webImages = await webViewHelper?.getWebPageImages(imgUrl);

    if ((webImages != null) && (webImages.images.isNotEmpty) && mounted) {
      if ((_webPageImageLookIndex < 0) || (webImages.images.length <= _webPageImageLookIndex)) {
        _webPageImageLookIndex = 0;
      }
      if (imgUrl != null && webImages.images.contains(imgUrl)) {
        _webPageImageLookIndex = webImages.images.indexOf(imgUrl);
      }
      SwipeImageGallery(
        context: context,
        initialOverlay: OverlayWebImageGallery(
          title: '${_webPageImageLookIndex + 1}/${webImages.count}',
          callback: (BuildContext ctx) {
            webViewHelper?.webImageGallerySaver(ctx, webImages.imageAtIndex(_webPageImageLookIndex) ?? '');
          },
        ),
        initialIndex: _webPageImageLookIndex,
        itemBuilder: (context, index) {
          return CachedNetworkImage(
            imageUrl: webImages.imageAtIndex(index) ?? '',
            cacheManager: ZjImageCacheManager(),
            progressIndicatorBuilder: (context, url, progress) {
              return Container(
                alignment: AlignmentGeometry.center,
                child: SizedBox(width: 40, height: 40, child: CircularProgressIndicator(value: progress.progress)),
              );
            },
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                image: DecorationImage(image: imageProvider, fit: BoxFit.fitWidth),
              ),
            ),
            errorWidget: (context, url, error) {
              ZsLog.d('image $url load error:$error');
              return Icon(Icons.error, color: Colors.red);
            },
          );
        },
        itemCount: webImages.count,
        // ignore: avoid_print
        onSwipe: (index) {
          _webPageImageLookIndex = index;
          _overlayController?.add(
            OverlayWebImageGallery(
              title: '${index + 1}/${webImages.count}',
              callback: (BuildContext ctx) {
                webViewHelper?.webImageGallerySaver(ctx, webImages.imageAtIndex(_webPageImageLookIndex) ?? '');
              },
            ),
          );
          ZsLog.d('$index');
        },
        overlayController: _overlayController,
      ).show().then((value) async {
        ZsLog.d('gallery end...');
        webViewHelper?.jsWebViewImageGalleryExit();
      });
    }
  }

  Future<void> _webJsUpdateBlackList(String name, bool isAdd) async {
    if (_webViewController != null) {
      var params = jsonEncode({'name': name, 'op': isAdd ? 1 : 0});
      String source =
          '''
        webinterfaceUpdateBlacklist($params)
        ''';
      _webViewController?.evaluateJavascript(source: source);
    }
  }

  Future<void> _updateSDKJSUserScript(ThemeProvider tp) async {
    if (_updateUserScript) return;
    _updateUserScript = true;
    if ((tp.preUserScript == null) || (webViewHelper?.valid() != true)) {
      _updateUserScript = false;
      return;
    }
    if (progress < 1.0) {
      await stopLoading();
    }
    await tp.updateSDKJSUserScript(_webViewController);
    await _reloadWeb();
    _updateUserScript = false;
  }

  void _setWebThemeReady(WebThemeSyncState v, {bool updateUi = true}) {
    WebThemeSyncState bv = _webThemeReady;
    if (_webThemeReady != v) {
      if (updateUi) {
        setState(() {
          _webThemeReady = v;
        });
      } else {
        _webThemeReady = v;
      }
    }
    ZsLog.d('Web _setWebThemeReady progress: $progress, _webThemeReady from $bv to $_webThemeReady');
  }

  void _updateWebThemeReady({WebThemeSyncState v = WebThemeSyncState.delayCompleted, bool isComplete = true}) {
    // if (_webThemeReady != v) {
    if (isComplete) {
      if (_webThemeReady == WebThemeSyncState.complete) {
        _setWebThemeReady(v);
      }
    } else {
      _setWebThemeReady(v);
      // setState(() {
      //   _webThemeReady = v;
      // });
      // }
    }
  }

  void _delayUpdateWebThemeReady({
    WebThemeSyncState v = WebThemeSyncState.delayCompleted,
    bool isComplete = true,
    bool isDelay = true,
    int? milliseconds,
  }) {
    if (isDelay) {
      var d = milliseconds ?? (Utils.isAndroi10Under() ? 1000 : 500);
      Future.delayed(Duration(milliseconds: d), () {
        _updateWebThemeReady(v: v, isComplete: isComplete);
      });
    } else {
      _updateWebThemeReady(v: v, isComplete: isComplete);
    }
  }

  void _updateWebLoadingProgress(
    AppState appState,
    ThemeProvider themeProvider,
    InAppWebViewController controller,
    int progs, {
    bool forceStrop = false,
    bool isDelay = false,
  }) {
    bool stopFlag = forceStrop;

    double pr = stopFlag ? 1.0 : progs / 100;
    if (stopFlag || progs == 100) {
      pullToRefreshController?.endRefreshing();
    }

    if (stopFlag) {
      if (_stopUrl.isNotEmpty && _stopUrl != _startUrl) {
        _startUrl = _stopUrl;
      }
      pr = 1.0;
      _delayUpdateWebThemeReady(v: WebThemeSyncState.delayCompleted, isDelay: true, isComplete: true);
    } else if (_webThemeReady == WebThemeSyncState.start || _webThemeReady == WebThemeSyncState.none) {
      // _webThemeReady = WebThemeSyncState.loading;
      _setWebThemeReady(WebThemeSyncState.loading, updateUi: false);
      if (progs >= 100) {
        // _webThemeReady = WebThemeSyncState.complete;
        // _setWebThemeReady(WebThemeSyncState.complete,updateUi: false,);
        _delayUpdateWebThemeReady(v: WebThemeSyncState.complete, isDelay: true, isComplete: true, milliseconds: 400);
        if (isDelay) {
          _delayUpdateWebThemeReady(v: WebThemeSyncState.delayCompleted, isDelay: true, isComplete: true);
        }
      }
    } else if (_webThemeReady == WebThemeSyncState.complete) {
      if (progs < 100) {
        //_webThemeReady = WebThemeSyncState.loading;
        _setWebThemeReady(WebThemeSyncState.loading, updateUi: false);
      } else if (isDelay) {
        _delayUpdateWebThemeReady(v: WebThemeSyncState.delayCompleted, isDelay: true, isComplete: true);
      }
    }

    ZsLog.d('Web load url current Progress:$pr, setprogress:$progs, forceStop=$stopFlag, _webThemeReady[$_webThemeReady]');
    setState(() {
      progress = pr;
    });

    if (progs > 20) {
      if (_loadPreUpdateThemeModelToJs == false) {
        _loadPreUpdateThemeModelToJs = true;
        _updateWebAutoTheme(appState, themeProvider, _startUrl.length > 5 ? WebUri(_startUrl) : null, true);
      }
    }
  }

  Future<void> _webTapFavr(bool flag) async {
    //移动站收藏链接
    Favor? lk = await Favorites().updateLookUrl((await _getWebCurrentUrl()).toString(), _webPageTitle, setFavor: flag);
    if (lk != null && mounted) {
      Uiutils.showSnackBar(context, flag ? '收藏成功' : '取消收藏成功');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isWindowClosed) {
      return Container();
    }
    //没有用到
    var appState = Provider.of<AppState>(context, listen: false);
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    var webTextSize = Provider.of<WebTextSize>(context, listen: true);
    super.build(context);
    // SystemChrome.setSystemUIOverlayStyle(
    //   SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.purple),
    // );
    //为这个页面设置单独status bar
    // return _callbackShortcutsWidget(
    //   context,
    //   appState,
    //   themeProvider,
    //   webTextSize,
    // );
    // return _annotatedRegionWidget(context, appState, themeProvider, webTextSize, null);
    return OrientationBuilder(
      builder: (context, orientation) {
        //如果当前widget 的长宽 来判断方向，而不是设备的方向，获得设备的方向使用DeviceOrientationBuilder
        return _annotatedRegionWidget(context, appState, themeProvider, webTextSize, orientation);
      },
    );
  }

  Widget _annotatedRegionWidget(
    BuildContext context,
    AppState appState,
    ThemeProvider themeProvider,
    WebTextSize webTextSize,
    Orientation? orientation,
  ) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // 该页面专属的状态栏样式
      value: Provider.of<ThemeProvider>(context).getWebPageUIOverlayStyle(),
      //  SystemUiOverlayStyle(
      //   statusBarColor: Colors.purple, // 紫色背景
      //   statusBarIconBrightness: Brightness.light, // 浅色图标（Android）
      //   statusBarBrightness: Brightness.dark, // 深色文字（iOS）
      // ),
      // 子组件为当前页面的完整布局
      //child: Scaffold(appBar: _appBar()),
      child: _callbackShortcutsWidget(context, appState, themeProvider, webTextSize, orientation),
    );
  }

  final ismate = Utils.isApple();
  final isctrl = Utils.isWindows() || Utils.isLinux();

  Widget _callbackShortcutsWidget(
    BuildContext context,
    AppState appState,
    ThemeProvider themeProvider,
    WebTextSize webTextSize,
    Orientation? orientation,
  ) {
    //LogicalKeyboardKey.meta‌  在 macOS 上‌：对应 ‌Command 键（⌘）‌,在 Windows 和 Linux 上‌：对应 ‌Windows 键（Win 键）‌ 或 ‌Super 键‌
    //LogicalKeyboardKey.keypadMinus‌：表示‌数字小键盘上的减号键
    //LogicalKeyboardKey.minus‌：表示‌主键盘区的减号键‌（通常位于 0 键右侧或主键盘右上角
    //LogicalKeyboardKey.numpadAdd‌ 是 Flutter 用于标识数字小键盘加号键的常量。
    //LogicalKeyboardKey.add：表示‌主键盘区的减号键‌（通常位于 - 键右侧或主键盘右上角
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        SingleActivator(control: isctrl, meta: ismate, LogicalKeyboardKey.minus): () {
          webTextSize.previousPageZoom();
          ZsLog.d('Web meta + control +  - previousPageZoom');
        },
        SingleActivator(control: isctrl, meta: ismate, LogicalKeyboardKey.add): () {
          webTextSize.nextPageZoom();
          ZsLog.d('Web meta + control +  + nextPageZoom');
        },
        SingleActivator(control: isctrl, meta: ismate, LogicalKeyboardKey.arrowLeft): () {
          goBack();
          ZsLog.d('Web meta + arrowLeft goBack');
        },
        SingleActivator(control: isctrl, meta: ismate, LogicalKeyboardKey.arrowRight): () {
          goForward();
          ZsLog.d('Web meta arrowRight');
        },
        SingleActivator(control: isctrl, meta: ismate, LogicalKeyboardKey.arrowUp): () async {
          webScrollAction(true);
          ZsLog.d('Web meta + arrowUp web scroll to top');
        },
        SingleActivator(LogicalKeyboardKey.arrowDown, control: isctrl, meta: ismate): () {
          webScrollAction(false);
          ZsLog.d('Web meta + arrowDown web scroll to bottom');
        },
        SingleActivator(LogicalKeyboardKey.keyR, control: isctrl, meta: ismate): () {
          _reloadWeb();
          ZsLog.d('Web meta + r web reload');
        },
        SingleActivator(LogicalKeyboardKey.arrowDown, control: isctrl, meta: ismate): () {
          ZsLog.d('Web arrowDown');
        },
        SingleActivator(LogicalKeyboardKey.keyF, control: isctrl, meta: ismate): () {
          if (webViewHelper != null) {
            webViewHelper?.isFindInteractionEnabled = !webViewHelper!.isFindInteractionEnabled;
          }

          ZsLog.d('Web meta + shift+ f web one page find');
        },
      },
      child: _focusWidget(context, appState, themeProvider, webTextSize, orientation),
    );
  }

  PreferredSizeWidget? _findAppBar() {
    if (Utils.isIOS() || webViewHelper == null) {
      return null;
    }
    return webViewHelper?.isFindInteractionEnabled == true
        ? WebViewFindBar(
            height: Utils.isDesktopSystem ? 60 : 56,
            webViewHelper: webViewHelper!,
            callFunc: (String? searchText, int numberOfMatches, bool hide) {
              if (hide) {
                webViewHelper?.isFindInteractionEnabled = false;
              }
              // else if (searchText == null || searchText.isEmpty) {
              //   ZsLog.d('find text is null');
              // } else {
              //   ZsLog.d('find text is $searchText');
              // }
            },
          )
        : null;
  }

  Widget _focusWidget(
    BuildContext context,
    AppState appState,
    ThemeProvider themeProvider,
    WebTextSize webTextSize,
    Orientation? orientation,
  ) {
    return Focus(
      autofocus: true,
      focusNode: _focusNode,
      descendantsAreFocusable: true, //默认为true，如果为false，可以使该组件的后代节点无法获得焦点（与canRequestFocus对应，只是影响对象不一样）。
      // descendantsAreTraversable:
      //     true, //默认为true，如果为false，可以使该组件的后代节点无法被遍历（与skipTraversal对应，会影响skipTraversal的结果）
      //skipTraversal: true, //true 使用 Tab 该节点不会获得焦点，但使用 requestFocus 仍可获得焦点
      //canRequestFocus: false, //false 均无法获得焦点
      //includeSemantics: 默认为true，会在组件中包Semantics
      // onFocusChange: (value) {
      //   ZsLog.d('focus changed:$value');
      // },
      // onKeyEvent: (node, event) {
      //   // KeyEventResult result = KeyEventResult.ignored;
      //   // // Activates all key bindings that match, returns "handled" if any handle it.
      //   // for (final ShortcutActivator activator in bindings.keys) {
      //   //   result = _applyKeyEventBinding(activator, event)
      //   //       ? KeyEventResult.handled
      //   //       : result;
      //   // }
      //   // return result;

      //   return KeyEventResult.ignored; //关键事件尚未处理，但不应处理
      //   // return KeyEventResult.handled; //则 key 事件不会传递给下一个节点
      // },
      child: PopScope(
        //2秒内多少返回手势，则返回true退出应用。 返回false禁止回退、滑动回退以及Android的物理键回退，android 有效
        canPop: false, //canPopExit(),
        onPopInvokedWithResult: (didPop, result) async {
          ZsLog.d('Web didPop: $didPop; result:$result ');
          if (!didPop) {
            if (await _handlePopBackGesture(false)) {
              prePopDateTime = null;
            } else if (appState.swipeRightExit) {
              if (prePopDateTime == null) {
                prePopDateTime = DateTime.now();
              } else {
                DateTime nowTime = DateTime.now();
                if ((nowTime.millisecondsSinceEpoch - prePopDateTime!.millisecondsSinceEpoch) < 1500) {
                  //1.5秒内在一次手势返回，手动退出应用
                  if (context.mounted) {
                    prePopDateTime = null;
                    if (Utils.isAndroid()) {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        await AppState().handleExit();
                        await SystemNavigator.pop();
                      }
                      //Navigator.pop(context);
                    } else if (Utils.isIOS()) {
                      //如果应用要审核，不实现这个功能
                      //exit(0);
                    }
                  }
                } else {
                  //超过了时间
                  prePopDateTime = nowTime;
                }
              }
            }
          } else {
            prePopDateTime = null;
          }
        },
        child: Scaffold(
          appBar: _findAppBar(),
          //默认设置为true，ios anndroid 键盘出来的时候，bottom区域被顶上去，所以设置false,android 10+ 还需要把bottombar高度固定
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            //SafeArea
            // top: false,
            // maintainBottomViewPadding: true,
            //   bottom: false, // 如果你不需要底部安全区域
            //child: SingleChildScrollView( //OverflowBar 如何禁止随着键盘上移动
            child: Column(
              //spaceBetween 两端对齐，也就是第一个子组件靠顶部，最后一个子组件靠底部，剩余组件在中间平均分散排列
              //MainAxisAlignment.spaceEvenly：每个子组件平均分散排列，也就是均分垂直空间。效果如下
              //控制子组件在主轴（垂直方向）的对齐方式
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //控制子组件在交叉轴（水平方向）的对齐方式
              crossAxisAlignment: CrossAxisAlignment.center,

              // children: [Text('1')],
              children: contentAareWidget(context, appState, themeProvider, webTextSize, orientation),
            ),
            //),
          ),
        ),
      ),
    );
  }

  List<Widget> contentAareWidget(
    BuildContext context,
    AppState appState,
    ThemeProvider themeProvider,
    WebTextSize webTextSize,
    Orientation? orientation,
  ) {
    return <Widget>[
      Expanded(
        flex: 1, //两个控件 有一个剩余空间。Expanded空间占用剩余空间,保证Expand最大化
        child: ((Utils.isAndroid() || Utils.isWindows() || Utils.isLinux()) && Provider.of<ThemeProvider>(context).isDarkTheme())
            ? indexStackModeOfContent(context, appState, themeProvider, webTextSize)
            : stackModeOfContent(context, appState, themeProvider, webTextSize),
      ),
      _webNavBottomBarBuilder(appState, themeProvider, webTextSize, orientation),
      //bottomNavBarBuilder(appState, orientation),
      //Expanded(child: bottomNavBarBuilder(appState)),
    ];
  }

  //android 上使用：主要是切换链接的时候遮罩，暗黑模式下会闪闪
  // IndexedStack indexStackModeOfContent(
  //   BuildContext context,
  //   AppState appState,
  // ) {
  //   return IndexedStack(
  //     index: progress < 1.0 ? 1 : 0,
  //     children: [
  //       buildWebView(context, appState),
  //       LinearProgressIndicator(value: progress, minHeight: 2),
  //     ],
  //   );
  // }

  //android/windows 上使用：主要是切换链接的时候遮罩，暗黑模式下会闪闪
  Widget indexStackModeOfContent(BuildContext context, AppState appState, ThemeProvider themeProvider, WebTextSize webTextSize) {
    bool s;
    if (Utils.isAndroi10Under()) {
      s =
          (((progress > themeProvider.webLoadDarkMaskMaxProgress) &&
          //(_webThemeReady == WebThemeSyncState.complete ||
          _webThemeReady == WebThemeSyncState.delayCompleted) //) ||
          // (_webThemeReady == WebThemeSyncState.delayCompleted)
          );
    } else {
      s =
          ((progress > 0.95) ||
          ((progress > themeProvider.webLoadDarkMaskMaxProgress) &&
              (_webThemeReady == WebThemeSyncState.complete || _webThemeReady == WebThemeSyncState.delayCompleted)) ||
          (_webThemeReady == WebThemeSyncState.delayCompleted));
    }

    // return Stack(
    //   children: <Widget>[
    //     IndexedStack(
    //       index: s ? 0 : 1,
    //       children: [
    //         buildWebView(context, appState, themeProvider, webTextSize),
    //         Container(color: const Color.fromARGB(6, 26, 25, 25)),
    //       ],
    //     ),
    //     // buildWebView(context, appState),
    //     progress < 1.0 ? LinearProgressIndicator(value: progress, minHeight: 2) : Container(height: 2),
    //     //LinearProgressIndicator(value: progress, minHeight: 2),
    //   ],
    // );
    return _stackContent(context, appState, themeProvider, webTextSize, themeProvider.isDarkTheme() && !s);
  }

  //ios ipad macos
  //使用IndexedStack 会在ios手势返回上一页面会有白色的空白页，体验不好
  Widget stackModeOfContent(BuildContext context, AppState appState, ThemeProvider themeProvider, WebTextSize webTextSize) {
    bool finished =
        ((progress > 0.9) ||
        ((progress > themeProvider.webLoadDarkMaskMaxProgress) &&
            (_webThemeReady == WebThemeSyncState.complete || _webThemeReady == WebThemeSyncState.delayCompleted)) ||
        (_webThemeReady == WebThemeSyncState.delayCompleted));
    return _stackContent(context, appState, themeProvider, webTextSize, themeProvider.isDarkTheme() && !finished);
  }

  Widget _stackContent(BuildContext context, AppState appState, ThemeProvider themeProvider, WebTextSize webTextSize, bool showMask) {
    List<Widget> children = [];
    // final darkColor = Color.fromARGB(255, 26, 25, 25);
    //final lightColor = Color.fromARGB(255, 255, 255, 255);

    final web = buildWebView(context, appState, themeProvider, webTextSize);
    //final mask = Container(color: Color.fromARGB(6, 26, 25, 25));
    final mask = Container(color: Color.fromARGB(240, 21, 21, 21));
    children.add(web);
    if (showMask) {
      children.add(mask);
      ZsLog.d('Web mask 显示');
    } else {
      // children.add(mask);
      ZsLog.d('Web mask 不显示');
    }
    children.add(progress < 1.0 ? LinearProgressIndicator(value: progress, minHeight: 2) : Container(height: 2));

    /// ios 26 弹出模态控件后 webview 不能点击
    if (Utils.isIOS26Late()) {
      children.add(
        Positioned.fill(
          child: PointerInterceptor(intercepting: !_isTopOfNavigationStack, debug: false, child: const SizedBox.expand()),
        ),
      );
    }
    return Stack(children: children);
  }

  Widget buildWebView(BuildContext context, AppState appState, ThemeProvider themeProvider, WebTextSize webTextSize) {
    //ZsLog.d('-----------------run buildWebView--------------');
    List<UserScript> usList = [themeProvider.sdkJsUserScript()];

    if (webViewHelper?.supportNotification == true) {
      usList.add(themeProvider.jsNotificationApiUserScript);
      usList.add(themeProvider.jsNotificationDbUserScript);
    }

    //fixed windows theme web scrollbar background color error
    UserScript? wsbus = themeProvider.windowsScrollBarUserScripter();
    if (wsbus != null) {
      usList.add(wsbus);
    }

    UserScript? textZoomScript = webTextSize.textZoomUserScript();
    if (textZoomScript != null) {
      usList.add(textZoomScript);
    }
    //notfi
    // UserScript(
    //   source: tp.sdkjs,
    //   injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
    //   forMainFrameOnly: true,
    // ),
    // UserScript(
    //   source: "var bar = 2;",
    //   injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
    //   forMainFrameOnly: true,
    // ),

    return InAppWebView(
      keepAlive: Utils.isLinux() ? null : keepAlive,
      //key: ValueKey('webview-0-0'),
      key: webViewKey,
      onRequestFocus: (controller) {
        //ZsLog.d('webview request focus');
      },
      // windowId: widget.webMode.windowId, //不管理请求
      webViewEnvironment: AppState.webViewEnvironment,
      initialUrlRequest: URLRequest(url: WebUri(widget.webMode.initUrl ?? WebConstants.kNullUrl)),
      initialUserScripts: UnmodifiableListView<UserScript>(usList),
      initialSettings: settings,
      findInteractionController: webViewHelper?.findController,
      contextMenu: contextMenu,
      pullToRefreshController: pullToRefreshController,
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        //会“急切”地声明手势所有权，避免父级滚动视图拦截点击。
        Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
      },

      // onConsoleMessage: (controller, consoleMessage) {
      //   ZsLog.d('onConsoleMessage: ${consoleMessage.message}');
      // },
      onWebViewCreated: (controller) async {
        controller.addJavaScriptHandler(
          handlerName: '__jszHandler__',
          callback: (List<dynamic> arguments) {
            // var args = [{'domReady': '1'}];
            // window.flutter_inappwebview.callHandler('__jszHandler__', ...args);
            // 文档准备好了
            //ZsLog.d('接受js __jszHandler__ 事件: $arguments');
            if (arguments.isNotEmpty) {
              var arg = arguments[0];
              if (arg is Map) {
                if (arg.containsKey('domReady')) {
                  var value = arg['domReady'];
                  if (value != null && (value is String)) {
                    // ZsLog.d('接受js __jszHandler__ 事件 domReady: $value');
                  }
                } else if (arg.containsKey('siteinfo')) {
                  var value = arg['siteinfo'];
                  if (value != null) {
                    if (value is Map) {
                      _handleWebSiteInfo(appState, value);
                    }
                    // ZsLog.d('接受js __jszHandler__ 事件 siteinfo: $value');
                  }
                } else if (arg.containsKey('promptmsg')) {
                  var value = arg['promptmsg'];
                  if (value != null && (value is Map)) {
                    _updateWebSitePromptMsg(appState, value);
                  }
                } else if (arg.containsKey('imageCount')) {
                  var value = arg['imageCount'];
                  if (value != null && (value is int) && (value >= 0)) {
                    webPageImageCount = value;
                  }
                } else if (arg.containsKey('theme')) {
                  var value = arg['theme'];
                  if (value != null && (value is String)) {
                    //  ZsLog.d('接受js __jszHandler__ 事件 theme: $value');
                    if (value == '0') {
                      int stm = themeProvider.isSystemDarkTheme ? 1 : 0;
                      int ctm = themeProvider.currentThemeModeCode();
                      int uatype = appState.isMobileUA() ? 1 : 2;
                      int imageMode = appState.webImgMode;
                      var param = [appState.autoImageGallery ? '1' : '0', '${appState.blackListApply}'];
                      // jsonEncode([appState.autoImageGallery ? '1' : '0']);
                      var rs = {'themeModel': ctm, 'uatype': uatype, 'imageMode': imageMode, 'sysThemeDarkMode': stm, 'param': param};
                      return rs;
                    } else if (value == '1') {
                      //添加了theme css
                      if (_webThemeReady == WebThemeSyncState.loading || _webThemeReady == WebThemeSyncState.start) {
                        _webThemeReady = WebThemeSyncState.complete;
                        _updateWebBlacklist();
                        //Future.delayed(Duration(milliseconds: 500), () {
                        _delayUpdateWebThemeReady(v: WebThemeSyncState.delayCompleted, isDelay: true, isComplete: true);
                        // if (_webThemeReady == WebThemeSyncState.complete) {
                        //   setState(() {
                        //     _webThemeReady = WebThemeSyncState.delayCompleted;
                        //   });
                        // }
                        //});
                      }
                    } else if (value == '2') {
                      //已经存在
                      if (_webThemeReady == WebThemeSyncState.loading || _webThemeReady == WebThemeSyncState.start) {
                        _webThemeReady = WebThemeSyncState.complete;
                        _updateWebBlacklist();
                        //Future.delayed(Duration(milliseconds: 500), () {
                        _delayUpdateWebThemeReady(v: WebThemeSyncState.delayCompleted, isDelay: true, isComplete: true);
                        // if (_webThemeReady == WebThemeSyncState.complete) {
                        //   setState(() {
                        //     _webThemeReady = WebThemeSyncState.delayCompleted;
                        //   });
                        // }
                        // });
                      }
                    } else if (value == '3') {
                      //theme css 移除
                    } else if (value == '4') {
                      //theme css 已经移除
                    } else if (value == '5') {
                      //theme css，非site的url 不需要设置
                      _delayUpdateWebThemeReady(v: WebThemeSyncState.delayCompleted, isComplete: false, isDelay: false);
                      //_webThemeReady = WebThemeSyncState.delayCompleted;
                    }
                  }
                } else if (arg.containsKey('tapFavor')) {
                  _webTapFavr(true);
                  var value = arg['tapFavor'];
                  if (value != null && (value is String)) {
                    //ZsLog.d(value == '1' ? '收藏成功' : '取消收藏成功');
                  }
                } else if (arg.containsKey('tapImage')) {
                  var value = arg['tapImage'];
                  if (value != null && (value is String)) {
                    // ZsLog.d('click image :$value');
                    if (appState.autoImageGallery) {
                      //现实图片画廊
                      showWebImageGallery(imgUrl: value);
                    }
                  }
                } else if (arg.containsKey('domInitVars')) {
                  var value = arg['domInitVars'];
                  var vsite = appState.webSite;

                  String? webUrl;
                  String? webhost;
                  String? webExName;
                  List<String> hosts = [];

                  int mb = appState.isMobileUA() ? 1 : 0;
                  String? discuzSiteUrl;
                  String? cssStr;
                  String? jsStr;
                  int isDz = 0;

                  if (value != null && (value is List) && value.length > 2) {
                    webUrl = value[0];
                    webhost = value[1];
                    webViewHelper?.webViewUserAgent = value[2];
                  }

                  if (webhost != null && webhost.isNotEmpty == true) {
                    if (vsite.isSite(webUrl) == true) {
                      discuzSiteUrl = vsite.url;
                      isDz = vsite.isDiscuz() ? 1 : 0;
                      if (isDz == 1) {
                        String? cssName = vsite.currentSameDomainSite?.cssExtensionName;
                        cssName ??= vsite.mainSite?.cssExtensionName;
                        if (cssName != null && cssName.length > 3 && !hosts.contains(cssName)) {
                          webExName = cssName;
                        }
                      }
                      webExName ??= vsite.cssExtensionName;
                    }
                  } else {
                    WebUri? wu = _getStopStartWebUri();
                    webhost = wu?.host;
                  }

                  if (webExName == null && webhost != null && webhost.isNotEmpty) {
                    webExName = webhost;
                  }

                  if (webExName != null && webExName.isNotEmpty) {
                    hosts.add(webExName);
                    var v = themeProvider.getHostExtensionFromCache(hosts, appState.isMobileUA(), jsOrCss: false);
                    if (v != null) {
                      cssStr = v;
                    }
                    var js = themeProvider.getHostExtensionFromCache(hosts, appState.isMobileUA(), jsOrCss: true);
                    if (js != null) {
                      jsStr = base64Encode(js.codeUnits);
                    }
                    ZsLog.d('Web load host:[$hosts],css:$cssStr; js: $js');
                  } else {
                    ZsLog.d('Web load host css and js is null');
                  }

                  return {
                    'host': webhost ?? '',
                    'url': discuzSiteUrl ?? '',
                    'discuz': isDz,
                    'mb': mb,
                    'css': cssStr ?? '',
                    'js': jsStr ?? '',
                  };
                }
              }
            }
            //return {'bar': 'bar_value', 'baz': 'baz_value'};
          },
        );
        // Future.sync(() async {
        await controller.setSettings(settings: settings);
        //执行js 将失败
        if (_webViewController != controller) {
          _webViewController = controller;
          webViewHelper?.initWebViewController(_webViewController);
        }
        if (Utils.isAndroid()) {
          controller.startSafeBrowsing();
        }
        widget.onStateUpdated.call();
        //});
      },
      onWindowFocus: (controller) {
        //ZsLog.d('Web  window focus');
        if (WebMorePopMenu.isShowedMenu) {
          Navigator.of(context).maybePop();
          WebMorePopMenu.isShowedMenu = false;
        }
        // _focusNode.requestFocus();
        // resumeAll();
        // _hitWebView();
      },
      onCreateWindow: (controller, createWindowAction) async {
        //macos 右键弹出新窗口菜单
        bool open = false;
        bool iswin = Utils.isWindows();
        String newUrl = createWindowAction.request.url.toString();
        ZsLog.d('Main Web create window:$newUrl');
        bool r = widget.supportMultipleWindows();
        // if (AppState.isWebSite(newUrl)) {}
        if (Utils.isValidHttpUrl(newUrl) && (createWindowAction.isRedirect == null || createWindowAction.isRedirect == false)) {
          if (r) {
            if (createWindowAction.isForMainFrame &&
                (createWindowAction.isRedirect == null) &&
                (createWindowAction.navigationType == null) &&
                (site.isSite(newUrl))) {
              //<a href="article-34829-1.html" class="tm01 cl" target="_blank">
              //<a href="forum.php?mod=attachment&amp;aid=MTE3MTk2OTR8YjBjZjZjOWNlMmRjZWNjNzRmNDUwYWI4YWQxZmEwMzl8MTc3NTUyMDAwMA%3D%3D&amp;nothumb=yes" target="_blank">下载附件</a>
              if (iswin) {
                //https://www.chiphell.com/forum.php?mod=attachment&aid=MTEwMDMyMjd8Y2M1ZmNiMmJmZTI5NDM1ODYxNjc0YmRmZjEyNjczN2Z8MTc3NTUyMDAwMA%3D%3D&nothumb=yes
                if (site.isImageAttachment(newUrl)) {
                  ZsLog.d('windows 点击附件链接 不开新窗口');
                } else if (createWindowAction.hasGesture == true) {
                  //点击/右键打开链接 和macos 保持一致
                  ZsLog.d('windows 点击/右键打开');
                  //createWindowAction.windowFeatures?.menuBarVisibility;
                } else {
                  open = true;
                  ZsLog.d('windows 右键打开 开新窗口');
                }
              } else {
                //linux 不开新窗口
                ZsLog.d('linux 不开新窗口');
              }
            } else if ((Utils.isMacOS() || iswin || Utils.isIPad()) &&
                (createWindowAction.isForMainFrame == false && createWindowAction.navigationType == NavigationType.LINK_ACTIVATED)) {
              //<a href="article-34829-1.html" class="tm01 cl" target="_blank">
              //macos/windows/ipad 不开新窗口，点击一个附件
              ZsLog.d('macos/windows 不开新窗口');
            } else if (Utils.isMacOS() &&
                (createWindowAction.isForMainFrame == false) &&
                (createWindowAction.navigationType == NavigationType.OTHER) &&
                (createWindowAction.targetFrame == null)) {
              //macos 右键打开 开新窗口
              ZsLog.d('macos 右键打开 开新窗口');
              open = true;
            } else {
              open = true;
            }
          } else if ((createWindowAction.isForMainFrame == false && createWindowAction.navigationType == NavigationType.OTHER)) {
            //右键打开
            open = true;
          }

          if (open) {
            webViewHelper?.innerBrowserOpen(context, newUrl, windowid: createWindowAction.windowId);
            //TODO:windows 6.2.0-beta2  bug（webview有几率失去响应）,在 shouldOverrideUrlLoading 拦截
            if (iswin) {
              userClickNewWindowTime = DateTime.now().millisecondsSinceEpoch;
              open = false;
            }
          }
          //widget.webMode.onCreateTabRequested(createWindowAction);
        }
        // widget.webMode.onCreateTabRequested(createWindowAction);
        //放回false 此逻辑可防止任何在其链接中使用target="_blank"的页面加载。
        //   // widget.supportMultipleWindows();
        return open;
      },
      onTitleChanged: (controller, title) {
        if (title != WebConstants.kNullUrl) {
          if (_webPageTitle != title) {
            _webPageTitle = title;
            if (Utils.isDesktopSystem) {
              WindowUtil.updateWindowTitle(title);
            }
          }
          widget.onStateUpdated.call();
        }
        ZsLog.d('Web window title:$title');
      },
      onPrintRequest: (controller, url, printJobController) async {
        // handle the print job
        return true;
      },
      // shouldInterceptAjaxRequest: (controller, ajaxRequest) {
      //   return ajaxRequest;
      // },
      // shouldInterceptRequest: (controller, ajaxRequest) {
      //   return ajaxRequest;
      // },
      // shouldInterceptFetchRequest: (controller, fetchRequest) {
      //   return fetchRequest;
      // },
      onCloseWindow: (controller) {
        ZsLog.d('Web window close');
        if (_isWindowClosed) {
          return;
        }
        willClose();
        widget.webMode.onCloseTabRequested();
      },

      onWebContentProcessDidTerminate: (controller) {
        // 处理内容进程终止的情况
        ZsLog.d('Web content process terminated,will reload');
        // 尝试重新加载页面或恢复操作
        _reloadWeb();
        //controller.reload();
      },

      onReceivedTouchIconUrl: (controller, url, precomposed) {
        ZsLog.d('Web received touch icon url: $url');
      },

      onContentLoading: (controller, url) {
        ZsLog.d('Web onContentLoading url: $url');
      },
      onDOMContentLoaded: (controller, url) {
        ZsLog.d('Web onDOMContentLoaded url: $url');
      },

      //正在加载HTTP响应的body内容，回调该方法，获取对应url地址
      onPageCommitVisible: (controller, url) {
        ZsLog.d('Web commit visible - $_webThemeReady -visiable[${_webThemeReady.index >= WebThemeSyncState.visiable.index}]- url: $url ');
        _updateWebAutoTheme(appState, themeProvider, url, false);
      },

      onNavigationResponse: (controller, navigationResponse) {
        ZsLog.d('Web navigationResponse url: ${navigationResponse.response?.url}');
        bool r =
            webViewHelper?.webViewOnNavigationResponse(navigationResponse, site, (String url) {
              webViewOpenUrl(url);
            }) ==
            true;
        return r ? NavigationResponseAction.ALLOW : NavigationResponseAction.CANCEL;
      },

      // onDownloadStarting: (controller, downloadStartRequest) async {
      //   ZsLog.d('Web start download url: $downloadStartRequest');

      //   if (await webViewHelper?.webViewHasHistory() == true) {
      //     //macos 右键 弹出菜单，显示open image in new window,
      //     //下载附件 <a href="forum.php?mod=attachment&amp;aid=MTE3MTE3OTN8Yjk3MTgyODFlZWFlMzViMTE2Mjg1NWE1NzYwNDczZmJ8MTc3NTAwMTYwMA%3D%3D&amp;nothumb=yes" target="_blank">下载附件</a>
      //     String? sg = downloadStartRequest.suggestedFilename;
      //     String? mmt = downloadStartRequest.mimeType;
      //     String url = downloadStartRequest.url.toString();
      //     String? fileExtension = mmt != null ? Utils.fileExtensionFromMimeType(mmt) : null;
      //     bool isimg = mmt != null ? Utils.isImageMimeType(mmt) : false;
      //     if (!isimg) {
      //       isimg = Utils.isImageExtension(fileExtension);
      //     }
      //     if (!isimg) {
      //       isimg = Utils.isImageExt(
      //         url,
      //         callFn: (ex) {
      //           fileExtension ??= ex;
      //         },
      //       );
      //     }
      //     if (!isimg) {
      //       isimg = Utils.isDiscuzContentImageUrl(url);
      //     }
      //     String? urlaid;
      //     if (!isimg) {
      //       urlaid = appState.webSite.imageAttachmentSuggestedFileName(url, onlyMode: true);
      //       if (urlaid != null) {
      //         isimg = true;
      //       }
      //     }
      //     if (isimg) {
      //       sg ??= appState.webSite.imageAttachmentSuggestedFileName(url, onlyMode: true);
      //       //如果是附件 可能下载不了，需要cookies
      //       // webViewHelper?.downloadWebFile(
      //       //   url,
      //       //   userAgent: downloadStartRequest.userAgent,
      //       //   sugName: sg ?? urlaid,
      //       //   sugExtension: fileExtension,
      //       //   autoSave: Utils.isMobile(),
      //       //   imageOrFiler: isimg,
      //       //   refererUrl: await _getAbleRefererWebUrl(),
      //       // );
      //       //windows linux 不会调用系统的下载功能
      //       // return Utils.isLinux() || Utils.isWindows()
      //       //     ? DownloadStartResponse(
      //       //         action: DownloadStartResponseAction.CANCEL,
      //       //         handled: true,
      //       //       )
      //       //     : null;
      //     } else {
      //       //handleWebOtherHostUrl(url);
      //     }
      //   }

      //   return DownloadStartResponse(action: DownloadStartResponseAction.CANCEL, handled: false);
      // },
      onLoadStart: (controller, url) {
        //执行js 将失败
        startUrl = url.toString();
        ZsLog.d('Web start load url:$url');
        isSecure = Utils.urlIsSecure(url!);
        _startLayzImageMode();
      },

      onProgressChanged: (controller, progs) {
        if ((progs >= 100) && themeProvider.isDarkTheme() && (Utils.isAndroidPad)) {
          //延时1秒
          // Future.delayed(Duration(milliseconds: 1500), () {
          _updateWebLoadingProgress(appState, themeProvider, controller, progs, isDelay: true);
          //});
        } else {
          if (Utils.isWindows() && _stopUrl.isNotEmpty && progs == 0) {
            //防止 另存为图片时候 显示黑色/白色进度遮罩
            return;
          }
          _updateWebLoadingProgress(appState, themeProvider, controller, progs, isDelay: false);
        }
      },
      onZoomScaleChanged: (controller, oldScale, newScale) {
        if (Utils.isWindows()) {
          //windows ctrl ++ /ctrl --
          webTextSize.pageZoom = newScale / webTextSize.sysTextZoom;
          settings.pageZoom = newScale;
        }
        //controller.getZoomScale();supportZoom
        ZsLog.d('Web onZoomScaleChanged:$oldScale to  $newScale');
      },
      onReceivedLoginRequest: (controller, loginRequest) {
        ZsLog.d('Web onReceivedLoginRequest:$loginRequest');
      },
      onFaviconChanged: (controller, faviconChangedRequest) {},
      // onReceivedIcon: (controller, icon) {
      //   ZsLog.d('Web onReceivedIcon:');
      // },
      shouldAllowDeprecatedTLS: (controller, challenge) {
        return ShouldAllowDeprecatedTLSAction.ALLOW;
      },
      // onRenderProcessResponsive:(controller, url) {

      // },
      onRenderProcessUnresponsive: (controller, url) async {
        //渲染过程无响应,windows 点击跳转链接，打开新窗口，此时源窗口失去响应
        // if (url != null) {
        //   _stopUrl = url.toString();
        // }
        //_webLoadSiteStop(appState, themeProvider, url);
        return WebViewRenderProcessAction.TERMINATE;
      },
      onProcessFailed: (controller, detail) {
        //onRenderProcessUnresponsive被调用，此回调很可能被调用
        if (controller != _webViewController) {
          ZsLog.e('error');
        }
        ZsLog.d('Web onProcessFailed:$detail');
        if (isLoadingSyn()) {
          controller.stopLoading();
        }
      },
      onAcceleratorKeyPressed: (controller, detail) {
        ZsLog.d('Web onAcceleratorKeyPressed:$detail');
      },
      onPermissionRequest: (controller, permissionRequest) async {
        ZsLog.d('Web onPermissionRequest');
        final resources = <PermissionResourceType>[];
        // only for iOS and macOS
        if (permissionRequest.resources.contains(PermissionResourceType.CAMERA_AND_MICROPHONE)) {
          final cameraStatus = await Permission.camera.request();
          final microphoneStatus = await Permission.microphone.request();
          if (!cameraStatus.isDenied && !microphoneStatus.isDenied) {
            resources.add(PermissionResourceType.CAMERA_AND_MICROPHONE);
          }
        } else if (permissionRequest.resources.contains(PermissionResourceType.CAMERA)) {
          final cameraStatus = await Permission.camera.request();
          if (!cameraStatus.isDenied) {
            resources.add(PermissionResourceType.CAMERA);
          }
        } else if (permissionRequest.resources.contains(PermissionResourceType.MICROPHONE)) {
          final microphoneStatus = await Permission.microphone.request();
          if (!microphoneStatus.isDenied) {
            resources.add(PermissionResourceType.MICROPHONE);
          }
        }
        return PermissionResponse(
          resources: resources,
          action: resources.isEmpty ? PermissionResponseAction.DENY : PermissionResponseAction.GRANT,
        );
        // return PermissionResponse(
        //   action: PermissionResponseAction.GRANT,
        //   resources: permissionRequest.resources,
        // );
      },
      //onLoadResource: (controller, resource) {
      //  ZsLog.i('onLoadResource:${resource.url}');

      //   widget.webViewModel.addLoadedResources(resource);
      //   if (isCurrentTab(currentWebViewModel)) {
      //     currentWebViewModel.updateWithValue(widget.webViewModel);
      //   }
      //},
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        ZsLog.d('Web should override :${navigationAction.toString()}');
        if (redirectCount == WebConstants.kUrlRedirectMax) {
          urlMaxLoadCheck();
        } else if (redirectCount > WebConstants.kUrlRedirectMax) {
          redirectCount = 0;
          return NavigationActionPolicy.CANCEL;
        }
        bool isForMainFrame = navigationAction.isForMainFrame;
        if (isForMainFrame &&
            (navigationAction.navigationType == NavigationType.BACK_FORWARD ||
                navigationAction.navigationType == NavigationType.RELOAD ||
                navigationAction.navigationType == NavigationType.FORM_RESUBMITTED ||
                navigationAction.navigationType == NavigationType.FORM_SUBMITTED)) {
          if (_lastWebError == null) {
            return NavigationActionPolicy.ALLOW;
          }
        }

        //https://www.chiphell.com/zorro_add_filter://jackspirate
        WebUri? uri = navigationAction.request.url;
        String? url = uri?.toString();

        if (uri != null) {
          if (uri.scheme == WebConstants.kCustomUrlSchemeAddFilter) {
            String blackUser = Uri.decodeFull(uri.host).trim();
            if (blackUser.isNotEmpty) {
              addBlacklist(blackUser);
            }
            return NavigationActionPolicy.CANCEL;
          } else if ((url != null) && url.contains(WebConstants.kCustomUrlSchemeHeaderAddFilter)) {
            String deurl = Uri.decodeFull(url);
            String blackUser = deurl.split(WebConstants.kCustomUrlSchemeHeaderAddFilter).last;
            if (blackUser.isNotEmpty) {
              addBlacklist(blackUser);
            }
            return NavigationActionPolicy.CANCEL;
          }
        }

        String? urlDecode = url?.toLowerCase();
        urlDecode = urlDecode != null ? Uri.decodeFull(urlDecode) : urlDecode;
        if (uri == null || url == null) {
          return NavigationActionPolicy.CANCEL;
        }

        // bool userReqOrClick = (isForMainFrame && navigationAction.navigationType == NavigationType.OTHER);
        // bool userClickActived = (isForMainFrame && navigationAction.navigationType == NavigationType.LINK_ACTIVATED);
        // bool userDownloadAttach = (isForMainFrame == false && navigationAction.navigationType == NavigationType.LINK_ACTIVATED);

        if (Utils.isApple() && (navigationAction.shouldPerformDownload ?? false)) {
          Toast.toastAtCenter(mounted ? context : null, Constants.kPopMesgImageDownloadedStart);
          webViewHelper?.downloadHttpFile(urlDecode ?? url, referUrl: _startUrl, orgHeader: navigationAction.request.headers, prompt: true);
          return (Utils.isIOS()) ? NavigationActionPolicy.DOWNLOAD : NavigationActionPolicy.CANCEL;
        }

        if (url.startsWith("about:blank") && !isForMainFrame) {
          ZsLog.d('blocking navigation (isMainFrame:$isForMainFrame) to $url');
          return NavigationActionPolicy.ALLOW;
        }

        if ((!url.startsWith('https://turing.captcha.gtimg.com')) &&
            (!url.startsWith('https://player.bilibili.com')) &&
            (!url.startsWith('https://www.bilibili.com/blackboard')) &&
            (!site.isSite(url))) {
          if (isForMainFrame) {
            if (!url.startsWith("about:blank")) {
              webViewHelper?.innerBrowserOpen(mounted ? context : null, url, newWindow: true);
            }
          } else if (_webViewController != null) {
            bool isloading = isLoadingSyn() == true;
            if (!isloading && Utils.isValidHttpUrl(url)) {
              webViewHelper?.innerBrowserOpen(mounted ? context : null, url, newWindow: true);
            }
          } else {
            handleWebOtherHostUrl(url);
          }
          ZsLog.d('blocking navigation (isMainFrame:$isForMainFrame) to $url');
          return NavigationActionPolicy.CANCEL;
        }

        if (!Utils.allowBrowserSchemes.contains(uri.scheme)) {
          // if (await canLaunchUrl(uri)) {
          launchUrl(uri);
          return NavigationActionPolicy.CANCEL;
          //}
        }

        int diff = DateTime.now().millisecondsSinceEpoch - userClickNewWindowTime;
        if (diff < (Utils.isWindows() ? 500 : 200)) {
          //新窗口打开
          userClickNewWindowTime = 0;
          if (Utils.isWindows() && (WebConstants.webCore().code == 0)) {
            ZsLog.d('拦截windows 打开窗口后，当前webview 不继续加载');
          } else {
            webViewHelper?.innerBrowserOpen(mounted ? context : null, url, newWindow: true);
          }
          return NavigationActionPolicy.CANCEL;
        }

        // if (isForMainFrame && Utils.isMacOS() && (urlDecode != null) && (userReqOrClick || userClickActived || userDownloadAttach)) {
        //   if ((await webViewHelper?.webViewHasHistory() == true)) {
        //     if (appState.webSite.isImageAttachment(urlDecode, decoded: true)) {
        //       webViewHelper?.downloadHttpFile(
        //         urlDecode,
        //         referUrl: _startUrl,
        //         orgHeader: navigationAction.request.headers,
        //         // isImageFile: true,
        //         prompt: true,
        //       );
        //       return NavigationActionPolicy.CANCEL;
        //     } else if (appState.webSite.isContentImageUrl(urlDecode, decoded: true)) {
        //       webViewHelper?.downloadWebFile(
        //         urlDecode,
        //         autoSave: false,
        //         // refererUrl: _startUrl,
        //         // orgHeader: navigationAction.request.headers,
        //         // enableHeader: true,
        //       );
        //       return NavigationActionPolicy.CANCEL;
        //     }
        //   }
        // }
        return NavigationActionPolicy.ALLOW;
      },

      onSaveAsUIShowing: (controller, request) async {
        //用户右键图片另存为-》shouldOverrideUrlLoading-onProgressChanged->onLoadStart->onSaveAsUIShowing->
        //onSaveFileSecurityCheckStarting-》onDownloadStarting
        //SaveAsUIShowingResponse
        ZsLog.i('Web onSaveAsUIShowing $request');
        return SaveAsUIShowingResponse(
          allowReplace: request.allowReplace,
          cancel: request.cancel,
          kind: request.kind,
          suppressDefaultDialog: request.suppressDefaultDialog,
          saveAsFilePath: request.saveAsFilePath,
        );
      },
      onSaveFileSecurityCheckStarting: (controller, request) async {
        //request 用户是否保持下载，文件扩展名，路径等信息。
        //onSaveFileSecurityCheckStarting" using {cancelSave: false, documentOriginUri: https://static.chiphell.com/forum/202604/07/093811paacyucs777oogaa.jpg, fileExtension: .jpg, filePath: C:\Users\Zorro\Downloads\093811paacyucs777oogaa (2).jpg, suppressDefaultPolicy: false}
        //SaveFileSecurityCheckStartingResponse,确认完成，则开始下载
        ZsLog.i('Web onSaveFileSecurityCheckStarting $request');
        _updateWebLoadingProgress(appState, themeProvider, controller, 100, forceStrop: true, isDelay: false);
        stopLoading();
        return SaveFileSecurityCheckStartingResponse(cancelSave: request.cancelSave, suppressDefaultPolicy: request.suppressDefaultPolicy);
      },

      onScreenCaptureStarting: (controller, request) async {
        //ScreenCaptureStartingResponse
        ZsLog.i('Web onScreenCaptureStarting $request');
        return ScreenCaptureStartingResponse();
      },

      onLoadStop: (controller, url) async {
        ZsLog.i('Web onLoadStop url $url');
        pullToRefreshController?.endRefreshing();
        stopUrl = url.toString();
        Future(() async {
          var sslCertificateFuture = controller.getCertificate();
          var sslCertificate = await sslCertificateFuture;
          if (sslCertificate == null && !Utils.isLocalizedContent(Uri.parse(url.toString()))) {
            isSecure = false;
          }
          await _webLoadSiteStop(appState, themeProvider, url);
          final favicons = await _webViewController?.getFavicons();
          if (favicons != null && favicons.isNotEmpty) {
            for (final favicon in favicons) {
              if (_favicon == null) {
                _favicon = favicon;
              } else if (favicon.width != null && (favicon.width ?? 0) > (_favicon?.width ?? 0)) {
                _favicon = favicon;
              }
            }
          }
          //不处理截屏
          // updateScreenshot();
          widget.onStateUpdated.call();
          await webViewHelper?.webRequestStop(
            url,
            (_webThemeReady == WebThemeSyncState.complete || _webThemeReady == WebThemeSyncState.delayCompleted),
          );
        });
      },
      // onReceivedClientCertRequest: (controller, challenge) {
      //   //
      //   ClientCertResponse? r;
      //   return r;
      // },
      onReceivedServerTrustAuthRequest: (controller, challenge) async {
        var sslError = challenge.protectionSpace.sslError;
        if (sslError != null && (sslError.code != null)) {
          //https 证书不信任
          if ((Utils.isIOS() || Utils.isMacOS() || Utils.isAndroid()) && sslError.code == SslErrorType.UNSPECIFIED) {
            return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
          }
          isSecure = false; //cliff.imwork.net
          var item = await appState.getChallengeHost(challenge.protectionSpace.host, used: true);
          await item.userTrust(true);
          if (site.isChallengeHost(challenge.protectionSpace.host) == true) {
            //TODO:如果网站证书换了，有可能出错。这里放行
            return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
          }
          return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED); // CANCEL);
        }
        return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
      },

      onReceivedError: (controller, request, error) async {
        ZsLog.e('Web page resource ismain[${request.isForMainFrame}] error:', error: error);

        var isForMainFrame = request.isForMainFrame ?? false;
        if (!isForMainFrame) {
          return;
        }
        pullToRefreshController?.endRefreshing();
        if ((Utils.isIOS() || Utils.isDesktopSystem) && error.type == WebResourceErrorType.CANCELLED) {
          // NSURLErrorDomain
          return;
        }
        if (Utils.isWindows() && error.type == WebResourceErrorType.CONNECTION_ABORTED) {
          // CONNECTION_ABORTED
          return;
        }
        //(Utils.isMacOS() || Utils.isIPad()) &&
        if (error.type == WebResourceErrorType.UNKNOWN) {
          //WebResourceError{description: domain=WebKitErrorDomain, code=102, Frame load interrupted, type: UNKNOWN}
          if (request.isForMainFrame == true) {
            stopLoading();
            _updateWebLoadingProgress(appState, themeProvider, controller, 100, forceStrop: true, isDelay: true);
          }
          return;
        }

        //CANNOT_CONNECT_TO_HOST linux WPEWebKit 第一次加载 内部网络判断异常
        if (Utils.isLinux() && (error.type == WebResourceErrorType.CANNOT_CONNECT_TO_HOST) && (loadCount < 2)) {
          //description: WebKit encountered an internal error, type: CANNOT_CONNECT_TO_HOST
          return;
        }
        _lastWebError = error;
        if (error.type == WebResourceErrorType.NOT_CONNECTED_TO_INTERNET) {}
        var errorUrl = request.url;
        Future.microtask(() async {
          _webViewController?.loadData(
            data: await themeProvider.getWebErrorPage(errorUrl.toString(), error.description),
            baseUrl: errorUrl,
            historyUrl: errorUrl,
          );
        });
        //               """
        // <!DOCTYPE html>
        // <html lang="en">
        // <head>
        //     <meta charset="UTF-8">
        //     <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
        //     <meta http-equiv="X-UA-Compatible" content="ie=edge">
        //     <style>
        //     ${await InAppWebViewController.tRexRunnerCss}
        //     </style>
        //     <style>
        //     .interstitial-wrapper {
        //         box-sizing: border-box;
        //         font-size: 1em;
        //         line-height: 1.6em;
        //         margin: 0 auto 0;
        //         max-width: 600px;
        //         width: 100%;
        //     }
        //     </style>
        // </head>
        // <body>
        //     ${await InAppWebViewController.tRexRunnerHtml}
        //     <div class="interstitial-wrapper">
        //       <h1>Website not available</h1>
        //       <p>Could not load web pages at <strong>$errorUrl</strong> because:</p>
        //       <p>${error.description}</p>
        //     </div>
        // </body>
        //     """,
        // if (error.type == WebResourceErrorType.BAD_URL) {
        // } else if (error.type == WebResourceErrorType.TIMEOUT) {
        // } else if (error.type == WebResourceErrorType.HOST_LOOKUP) {
        //   //404
        // } else {}
      },

      onReceivedHttpError: (controller, request, errorResponse) async {
        ZsLog.d('Web onReceivedHttpError: $request; -- errorResponse:$errorResponse');
        //当服务器的负载超过其处理能力时，会拒绝新的连接请求，从而导致503错误。
        webViewHelper?.handleWebHttpError(request.isForMainFrame, errorResponse.statusCode);
      },

      onUpdateVisitedHistory: (controller, url, isReload) async {
        //页面内容展示
        ZsLog.d('Web onUpdateVisitedHistory isReload: $isReload ;url:$url');
        _updateHistoryUrl(url.toString());
        Future.microtask(() async {
          String? t = await controller.getTitle();
          if (t != WebConstants.kNullUrl) {
            _webPageTitle = t;
          }
        });
        _updateWebAutoTheme(appState, themeProvider, url, false);
        _updateWebImageInfos(appState, themeProvider, url);
      },

      onReceivedHttpAuthRequest: (controller, challenge) async {
        HttpAuthResponse? r;
        if (mounted) {
          _isPopMenu = true;
          await showDialog(
            context: context,
            builder: (ctx) {
              return WebViewHttpAuthDialog(
                challenge: challenge,
                onCall: (response) {
                  r = response;
                },
              );
            },
          ).then((onValue) {
            ZsLog.d('showDialog is close');
            _isPopMenu = false;
          });
        } else {
          ZsLog.d('onReceivedHttpAuthRequest mounted is false');
        }
        //  var action = await createHttpAuthDialog(challenge);
        return r ??
            HttpAuthResponse(
              username: Constants.kStrNull,
              password: Constants.kStrNull,
              action: HttpAuthResponseAction.CANCEL,
              permanentPersistence: true,
            );
      },

      onLongPressHitTestResult: (controller, hitTestResult) {
        //长按支持类型
        if (Utils.isMobile() == false || !LongPressAlertDialog.hitTestResultSupported.contains(hitTestResult.type)) {
          return;
        }
        if (_isPopMenu) {
          ZsLog.d('showDialog is pushed,onLongPressHitTestResult');
          return;
        }
        Future.microtask(() async {
          //String? url = _getStopStartWebUri()?.toString();
          String? url = await _getWebCurrentUrl();
          bool isSite = appState.webSite.isSite(url);
          if ((url != null) &&
              isSite &&
              (appState.webSite.isThreadUrl(url, onlyMode: true) ||
                  appState.webSite.isArticleUrl(url, onlyMode: true) ||
                  appState.webSite.isHomeUrl(url, onlyMode: true) ||
                  appState.webSite.isForumUrl(url, onlyMode: true) ||
                  appState.webSite.isAreaUrl(url, onlyMode: true))) {
            var requestFocusNodeHrefResult = await controller.requestFocusNodeHref();
            var requestImageHrefResult = await controller.requestImageRef();
            if (mounted && (requestFocusNodeHrefResult != null || requestImageHrefResult != null)) {
              _isPopMenu = true;
              showDialog(
                // ignore: use_build_context_synchronously
                context: context,
                builder: (ctx) {
                  return LongPressAlertDialog(
                    hitTestResult: hitTestResult,
                    requestFocusNodeHrefResult: requestFocusNodeHrefResult,
                    requestImageRefResult: requestImageHrefResult,
                    site: site,
                    callback: (
                      desc: '',
                      onCall: (String result, int type) async {
                        if (type == 0) {
                          webViewHelper?.downloadWebFile(result, refererUrl: url);
                        } else if (type == 1) {
                          //open linker
                          Future.delayed(Duration(milliseconds: 1000), () {
                            webViewHelper?.innerBrowserOpen(mounted ? context : null, url, newWindow: true);
                          });
                        } else if (type == 2) {
                          //open linker
                          Future.delayed(Duration(milliseconds: 500), () {
                            webViewHelper?.systemBrowserOpenUrl(url);
                          });
                        } else if (type == 3) {
                          //增加或者去掉黑名单
                          addOrDelBlacklist(result, await BlackList.isExistBlacklist(result));
                        }
                      },
                    ),
                  );
                },
              ).then((onValue) {
                ZsLog.d('showDialog is close');
                _isPopMenu = false;
              });
            } else {
              ZsLog.d('long press focusnode href is null');
            }
          }
        });
      },
      onNotificationReceived: (controller, request) async {
        ///TODO: 有待测试
        //NotificationReceivedResponse
        ZsLog.i('Web onNotificationReceived $request');
        // final notification = request.notificationController?.notification;
        // final senderOrigin = request.senderOrigin;
        // debugPrint('=== onNotificationReceived ===');
        // debugPrint('Sender Origin: $senderOrigin');
        // debugPrint(
        //     'Notification ID: ${request.notificationController?.id}');
        // debugPrint('Title: ${notification?.title}');
        // debugPrint('Body: ${notification?.body}');
        // debugPrint('Tag: ${notification?.tag}');
        // debugPrint('Icon URI: ${notification?.iconUri}');
        // debugPrint('Badge URI: ${notification?.badgeUri}');
        // debugPrint(
        //     'Body Image URI: ${notification?.bodyImageUri}');
        // debugPrint('Language: ${notification?.language}');
        // debugPrint('Direction: ${notification?.direction}');
        // debugPrint('Is Silent: ${notification?.isSilent}');
        // debugPrint(
        //     'Requires Interaction: ${notification?.requiresInteraction}');
        // debugPrint(
        //     'Should Renotify: ${notification?.shouldRenotify}');
        // debugPrint('Timestamp: ${notification?.timestamp}');
        // debugPrint(
        //     'Vibration Pattern: ${notification?.vibrationPattern}');
        // debugPrint('==============================');
        // if(notification!=null){
        //   webViewHelper?.onShowNotification(notification);
        // }

        // setState(() {
        //   notificationStatus = 'Received: ${notification?.title ?? "Unknown"}';
        //   activeNotificationController = request.notificationController as WindowsWebNotificationController?;
        // });

        // // Set up the onClose handler
        // request.notificationController?.onClose = () async {
        //   debugPrint('Notification close requested from web code');
        //   setState(() {
        //     notificationStatus = 'Notification closed by web code';
        //     activeNotificationController = null;
        //   });
        // };
        return NotificationReceivedResponse(handled: true);
      },

      // shouldInterceptAjaxRequest: (controller, ajaxRequest) async {
      //   //if (ajaxRequest.data) {}
      //   ZsLog.i('ajax request:${ajaxRequest.url}');
      //   var uri = ajaxRequest.url;
      //   if (ajaxRequest.isAsync == true && ajaxRequest.method == 'POST' && uri != null) {
      //     //https://www.chiphell.com/misc.php?mod=swfupload&operation=upload&type=image&inajax=yes&infloat=yes&simple=2
      //     // "content-type" -> "multipart/form-data; boundary=------multipartformboundary1780014535335"
      //     var query = uri.query;
      //     if (uri.path == 'misc.php' && (query.contains('mod=swfupload') || query.contains('type=image'))) {
      //       var header = ajaxRequest.headers?.getHeaders();
      //       if (header != null && header.containsKey("content-type")) {
      //         var ct = header["content-type"];
      //         if (ct is String && ct.startsWith('multipart/form-data; boundary=------multipartformboundary')) {
      //           if (ajaxRequest.data != null && (ajaxRequest.data is List<dynamic>)) {
      //             var buffer = ajaxRequest.data as List<dynamic>;
      //             var vb = UtilList.dyListToUint8List(buffer);
      //             var str = Utils.stringFromUint8List(vb);

      //             var tmp = Utils.dirAppand(await Utils.getAppTempDirectory(), 'vvv.jpg');

      //             var tmp1 = Utils.dirAppand(await Utils.getAppTempDirectory(), 'vvv11.txt');

      //             Utils.writeUint8ListToFile(vb, tmp);
      //             Utils.writeStringToFile(str, tmp1);

      //             ZsLog.i('ajax request content-type:$ct');
      //           }
      //         }
      //       }
      //     }
      //   }
      //   return ajaxRequest;
      // },
    );
  }

  // Future<HttpAuthResponseAction> createHttpAuthDialog(
  //   URLAuthenticationChallenge challenge,
  // ) async {
  //   HttpAuthResponseAction action = HttpAuthResponseAction.CANCEL;
  //   await showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text("Login"),
  //         content: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           mainAxisSize: MainAxisSize.min,
  //           children: <Widget>[
  //             Text(challenge.protectionSpace.host),
  //             TextField(
  //               decoration: const InputDecoration(labelText: "Username"),
  //               controller: _httpAuthUsernameController,
  //             ),
  //             TextField(
  //               decoration: const InputDecoration(labelText: "Password"),
  //               controller: _httpAuthPasswordController,
  //               obscureText: true,
  //             ),
  //           ],
  //         ),
  //         actions: <Widget>[
  //           ElevatedButton(
  //             child: const Text("Cancel"),
  //             onPressed: () {
  //               action = HttpAuthResponseAction.CANCEL;
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           ElevatedButton(
  //             child: const Text("Ok"),
  //             onPressed: () {
  //               action = HttpAuthResponseAction.PROCEED;
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  //   return action;
  // }
  bool isLoadingSyn() {
    return progress < 1.0 ||
        (_webThemeReady != WebThemeSyncState.delayCompleted &&
            _webThemeReady != WebThemeSyncState.complete &&
            _webThemeReady != WebThemeSyncState.none);
  }

  Future<bool> isLoading() async {
    return await webViewHelper?.isLoading() == true;
  }

  Future<bool> canGoBack() async {
    return await webViewHelper?.canGoBack() == true;
  }

  Future<bool> goBack() async {
    return await webViewHelper?.goBack() == true;
  }

  Future<bool> canGoForward() async {
    return await webViewHelper?.canGoForward() == true;
  }

  Future<bool> goForward() async {
    return await webViewHelper?.goForward() == true;
  }

  Future<bool> stopLoading() async {
    return await webViewHelper?.stopLoading() == true;
  }

  Future<bool> _handlePopBackGesture(bool forceForum) async {
    return await webViewHelper?.handlePopBackGesture(forceForum) == true;
  }

  Future<bool> _handleBackMenu(bool forceForum) async {
    return await webViewHelper?.handleBackMenu(forceForum) == true;
  }

  /// bottom nav bar
  Widget _webNavBottomBarBuilder(AppState appState, ThemeProvider themeProvider, WebTextSize webTextSize, Orientation? orientation) {
    return WebNavigationBottomBar(
      isPrompt: _webPageImageCount > 0,
      orientation: orientation,
      eventCallBack: (WebNavBottomBarEvent event, {RelativeRect? position}) async {
        if (event == WebNavBottomBarEvent.backAllParent) {
          _handleBackMenu(true);
        } else if (event == WebNavBottomBarEvent.home) {
          webViewHelper?.goSiteHome();
        } else if (event == WebNavBottomBarEvent.back) {
          _handleBackMenu(false);
        } else if (event == WebNavBottomBarEvent.backParent) {
          _handlePopBackGesture(true);
        } else if (event == WebNavBottomBarEvent.stop) {
          stopLoading();
        } else if (event == WebNavBottomBarEvent.refresh) {
          await _reloadWeb();
        } else if (event == WebNavBottomBarEvent.forward) {
          goForward();
        } else if (event == WebNavBottomBarEvent.more) {
          _handleBottomBarMoreAction(appState, themeProvider, position);
        }
      },
    );
  }

  /// pop menu
  void _handleBottomBarMoreAction(AppState appState, ThemeProvider themeProvider, RelativeRect? rect) async {
    String? url = await getValidWebUrlString(); // await _getWebCurrentUrl();
    bool hasUrl = url != null;

    bool? addFilter;
    String? username;
    if (site.isAuthorUrl(url)) {
      username = site.authorNameFromTitle(_webPageTitle);
      if (username != null && username.isNotEmpty && (appState.webSite.user.name != username) && (appState.webSite.user.url != url)) {
        addFilter = await BlackList.isExistBlacklist(username);
        // addFilter = isAdded;
        //mbuttonItems.add(_mbiFilterUser(name, isAdded));
      }
    }

    bool isLogin = appState.webSite.user.isLogin();
    bool isGoLogin = false;
    if (url == null || !site.isLoginUrl(url)) {
      if (!isLogin) {
        isGoLogin = true;
      }
    }

    WebMorePopMenu.showWebPagePopMenu(
      context.mounted ? context : null,
      false,
      position: rect,
      addFilter: addFilter,
      haveUserHome: isLogin,
      isGoLogin: isGoLogin,
      haveCopy: hasUrl,
      haveimageGallery: (_webPageImageCount > 0),
      haveArea: true,
      haveInBrowserOpen: hasUrl,
      haveOutBrowserOpen: hasUrl,
      isMobileUA: appState.isMobileUA(),
      haveSiteManager: true,
      selectedFn: (event) async {
        if (event == MenuButtonItemEvent.login) {
          webViewOpenUrl(site.loginUrl(appState.isMobileUA()));
        } else if (event == MenuButtonItemEvent.userHome) {
          if (appState.webSite.user.isLogin()) {
            webViewOpenUrl(appState.webSite.user.url);
          }
        } else if (event == MenuButtonItemEvent.home) {
          webViewHelper?.goSiteHome();
        } else if (event == MenuButtonItemEvent.area) {
          webViewOpenUrl(site.areaUrl(appState.isMobileUA()));
        } else if (event == MenuButtonItemEvent.copy) {
          Uiutils.simpleSelectOptionsDialog(context, [
            (
              label: Constants.kCopyTitle,
              onPressed: () {
                Uiutils.copyContentToClipboard(context, _webPageTitle ?? '');
              },
            ),
            (
              label: Constants.kCopyLinker,
              onPressed: () async {
                var text = await getValidWebUrlString() ?? '';
                if (mounted) {
                  Uiutils.copyContentToClipboard(context, text);
                }
              },
            ),
            (label: Constants.kTipCancel, onPressed: () {}),
          ]);
        } else if (event == MenuButtonItemEvent.inBrowser) {
          if (url != null) {
            webViewHelper?.innerBrowserOpen(mounted ? context : null, url, newWindow: Utils.isDesktopSystem);
          }
        } else if (event == MenuButtonItemEvent.outBrowser) {
          openCurrentUrlOtherBrowser();
        } else if (event == MenuButtonItemEvent.userAgent) {
          toggleUA();
        } else if (event == MenuButtonItemEvent.addFilter) {
          addOrDelBlacklist(username, true);
        } else if (event == MenuButtonItemEvent.delFilter) {
          addOrDelBlacklist(username, false);
        } else if (event == MenuButtonItemEvent.imgGallery) {
          Future.delayed(Duration(milliseconds: 500), () {
            // 延迟执行的代码
            showWebImageGallery();
          });
        } else if (event == MenuButtonItemEvent.more) {
          if (webViewHelper != null) {
            WebViewMoreOptions.menuMoreOptions(context, webViewHelper!);
          }
        } else if (event == MenuButtonItemEvent.setting) {
          // NavigatorUtils.push(
          //   context,
          //   (ctx) {
          //     return SettingPage();
          //   },
          //   (val) {
          //     if (val != null && (val is Favor)) {
          //       setState(() {});
          //     }
          //   },
          // );

          // var result = await Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => SettingPage(), // 非全屏页面
          //     fullscreenDialog: false, // 这里设置为false表示非全屏弹出，但实际效果取决于页面设计（例如使用Scaffold的resizeToAvoidBottomInset等）
          //   ),
          // );
          //从下往上推出一个sheet页面
          //var result = await Uiutils.pushModalBottomSheet(context, child: SettingPage());

          // var result = await context.pushNamed('settings');
          // if (result != null && (result is Favor)) {
          //   setState(() {});
          // }
          context.pushNamed('settings');
        } else if (event == MenuButtonItemEvent.blackList) {
          //检查配置
          // debugPrint(GoRouter.of(context).configuration.toString());
          //go方式推出，返回用 context.go('/');
          //context.pushNamed('blacklist');
          var r = await context.pushNamed('blacklist');
          //手势返回 r为null
          if ((r != null && (r as bool)) || BlackList.userBlackListChanged) {
            await _updateWebBlacklist();
            BlackList.userBlackListChanged = false;
          }
          ZsLog.d('blacklist page pop state:$r');
        } else if (event == MenuButtonItemEvent.history) {
          var result = await context.pushNamed('favorites');
          if (result != null && (result is Favor)) {
            //open favor link
            Favor favor = result;
            if (favor.url != null) {
              String? url = favor.url;
              webViewOpenUrl(url);
            }
          }
        } else if (event == MenuButtonItemEvent.siteManger) {
          //检查配置
          //debugPrint(GoRouter.of(context).configuration.toString());
          //go方式推出，返回用 context.go('/');
          //context.pushNamed('sites');
          var r = await context.pushNamed('sites');
          //手势返回 r为null
          if ((r != null && (r is Map))) {
            int v = UtilMap.safeIntForKey(r, 'event');
            String? param = UtilMap.safeStringForKey(r, 'param');
            if (v == 1) {
              //重新加载新的main web site
              _checkMainSiteChanged();
            } else if (param != null && param.isNotEmpty) {
              if (v == 2) {
                webViewHelper?.innerBrowserOpen(mounted ? context : null, param);
              } else if (v == 3) {
                webViewHelper?.systemBrowserOpenUrl(param);
              }
            }
          }
          ZsLog.d('site manager page pop state:$r');
        }
      },
    );
  }
}
