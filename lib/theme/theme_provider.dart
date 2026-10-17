import 'dart:convert';

import 'package:chiphell/theme/theme_app.dart';
import 'package:chiphell/utils/aes_util.dart';
import 'package:chiphell/utils/utils.dart';
import 'package:chiphell/utils/wb_sdk_extension.dart';
import 'package:chiphell/web/web_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../data/app_prefs.dart';
import '../data/zj_memory_cache.dart';
import '../utils/zs_log.dart';
import '../web/zj_web_notification.dart';

class ThemeProvider extends ChangeNotifier {
  void Function(int event, ThemeProvider object)? tallValueChangesCallBack;
  final ZjMemoryCache _siteExCssJsCaches = ZjMemoryCache(maxCache: 10, maxCacheErrorKey: 50);

  //单例
  static final ThemeProvider _instance = ThemeProvider._();
  factory ThemeProvider() {
    return _instance;
  }
  ThemeProvider._() : super();
  bool _initFlag = false;
  bool _isSystemDarkTheme = false; // 系统的是否为dark主题
  ThemeMode _themeMode = ThemeMode.system; // 默认跟随系统

  static late String _sdkjs;
  UserScript? preUserScript;
  UserScript? currentUserScript;
  late UserScript _jsNotificationApiUserScript;
  late UserScript _jsNotificationDbUserScript;

  double _webLoadDarkMaskMaxProgress = 0.8;
  double get webLoadDarkMaskMaxProgress => _webLoadDarkMaskMaxProgress;
  double _webTabLoadDarkMaskMaxProgress = 0.69;
  double get webTabLoadDarkMaskMaxProgress => _webTabLoadDarkMaskMaxProgress;

  Future<void> initTheme() async {
    if (!_initFlag) {
      _initFlag = true;
      _isSystemDarkTheme = getSystemSchedulerBindingThemeIsDark();
      int? r = await AppPrefs.loadThemeModeToPref();
      if (r != null) {
        _themeMode = _themeModeFromCode(r);
      }
      if (Utils.isAndroi10Under()) {
        _webLoadDarkMaskMaxProgress = 0.95;
        _webTabLoadDarkMaskMaxProgress = 0.85;
      } else if (Utils.isMacOS()) {
        _webLoadDarkMaskMaxProgress = 0.5;
        _webTabLoadDarkMaskMaxProgress = 0.5;
      }
    }
  }

  Future<void> initLoad() async {
    ///TODO:开启js调试
    //ThemeProvider._sdkjs = await Utils.loadAsset('assets/js/wbsdk_release.js');
    ThemeProvider._sdkjs = await AesUtil.decodeWBSDKJS();

    //init web notification
    _jsNotificationApiUserScript = UserScript(
      source: await rootBundle.loadString('assets/js/web_notification.js'),
      injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
    );

    await ZjWebNotificationPermissionDb.loadSavedPermissions();
    final json = jsonEncode(ZjWebNotificationPermissionDb.getPermissions());
    _jsNotificationDbUserScript = UserScript(
      source:
          """
    (function(window) {
      var notificationPermissionDb = $json;
      if (notificationPermissionDb[window.location.host] === 'granted') {
        Notification._permission = 'granted';
      } 
    })(window);
    """,
      injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
    );
  }

  UserScript? windowsScrollBarUserScripter() {
    UserScript? r;
    if (Utils.isWindows()) {
      r = UserScript(source: windowsWebViewScrollBarJs, injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START);
    }
    return r;
  }

  String get windowsWebViewScrollBarJs {
    const String js = """
           (function() {
            function injectStyle() {
              var style = document.createElement('style');
              style.setAttribute('type', 'text/css');
              style.setAttribute('id', '_zjw_scrollbar_dark');
              style.textContent = `
                ::-webkit-scrollbar { width: 12px; background: transparent; }
                ::-webkit-scrollbar-thumb { background: #555555; border-radius: 6px; }
                ::-webkit-scrollbar-thumb:hover { background: #777777; }
                ::-webkit-scrollbar-corner { background: transparent;}
              `;
              (document.head || document.documentElement).appendChild(style);
            }
            if (document.readyState === 'loading') {
              document.addEventListener('DOMContentLoaded', injectStyle);
            } else {
              injectStyle();
            }
          })();
          """;
    const String jsFn = """
       function appWindowsUpdateScrollbarCss(toDark){
            var darkIds = '_zjw_scrollbar_dark';
            var lightIds = '_zjw_scrollbar_light';
            var darkThumb = '#555555';
            var lightThumb = '#C1C1C1';
            var darkThumbHover = '#777777';
            var lightThumbHover = '#A8A8A8';
            var ids =toDark? lightIds:darkIds;
            ids = "#"+ids;
            var node = document.querySelector(ids);
            if(node){
              var ctx= node.innerHTML;
              var c= ctx.replace(toDark?lightThumb:darkThumb,toDark?darkThumb:lightThumb);
              c= c.replace(toDark?lightThumbHover:darkThumbHover,toDark?darkThumbHover:lightThumbHover);
              node.setAttribute('id', toDark? darkIds:lightIds);
              node.innerHTML = c;
            }
          }
        """;
    if (isDarkThreme()) {
      return js + jsFn;
    } else {
      //rgba(0, 0, 0, 0.2) rgba(0, 0, 0, 0.35)
      var lightJs = js
          .replaceFirst('_zjw_scrollbar_dark', '_zjw_scrollbar_light')
          .replaceFirst('#555555', '#C1C1C1')
          .replaceFirst('#777777', '#A8A8A8');

      return lightJs + jsFn;
    }
  }

