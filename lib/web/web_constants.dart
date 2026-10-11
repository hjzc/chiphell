enum WebViewCoreVersions {
  bs0(0, desc: '6.2.0_beta2'),
  bs1(1, desc: '6.2.0_beta3');

  final int code;
  final String? desc;
  const WebViewCoreVersions(this.code, {this.desc});

  @override
  String toString() => "code:$code,description:${desc ?? 'null'}";
}

class WebConstants {
  static WebViewCoreVersions webCore() {
    return WebViewCoreVersions.bs1;
  }

  static const String kAppTitle = 'Chiphell';
  static const String kAppFolder = 'chiphell';
  static const String kAppLocalFolder = 'Chiphell';

  static const String kWebAllowingReadAccessFolder = 'web';
  static const String kWebViewSiteExtensionUserFolder = 'sites';
  static const String kLogFolder = 'logs';
  static const String kAppPictureFolder = 'Pictures';
  static const String kAppPictureCNFolder = '图片';

  //lable
  static const String kWebUrlAddressInputHint = '搜索或输入网站名称';
  //search
  static const String kWebSearchSiteBaidu = "https://www.baidu.com/";
  static const String kWebSearchSiteBing = "https://cn.bing.com/";

  static const String kNullUrl = 'about:blank';

  //web custom scheme
  // zorro_add_filter://username
  static const String kCustomUrlSchemeAddFilter = 'zorro_add_filter';
  static const String kCustomUrlSchemeHeaderAddFilter = 'zorro_add_filter://';

  //upgrade
  static const gWindowsAppcastURL = 'https://cliff.imwork.net:19999/chiphell/upgrade/appcast_windows.xml';
  static const gMacosAppcastURL = 'https://cliff.imwork.net:19999/chiphell/upgrade/appcast_macos.xml';
  static const gAndroidAppcastURL = 'https://cliff.imwork.net:19999/chiphell/upgrade/appcast_android.xml';

  static const String kUAMacos =
      '"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15';
  static const String kUAiOS =
      'Mozilla/5.0 (iPhone; CPU iPhone OS 18_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.4 Mobile/15E148';
  static const String kUAAndroid =
      'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.5414.117 Mobile Safari/537.36';
  static const String kUAiPad = 'Mozilla/5.0 (iPad; CPU OS 18_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148';
  static const String kUAAndroidPad =
      'Mozilla/5.0 (Linux; Android 13; XYZ Tablet) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.5414.117 Safari/537.36';
  static const String kUAWindows = kUAMacos;
  // 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36 Edg/140.0.0.0';
  static const String kUALinux = "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:149.0) Gecko/20100101 Firefox/149.0";

  /// {User-Agent: Mozilla/5.0 (Linux; Android 12; BRE-AL00b Build/HUAWEIBRE-AL00b; wv)

  static const int kUrlRedirectMax = 5;

  //prefs save keys
  static const String kPrefUAKey = 'webuatype';
  static const String kPrefCookiesKey = 'webcookies';
  static const String kPrefLastUrl = 'weblasturl';
  static const String kPrefThemeMode = 'thememode';
  static const String kPrefWebTextZoom = 'webtextsize';
  static const String kPrefWebPageZoom = 'webpagezoom';
  static const String kPrefAutoUpgrade = 'appUpgrade';
  static const String kPrefWebImgMode = 'webImgMode';
  static const String kPrefAutoImageGallery = 'autoImageGallery';
  static const String kPrefWebNotificationEnable = 'webNotificationEnable';
  static const String kPrefWebSearchEngin = 'webSearchEngin';
  static const String kPrefPressImageSize = 'pressImageSize';

  static const String kPrefWebChiphellNotificationEnable = 'webChiphellNotificationEnable';
  static const String kPrefSwipeRightExit = 'swipeRightExit';
  static const String kPrefWebSitePromptMsg = 'webSitePromptMsg';
  static const String kPrefBlackListApplyType = 'blackListApplyType';

  static const int kWinEventHead = 10;
  //主窗口单向发给子窗口
  static const int kWinM2SEventHead = 11;
  //发给自己窗口
  static const int kWinSelfEventHead = 12;

  //AppState 的成员改变标记
  static const int kAppStateChangedEventImageMode = 0;
  static const int kAppStateChangedEventNotification = 1;
  static const int kAppStateChangedEventGallery = 2;
  static const int kAppStateChangedEventSearchEnginMode = 3;
  static const int kAppStateChangedEventBlackListApply = 4;
  static const int kAppStateChangedEventMainWebSiteChanged = 5;
  static const int kAppStateChangedEventPressImageSize = 0;

  //ThemeProvider 的成员改变标记
  static const int kThemeProviderChangedEventTheme = 0;
  //WebTextSize 的成员改变标记
  static const int kWebTextSizeChangedEventTextZoom = 0;
  static const int kWebTextSizeChangedEventPageZoom = 1;

  static const String kWinSubEventNet = 'Net';
  static const String kWinSubEventTheme = 'theme';
  static const String kWinSubEventBlackList = 'blacklist';
  static const String kWinSubEventFavor = 'favor';
  static const String kWinSubEventPageZoom = 'pagezoom';
  static const String kWinSubEventImageMode = 'imagemode';
  static const String kWinSubEventSearchEngin = 'searchengin';
  static const String kWinSubEventNewWebTab = 'newWebTab';

  static const String kWinSubEventNotification = 'notification';
  static const String kWinSubEventGallery = 'Gallery';
  static const String kWinSubEventBlackListApply = 'blackListApply';

  static const String kWinSubEventMainWebSiteChanged = 'mainsitechanged';

  static const String kWinSubEventPressImageSize = 'pressImageSize';
}
