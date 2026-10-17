import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:chiphell/common/constants.dart';
import 'package:chiphell/data/black_list.dart';
import 'package:chiphell/long_press_alert_dialog.dart';
import 'package:chiphell/modals/Adblock.dart';
import 'package:chiphell/modals/AppState.dart';
import 'package:chiphell/data/Favorites.dart';
import 'package:chiphell/modals/WebTextSize.dart';
import 'package:chiphell/modals/zj_Image_cacheManager.dart';
import 'package:chiphell/sites/main_site.dart';
import 'package:chiphell/sites/web_site.dart';
import 'package:chiphell/theme/theme_provider.dart';
import 'package:chiphell/net/net_state.dart';
import 'package:chiphell/utils/Toast.dart';
import 'package:chiphell/utils/ui_utils.dart';
import 'package:chiphell/utils/utils.dart';
import 'package:chiphell/web/web_view_helper.dart';
import 'package:chiphell/web/web_view_http_auth_dialog.dart';
import 'package:chiphell/web/web_view_more_options.dart';
import 'package:chiphell/web/web_constants.dart';
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
import '../modals/web_user.dart';
import '../overlay_web_image_gallery.dart';

import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../sites/site_constants.dart';
import '../sites/util_site.dart';
import '../utils/util_map.dart';
import '../utils/zs_log.dart';
import 'web_more_pop_menu.dart';
import 'web_navigation_bottom_bar.dart';
import 'web_view_find_bar.dart';

//BrowserWebTabPage _TabWebPageState

class BrowserWebTabPage extends StatefulWidget {
  final WebMode webMode;
  const BrowserWebTabPage({required GlobalKey key, required this.webMode}) : super(key: key);

  @override
  State<BrowserWebTabPage> createState() => TabWebPageState();

  bool supportMultipleWindows() {
    return webMode.multipleWindows;
  }

  TabWebPageState? getState() {
    return (key as GlobalKey).currentState as TabWebPageState?;
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
    return state?.isSecure;
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

  Future<void> willClose() async {
    final state = getState();
    await state?.willClose();
  }

  Future<void> openUrl(String url) async {
    final state = getState();
    await state?.webViewOpenUrl(url);
  }

  WebViewHelper? help() {
    final state = getState();
    return state?.webViewHelper;
  }
}

class TabWebPageState extends State<BrowserWebTabPage> with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? _webViewController;
  WebViewHelper? webViewHelper;

  final keepAlive = InAppWebViewKeepAlive();