  ///主題改變后，在windows平臺應該執行
  String get windowsWebViewScrollBarUpdateJsFn {
    return isDarkThreme() ? "appWindowsUpdateScrollbarCss(1)" : "appWindowsUpdateScrollbarCss(0)";
  }

  bool updateSystemDarkTheme() {
    return setSystemDarkTheme(getSystemThemeIsDark());
  }

  // 系统主题监听
  // void _addSystemThemeListener() {
  //   // _brightnessListener = () {
  //   //   updateSystemDarkTheme();
  //   // };
  //   // WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged =  _brightnessListener;
  // }

  // 清理资源
  @override
  void dispose() {
    //WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged =null;
    super.dispose();
  }

  bool setSystemDarkTheme(bool dark) {
    bool r = false;
    if (dark != _isSystemDarkTheme) {
      _isSystemDarkTheme = dark;
      if (themeMode == ThemeMode.system) {
        notifyListeners();
        r = true;
      }
    }
    return r;
  }

  bool get isSystemDarkTheme => _isSystemDarkTheme;

  static List<String> themeModeDesList() {
    return ['系统', '浅色', '深色'];
  }

  String themeModeDes() {
    return themeModeDesList()[_themeModeCode(_themeMode)];
  }

  int currentThemeModeCode() {
    return _themeModeCode(themeMode);
  }

  void synThemeModeFromCode(int i, {bool syn = false}) {
    synThemeMode(_themeModeFromCode(i), syn: syn);
  }

  set themeMode(ThemeMode themeMode) {
    synThemeMode(themeMode, syn: true);
  }

  void synThemeMode(ThemeMode themeMode, {bool syn = false}) {
    if (themeMode != _themeMode) {
      preUserScript = currentUserScript;
      _themeMode = themeMode;
      currentUserScript = null;
      AppPrefs.saveThemeModeToPref(_themeModeCode(themeMode));
      notifyListeners();
      if ((syn == true) && (tallValueChangesCallBack != null)) {
        tallValueChangesCallBack?.call(WebConstants.kThemeProviderChangedEventTheme, this);
      }
    }
  }

  ThemeMode get themeMode => _themeMode;

  int _themeModeCode(ThemeMode themeMode) {
    int r = 0;
    if (themeMode == ThemeMode.light) {
      r = 1;
    } else if (themeMode == ThemeMode.dark) {
      r = 2;
    }
    return r;
  }

  ThemeMode _themeModeFromCode(int code) {
    ThemeMode r = ThemeMode.system;
    if (code == 1) {
      r = ThemeMode.light;
    } else if (code == 2) {
      r = ThemeMode.dark;
    }
    return r;
  }

  //当前app theme 模式
  bool isDarkThreme() {
    bool rc = isSystemDarkTheme;
    if (_themeMode == ThemeMode.light) {
      rc = false;
    } else if (_themeMode == ThemeMode.dark) {
      rc = true;
    }
    return rc;
  }

  Brightness themeBrightness() {
    return isDarkThreme() ? Brightness.dark : Brightness.light;
  }

  //获得应用本身当前主题的是否为暗黑模式
  static bool getWidgetThemeIsDark(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark;
  }

  // 应用本身主题模式 final brightness = Theme.of(context).brightness;
  // 手机当前主题模式  final platformBrightness =
  //       SchedulerBinding.instance.platformDispatcher.platformBrightness;
  // 手机当前主题模式 final platformBrightness1 =
  //       WidgetsBinding.instance.platformDispatcher.platformBrightness;
  // 手机当前主题模式  final brightness1 = MediaQuery.of(context).platformBrightness;

  // 获取机器系统主题,是否为暗黑问题
  static bool getSystemThemeIsDark() {
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark;
  }

  // 获取机器系统主题,是否为暗黑问题
  static bool getSystemSchedulerBindingThemeIsDark() {
    final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark;
  }

  // 获取机器系统主,是否为暗黑问题题
  static bool getSystemMediaQueryThemeIsDark(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark;
  }

  SystemUiOverlayStyle getWebPageUIOverlayStyle() {
    if (Utils.isAndroid()) {
      return ThemeApp.androidStatusBar(isDarkThreme());
    } else {
      return ThemeApp.statusBar(isDarkThreme());
    }
  }

  // UserScript textSizeUserScript() {
  //   var rc = currentUserScript;
  //   if (rc == null) {
  //     rc = UserScript(
  //       source: kTextSizeSourceJS.replaceAll(kTextSizePlaceholder, '$textSize'),
  //       injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
  //     );
  //     currentUserScript = rc;
  //   }
  //   return rc;
  // }
  String appThemeJs() {
    return "this.appThemeMode=${currentThemeModeCode()};";
  }

