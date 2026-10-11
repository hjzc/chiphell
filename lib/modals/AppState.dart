import 'dart:convert';
import 'dart:io';
import 'package:chiphell/data/black_list.dart';
import 'package:chiphell/data/challenge_hosts_manager.dart';
import 'package:chiphell/data/database_manager.dart';
import 'package:chiphell/data/main_site_manager.dart';
import 'package:chiphell/modals/Adblock.dart';
import 'package:chiphell/utils/util_map.dart';
import 'package:chiphell/utils/utils.dart';
import 'package:chiphell/web/web_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../common/type_utils.dart';
import '../data/app_prefs.dart';
import '../data/zj_memory_cache.dart';
import '../multi_windows/window_util.dart';
import '../sites/main_site.dart';
import '../sites/util_site.dart';
import '../sites/web_site.dart';
import '../upgrade/upgrade_view.dart';
import 'web_user.dart';
import '../utils/zs_log.dart';
import 'zj_cache.dart';
import 'web_image_url_downloader.dart';
//import 'package:easy_notifications/easy_notifications.dart';

typedef ThemeModeCallback = void Function(ThemeMode mode);

class AppState extends ChangeNotifier {
  static late final String webArchiveDir;
  static WebViewEnvironment? webViewEnvironment;
  WebImageUrlDownloader webDownloadQueue = WebImageUrlDownloader();

  void Function(int event, AppState object)? tallValueChangesCallBack;
  void Function(int event, AppState object)? talMainWebValueChangesCallBack;
  //macos window linux 有效
  static late String windowId;

  //系统默认UA
  late String _webDefaultUA;

  late int androidVersion;
  late PackageInfo appInfo;

  bool _autoUpgrade = false;
  bool _autoImageGallery = true;

  bool _webNotificationEnable = true;
  bool _webChiphellNotificationEnable = true;

  ///侧边右滑退出
  bool _swipeRightExit = true;

  ///blacklist, 0 关闭， 1对所有有效，2仅列表，3仅内容
  int _blackListApply = 1;
  static List<String> blackListApplyDesc = ['关闭', '全开启', '仅列表', '仅内容'];

  static List<String> webImageLoadModeDesc = ['默认', '无图', '懒人'];
  int _webImgMode = 0;

  static List<String> pressImageSizeDesc = ['无限制', '1MB', '3MB', '5MB', '10MB'];
  int _pressImageSize = 1024 * 1024;

  static List<String> webSearchEnginDesc = ['百度', '必应'];
  static List<String> webSearchEnginHomeUrls = [WebConstants.kWebSearchSiteBaidu, WebConstants.kWebSearchSiteBing];
  int _webSearchEngin = 0;
  String get webSearchEnginHomeUrl => webSearchEnginHomeUrls[_webSearchEngin];

  ///用户允许不安全https访问,
  //List<ChallengeHost> challengeHostCache = [];
  ZjMemoryCache challengeHostCache = ZjMemoryCache(maxCache: 5, maxCacheErrorKey: 50);

  final Map<String, WebSite> _webSiteCache = {};
  final List<String> _webSiteCacheKeyQueue = [];

  static late WebSite site;
  WebSite get webSite => site;
  PromptMsg? get webSitePromptMsg => webSite.user.msg;

  //单例
  static final AppState _instance = AppState._();
  factory AppState() {
    return _instance;
  }

  AppState._() : super();

