import 'dart:async';
import 'dart:io';
import 'package:chiphell/theme/theme_provider.dart';
import 'package:chiphell/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'modals/Adblock.dart';
import '../utils/zs_log.dart';
import 'modals/AppState.dart';
//android 切换主题 会出错

class Ibrowser extends InAppBrowser {
  Ibrowser({
    super.windowId,
    super.initialUserScripts,
    super.pullToRefreshController,
  }) : super(webViewEnvironment: AppState.webViewEnvironment);

  @override
  void onBrowserCreated() {
    configSettings();
    super.onBrowserCreated();
    ZsLog.d("\n\nBrowser Created!\n\n");
  }

  void configSettings() async {
    //InAppBrowserClassSettings? tset = await this.getSettings();
    //tset?.browserSettings.toolbarTopTranslucent = true;
    //var aState = Provider.of<AppState>(this.context, listen: true);
  }

  // @override
  // void dispose() {
  //   super.dispose();
  // }

  @override
  void onLoadStart(url) {}

  @override
  void onLoadStop(url) {
    pullToRefreshController?.endRefreshing();
  }

  @override
  Future<PermissionResponse?>? onPermissionRequest(
    PermissionRequest permissionRequest,
  ) async {
    return PermissionResponse(
      action: PermissionResponseAction.GRANT,
      resources: permissionRequest.resources,
    );
  }
  // @override
  // UnmodifiableListView<UserScript>? get initialUserScripts (){
  //   UserScript  UserScript(
  //         source: appState.sdkjs,
  //         injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
  //         forMainFrameOnly: true,
  //       ),
  //  super.initialUserScripts;
  // }

  @override
  void onLoadError(url, code, message) {
    pullToRefreshController?.endRefreshing();
  }

  @override
  void onProgressChanged(progress) {
    if (progress == 100) {
      pullToRefreshController?.endRefreshing();
    }
  }

  @override
  void onExit() {
    ZsLog.d("\n\nBrowser closed!\n\n");
  }

  @override
  Future<NavigationActionPolicy> shouldOverrideUrlLoading(
    navigationAction,
  ) async {
    ZsLog.d("\n\nOverride ${navigationAction.request.url}\n\n");
    return NavigationActionPolicy.ALLOW;
  }

  // @override
  // void onMainWindowWillClose() {
  //   close();
  // }

  // @override
  // Future<bool?>? onCreateWindow(CreateWindowAction createWindowAction) {
  //   return super.onCreateWindow(createWindowAction);
  // }

  static Future<Ibrowser> iBrowserOpenUrl(String url) async {
    late Ibrowser browser;
    PullToRefreshController? pullToRefreshController =
        kIsWeb ||
            ![
              TargetPlatform.iOS,
              TargetPlatform.android,
            ].contains(defaultTargetPlatform)
        ? null
        : PullToRefreshController(
            settings: PullToRefreshSettings(color: Colors.black),
            onRefresh: () async {
              if (Platform.isAndroid) {
                browser.webViewController?.reload();
              } else if (Platform.isIOS) {
                browser.webViewController?.loadUrl(
                  urlRequest: URLRequest(
                    url: await browser.webViewController?.getUrl(),
                  ),
                );
              }
            },
          );

    browser = Ibrowser(pullToRefreshController: pullToRefreshController);
    var openUrl = WebUri(url);
    if (openUrl.scheme.isEmpty) {
      openUrl = WebUri(
        (!kIsWeb
                ? "https://www.baidu.com/search?q="
                : "https://www.bing.com/search?q=") +
            url,
      );
    }

    bool isdark = ThemeProvider.getSystemThemeIsDark();
    //bool systemDark = AppState().isSystemDarkTheme;

    bool hideToolbarBottom = false;
    Color ttbgcolor = isdark
        ? Colors.black
        : const Color.fromARGB(255, 240, 240, 240);
    ModalPresentationStyle presentationStyle =
        ModalPresentationStyle.FULL_SCREEN;
    if (Utils.isAndroidPad || Utils.isIOSPad) {
      presentationStyle = ModalPresentationStyle.PAGE_SHEET;
      ttbgcolor = isdark
          ? Utils.isAndroid()
                ? const Color.fromARGB(255, 117, 117, 117)
                : Colors.black
          : const Color.fromARGB(255, 255, 246, 254);
    } else if (Utils.isIOS()) {
      //后退和前进按有bug
      hideToolbarBottom = true;
      presentationStyle = ModalPresentationStyle.OVER_CURRENT_CONTEXT;
      ttbgcolor = isdark
          ? Colors.black
          : const Color.fromARGB(255, 255, 246, 254);
    } else {
      ttbgcolor = isdark
          ? const Color.fromARGB(255, 117, 117, 117)
          : const Color.fromARGB(255, 240, 240, 240);
    }

    await browser.openUrlRequest(
      urlRequest: URLRequest(url: openUrl),
      settings: InAppBrowserClassSettings(
        browserSettings: InAppBrowserSettings(
          //    toolbarTopTranslucent: false,
          // toolbarBottomTranslucent: false,
          //toolbarTopTintColor: Colors.red,
          hideToolbarBottom: hideToolbarBottom,
          //toolbarTopTranslucent: false,
          toolbarTopBackgroundColor: ttbgcolor,
          presentationStyle: presentationStyle,

          //OVER_FULL_SCREEN,
        ),
        webViewSettings: InAppWebViewSettings(
          isInspectable: kDebugMode,
          useShouldOverrideUrlLoading: true,
          // transparentBackground: false,
          //  underPageBackgroundColor: Colors.blue,
          useOnLoadResource: true,
          //  transparentBackground: true,
          mediaPlaybackRequiresUserGesture: false,
          allowsInlineMediaPlayback: true,
          contentBlockers: AdBlock().contentBlockers,
          allowingReadAccessTo: (AppState.webArchiveDir.isNotEmpty)
              ? WebUri('file://${AppState.webArchiveDir}/')
              : null,
          //mediaPlaybackRequiresUserGesture: false,
        ),
      ),
    );
    return browser;
  }

  static Future<void> iBrowserOutOpenUrl(String url) async {
    var openUrl = WebUri(url);
    if (openUrl.scheme.isEmpty) {
      openUrl = WebUri(
        (!kIsWeb
                ? "https://www.baidu.com/search?q="
                : "https://www.bing.com/search?q=") +
            url,
      );
    }
    await InAppBrowser.openWithSystemBrowser(url: openUrl);
  }
}