  String get sdkjs {
    var prefix = (kDebugMode ? webSdkDebug : webSdkRelease);
    var sdk = ThemeProvider._sdkjs.replaceFirst(RegExp(r"this.appThemeMode=-1;"), appThemeJs());
    sdk = '$prefix $sdk';
    return sdk;
  }

  Future<String> getWebErrorPage(String? url, String? errDesc) async {
    return """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <style>
    @media (prefers-color-scheme: ${isDarkThreme() ? "light" : "dark"}) {body {background:black !important; background-color: black !important;color: white !important; }}
    ${await InAppWebViewController.tRexRunnerCss}
    </style>
    <style>
    .interstitial-wrapper {
        box-sizing: border-box;
        font-size: 1em;
        line-height: 1.6em;
        margin: 0 auto 0;
        max-width: 600px;
        width: 100%;
    }
    </style>
</head>
<body>
    ${await InAppWebViewController.tRexRunnerHtml}
    <div class="interstitial-wrapper">
      <h1>Website not available</h1>
      <p>Could not load web pages at <strong>${url ?? ''}</strong> because:</p>
      <p>${errDesc ?? ''}</p>
    </div>
</body>
    """;
  }

  UserScript? sdkJsUserScriptPre() {
    return preUserScript;
  }

  UserScript sdkJsUserScript() {
    var rc = currentUserScript;
    if (rc == null) {
      rc = UserScript(source: sdkjs, injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START, forMainFrameOnly: true);
      currentUserScript = rc;
    }
    return rc;
  }

  Future<void> updateSDKJSUserScript(InAppWebViewController? webViewController) async {
    if (webViewController == null) {
      return;
    }
    if (!kIsWeb) {
      var pre = preUserScript;
      if (pre != null) {
        if (!await webViewController.removeUserScript(userScript: pre)) {
          ZsLog.d('remove pre sdkjs userscript failed!');
        }
        preUserScript = null;
      }
      await webViewController.addUserScript(userScript: sdkJsUserScript());
    }
  }

  String _extensionCacheKey(String host, bool mobile, bool js) {
    return "$host${mobile ? '-mb' : ''}.${js ? 'js' : 'css'}";
  }

  Future<String?> asynLoadHostExtension(String host, bool mobile, {bool used = false, int jscssType = 0}) async {
    String? r;
    if (jscssType == 0 || jscssType == 1) {
      /// load css
      String key = _extensionCacheKey(host, mobile, false);
      r = await _siteExCssJsCaches.load(
        key,
        (p) async {
          String? r;
          try {
            r = await Utils.webViewSiteExtensionUserConfigContent('$p');
            if (r == null || r.isNotEmpty) {
              r = await rootBundle.loadString("assets/extension/$p");
            }
          } catch (e) {
            ZsLog.e('load css error[$p] ', error: e);
          }
          return r;
        },
        param: key,
        used: used,
      );
    }
    if (jscssType == 0 || jscssType == 2) {
      /// load js
      String key = _extensionCacheKey(host, mobile, true);
      r = await _siteExCssJsCaches.load(
        key,
        (p) async {
          String? r;
          try {
            r = await Utils.webViewSiteExtensionUserConfigContent('$p');
            if (r == null || r.isNotEmpty) {
              r = await rootBundle.loadString("assets/extension/$p");
            }
          } catch (e) {
            ZsLog.e('load css error[$p] ', error: e);
          }
          return r;
        },
        param: key,
        used: used,
      );
    }

    return r;
  }

  String? getHostExtensionFromCache(List<String> hosts, bool mobile, {bool jsOrCss = true}) {
    String? r;
    for (int i = 0; i < hosts.length; i++) {
      var h = hosts[i];
      r = _siteExCssJsCaches.get(_extensionCacheKey(h, mobile, jsOrCss));
      if (r != null) {
        break;
      }
    }
    return r;
  }

  void cleanCssCacheErrorKeys() {
    _siteExCssJsCaches.cleanErrorKeys();
  }

  UserScript get jsNotificationApiUserScript => _jsNotificationApiUserScript;
  UserScript get jsNotificationDbUserScript => _jsNotificationDbUserScript;

  //font size
  double get textScaleFacotr => WidgetsBinding.instance.platformDispatcher.textScaleFactor;
  double get labelLargeFontsize => 16 * textScaleFacotr;
  double get labelMediumFontsize => 14 * textScaleFacotr;
  double get labelSmallFontsize => 12 * textScaleFacotr;
  //  this.displayLarge,
  //   this.displayMedium,
  //   this.displaySmall,
  //   this.headlineLarge,
  //   this.headlineMedium,
  //   this.headlineSmall,
  //   this.titleLarge,
  //   this.titleMedium,
  //   this.titleSmall,
  //   this.bodyLarge,
  //   this.bodyMedium,
  //   this.bodySmall,
  //   this.labelLarge,
  //   this.labelMedium,
  //   this.labelSmall,
}