  Future<void> init() async {
    _autoUpgrade = await AppPrefs.loadAutoUpgradeFromPrefs();
    _autoImageGallery = await AppPrefs.loadAutoImageGalleryFromPrefs();
    _webNotificationEnable = await AppPrefs.loadValueFromPrefs(WebConstants.kPrefWebNotificationEnable, value: true);
    _webChiphellNotificationEnable = await AppPrefs.loadValueFromPrefs(WebConstants.kPrefWebChiphellNotificationEnable, value: true);

    _webSearchEngin = await AppPrefs.loadValueFromPrefs(WebConstants.kPrefWebSearchEngin, type: APType.AT_Int, value: 0);
    _swipeRightExit = await AppPrefs.loadValueFromPrefs(WebConstants.kPrefSwipeRightExit, type: APType.AT_Bool, value: true);
    _blackListApply = await AppPrefs.loadValueFromPrefs(WebConstants.kPrefBlackListApplyType, type: APType.AT_Int, value: 1);
    _pressImageSize = await AppPrefs.loadValueFromPrefs(WebConstants.kPrefPressImageSize, type: APType.AT_Int, value: 1024 * 1024);

    webArchiveDir = await Utils.webViewAllowingReadAccessToFolder();

    if (Platform.isAndroid) {
      //macos 不支持 suffix_chiphell
      final dataDirectorySuffix = (await WebViewFeature.isStartupFeatureSupported(WebViewFeature.STARTUP_FEATURE_SET_DATA_DIRECTORY_SUFFIX))
          ? 'suffix_${WebConstants.kAppFolder}'
          : null;

      ///data/user/0/com.zorro.chiphell/app_flutter/chiphell/cache
      ////data/user/0/com.zorro.chiphell/app_flutter/chiphell/data
      final directoryBasePaths = (await WebViewFeature.isStartupFeatureSupported(WebViewFeature.STARTUP_FEATURE_SET_DIRECTORY_BASE_PATHS))
          ? ProcessGlobalConfigDirectoryBasePaths(
              cacheDirectoryBasePath: await Utils.androidWebCacheDirectoryBasePath(),
              dataDirectoryBasePath: await Utils.androidWebDataDirectoryBasePath(),
            )
          : null;
      try {
        // call apply before any API related to Android WebViews
        await ProcessGlobalConfig.instance().apply(
          settings: ProcessGlobalConfigSettings(
            dataDirectorySuffix: dataDirectorySuffix, //suffix_chiphell
            directoryBasePaths: directoryBasePaths,
          ),
        );
      } catch (e) {
        // use try/catch if you are calling more than once
        // for example, when hot restarting your Flutter App.
        ZsLog.d('Global Config Failed: ${e.toString()}');
      }
    }

    await DatabaseManager.init();

    // await Permission.camera.request();
    // await Permission.microphone.request();
    // await Permission.storage.request();

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      final availableVersion = await WebViewEnvironment.getAvailableVersion();
      assert(availableVersion != null, 'Failed to find an installed WebView2 runtime or non-stable Microsoft Edge installation.');
      AppState.webViewEnvironment = await WebViewEnvironment.create(
        settings: WebViewEnvironmentSettings(
          additionalBrowserArguments: kDebugMode ? '--enable-features=msEdgeDevToolsWdpRemoteDebugging' : null,
          userDataFolder: WebConstants.kAppFolder,
        ),
      );

      AppState.webViewEnvironment?.onBrowserProcessExited = (detail) {
        if (kDebugMode) {
          ZsLog.d('Browser process exited with detail: $detail');
        }
      };
      //在调用打印,devtools等外功能的时候，进程id 会改变
      AppState.webViewEnvironment?.onProcessInfosChanged = (BrowserProcessInfosChangedDetail detail) {
        if (kDebugMode) {
          ZsLog.d('Browser process info changed with detail: $detail');
        }
      };
    }

    if ((!kIsWeb) && defaultTargetPlatform == TargetPlatform.android) {
      //debug Inspect
      await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
    }

    // if (Utils.isMacOS() || Utils.isIOS() || Utils.isAndroid()) {
    //   //代理
    //   var proxyAvailable = await WebViewFeature.isFeatureSupported(
    //     WebViewFeature.PROXY_OVERRIDE,
    //   );
    //   if (proxyAvailable) {
    //     ProxyController proxyController = ProxyController.instance();
    //     await proxyController.clearProxyOverride();
    //     await proxyController.setProxyOverride(
    //       settings: ProxySettings(
    //         proxyRules: [ProxyRule(url: "https://myproxy.com")],
    //         bypassRules: ["www.excluded.*"],
    //       ),
    //     );
    //   }
    // }