  InAppWebViewSettings settings = InAppWebViewSettings(
    useShouldOverrideUrlLoading: true,
    // useShouldInterceptAjaxRequest: true,  //打开这个，可能会中断内容加载，附件上传等
    // useShouldInterceptFetchRequest: true,
    //useShouldInterceptRequest: true,
    //useOnLoadResource: true,  //探测页面内容加载。比如图片等，暂时没有使用
    javaScriptEnabled: true,
    isInspectable: kDebugMode,
    mediaPlaybackRequiresUserGesture: true, // 播放媒体不需要用户交互,false打开页面自动播放
    allowsInlineMediaPlayback: true, // 允许内联媒体播放
    iframeAllow: "camera; microphone",
    iframeAllowFullscreen: true,
    supportMultipleWindows: false,
    //打开的话。android supportMultipleWindows 也应该打开
    javaScriptCanOpenWindowsAutomatically: false,
    allowsLinkPreview: false,
    supportZoom: true,
    //macos11 效果好. ios14 效果不好，ipad效果不好
    pageZoom: 1.0,

    //android, iphone 适配 document.body.style.textSizeAdjust
    textZoom: 100,
    //allowingReadAccessTo: WebUri('file://$webArchiveDir/'),
    // underPageBackgroundColor: Colors.red,
    //ios 上设置为true，在手势后一页的时候上面页面可以透视下面，视觉效果不佳
    // transparentBackground: true,
    useOnDownloadStart: true,
    // underPageBackgroundColor: Colors.red,
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

    //android 有效 在这种模式下，WebView将允许安全的源从任何其他源加载内容，即使该源不安全。
    //这是WebView最不安全的操作模式，在可能的情况下，应用程序不应设置此模式。
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
    //Android
    //useShouldInterceptRequest:true,
    useOnNavigationResponse: true,

    allowFileAccessFromFileURLs: true,

    shouldPrintBackgrounds: true,

    isFindInteractionEnabled: !Utils.isWindows(),
    //夜晚模式的时候ios 第一次会白色
    transparentBackground: Utils.isApple(),
    //corsAllowlist:true,
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
  DateTime prePopDateTime = DateTime.now();

  int _webPageImageCount = 0;
  bool get hasWebPageImage => _webPageImageCount > 0;
  int _webPageImageLookIndex = 0;
  ImageGalleryController galleryController = ImageGalleryController(initialPage: 3);
  StreamController<Widget>? _overlayController;
  bool get _isTopOfNavigationStack => ModalRoute.of(context)?.isCurrent ?? false;
  bool _updateUserScript = false;
  WebResourceError? _lastWebError;
  Favicon? _favicon;

  //自动加载site的js
  bool _isSiteMode = false;
  bool get isSiteMode => _isSiteMode;
  final int _redirectMax = WebConstants.kUrlRedirectMax;
  int _webImgMode = 0;
  bool _webAutoImageGallery = false;
  int _webBlacklistMode = 0;

  final bool _enableLoadsImagesAutomatically = Utils.isAndroid() || Utils.isLinux();

  int loadCount = 0;
  //上一次用户右键点击新窗口
  int userClickNewWindowTime = 0;

  bool isPause = false;
  //切换页面，如何保持当前页的状态 with AutomaticKeepAliveClientMixin
  @override
  bool get wantKeepAlive => !_isWindowClosed;
  WebSite? beforeSite;
  WebSite? site;

  AppState? _appStateNoListen;
  ThemeProvider? _themeProviderNoListen;
  NetStateQueue? _netStateQueueNoListen;
  WebTextSize? _webTextSizeNoListen;

  set isSiteMode(bool val) {
    if (val != _isSiteMode) {
      _isSiteMode = val;
      forcWebViewDarkMode(_isSiteMode);
    }
  }

  bool _isSiteModelUrl(String? url) {
    return site != null && site!.isSite(url);
    // return url != null
    //     ? url.startsWith(SiteConstants.kWebHomeUrl, 0)
    //     : (_startUrl.startsWith(SiteConstants.kWebHomeUrl, 0) || _stopUrl.startsWith(SiteConstants.kWebHomeUrl, 0));
  }

  bool _checkSiteMode(String? url) {
    isSiteMode = _isSiteModelUrl(url);
    String? r = site?.cssExtensionName;
    bool loadc = isSiteMode;
    String? c = UtilSite.cssFileNameFromUrl(url);
    if (r != null && r.length > 1) {
      ThemeProvider().asynLoadHostExtension(r, AppState().isMobileUA());
    } else if (!loadc) {
      loadc = true;
    }
    if (loadc && c != null && c.length > 1 && (r != c)) {
      ThemeProvider().asynLoadHostExtension(c, AppState().isMobileUA());
    }
    return isSiteMode;
  }

  void _updateWebSiteFromUrl(String? url) async {
    if (url == null || url.isEmpty) {
      if (site != null) {
        beforeSite = site;
        await beforeSite?.save();
      }
      site = null;
    } else if (site != null && site?.isSite(url) == true) {
    } else if (beforeSite != null && beforeSite?.isSite(url) == true) {
      WebSite? bs = site;
      site = beforeSite;
      beforeSite = bs;
      await beforeSite?.save();
    } else {
      if (site != null) {
        beforeSite = site;
        await beforeSite?.save();
      }
      site = await AppState().getWebSiteFormUrl(url);
    }
  }

  void _updateWebSite(WebSite? nval) {
    if (site != nval) {
      if (site != null) {
        beforeSite = site;
      }
      site = nval;
    }
  }

  set startUrl(String? url) {
    String nu = url ?? '';
    _loadPreUpdateThemeModelToJs = false;
    _webThemeReady = WebThemeSyncState.start;
    if (nu != _startUrl) {
      loadCount++;
      _startUrl = nu;
      webPageImageCount = 0;
      _webPageImageLookIndex = 0;
      redirectCount = 0;
      _lastWebError = null;
      _favicon = null;
      _updateWebSiteFromUrl(_startUrl);
      _checkSiteMode(_startUrl);
    } else {
      redirectCount++;
    }
    //url变化时候关闭查找ui
    webViewHelper?.isFindInteractionEnabled = false;
    ZsLog.d('set start load url:$_startUrl');
  }

  //TODO: 非chiphell 页面 使用浏览器支持的强制暗黑模式
  void forcWebViewDarkMode(bool siteMode) {
    // if(Utils.isAndroid()){
    //   var tp = Provider.of<ThemeProvider>(context, listen: false);
    //   if (siteMode) {

    //   }
    //   if (tp.isDarkTheme()) {
    //     settings.darkMode = true; //algorithmicDarkeningAllowed
    //     settings.algorithmicDarkeningAllowed = true;
    //     _webViewController?.setSettings(settings: settings);
    //   }else{

    //   }
    // }
  }

  Future<void> urlMaxLoadCheck() async {
    if ((redirectCount >= _redirectMax)) {
      await stopLoading();
    }
  }

  set stopUrl(String? url) {
    ZsLog.d('stop load url:$url');
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
  bool _updateHistoryUrl(String? url) {
    bool r = false;
    ZsLog.d('_updateHistoryUrl stop($_stopUrl) to  load url:$url');
    String tmp = url ?? '';
    if (_stopUrl != tmp) {
      _stopUrl = tmp;
      _webPageImageCount = 0;
      _webPageImageLookIndex = 0;
      _checkSiteMode(_stopUrl);
      saveLastUrl(_stopUrl);
      r = true;
      // widget.onStateUpdated.call();
    }
    return r;
  }

  set webPageImageCount(int count) {
    if (count != _webPageImageCount) {
      _webPageImageCount = count;
      if (_webPageImageCount <= _webPageImageLookIndex) {
        _webPageImageLookIndex = 0;
      }
      // if (count > 0) {
      //   ZsLog.d('web page images:$count');
      // }
      _updateImageUITip();
    }
    webViewHelper?.webPageImageCount = count;
  }

  //https 是否安全
  bool get isSecure => _isSecure;
  set isSecure(bool value) {
    if (value != _isSecure) {
      _isSecure = value;
      widget.onStateUpdated.call();
    }
  }

  Future<void> _reloadWeb() async {
    if (isLoadingSyn() || await isLoading()) {
      await _webViewController?.stopLoading();
    }
    bool ish = await webViewHelper?.webViewHasHistory() == true;
    if (ish == false ||
        (_lastWebError != null) ||
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
    if (!isSiteMode || site == null) {
      return;
    }
    if ((urlStr != null) && Utils.isValidHttpUrl(urlStr) && (urlStr.length > 5)) {
      if (context.mounted) {
        webViewHelper?.saveLastUrl(urlStr);
      }
    }
  }

  /// 检查site是否修改
  // void _checkMainSiteChanged() {
  //   WebUri? r = _getStopStartWebUri();
  //   if (r != null) {
  //     if (!AppState.site.isSite(r.toString())) {
  //       //site 改变了，需要reset
  //       if (Utils.isAndroid()) {
  //         _webViewController?.clearHistory();
  //       }
  //       webViewOpenUrl(AppState.site.firstUrl(AppState().isMobileUA()));
  //     }
  //   }
  // }
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
    webViewHelper = WebViewHelper();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _overlayController = StreamController<Widget>.broadcast();
    var appState = Provider.of<AppState>(context, listen: false);

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
      } else if (eventFn == 'goBack') {
        r = await goBack();
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
      ZsLog.d('Set tab webview ua: ${widget.webMode.initUa}');
      settings.userAgent = widget.webMode.initUa;
    } else {
      ZsLog.d('Set tab webview ua: null');
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

    // if (Utils.isWindows() || Utils.isIOSPad) {
    //   settings.preferredContentMode = appState.isMobileUA()
    //       ? UserPreferredContentMode.MOBILE
    //       : UserPreferredContentMode.RECOMMENDED;
    // }
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
      menuItems: [
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
            WebSite? v = site;
            if ((url != null) && (v != null) && ((v.isThreadUrl(url)) || v.isArticleUrl(url))) {
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

  //android
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
  }

  //上一个widget 调用。
  Future<void> willClose() async {
    if (!_isWindowClosed) {
      _isWindowClosed = true;
      _overlayController?.close();
      _overlayController = null;
      cleanListener();
    }
    webViewHelper?.clean();
    await pauseAll();
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

    _appStateNoListen = null;
    _themeProviderNoListen = null;
    _webTextSizeNoListen = null;
    _netStateQueueNoListen = null;
    _focusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    InAppWebViewController.disposeKeepAlive(keepAlive);
    ZsLog.d("browser_web_tab_page dispose");
    super.dispose();
  }

  @override
  void didChangeTextScaleFactor() {
    super.didChangeTextScaleFactor();
    var webTextSize = Provider.of<WebTextSize>(context, listen: false);
    webTextSize.sysTextZoom = WidgetsBinding.instance.platformDispatcher.textScaleFactor;
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
  void didChangePlatformBrightness() async {
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
    if (!_isWindowClosed) {
      // ZsLog.d('did changd app lifecycle state:$state');
      if (_webViewController != null) {
        if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
          site?.save();
        }
        if (Utils.isAndroid()) {
          if (state == AppLifecycleState.paused) {
            pauseAll();
          } else {
            resumeAll();
          }
        } else if (Utils.isWindows()) {}

        // if (state == AppLifecycleState.paused) {
        //   if (Utils.isAndroid()) {
        //     if (!isPause) {
        //       pauseAll();
        //       isPause == true;
        //     }
        //   }
        // } else {
        //   if (Utils.isAndroid()) {
        //     if (!isPause) {
        //       resumeAll();
        //       isPause == false;
        //     }
        //   } else if (Utils.isWindows()) {}
        //   //if (state == AppLifecycleState.resumed)
        //   // if (Utils.isWindows()) { //6.2.0-beta.2修复了windows问题
        //   //   if (state == AppLifecycleState.inactive) {
        //   //     asyncWindowsHandleInactive(false);
        //   //   } else {
        //   //     resumeAll();
        //   //   }
        //   // } else {
        //   //      resumeAll();
        //   //}
        // }
      }
    }
  }

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
    //ZsLog.d('webView pauseAll');
    if (Utils.isAndroid()) {
      await _webViewController?.pause();
      isPause = false;
    } else if (Utils.isWindows()) {
      if (isPause) {
        await _webViewController?.pause();
        isPause = false;
        ZsLog.d('webView pause:${widget.webMode.windowId}');
      }
    }
    await pauseTimers();
  }

  Future<void> resumeAll() async {
    // ZsLog.d('webView resumeAll');
    if (Utils.isAndroid()) {
      await _webViewController?.resume();
      isPause = false;
    } else if (Utils.isWindows()) {
      if (isPause) {
        await _webViewController?.resume();
        isPause = false;
        ZsLog.d('webView resume:${widget.webMode.windowId}');
      }
    }
    await resumeTimers();
  }

  Future<void> pause() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _webViewController?.setAllMediaPlaybackSuspended(suspended: true);
    } else if (Utils.isAndroid()) {
      await _webViewController?.pause();
      isPause = true;
    } else if (Utils.isWindows()) {
      if (!isPause) {
        await _webViewController?.pause();
        isPause = true;
        ZsLog.d('webView pause:${widget.webMode.windowId}');
      }
    }
  }

  Future<void> resume() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _webViewController?.setAllMediaPlaybackSuspended(suspended: false);
    } else if (Utils.isAndroid()) {
      await _webViewController?.resume();
      isPause = false;
    } else if (Utils.isWindows()) {
      if (isPause) {
        await _webViewController?.resume();
        isPause = false;
        ZsLog.d('webView resume:${widget.webMode.windowId}');
      }
    }
  }

  Future<void> pauseTimers() async {
    if ((!Utils.isWindows()) && (!Utils.isLinux())) {
      await _webViewController?.pauseTimers();
    }
  }

  Future<void> resumeTimers() async {
    if (!Utils.isWindows() && !Utils.isLinux()) {
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

  //新标签打开
  void _newTabOpenInWindow(String url) {
    widget.webMode.onCreateTabRequested(null, url);
  }

  //其他浏览器打开当前url
  Future<void> openCurrentUrlOtherBrowser() async {
    webViewHelper?.systemBrowserOpenUrl(await getValidWebUrlString());
  }

  Future<bool> webViewOpenUrl(String? url) async {
    return await webViewHelper?.webViewOpenUrl(url) == true;
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

    ZsLog.d('switch set ua:${uas ?? ''}');

    settings.userAgent = uas;
    String? webUrl = await _getWebCurrentUrl();
    await _webViewController?.setSettings(settings: settings);
    if (Utils.isAndroid()) {
      await _webViewController?.clearHistory();
    }
    if (webUrl != null) {
      var reloadUrl = site?.convertUrlFromUrl(webUrl, isPCUA(), isMobileUA());
      ZsLog.d('UA Switch url:$reloadUrl');
      reloadUrl ??= webUrl;
      await _webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri(reloadUrl)));
    }
  }

  // WebSite site()
  // {
  //   //WebSite site;
  // }
  Future<void> _getWebUserInfo() async {
    if (!isSiteMode || site == null || site?.mainSite == null) {
      return Future.value(null);
    }
    String? url = await _getWebCurrentUrl();
    if (url == null) {
      return Future.value(null);
    }
    var tempSite = site;
    if (tempSite == null || tempSite.mainSite == null) {
      return Future.value(null);
    }
    WebUri wuri = WebUri(url);
    // var appState = Provider.of<AppState>(context, listen: false);
    //cookie 可以获得isHttpOnly: true,
    CookieManager cookieManager = CookieManager.instance();
    List<Cookie> cookies = await cookieManager.getCookies(url: wuri, webViewController: _webViewController);
    String? authCookie;

    String? key = tempSite.mainSite?.authCookieFullNameKey;

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
    site?.updateCookieToInfo(cookieStr);

    // if (key != null && key.isNotEmpty) {
    //   for (var i = 0; i < cookies.length; i++) {
    //     var cookie = cookies[i];
    //     if (cookie.name == key) {
    //       authCookie = cookie.value;
    //       break;
    //     }
    //   }
    // }

    bool getjs = tempSite.user.cookieAuth != authCookie;
    if (getjs == false && tempSite.user.isLogin() && !tempSite.user.isValidName()) {
      getjs = true;
    } else if (!tempSite.user.isLogin()) {
      return;
    }
    if (getjs && tempSite.isSite(url)) {
      var result = await _webViewController?.evaluateJavascript(source: "webinterfaceGetLoginUserInfo()");
      if (result != null) {
        var dict = jsonDecode(result);
        String? name = dict['name'];
        //String? webUrl = dict['src'];
        String? userUrl = dict['url'];
        String? userIcon = dict['icon'];
        String? uid = dict['uid'];
        tempSite.updateUserInfo(name: name, userUrl: userUrl, userIcon: userIcon, uid: uid, authCookie: authCookie);
        tempSite.save();
      }
    }
  }

  Future<bool> isAuthorCurrentPageUrl() async {
    String? webUrl = await _getWebCurrentUrl();
    if (webUrl == null || webUrl.isEmpty) {
      return false;
    }
    return site?.isAuthorUrl(webUrl) == true;
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

  /*
   * 其他app打开
   */
  Future<void> handleWebOtherHostUrl(String url) async {
    List<OptionButtonItem> list = [];
    list.add((
      label: Constants.kNewTabOpen,
      onPressed: () {
        _newTabOpenInWindow(url);
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

  Future<void> _updateWebAutoTheme(AppState appState, ThemeProvider themeProvider, WebUri? curl, bool progressRun) async {
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

  //js dom loaded 后，发送回来的web info
  Future<void> _handleWebSiteInfo(AppState? appState, Map val) async {
    if (val is Map<String, dynamic> && val.isNotEmpty) {
      MainSite? ms = MainSite.fromMap(val);
      // String? uid = UtilMap.safeStringForKey(val, 'uid');
      if (ms != null && ms.valid && ms.isDiscuz) {
        ms.updateSource(MainSiteSourceType.detect);
        ms.updateSiteType(SiteType.discuz);
        var newSite = await appState?.updateWebSiteFromJs(
          ms,
          info: val,
          siteCallBack: (ms, newSite) {
            if (newSite) {
              Toast.toastAtTop(context, '${Constants.kWebDetectDiscuzSite} - ${ms.title}', showTime: 1500);
            }
          },
        );
        // if (uid != null && uid.isNotEmpty) {
        //   newSite?.updateUserInfo(uid: uid);
        // }
        _updateWebSite(newSite);
      }
    }
  }

  /// 收到web的提醒消息
  Future<void> _updateWebSitePromptMsg(AppState? appState, Map val) async {
    if (context.mounted == false || val.length < 4 || site == null || site?.isDiscuz() != true) {
      return;
    }
    try {
      PromptMsg msg = PromptMsg.fromMap(val as Map<String, dynamic>);
      site?.updatePromptMessage(msg);
      site?.save();
    } catch (e) {
      ZsLog.e('update prompt msg error:$e');
    }
  }

  // bool _currentUrlIsImage({String? url}) {
  //   return Utils.isImageExtensionUrl(url ?? (_stopUrl.isNotEmpty ? _stopUrl : _startUrl));
  // }

  Future<void> _updateWebImageInfos(AppState appState, ThemeProvider themeProvider, WebUri? url) async {
    if (url != null) {
      var count = await webViewHelper?.jsWebPageImageCount(url.toString());
      if (count != null) {
        webPageImageCount = count;
      }
    }
  }

  Future<void> _webLoadSiteStop(AppState appState, ThemeProvider themeProvider, WebUri? url) async {
    String urlstr = url.toString();
    await _updateWebAutoTheme(appState, themeProvider, url, false);
    WebSite? v = site;
    if ((_webViewController != null) && (url != null) && v != null && v.isSite(urlstr)) {
      var params = jsonEncode({'list': BlackList.userBlackList});
      String source =
          '''
        webinterfaceSetBlacklist($params)
        ''';
      await _webViewController?.evaluateJavascript(source: source);
      await _getWebUserInfo();
    }

    var count = await webViewHelper?.jsWebPageImageCount(url.toString());
    if (count != null) {
      webPageImageCount = count;
    }

    Future.delayed(Duration(milliseconds: 800), () {
      Favorites().updateLookUrl(urlstr, _webPageTitle);
    });
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
    if ((tp.preUserScript == null) || webViewHelper?.valid() != true) {
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

  void _updateWebThemeReady({WebThemeSyncState v = WebThemeSyncState.delayCompleted, bool isComplete = true}) {
    if (_webThemeReady != v) {
      if (isComplete) {
        if (_webThemeReady == WebThemeSyncState.complete) {
          setState(() {
            _webThemeReady = v;
          });
        }
      } else {
        setState(() {
          _webThemeReady = v;
        });
      }
    }
  }

  void _delayUpdateWebThemeReady({WebThemeSyncState v = WebThemeSyncState.delayCompleted, bool isComplete = true, bool isDelay = true}) {
    if (isDelay) {
      Future.delayed(Duration(milliseconds: Utils.isAndroi10Under() ? 1000 : 500), () {
        _updateWebThemeReady(v: v, isComplete: isComplete);
      });
    } else {
      _updateWebThemeReady(v: v, isComplete: isComplete);
    }
  }

  //在加载一个history页面 android progress 70 80 可能卡住
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
      _delayUpdateWebThemeReady(v: WebThemeSyncState.delayCompleted, isDelay: true, isComplete: true);
    } else if (_webThemeReady == WebThemeSyncState.start || _webThemeReady == WebThemeSyncState.none) {
      _webThemeReady = WebThemeSyncState.loading;
      if (progs >= 100) {
        _webThemeReady = WebThemeSyncState.complete;
        if (isDelay == false) {
          _delayUpdateWebThemeReady(v: WebThemeSyncState.delayCompleted, isDelay: true, isComplete: true);
        }
      }
    } else if (_webThemeReady == WebThemeSyncState.complete) {
      if (progs < 100) {
        _webThemeReady = WebThemeSyncState.loading;
      } else if (isDelay == false) {
        _delayUpdateWebThemeReady(v: WebThemeSyncState.delayCompleted, isDelay: true, isComplete: true);
      }
    }

    ZsLog.d('web load url progress: $progs, forceStop=$stopFlag,_webThemeReady:$_webThemeReady');
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

  final ismate = Utils.isApple();
  final isctrl = Utils.isWindows() || Utils.isLinux();

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

  @override
  Widget build(BuildContext context) {
    //没有用到
    var appState = Provider.of<AppState>(context, listen: false);
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    var webTextSize = Provider.of<WebTextSize>(context, listen: true);
    super.build(context);
    // SystemChrome.setSystemUIOverlayStyle(
    //   SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.purple),
    // );
    //为这个页面设置单独status bar
    //return _buildAnnotatedRegion(context, appState, themeProvider, webTextSize, orientation);
    return OrientationBuilder(
      builder: (context, orientation) {
        return _buildAnnotatedRegion(context, appState, themeProvider, webTextSize, orientation);
      },
    );
  }

  Widget _buildAnnotatedRegion(
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
      child: CallbackShortcuts(
        bindings: <ShortcutActivator, VoidCallback>{
          SingleActivator(control: isctrl, meta: ismate, LogicalKeyboardKey.minus): () {
            webTextSize.previousPageZoom();
            ZsLog.d('meta + control +  - previousPageZoom');
          },
          SingleActivator(control: isctrl, meta: ismate, LogicalKeyboardKey.add): () {
            webTextSize.nextPageZoom();
            ZsLog.d('meta + control +  + nextPageZoom');
          },
          SingleActivator(control: isctrl, meta: ismate, LogicalKeyboardKey.arrowLeft): () {
            goBack();
            ZsLog.d('meta + arrowLeft goBack');
          },
          SingleActivator(control: isctrl, meta: ismate, LogicalKeyboardKey.arrowRight): () {
            goForward();
            ZsLog.d('meta arrowRight');
          },
          SingleActivator(control: isctrl, meta: ismate, LogicalKeyboardKey.arrowUp): () async {
            webScrollAction(true);
            ZsLog.d('meta + arrowUp web scroll to top');
          },
          SingleActivator(LogicalKeyboardKey.arrowDown, control: isctrl, meta: ismate): () {
            webScrollAction(false);
            ZsLog.d('meta + arrowDown web scroll to bottom');
          },
          SingleActivator(LogicalKeyboardKey.keyR, control: isctrl, meta: ismate): () {
            _reloadWeb();
            ZsLog.d('meta + r web reload');
          },
          SingleActivator(LogicalKeyboardKey.arrowDown, control: isctrl, meta: ismate): () {
            ZsLog.d('arrowDown');
          },

          SingleActivator(LogicalKeyboardKey.keyF, control: isctrl, meta: ismate): () {
            if (webViewHelper != null) {
              webViewHelper?.isFindInteractionEnabled = !webViewHelper!.isFindInteractionEnabled;
            }
            ZsLog.d('meta + shift+ f web one page find');
          },
        },
        child: Focus(
          autofocus: true,
          focusNode: _focusNode,
          descendantsAreFocusable: true, // 设置所有子组件可聚焦 false,
          //descendantsAreTraversable: false,
          child: PopScope(
            //2秒内多少返回手势，则返回true退出应用。 返回false禁止回退、滑动回退以及Android的物理键回退，android 有效
            canPop: (DateTime.now().millisecondsSinceEpoch - prePopDateTime.millisecondsSinceEpoch) < 1500,
            onPopInvokedWithResult: (didPop, result) async {
              ZsLog.d('didPop: $didPop; result:$result ');
              prePopDateTime = DateTime.now();
              if (!didPop) {
                var flag = await _handlePopBackGesture(false);
                if (flag == false && Utils.isMobile()) {
                  //在移动，在返回的手势中，不能后退了，则返回主页面
                  _pageAutoClose();
                }
              }
            },
            child: Scaffold(
              appBar: _findAppBar(),
              //默认设置为true，ios anndroid 键盘出来的时候，bottom区域被顶上去，所以设置false,android 10+ 还需要把bottombar高度固定
              resizeToAvoidBottomInset: false,
              body: SafeArea(
                // top: false,
                // maintainBottomViewPadding: true,
                child: Column(
                  //spaceBetween 两端对齐，也就是第一个子组件靠顶部，最后一个子组件靠底部，剩余组件在中间平均分散排列。效果如下：
                  //MainAxisAlignment.spaceEvenly：每个子组件平均分散排列，也就是均分垂直空间。效果如下
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, //控制子组件在主轴（垂直方向）的对齐方式
                  crossAxisAlignment: CrossAxisAlignment.center, //控制子组件在交叉轴（水平方向）的对齐方式
                  children: contentAareWidget(context, appState, themeProvider, webTextSize, orientation),
                ),
              ),
            ),
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
        flex: 1, //两个控件 有一个剩余空间。Expanded空间占用剩余空间
        child: ((Utils.isAndroid() || Utils.isWindows() || Utils.isLinux()) && themeProvider.isDarkTheme())
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
    bool s = false;
    // s =
    //     ((progress > 0.95) ||
    //     ((progress >= themeProvider.webTabLoadDarkMaskMaxProgress) &&
    //         (_webThemeReady == WebThemeSyncState.visiable ||
    //             _webThemeReady == WebThemeSyncState.complete ||
    //             _webThemeReady == WebThemeSyncState.delayCompleted)) ||
    //     (_webThemeReady == WebThemeSyncState.delayCompleted));

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
    return _stackContent(context, appState, themeProvider, webTextSize, themeProvider.isDarkTheme() && !s);
    // return Stack(
    //   children: <Widget>[
    //     IndexedStack(
    //       index:
    //           ((progress > 0.95) ||
    //               ((progress >= themeProvider.webTabLoadDarkMaskMaxProgress) &&
    //                   (_webThemeReady == WebThemeSyncState.visiable ||
    //                       _webThemeReady == WebThemeSyncState.complete ||
    //                       _webThemeReady == WebThemeSyncState.delayCompleted)) ||
    //               (_webThemeReady == WebThemeSyncState.delayCompleted))
    //           ? 0
    //           : 1,
    //       children: [
    //         buildWebView(context, appState, themeProvider, webTextSize),
    //         Container(color: const Color.fromARGB(6, 26, 25, 25)),
    //       ],
    //     ),
    //     // buildWebView(context, appState),
    //     progress < 1.0 ? LinearProgressIndicator(value: progress, minHeight: Utils.isWindows() ? 4 : 2) : Container(height: 2),
    //     //LinearProgressIndicator(value: progress, minHeight: 2),
    //   ],
    // );
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
    final web = buildWebView(context, appState, themeProvider, webTextSize);
    // final mask = Container(color: const Color.fromARGB(6, 26, 25, 25)); //(6, 26, 25, 25));
    final mask = Container(color: Color.fromARGB(240, 21, 21, 21));
    children.add(web);
    if (showMask) {
      children.add(mask);
      //ZsLog.d('Web mask 显示');
    } else {
      // ZsLog.d('Web mask 不显示');
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
  // //ios ipad macos
  // Stack stackModeOfContent(BuildContext context, AppState appState, ThemeProvider themeProvider, WebTextSize webTextSize) {
  //   List<Widget> children = [];
  //   if (Utils.isMacOS()) {
  //     //children.add(buildWebView(context, appState));
  //     children.add(
  //       IndexedStack(
  //         index:
  //             ((progress > 0.9) ||
  //                 ((progress > themeProvider.webTabLoadDarkMaskMaxProgress) &&
  //                     (_webThemeReady == WebThemeSyncState.complete || _webThemeReady == WebThemeSyncState.delayCompleted)) ||
  //                 (_webThemeReady == WebThemeSyncState.delayCompleted))
  //             ? 0
  //             : 1,
  //         children: [
  //           buildWebView(context, appState, themeProvider, webTextSize),
  //           Container(color: const Color.fromARGB(6, 26, 25, 25)),
  //         ],
  //       ),
  //     );
  //   } else {
  //     children.add(buildWebView(context, appState, themeProvider, webTextSize));
  //   }

  //   children.add(progress < 1.0 ? LinearProgressIndicator(value: progress, minHeight: 2) : Container(height: 2));

  //   /// ios 26 弹出模态控件后 webview 不能点击
  //   if (Utils.isIOS26Late()) {
  //     children.add(
  //       Positioned.fill(
  //         child: PointerInterceptor(intercepting: !_isTopOfNavigationStack, debug: false, child: const SizedBox.expand()),
  //       ),
  //     );
  //   }
  //   return Stack(children: children);
  // }

  InAppWebView buildWebView(BuildContext context, AppState appState, ThemeProvider themeProvider, WebTextSize webTextSize) {
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
    //widget.webMode.windowId != null
    return InAppWebView(
      keepAlive: Utils.isLinux() ? null : keepAlive,
      key: webViewKey,
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
                  // var value = arg['domReady'];
                  // if (value != null && (value is String)) {
                  //   ZsLog.d('接受js __jszHandler__ 事件 domReady: $value');
                  // }
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
                        // Future.delayed(Duration(milliseconds: 500), () {
                        _delayUpdateWebThemeReady(v: WebThemeSyncState.delayCompleted, isDelay: true, isComplete: true);
                        // if (_webThemeReady == WebThemeSyncState.complete) {
                        //   setState(() {
                        //     _webThemeReady = WebThemeSyncState.delayCompleted;
                        //   });
                        // }
                        //});
                      }
                    } else if (value == '3') {
                      //theme css 移除
                    } else if (value == '4') {
                      //theme css 已经移除
                    } else if (value == '5') {
                      //theme css，非site的url 不需要设置
                      _delayUpdateWebThemeReady(v: WebThemeSyncState.delayCompleted, isComplete: false, isDelay: false);
                      // setState(() {
                      //   _webThemeReady = WebThemeSyncState.delayCompleted;
                      // });
                    }
                  }
                } else if (arg.containsKey('tapFavor')) {
                  _webTapFavr(true);
                  // var value = arg['tapFavor'];
                  // if (value != null && (value is String)) {
                  //   ZsLog.d(value == '1' ? '收藏成功' : '取消收藏成功');
                  // }
                } else if (arg.containsKey('tapImage')) {
                  var value = arg['tapImage'];
                  if (value != null && (value is String)) {
                    //  ZsLog.d('click image :$value');
                    if (appState.autoImageGallery) {
                      //现实图片画廊
                      showWebImageGallery(imgUrl: value);
                    }
                  }
                } else if (arg.containsKey('domInitVars')) {
                  var value = arg['domInitVars'];
                  var vsite = site;
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
                    if (vsite != null && vsite.isSite(webUrl) == true) {
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
        Future.sync(() async {
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
        });
      },

      onWindowFocus: (controller) {
        //  ZsLog.d('Web tab  window focus');
        if (WebMorePopMenu.isShowedMenu) {
          Navigator.of(context).maybePop();
          WebMorePopMenu.isShowedMenu = false;
        }
      },

      onCreateWindow: (controller, createWindowAction) async {
        //macos 右键弹出新窗口菜单
        bool open = false;
        String newUrl = createWindowAction.request.url.toString();
        ZsLog.d('Web create window:$newUrl');
        bool r = widget.supportMultipleWindows();
        if (Utils.isValidHttpUrl(newUrl) && (createWindowAction.isRedirect == null || createWindowAction.isRedirect == false)) {
          if (r) {
            open = true;
          } else if ((createWindowAction.isForMainFrame == false && createWindowAction.navigationType == NavigationType.OTHER)) {
            //右键打开
            open = true;
          }
          if (open) {
            open = widget.webMode.onCreateTabRequested(createWindowAction, null);
            if (open && Utils.isWindows()) {
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
        // settings.supportMultipleWindows;
      },
      onTitleChanged: (controller, title) {
        if (title != WebConstants.kNullUrl) {
          if (_webPageTitle != title) {
            _webPageTitle = title;
          }
          widget.onStateUpdated.call();
        }
        ZsLog.d('Web window title:$title');
      },
      onPrintRequest: (controller, url, printJobController) async {
        // handle the print job
        return true;
      },
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
      onPageCommitVisible: (controller, url) async {
        ZsLog.d('Web page commit visible url: $url');
        if (progress > 0 && progress < 100 && (_webThemeReady == WebThemeSyncState.start || _webThemeReady == WebThemeSyncState.loading)) {
          _webThemeReady = WebThemeSyncState.visiable;
        }
        _updateWebAutoTheme(appState, themeProvider, url, false);
      },
      // onDownloadStarting: (controller, downloadStartRequest) async {
      //   //macos 右键 弹出菜单，显示open image in new window
      //   //windows suggestedFilename： attachment; filename="IMG_E1006.JPG"
      //   if (await webViewHelper?.webViewHasHistory() == true) {
      //     String? sg = downloadStartRequest.suggestedFilename;
      //     String? mmt = downloadStartRequest.mimeType;
      //     String url = downloadStartRequest.url.toString();
      //     String? fileExtension = mmt != null ? Utils.fileExtensionFromMimeType(mmt) : null;

      //     ZsLog.d('Web start download url: $url');
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

      //     String? urlaid;
      //     if (!isimg) {
      //       urlaid = site?.imageAttachmentSuggestedFileName(url, onlyMode: true);
      //       if (urlaid != null) {
      //         isimg = true;
      //       }
      //     }

      //     if (isimg) {
      //       // webViewHelper?.downloadWebFile(
      //       //   url,
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
      //     //  handleWebOtherHostUrl(url);
      //     }
      //   } else {
      //     //第一次加载不要下载
      //   }
      //   return null;
      // },
      onLoadStart: (controller, url) {
        //执行js 将失败
        startUrl = url.toString();
        // ZsLog.d('start load url:$url');
        isSecure = Utils.urlIsSecure(url!);
        _startLayzImageMode();
        //widget.onStateUpdated.call();
      },

      onProgressChanged: (controller, progs) {
        if ((progs >= 100) && themeProvider.isDarkTheme() && (Utils.isAndroidPad)) {
          //延时1秒
          Future.delayed(Duration(milliseconds: 1500), () {
            _updateWebLoadingProgress(appState, themeProvider, controller, progs, isDelay: true);
          });
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
      shouldAllowDeprecatedTLS: (controller, challenge) async {
        return ShouldAllowDeprecatedTLSAction.ALLOW;
      },
      // onReceivedClientCertRequest: (controller, challenge) {
      //   return ShouldAllowDeprecatedTLSAction.ALLOW;
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
        ZsLog.d('Web onProcessFailed:$detail');
        if (isLoadingSyn()) {
          controller.stopLoading();
        }
      },
      onAcceleratorKeyPressed: (controller, detail) {
        ZsLog.d('Web onAcceleratorKeyPressed:$detail');
      },
      onPermissionRequest: (controller, permissionRequest) async {
        final resources = <PermissionResourceType>[];
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
      // onLoadResource: (controller, resource) {
      //  // widget.webViewModel.addLoadedResources(resource);
      //   // if (isCurrentTab(currentWebViewModel)) {
      //   //   currentWebViewModel.updateWithValue(widget.webViewModel);
      //   // }
      // },
      onNavigationResponse: (controller, navigationResponse) {
        bool r =
            webViewHelper?.webViewOnNavigationResponse(navigationResponse, site, (String url) {
              webViewOpenUrl(url);
            }) ==
            true;
        return r ? NavigationResponseAction.ALLOW : NavigationResponseAction.CANCEL;
      },
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        WebUri? uri = navigationAction.request.url;
        String? url = uri?.toString();
        String? urlDecode = url?.toLowerCase();
        urlDecode = urlDecode != null ? Uri.decodeFull(urlDecode) : urlDecode;
        bool requestIsSitemodeUrl = _isSiteModelUrl(url);
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

        // InAppWebViewHitTestResult? htr = Utils.isAndroid()
        //     ? await controller.getHitTestResult()
        //     : null;

        ZsLog.d('-----------------should override :${navigationAction.toString()}');
        if (redirectCount == _redirectMax) {
          urlMaxLoadCheck();
        } else if (redirectCount > _redirectMax) {
          redirectCount = 0;
          ZsLog.d('should override redirectCount to max :${navigationAction.toString()}');
          return NavigationActionPolicy.CANCEL;
        }
        // else if (redirectCount > 1) {
        //   if (uri != null && uri.isScheme('HTTP') && (htr == null)) {
        //     webViewOpenUrl(url);
        //     return NavigationActionPolicy.CANCEL;
        //   }
        // }

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

        if (uri == null || url == null) {
          return NavigationActionPolicy.CANCEL;
        }

        bool userReqOrClick = (isForMainFrame && navigationAction.navigationType == NavigationType.OTHER);
        bool userClickActived = (isForMainFrame && navigationAction.navigationType == NavigationType.LINK_ACTIVATED);
        bool userDownloadAttach = (isForMainFrame == false && navigationAction.navigationType == NavigationType.LINK_ACTIVATED);

        if (Utils.isApple() && (navigationAction.shouldPerformDownload ?? false)) {
          Toast.toastAtCenter(mounted ? context : null, Constants.kPopMesgImageDownloadedStart);
          await webViewHelper?.downloadHttpFile(url, referUrl: _startUrl, orgHeader: navigationAction.request.headers, prompt: true);
          return (Utils.isIOS()) ? NavigationActionPolicy.DOWNLOAD : NavigationActionPolicy.CANCEL;
        }

        if (requestIsSitemodeUrl) {
          if (url.startsWith("about:blank") && !isForMainFrame) {
            ZsLog.d('blocking navigation (isMainFrame:$isForMainFrame) to $url');
            return NavigationActionPolicy.ALLOW;
          }

          if (!Utils.allowBrowserSchemes.contains(uri.scheme)) {
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
              return NavigationActionPolicy.CANCEL;
            }
          }
          if (isForMainFrame &&
              Utils.isMacOS() &&
              (site != null) &&
              (urlDecode != null) &&
              (userReqOrClick || userClickActived || userDownloadAttach)) {
            if (await webViewHelper?.webViewHasHistory() == true) {
              if (site?.isImageAttachment(urlDecode, decoded: true) == true) {
                Toast.toastAtCenter(mounted ? context : null, Constants.kPopMesgImageDownloadedStart);
                webViewHelper?.downloadHttpFile(urlDecode, referUrl: _startUrl, orgHeader: navigationAction.request.headers, prompt: true);
                return NavigationActionPolicy.CANCEL;
              } else if (site?.isContentImageUrl(urlDecode, decoded: true) == true) {
                Toast.toastAtCenter(mounted ? context : null, Constants.kPopMesgImageDownloadedStart);
                webViewHelper?.downloadWebFile(
                  url,
                  autoSave: false,
                  //  refererUrl: _startUrl,
                  // sugExtension: sg != null ? 'jpeg' : null,
                  //orgHeader: navigationAction.request.headers,
                  // ignoreCache: true,
                  // clearCache: true,
                  //enableHeader: true,
                );
                return NavigationActionPolicy.CANCEL;
              }
            }
          }
        } else if (url.isEmpty || !Utils.isValidHttpUrl(url)) {
          ZsLog.d('blocking navigation (isMainFrame:$isForMainFrame) to invalid url: $url');
          return NavigationActionPolicy.CANCEL;
        }

        int diff = DateTime.now().millisecondsSinceEpoch - userClickNewWindowTime;
        if (diff < 100) {
          userClickNewWindowTime = 0;
          webViewHelper?.innerBrowserOpen(mounted ? context : null, url, newWindow: true);
          return NavigationActionPolicy.CANCEL;
        }
        isSiteMode = requestIsSitemodeUrl;
        return NavigationActionPolicy.ALLOW;
      },
      onSaveAsUIShowing: (controller, request) async {
        //用户右键图片另存为-》shouldOverrideUrlLoading-onProgressChanged->onLoadStart->onSaveAsUIShowing->
        //onSaveFileSecurityCheckStarting-》onDownloadStarting
        //SaveAsUIShowingResponse
        ZsLog.i('onSaveAsUIShowing $request');
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
        ZsLog.i('onSaveFileSecurityCheckStarting $request');
        _updateWebLoadingProgress(appState, themeProvider, controller, 100, forceStrop: true, isDelay: false);
        stopLoading();
        return SaveFileSecurityCheckStartingResponse(cancelSave: request.cancelSave, suppressDefaultPolicy: request.suppressDefaultPolicy);
      },

      onScreenCaptureStarting: (controller, request) async {
        //ScreenCaptureStartingResponse
        ZsLog.i('onScreenCaptureStarting $request');
        return ScreenCaptureStartingResponse();
      },

      onLoadStop: (controller, url) {
        pullToRefreshController?.endRefreshing();
        stopUrl = url.toString();
        // Future.sync(()async{ });
        // Future.delayed(Duration.zero, () => print('event 2'));
        Future(() async {
          var sslCertificateFuture = controller.getCertificate();
          var sslCertificate = await sslCertificateFuture;
          if (sslCertificate == null && !Utils.isLocalizedContent(Uri.parse(url.toString()))) {
            isSecure = false;
          }
          await _webLoadSiteStop(appState, themeProvider, url);
          try {
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
          } catch (e) {
            ZsLog.d("load favicons error:$e");
          }
          await webViewHelper?.updateScreenshot();
          widget.onStateUpdated.call();
        });
      },

      onReceivedServerTrustAuthRequest: (controller, challenge) async {
        var sslError = challenge.protectionSpace.sslError;
        if (sslError != null && (sslError.code != null)) {
          //https 证书不信任
          if ((Utils.isIOS() || Utils.isMacOS() || Utils.isAndroid()) && sslError.code == SslErrorType.UNSPECIFIED) {
            return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
          }
          String host = challenge.protectionSpace.host;
          if (site?.isChallengeHost(host) == true) {
            /// 如果网站证书换了，有可能出错。这里放行
            return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
          }
          var item = await appState.getChallengeHost(host, used: true);
          if (item.host == host && item.allow) {
            return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
          }
          isSecure = false;
          bool prompt = false;
          if (Utils.isAndroid() && sslError.code == SslErrorType.UNTRUSTED) {
            prompt = true;
          } else if (sslError.code == SslErrorType.RECOVERABLE_TRUST_FAILURE) {
            //Indicates a trust policy failure which can be overridden by the user.
            prompt = true; //表示用户可以覆盖的信任策略失败。
          }
          if (prompt) {
            bool iscancel = true;
            await Uiutils.showAlertDialog(
              mounted ? context : null,
              content: '当前网站的安全证书已过期或不可信，可能存在安全风险。是否继续访问？',
              barrierDismissible: true,
              delayPop: false,
              callBackFun: (isOk) async {
                if (isOk) {
                  iscancel = false;
                }
              },
            );
            if (iscancel) {
              return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.CANCEL);
            } else {
              await item.userTrust(true);
            }
          }
          //证书不安全，是否继续执行 RECOVERABLE_TRUST_FAILURE
          //Indicates a trust policy failure which can be overridden by the user.
          // return ServerTrustAuthResponse(
          //   action: ServerTrustAuthResponseAction.CANCEL,
          // );
        }
        return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
      },
      onReceivedError: (controller, request, error) {
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
        //Utils.isMacOS() &&
        if (error.type == WebResourceErrorType.UNKNOWN) {
          //WebResourceError{description: domain=WebKitErrorDomain, code=102, Frame load interrupted, type: UNKNOWN}
          if (request.isForMainFrame == true) {
            stopLoading();
            _updateWebLoadingProgress(appState, themeProvider, controller, 100, forceStrop: true, isDelay: true);
          }
          return;
        }
        //CANNOT_CONNECT_TO_HOST linux WPEWebKit 第一次加载 内部网络判断异常
        if (Utils.isLinux() && error.type == WebResourceErrorType.CANNOT_CONNECT_TO_HOST) {
          //description: WebKit encountered an internal error, type: CANNOT_CONNECT_TO_HOST
          return;
        }
        _lastWebError = error;
        if (error.type == WebResourceErrorType.NOT_CONNECTED_TO_INTERNET) {}
        if (error.type == WebResourceErrorType.NETWORK_CONNECTION_LOST) {}

        Future.microtask(() async {
          var errorUrl = request.url;
          _webViewController?.loadData(
            data: await themeProvider.getWebErrorPage(errorUrl.toString(), error.description),
            baseUrl: errorUrl,
            historyUrl: errorUrl,
          );
        });

        // if (error.type == WebResourceErrorType.BAD_URL) {
        // } else if (error.type == WebResourceErrorType.TIMEOUT) {
        // } else if (error.type == WebResourceErrorType.HOST_LOOKUP) {
        //   //404
        // } else {}
      },
      onReceivedHttpError: (controller, request, errorResponse) {
        ZsLog.d('web onReceivedHttpError: $request; -- errorResponse:$errorResponse');
        //当服务器的负载超过其处理能力时，会拒绝新的连接请求，从而导致503错误。
        webViewHelper?.handleWebHttpError(request.isForMainFrame, errorResponse.statusCode);
      },

      onUpdateVisitedHistory: (controller, url, isReload) {
        //页面内容展示
        ZsLog.d('Web onUpdateVisitedHistory isReload: $isReload ;url:$url');
        Future.microtask(() async {
          int upflag = 0;
          upflag = _updateHistoryUrl(url.toString()) ? 1 : 0;
          String? t = await controller.getTitle();
          if ((t != WebConstants.kNullUrl) && (_webPageTitle != t)) {
            _webPageTitle = t;
            upflag++;
          }
          await _updateWebAutoTheme(appState, themeProvider, url, false);
          if (upflag > 0) {
            widget.onStateUpdated.call();
          }
          await _updateWebImageInfos(appState, themeProvider, url);
        });
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
            ZsLog.d('onReceivedHttpAuthRequest showDialog is close');
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
          WebSite? v = site;
          String? url = _getStopStartWebUri()?.toString();
          if ((v != null) &&
              (url != null) &&
              (v.isSite(url)) &&
              (v.isThreadUrl(url, onlyMode: true) ||
                  v.isHomeUrl(url, onlyMode: true) ||
                  v.isArticleUrl(url, onlyMode: true) ||
                  v.isForumUrl(url, onlyMode: true))) {
            var requestFocusNodeHrefResult = await controller.requestFocusNodeHref();
            var requestImageHrefResult = await controller.requestImageRef();
            if (mounted && (requestFocusNodeHrefResult != null)) {
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
                          Future.delayed(Duration(milliseconds: 500), () {
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
        //NotificationReceivedResponse
        ZsLog.i('onNotificationReceived $request');
        return NotificationReceivedResponse(handled: false);
      },
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
    bool ret = false;
    WebViewHelper? hp = webViewHelper;
    if (hp != null) {
      ret = await hp.goBack();
      if (forceForum && !ret) {
        ret = await hp.gotoCurrentForum(false);
      }
    }
    return ret;
  }

  Future<bool> _handleBackMenu(bool forceForum, {bool callGoBack = true, bool enableBackForum = true}) async {
    bool ret = false;
    WebViewHelper? hp = webViewHelper;
    if (hp != null) {
      ret = enableBackForum ? (isSiteMode ? await hp.gotoCurrentForum(forceForum) : false) : false;
      if (callGoBack && ret == false) {
        ret = await hp.goBack();
      }
    }
    return ret;
  }

  void _pageAutoClose() {
    if (mounted && Utils.isMobile()) {
      widget.webMode.onCloseBrowser();
    }
  }

  Widget _webNavBottomBarBuilder(AppState appState, ThemeProvider themeProvider, WebTextSize webTextSize, Orientation? orientation) {
    return WebNavigationBottomBar(
      isPrompt: _webPageImageCount > 0,
      orientation: orientation,
      eventCallBack: (WebNavBottomBarEvent event, {RelativeRect? position}) async {
        if (event == WebNavBottomBarEvent.backAllParent) {
          if (!await _handleBackMenu(false, callGoBack: Utils.isDesktopSystem)) {
            _pageAutoClose();
          }
        } else if (event == WebNavBottomBarEvent.home) {
          if (await webViewHelper?.goSiteHome(autoEnable: true) == true) {
          } else {
            _pageAutoClose();
          }

          // WebSite? vsite = site;
          // String? gurl = vsite?.homeUrl(appState.isMobileUA());
          // gurl ??= appState.getLoadHomeUrl();
          // if (isSiteMode || Utils.isMobile()) {
          //   String? url = await _getWebCurrentUrl();
          //   if (url != gurl) {
          //     await webViewOpenUrl(gurl);
          //   }
          // } else if (Utils.isDesktopSystem) {
          //   await webViewOpenUrl(gurl);
          // } else {
          //   _pageAutoClose();
          // }
        } else if (event == WebNavBottomBarEvent.back) {
          //_handleBackMenu(false,callGoBack: true,enableBackForum:false);
          await goBack();
        } else if (event == WebNavBottomBarEvent.backParent) {
          _handlePopBackGesture(Utils.isDesktopSystem);
        } else if (event == WebNavBottomBarEvent.stop) {
          await stopLoading();
        } else if (event == WebNavBottomBarEvent.refresh) {
          if (await isLoading()) {
            await stopLoading();
            Future.delayed(Duration(milliseconds: 1000), () async {
              await _reloadWeb();
            });
          } else {
            await _reloadWeb();
          }
        } else if (event == WebNavBottomBarEvent.forward) {
          await goForward();
        } else if (event == WebNavBottomBarEvent.more) {
          _handleBottomBarMoreAction(appState, themeProvider, position);
        }
      },
    );
  }

  void _handleBottomBarMoreAction(AppState appState, ThemeProvider themeProvider, RelativeRect? rect) async {
    String? url = await getValidWebUrlString(); // await _getWebCurrentUrl();
    bool hasUrl = url != null;

    bool? addFilter;
    String? username;
    WebSite? vsite = site;
    if (vsite != null && vsite.isAuthorUrl(url)) {
      username = vsite.authorNameFromTitle(_webPageTitle);
      if (username != null && username.isNotEmpty && (vsite.user.name != username) && (vsite.user.url != url)) {
        addFilter = await BlackList.isExistBlacklist(username);
        //addFilter = isAdded;
        //mbuttonItems.add(_mbiFilterUser(name, isAdded));
      }
    }

    bool isLogin = vsite != null ? vsite.user.isLogin() : false;
    bool isGoLogin = false;
    if (url == null || vsite?.isLoginUrl(url) != true) {
      if (!isLogin) {
        isGoLogin = true;
      }
    }

    WebMorePopMenu.showWebPagePopMenu(
      context.mounted ? context : null,
      true,
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
      haveBlackList: Utils.isDesktopSystem == false, //和主窗口不同1
      haveSiteManager: true,
      selectedFn: (event) async {
        if (event == MenuButtonItemEvent.login) {
          WebSite? vsite = site;
          webViewOpenUrl(vsite?.loginUrl(appState.isMobileUA()));
        } else if (event == MenuButtonItemEvent.userHome) {
          // var appState = Provider.of<AppState>(context, listen: false);
          WebSite? v = site;
          if (v != null && v.user.isLogin()) {
            webViewOpenUrl(v.user.url);
          }
        } else if (event == MenuButtonItemEvent.home) {
          WebSite? vsite = site;
          webViewOpenUrl(vsite?.homeUrl(appState.isMobileUA()));
        } else if (event == MenuButtonItemEvent.area) {
          WebSite? vsite = site;
          webViewOpenUrl(vsite?.areaUrl(appState.isMobileUA()));
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
          var result = await context.pushNamed('settings');
          if (result != null && (result is Favor)) {
            setState(() {});
          }
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
        } else if (event == MenuButtonItemEvent.inBrowser) {
          //和主窗口不同2
          if (url != null) {
            _newTabOpenInWindow(url);
          }
        } else if (event == MenuButtonItemEvent.siteManger) {
          //检查配置,当前只支持ios
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
              if (Utils.isAndroid()) {
                _webViewController?.clearHistory();
              }
              if (site?.host != AppState.site.host) {
                _updateWebSite(AppState.site);
              }
              webViewOpenUrl(AppState.site.firstUrl(isMobileUA()));
            } else if (param != null && param.isNotEmpty) {
              if (v == 2) {
                webViewHelper?.innerBrowserOpen(mounted ? context : null, param, newWindow: true);
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