    await UpgradeView.init();
    // if (webNotificationEnable) {
    //   await EasyNotifications.init();
    // }
    ZjCache.init();
  }

  String get appVersion => '${kDebugMode ? 'Debug' : ''}版本${appInfo.version}';

  bool get autoUpgrade => _autoUpgrade;
  set autoUpgrade(bool val) {
    if (val != _autoUpgrade) {
      _autoUpgrade = val;
      AppPrefs.saveAutoUpgradeToPrefs(_autoUpgrade);
      if (val) {
        UpgradeView.resetUpdateConfig();
      }
      notifyListeners();
    }
  }

  //bool get loadsImagesAutomatically => _webImgMode == 0;
  int get webImgMode => _webImgMode;
  set webImgMode(int val) {
    synWebImgMode(val, syn: true);
  }

  void synWebImgMode(int val, {bool syn = false}) {
    if (val != _webImgMode) {
      _webImgMode = val;
      AppPrefs.saveWebImgModeToPrefs(_webImgMode);
      notifyListeners();
      if (syn && tallValueChangesCallBack != null) {
        tallValueChangesCallBack?.call(WebConstants.kAppStateChangedEventImageMode, this);
      }
    }
  }

  /// 图片压缩大小
  int get pressImageSize => _pressImageSize;
  set pressImageSize(int val) {
    synPressImageSize(val, syn: true);
  }

  void synPressImageSize(int val, {bool syn = false}) {
    if (val != _pressImageSize) {
      _pressImageSize = val;
      AppPrefs.saveValueToPrefs(WebConstants.kPrefPressImageSize, type: APType.AT_Int, value: _pressImageSize);
      notifyListeners();
      if (syn && tallValueChangesCallBack != null) {
        tallValueChangesCallBack?.call(WebConstants.kAppStateChangedEventPressImageSize, this);
      }
    }
  }

  int pressImageSizeDescIndex() {
    int r = 0;
    if (_pressImageSize == 0) {
      r = 0;
    } else if (_pressImageSize == 1 * 1024 * 1024) {
      r = 1;
    } else if (_pressImageSize == 3 * 1024 * 1024) {
      r = 2;
    } else if (_pressImageSize == 5 * 1024 * 1024) {
      r = 3;
    } else if (_pressImageSize == 10 * 1024 * 1024) {
      r = 4;
    }
    return r;
  }

  String pressImageSizeSelectedDesc() {
    int i = pressImageSizeDescIndex();
    String rs = '限制大小 ${AppState.pressImageSizeDesc[i]}';
    return rs;
  }

  int setPressImageSizeDescIndex(int idx) {
    int r = idx;
    int nv = 0;
    if (idx == 0) {
      nv = 0;
    } else if (idx == 1) {
      nv = 1 * 1024 * 1024;
    } else if (idx == 2) {
      nv = 3 * 1024 * 1024;
    } else if (idx == 3) {
      nv = 5 * 1024 * 1024;
    } else if (idx == 4) {
      nv = 10 * 1024 * 1024;
    }
    if (nv != pressImageSize) {
      pressImageSize = nv;
    } else {
      r = -1;
    }
    return r;
  }

  int get webSearchEngin => _webSearchEngin;
  set webSearchEngin(int val) {
    synWebSearchEngin(val, syn: true);
  }

  void synWebSearchEngin(int val, {bool syn = false}) {
    if (val != _webSearchEngin) {
      _webSearchEngin = val;
      AppPrefs.saveValueToPrefs(WebConstants.kPrefWebSearchEngin, type: APType.AT_Int, value: _webSearchEngin);
      notifyListeners();
      if (syn && tallValueChangesCallBack != null) {
        tallValueChangesCallBack?.call(WebConstants.kAppStateChangedEventSearchEnginMode, this);
      }
    }
  }

  bool get autoImageGallery => _autoImageGallery;
  set autoImageGallery(bool val) {
    synAutoImageGallery(val, syn: true);
  }

  void synAutoImageGallery(bool val, {bool syn = false}) {
    if (val != _autoImageGallery) {
      _autoImageGallery = val;
      AppPrefs.saveAutoImageGalleryToPrefs(_autoImageGallery);
      // notifyListeners();
      if (syn && (tallValueChangesCallBack != null)) {
        tallValueChangesCallBack?.call(WebConstants.kAppStateChangedEventGallery, this);
      }
    }
  }

  bool get webNotificationEnable => _webNotificationEnable;
  set webNotificationEnable(bool val) {
    synWebNotificationEnable(val, syn: true);
  }

  void synWebNotificationEnable(bool val, {bool syn = false}) {
    if (val != _webNotificationEnable) {
      _webNotificationEnable = val;
      AppPrefs.saveValueToPrefs(WebConstants.kPrefWebNotificationEnable, type: APType.AT_Bool, value: _webNotificationEnable);
      // notifyListeners();// ui 不更新
      if (syn && (tallValueChangesCallBack != null)) {
        tallValueChangesCallBack?.call(WebConstants.kAppStateChangedEventNotification, this);
      }
      if (_webNotificationEnable == false && webChiphellNotificationEnable) {
        webChiphellNotificationEnable = _webNotificationEnable;
      }
    }
  }

  bool get webChiphellNotificationEnable => _webChiphellNotificationEnable;
  set webChiphellNotificationEnable(bool val) {
    synWebChiphellNotificationEnable(val, syn: true);
  }

  void synWebChiphellNotificationEnable(bool val, {bool syn = false}) {
    if (val != _webChiphellNotificationEnable) {
      _webChiphellNotificationEnable = val;
      AppPrefs.saveValueToPrefs(
        WebConstants.kPrefWebChiphellNotificationEnable,
        type: APType.AT_Bool,
        value: _webChiphellNotificationEnable,
      );
      // // notifyListeners();// ui 不更新
      // if (syn && (tallValueChangesCallBack != null)) {
      //   tallValueChangesCallBack?.call(
      //     WebConstants.kAppStateChangedEventNotification,
      //     this,
      //   );
      // }
    }
  }

  /// mobile used
  bool get swipeRightExit => _swipeRightExit;
  set swipeRightExit(bool val) {
    synSwipeRightExit(val, syn: true);
  }

  void synSwipeRightExit(bool val, {bool syn = false}) {
    if (val != _swipeRightExit) {
      _swipeRightExit = val;
      AppPrefs.saveValueToPrefs(WebConstants.kPrefSwipeRightExit, type: APType.AT_Bool, value: _swipeRightExit);
      notifyListeners();
    }
  }

  bool updateWebSitePromptMsg(PromptMsg msg) {
    return site.updatePromptMessage(msg);
  }

  // void _saveWebSitePromptMsg() {
  //   String json = jsonEncode(_webSitePromptMsg);
  //   AppPrefs.saveValueToPrefs(WebConstants.kPrefWebSitePromptMsg, type: APType.AT_String, value: json);
  // }

  int get blackListApply => _blackListApply;
  set blackListApply(int val) {
    synBlackListApply(val, syn: true);
  }

  void synBlackListApply(int val, {bool syn = false}) {
    if (val != _blackListApply) {
      _blackListApply = val;
      AppPrefs.saveValueToPrefs(WebConstants.kPrefBlackListApplyType, type: APType.AT_Int, value: _blackListApply);
      notifyListeners();
      if (syn && tallValueChangesCallBack != null) {
        tallValueChangesCallBack?.call(WebConstants.kAppStateChangedEventBlackListApply, this);
      }
    }
  }

  String webDefaultUA() {
    return _webDefaultUA;
  }

  String lastUrl() {
    return site.lastUrl;
    // _lastUrl ?? '';
  }

  static String defaultSiteUrl = 'https://cliff.imwork.net:19999';
  String appRootFirstUrl() {
    return site.firstUrl(isMobileUA()) ?? defaultSiteUrl;
    //return ((_lastUrl != null) && (_lastUrl!.isNotEmpty) && (_lastUrl!.length > 5)) ? _lastUrl! : getLoadHomeUrl();
  }

  //初始化时候设置
  void setWebDefaultUA(String? ua) {
    _webDefaultUA = ua ?? '';
  }

  String? webInitUA() {
    return getCurrentUAString();
  }

  String? webTabInitUA() {
    return getCurrentUAString();
  }

  WVUATypes _uaType = WVUATypes.uaAuto;

  Future<void> _asynReloadUAFromPrefs() async {
    int idx = await AppPrefs.loadUATypeFromPref();
    if (idx == 0) {
      _uaType = WVUATypes.uaAuto;
    } else if (idx == 1) {
      _uaType = WVUATypes.uaMobile;
    } else if (idx == 2) {
      _uaType = WVUATypes.uaPC;
    }
  }

  WVUATypes getSettingUaType() {
    return _uaType;
  }

  Future<void> toggleUa() async {
    WVUATypes tp = (_uaType == WVUATypes.uaPC) ? WVUATypes.uaMobile : WVUATypes.uaPC;

    await AppPrefs.saveUATypeToPref(tp.index);
    _uaType = tp;

    if (tallValueChangesCallBack != null) {
      tallValueChangesCallBack?.call(1, this);
    }
  }

  bool isMobileUA() {
    return getSettingUaType() == WVUATypes.uaMobile;
  }

  String? _getCurrentUAString(bool initFlag) {
    String? uastring;

    if (_uaType == WVUATypes.uaPC) {
      if (Platform.isMacOS) {
        //用系统的 在bilibili会提示浏览器太旧
        uastring = WebConstants.kUAMacos;
        // uastring = initFlag
        //     ? null
        //     : (_webDefaultUA.isEmpty ? WebConstants.kUAMacos : _webDefaultUA);
      } else if (Utils.isPad()) {
        //ipad
        if (Platform.isIOS) {
          //ipad
          uastring = initFlag ? null : (_webDefaultUA.isEmpty ? WebConstants.kUAiPad : _webDefaultUA);
        } else if (Platform.isAndroid) {
          //android 平板 默认UA就是跳到移动站
          uastring = WebConstants.kUAMacos;
        } else {
          //pad
          uastring = initFlag ? null : (_webDefaultUA.isEmpty ? WebConstants.kUAAndroidPad : _webDefaultUA);
        }
      } else if (Platform.isWindows) {
        uastring = initFlag ? null : (_webDefaultUA.isEmpty ? WebConstants.kUAWindows : _webDefaultUA);
      } else if (Platform.isLinux) {
        uastring = initFlag ? null : (_webDefaultUA.isEmpty ? WebConstants.kUALinux : _webDefaultUA);
      } else {
        //iphone/android
        uastring = WebConstants.kUAMacos;
      }
    } else if (_uaType == WVUATypes.uaMobile) {
      //
      if (Platform.isMacOS) {
        uastring = WebConstants.kUAiOS;
      } else if (Utils.isPad()) {
        if (Platform.isIOS) {
          //ipad
          uastring = WebConstants.kUAiOS;
        } else {
          //pad
          uastring = WebConstants.kUAAndroid;
        }
      } else if (Platform.isIOS) {
        uastring = initFlag ? null : (_webDefaultUA.isEmpty ? WebConstants.kUAiOS : _webDefaultUA);
      } else if (Platform.isWindows) {
        uastring = WebConstants.kUAiOS;
      } else if (Platform.isAndroid || Platform.isLinux) {
        uastring = initFlag ? null : (_webDefaultUA.isEmpty ? WebConstants.kUAAndroid : _webDefaultUA);
      } else {
        uastring = WebConstants.kUAiOS;
      }
    }

    ZsLog.d('_getCurrentUAString[$initFlag] webview ua: ${uastring ?? 'null'}');
    return uastring ?? _webDefaultUA;
  }

  String? getCurrentUAString() {
    return _getCurrentUAString(false);
  }

  String getSiteRootURL() {
    return site.siteUrl(isMobileUA()) ?? defaultSiteUrl;
    // SiteConstants.kWebHomeUrl;
  }

  Future<void> initLoad() async {
    if (Utils.isAndroid()) {
      // 获取Android系统版本（如"10"代表Android 10）
      var version = Platform.version;
      if (version.contains('.')) {
        final androidVersionStr = Platform.version.split('.').first;
        androidVersion = int.tryParse(androidVersionStr) ?? 0;
      }
    }
    appInfo = await PackageInfo.fromPlatform();
    await Utils.initDevice();

    if (Utils.isAndroid() || Utils.isIOS() || Utils.isMacOS() || Utils.isPad()) {
      setWebDefaultUA(await InAppWebViewController.getDefaultUserAgent());
    } else if (Utils.isWindows()) {
      setWebDefaultUA(WebConstants.kUAWindows);
    } else if (Platform.isLinux) {
      setWebDefaultUA(WebConstants.kUAMacos);
    } else {
      setWebDefaultUA(WebConstants.kUAMacos);
    }

    await _asynReloadUAFromPrefs();
    //调用前 先执行获取系统的UA
    if (_uaType == WVUATypes.uaAuto) {
      if (Utils.isDesktopSystem) {
        _uaType = WVUATypes.uaPC;
      } else if (Utils.isPad()) {
        if (Utils.isAndroid()) {
          //android 平板 自动跳转到mobile=2的站点
          _uaType = WVUATypes.uaMobile;
        } else {
          _uaType = WVUATypes.uaPC;
        }
      } else {
        _uaType = WVUATypes.uaMobile;
      }
      //ZsLog.i('init auto ua:${_webInitUA ?? ''}');
    } else {
      //String? uas = _getCurrentUAString(true);
      //  ZsLog.i('init set ua:${uas ?? ''}');
      //_webInitUA = uas;
    }

    _webImgMode = await AppPrefs.loadWebImgModeFromPrefs();

    await BlackList.initLoad();
    // userBlackList.addAll(['a', 'b', 'c', 'd', 'e', 'f', 'g']);

    // String cs = await InAppWebViewController.tRexRunnerCss;
    // FileOperations.writeStringToFile(cs, 'css.text');

    // String th = await InAppWebViewController.tRexRunnerHtml;
    // FileOperations.writeStringToFile(th, 'node.text');
    if (Platform.isMacOS || Platform.isIOS || Platform.isAndroid) {
      AdBlock().make();
    }

    //user web site db ready
    List<MainSite> sameSites = [];
    MainSite tSite = await MainSiteManager.initDataReady();
    if (tSite.validDomain) {
      String itemid = tSite.uuid;
      sameSites = await MainSiteManager.getSameDomainItems(
        tSite.domain,
        tSite.scheme,
        siteInfo: true,
        filterFn: (s, index) {
          return itemid == s.uuid;
        },
      );
    }
    site = WebSite.parserMainSite(tSite, sameSites: sameSites);
    site.mainSite = tSite;
    if (tSite.pageInfo.id <= 0) {
      await tSite.loadPageInfoFromDb();
    }

    //DownloadFile.test();
    // _darkcss = await Utils.loadAsset('assets/css/themedark.css');
    //test
    // await Future.delayed(Duration(seconds: 10));
    //阻塞UI sleep(Duration(seconds: 15));
    if (kDebugMode) {
      Utils.debugTest();
    }
  }

  /// https证书验证失败的站点缓存
  Future<ChallengeHost> getChallengeHost(String host, {bool used = false}) async {
    ChallengeHost? r = await challengeHostCache.load(
      host,
      (p) async {
        ChallengeHost? v;
        try {
          v = await ChallengeHostsManager.getItem(p);
        } catch (e) {
          ZsLog.e('load ChallengeHost error ', error: e);
        }
        v ??= ChallengeHost.from(0, p, 0);
        return v;
      },
      param: host,
      used: used,
    );
    r ??= ChallengeHost.from(0, host, 0);
    return r;
  }

  void cleanCssCacheErrorKeys() {
    challengeHostCache.cleanErrorKeys();
  }

  Future<void> handleExit() async {
    await site.save();
  }

  Future<void> handleHidden() async {
    await site.save();
  }

  /// 缓存操作
  List<WebSite> _getWebSiteList({bool includeMainSite = true}) {
    List<WebSite> r = [];
    if (includeMainSite) {
      r.add(site);
    }
    r.addAll(_webSiteCache.values);
    return r;
  }

  void _addWebSiteToCache(WebSite wsite) {
    final gcacheMaxCount = Utils.isDesktopSystem ? 20 : 5;
    _webSiteCache[wsite.host] = wsite;
    if (_webSiteCacheKeyQueue.contains(wsite.host)) {
      _webSiteCacheKeyQueue.remove(wsite.host);
    }
    _webSiteCacheKeyQueue.add(wsite.host);
    if (_webSiteCacheKeyQueue.length > gcacheMaxCount) {
      _webSiteCacheKeyQueue.removeAt(0);
    }
  }

  void _removeWebSiteFromCache(WebSite wsite) {
    UtilMap.safeRemoveForKey(_webSiteCache, wsite.host);
    if (_webSiteCacheKeyQueue.contains(wsite.host)) {
      _webSiteCacheKeyQueue.remove(wsite.host);
    }
  }

  WebSite? _webSiteFromCacheKey(String key) {
    return UtilMap.safeValueForStringKey(_webSiteCache, key);
  }

  void autorelaseWebSite(bool Function(WebSite s) block) {
    List<WebSite> r = _getWebSiteList();
    for (int i = 0; i < r.length; i++) {
      WebSite s = r[i];
      if (block(s)) {
        r.removeAt(i);
        i--;
        _webSiteCache.removeWhere((key, value) {
          bool r = value == s;
          if (_webSiteCacheKeyQueue.contains(key)) {
            _webSiteCacheKeyQueue.remove(key);
          }
          return r;
        });
      }
      s.save();
    }
  }

  void cleabWebSiteCache() {
    _webSiteCache.clear();
  }

  WebSite? _getWebSiteCacheFormUrl(String url, String schemeStr, String? authority, List<String> paths) {
    WebSite? r;
    if (site.isSite(url) || site.isSubSiteUrl(url)) {
      r = site;
    } else {
      String key = authority ?? Uri.parse(url).authority;
      r = _webSiteFromCacheKey(key);
      if (r == null) {
        for (int i = 0; i < paths.length; i++) {
          var sb = paths.sublist(0, i + 1);
          String nk = '$key/${sb.join('/')}';
          r = _webSiteFromCacheKey(nk);
          if (r != null) {
            break;
          }
        }
      }
      if (r == null) {
        List<WebSite> rs = _getWebSiteList(includeMainSite: false);
        for (int i = 0; i < rs.length; i++) {
          WebSite s = rs[i];
          if ((s.schemeString == schemeStr) && (s.isSite(url) || s.isSubSiteUrl(url))) {
            r = s;
            break;
          }
        }
      }
    }
    return r;
  }

  WebSite? _getWebSiteCacheFormMainSite(MainSite ms) {
    WebSite? r;
    if (site.mainSite?.isEqualSite(ms) == true || site.mainSite?.isSubSite(ms) == true) {
      r = site;
    } else {
      r = _webSiteFromCacheKey(ms.host);
      if (r == null) {
        List<WebSite> rs = _getWebSiteList(includeMainSite: false);
        for (int i = 0; i < rs.length; i++) {
          WebSite s = rs[i];
          if (s.mainSite?.isEqualSite(ms) == true || s.mainSite?.isSubSite(ms) == true) {
            r = s;
            break;
          }
        }
      }
    }
    return r;
  }

  ///从缓存中获得url对应的WebSite
  Future<WebSite?> getWebSiteFormUrl(String url) async {
    WebSite? r;
    if (Utils.validHttpUrl(url)) {
      Uri u = Uri.parse(url);
      if (u.hasAuthority) {
        String ha = u.authority;
        List<String> paths = List.from(u.pathSegments);
        String schemeStr = u.scheme;
        var schemeInt = MainSite.siteUrlSchemeIndexFromString(schemeStr);
        var domain = UtilSite.domainFromUrl(uri: u);
        if (ha.isNotEmpty) {
          r = _getWebSiteCacheFormUrl(url, schemeStr, ha, paths);
          if (r == null) {
            List<MainSite> sameSites = [];
            MainSite? ms = await MainSiteManager.getItem(ha, true, paths: paths, schemeVal: schemeInt);
            if (ms == null) {
              if (domain != null && (domain.length > 3) && MainSite.siteUrlSchemeIndexValid(schemeInt)) {
                List<MainSite> array = await MainSiteManager.getSameDomainItems(
                  domain,
                  schemeInt,
                  siteInfo: true,
                  filterFn: (s, index) {
                    return false;
                  },
                );
                if (array.isNotEmpty) {
                  ms = array.first;
                  if (array.length > 1) {
                    sameSites.addAll(array.sublist(1));
                  }
                  await ms.loadPageInfoFromDb();
                }
              } else {
                /// 无效domain
              }
            } else {
              await ms.loadPageInfoFromDb();
              if (ms.validDomain) {
                String itemid = ms.uuid;
                sameSites = await MainSiteManager.getSameDomainItems(
                  ms.domain,
                  ms.scheme,
                  siteInfo: true,
                  filterFn: (s, index) {
                    return itemid == s.uuid;
                  },
                );
              }
            }
            if (ms != null) {
              r = WebSite.parserMainSite(ms, sameSites: sameSites);
              _addWebSiteToCache(r);
            } else {
              r = WebSite.parserUrl(u.origin, u, orgUrl: url);
            }
          }
        }
      }
    }
    return r;
  }

  /// 更新main site
  Future<WebSite?> updateWebSiteFromJs(
    MainSite ms, {
    bool onlyMain = false,
    Map<String, dynamic>? info,
    void Function(MainSite ms, bool newSite)? siteCallBack,
  }) async {
    WebSite? r;
    var url = ms.url;
    int changedCount = 0;
    String? uid = UtilMap.safeStringForKey(info, 'uid');

    /// 单前页面的 url https://cliff.imwork.net:19999/xfbbs/home.php?mod=space&uid=1&do=profile
    //String? curl = UtilMap.safeStringForKey(info, 'curl');

    /// 单前页面的 host "cliff.imwork.net:19999"
    //String? chost = UtilMap.safeStringForKey(info, 'chost');

    /// 单前页面的origin https://cliff.imwork.net:19999
    //  String? corigin = UtilMap.safeStringForKey(info, 'corigin');

    /// "/xfbbs/"
    // String? cpath = UtilMap.safeStringForKey(info, 'cpath');

    // String? ableDiscuzUrl;
    // if (corigin != null && corigin.toLowerCase().startsWith('http') && corigin.length > 5) {
    //   if (corigin.endsWith('/')) {
    //     corigin = corigin.substring(0, corigin.length - 1);
    //   }
    //   if (cpath != null && cpath.isNotEmpty) {
    //     ///  /xfbbs/, /, /a/b/c/
    //     String foldPath = Utils.delUrlPathExtension(cpath);
    //     ableDiscuzUrl = '$corigin$foldPath';
    //   } else {
    //     ableDiscuzUrl = '$corigin/';
    //   }
    // }

    if (site.mainSite != null && (url == site.mainSite?.url)) {
      ms.selected = site.mainSite!.selected;
      ms.type = site.mainSite!.type;
      ms.source = site.mainSite!.source;
      var vals = site.mainSite?.updateFromMap(ms.toMap());
      if (vals != null && vals.isNotEmpty) {
        if (await site.mainSite?.saveToDb() == true) {
          changedCount++;
        }
      }
      r = site;
    } else if (site.isSubSite(ms)) {
      await site.updateMainSite(ms);
      r = site;
    } else if (!onlyMain) {
      Map<String, dynamic> vals = {};
      Uri u = Uri.parse(url);
      var host = u.authority;
      List<String> paths = List.from(u.pathSegments);
      WebSite? cacheItem = _getWebSiteCacheFormMainSite(ms);
      MainSite? itm = cacheItem?.mainSite;
      if (cacheItem != null) {
        if (!await cacheItem.updateMainSite(ms)) {
          ZsLog.i('main site[${ms.host}] update failed.');
        }
        r = cacheItem;
      } else {
        itm = await MainSiteManager.getItem(host, true, paths: paths);
        if (itm != null) {
          ms.source = itm.source;
          ms.type = itm.type;
          vals = itm.updateFromMap(ms.toMap());
          if (vals.isNotEmpty && (await itm.saveToDb())) {
            ZsLog.i('main site[${itm.host}] update success.');
          } else {
            ZsLog.i('main site[${itm.host}] update failed.');
          }
          await itm.loadPageInfoFromDb();
        } else {
          ms.selected = 0;
          ms.source = MainSiteSourceType.detect.index;
          if (await ms.saveToDb()) {
            itm = ms;
            ZsLog.d('main site[${ms.host}] insert success.');
            if (siteCallBack != null) {
              siteCallBack.call(ms, true);
            }
          } else {
            itm = ms;
            ZsLog.d('main site[${ms.host}] insert failed.');
          }
          await itm.loadPageInfoFromDb();
        }
        List<MainSite>? sameSites;
        if (itm.validDomain) {
          String itemid = itm.uuid;
          sameSites = await MainSiteManager.getSameDomainItems(
            itm.domain,
            itm.scheme,
            siteInfo: true,
            filterFn: (s, index) {
              return itemid == s.uuid;
            },
          );
        }
        r = WebSite.parserMainSite(itm, sameSites: sameSites);
        if (r.mainSite?.isDb == true) {
          _addWebSiteToCache(r);
        }
      }
    }

    //if (ableDiscuzUrl != null) {
    // if (r?.addSubHost(ableDiscuzUrl) == true) {
    //   changedCount++;
    // }
    //}
    if (uid != null && uid.isNotEmpty) {
      if (r?.updateUserInfo(uid: uid) == true) {
        changedCount++;
      }
    }
    if (changedCount > 0 && r != null) {
      await r.save();
    }
    return r;
  }

  Future<bool> selecteMainSite(MainSite oldsite, MainSite newSite) async {
    bool r = false;
    r = await MainSiteManager.selecteSite(oldsite, newSite);
    if (r) {
      WebSite? newWebSite = _getWebSiteCacheFormMainSite(newSite);
      if (newWebSite == null) {
        List<MainSite>? sameSites;
        if (newSite.validDomain) {
          String itemid = newSite.uuid;
          sameSites = await MainSiteManager.getSameDomainItems(
            newSite.domain,
            newSite.scheme,
            siteInfo: true,
            filterFn: (s, index) {
              return (itemid == s.uuid);
            },
          );
        }
        newWebSite = WebSite.parserMainSite(newSite, sameSites: sameSites);
        newWebSite.mainSite = newSite;
        await newSite.loadPageInfoFromDb();
      }

      WebSite? oldWebSite = site;
      newWebSite.mainSite?.setSelected();
      site = newWebSite;
      oldWebSite.mainSite?.unSelecte();
      _removeWebSiteFromCache(newWebSite);
      _addWebSiteToCache(oldWebSite);

      ///当前webview reload 发送消息给子窗口
      if ((tallValueChangesCallBack != null)) {
        ///desktop
        tallValueChangesCallBack?.call(WebConstants.kAppStateChangedEventMainWebSiteChanged, this);
      }
      if (Utils.isMobile()) {
        notifyListeners();
        // if (talMainWebValueChangesCallBack != null) {
        //   talMainWebValueChangesCallBack?.call(0, this);
        // }
      }
    }
    return r;
  }

  ///在desktop平台 窗口收到主站点变化消息，进行处理
  void synMainWebViewChanged(String mainSiteJson, {bool syn = false}) async {
    MainSite? newSite;
    try {
      var mp = jsonDecode(mainSiteJson);
      newSite = MainSite.fromMap(mp);
    } catch (e) {
      ZsLog.e('decode mainsite json failed.', error: e);
    }
    if (newSite != null && (newSite.host != site.host)) {
      WebSite? newWebSite = _getWebSiteCacheFormMainSite(newSite);
      if (newWebSite == null) {
        List<MainSite>? sameSites;
        if (newSite.validDomain) {
          String itemid = newSite.uuid;
          sameSites = await MainSiteManager.getSameDomainItems(
            newSite.domain,
            newSite.scheme,
            siteInfo: true,
            filterFn: (s, index) {
              return (itemid == s.uuid);
            },
          );
        }
        newWebSite = WebSite.parserMainSite(newSite, sameSites: sameSites);
        newWebSite.mainSite = newSite;
        await newSite.loadPageInfoFromDb();
      }
      WebSite? oldWebSite = site;
      newWebSite.mainSite?.setSelected();
      site = newWebSite;
      oldWebSite.mainSite?.unSelecte();
      await oldWebSite.save();

      _removeWebSiteFromCache(newWebSite);
      _addWebSiteToCache(oldWebSite);

      //如果是主窗口，应该手动刷新页面
      if (Utils.isDesktopSystem) {
        if (WindowUtil().winInfo.isMainWindow() || ZsLog.winOrder == 0) {
          //刷新主窗口的页面
          notifyListeners();
          // if (talMainWebValueChangesCallBack != null) {
          //   talMainWebValueChangesCallBack?.call(0, this);
          // }
        }
      } else {
        notifyListeners();
      }
    }
  }
}
