// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:chiphell/data/Favorites.dart';
import 'package:chiphell/modals/WebTextSize.dart';
import 'package:chiphell/router/zj_router.dart';
import 'package:chiphell/upgrade/upgrade_view.dart';
import 'package:chiphell/net/internet_status_manager.dart';
import 'package:chiphell/utils/utils.dart';
import 'package:chiphell/multi_windows/window_util.dart';
import 'package:chiphell/web/browser_root.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:provider/provider.dart';
import 'package:chiphell/modals/AppState.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tray_manager/tray_manager.dart';

import 'data/black_list.dart';
import 'router/system_ui_helper.dart';
import 'web/home_page.dart';
import 'multi_windows/app_window_info.dart';
import 'multi_windows/window_controller.dart';
import 'theme/theme_app.dart';
import 'theme/theme_provider.dart';

import 'package:window_manager/window_manager.dart';

import 'net/net_state.dart';
import 'web/web_constants.dart';
import '../utils/zs_log.dart';

Future<void> main(List<String> args) async {
  // FlutterMemoryAllocations.instance.addListener(
  //   (ObjectEvent event) => LeakTracking.dispatchObjectEvent(event.toMap()),
  // );
  // LeakTracking.start();
  WidgetsFlutterBinding.ensureInitialized();

  ///TODO:启动时候全屏
  SystemUIHelper.setFullScreen();

  late AppState a;
  late ThemeProvider t;
  late WebTextSize w;
  late NetStateQueue n;
  if (Utils.isDesktopSystem) {
    await WindowUtil.ensureInitialized();
    final windowController = await WindowController.fromCurrentEngine();
    windowController.doCustomInitialize();
    final arguments = WindowArguments.fromArguments(windowController.arguments);
    if (arguments.businessId == WindowArguments.businessIdBrowser) {
      var bargs = arguments as BrowserWindowArguments;
      ZsLog.winOrder = bargs.windowOrder;
    }
    await ZsLog.init();
    a = AppState();
    await a.init();
    t = ThemeProvider();
    await t.initTheme();
    w = WebTextSize();
    n = NetStateQueue();
    ZsLog.d('App started with arguments: $args');

    AppWindowsCenter info = AppWindowsCenter();
    // await WindowUtil.ensureInitialized();
    //final windowController = await WindowController.fromCurrentEngine();
    // windowController.doCustomInitialize();
    // final arguments = WindowArguments.fromArguments(windowController.arguments);
    ZsLog.d('Window id:${windowController.windowId} arguments: $arguments');
    info.windowId = windowController.windowId;
    info.arguments = arguments;
    await WindowUtil.setWindowFunctions(info, ThemeProvider().isDarkTheme());

    if (arguments.businessId == WindowArguments.businessIdMain) {
      return runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => t),
            ChangeNotifierProvider(create: (context) => a),
            ChangeNotifierProvider(create: (context) => w),
            ChangeNotifierProvider(create: (context) => n),
          ],
          child: MyApp(),
        ),
      );
    } else if (arguments.businessId == WindowArguments.businessIdBrowser) {
      var bargs = arguments as BrowserWindowArguments;
      // ZsLog.winOrder = bargs.windowOrder;
      //await AesUtil.initAes();
      // await t.initLoad(); //theme
      // await w.initTextSize(); //text size
      // await a.initLoad(); // appstate 避免重复执行
      return runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => t),
            ChangeNotifierProvider(create: (context) => a),
            ChangeNotifierProvider(create: (context) => w),
            ChangeNotifierProvider(create: (context) => n),
          ],
          child: BrowserRoot(url: bargs.url, webWindowId: bargs.webWindowId, windowOrder: bargs.windowOrder),
        ),
      );
    } else {
      //不应该存在
      return runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => t),
            ChangeNotifierProvider(create: (context) => a),
            ChangeNotifierProvider(create: (context) => w),
            ChangeNotifierProvider(create: (context) => n),
          ],
          child: BrowserRoot(url: WebConstants.kWebSearchSiteBaidu, webWindowId: -1, windowOrder: -1),
        ),
      );
    }
  } else {
    await ZsLog.init();
    a = AppState();
    await a.init();
    t = ThemeProvider();
    await t.initTheme();
    w = WebTextSize();
    n = NetStateQueue();
  }
  return runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => t),
        ChangeNotifierProvider(create: (context) => a),
        ChangeNotifierProvider(create: (context) => w),
        ChangeNotifierProvider(create: (context) => n),
      ],
      child: MyApp(),
    ),
  );

  // if (Utils.isAndroid()) {
  //   await Permission.storage.request();
  // }
  // await Permission.camera.request();
  // await Permission.microphone.request();
  // ui.window.titleBarStyle = ui.SystemUiOverlayStyle(
  //   systemNavigationBarColor: Colors.blue[900], // 设置底部标题栏颜色
  //   statusBarColor: Colors.transparent, // 透明状态栏，让系统导航栏颜色显示
  //   systemNavigationBarIconBrightness: Brightness.light, // 图标亮度（可选）
  // );

  // if (Platform.isAndroid) {
  //   SystemChrome.setSystemUIOverlayStyle(
  //     SystemUiOverlayStyle(
  //       statusBarColor: Colors.transparent, // 将状态栏颜色设置为透明
  //       statusBarIconBrightness: Brightness.light, // 设置状态栏图标为亮色（如白色）
  //     ),
  //   );
  // }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener, TrayListener, AutomaticKeepAliveClientMixin {
  late GoRouter _goRouter;
  late InternetStatusManager netMangager;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  GlobalKey mainPageKey = GlobalKey();
  GlobalKey browserPageKey = GlobalKey();

  StreamSubscription<void>? _windowsChangedSubscription;
  ThemeProvider? _themeProviderNoListen;

  @override
  bool get wantKeepAlive => true;
  GoRouter get goRouter => _goRouter;

  Future<void> onNetworkConnected(bool connected) async {
    var queue = Provider.of<NetStateQueue>(context, listen: false);
    var r = queue.addNetState(connected);
    if (Utils.isDesktopSystem && r) {
      //发个消息给子窗口
      WindowUtil().winInfo.synWindowEventValue([WebConstants.kWinSubEventNet, connected ? 1 : 0]);
    }
  }

  ///只支持windows macos linux
  void _updateWindowsTheme(ThemeProvider? themePro) {
    if (Utils.isDesktopSystem) {
      var theme = themePro ?? Provider.of<ThemeProvider>(context, listen: false);
      WindowUtil().winInfo.setBrightness(theme.isDarkTheme() ? Brightness.dark : Brightness.light);
    }
  }

  ///只支持windows macos linux
  void _initStateOnDesktopSystem(AppState appState, ThemeProvider themePro, WebTextSize webTextSize) {
    appState.tallValueChangesCallBack = (int event, AppState obj) {
      if (!Utils.isDesktopSystem) {
        return;
      }
      if (event == WebConstants.kAppStateChangedEventImageMode) {
        WindowUtil().winInfo.synWindowEventValue([WebConstants.kWinSubEventImageMode, obj.webImgMode]);
      } else if (event == WebConstants.kAppStateChangedEventSearchEnginMode) {
        WindowUtil().winInfo.synWindowEventValue([WebConstants.kWinSubEventSearchEngin, obj.webSearchEngin]);
      } else if (event == WebConstants.kAppStateChangedEventNotification) {
        //notification enable/disable
        WindowUtil().winInfo.synWindowEventValue([WebConstants.kWinSubEventNotification, obj.webNotificationEnable]);
      } else if (event == WebConstants.kAppStateChangedEventGallery) {
        WindowUtil().winInfo.synWindowEventValue([WebConstants.kWinSubEventGallery, obj.autoImageGallery]);
      } else if (event == WebConstants.kAppStateChangedEventBlackListApply) {
        WindowUtil().winInfo.synWindowEventValue([WebConstants.kWinSubEventBlackListApply, obj.blackListApply]);
      } else if (event == WebConstants.kAppStateChangedEventMainWebSiteChanged) {
        WindowUtil().winInfo.synWindowEventValue([WebConstants.kWinSubEventMainWebSiteChanged, obj.webSite.mainSiteJsonString()]);
      } else if (event == WebConstants.kAppStateChangedEventPressImageSize) {
        WindowUtil().winInfo.synWindowEventValue([WebConstants.kWinSubEventPressImageSize, obj.pressImageSize]);
      }
    };

    webTextSize.tallValueChangesCallBack = (int event, WebTextSize obj) {
      if (!Utils.isDesktopSystem) {
        return;
      }
      // if (Utils.isDesktopSystem && event == WebConstants.kWebTextSizeChangedEventTextZoom) {
      //   WindowUtil().synWindowEventValue([WebConstants.kWinSubEventTextZoom, obj.textRealZoom]);
      // }
      //else if (Utils.isDesktopSystem && event == WebConstants.kWebTextSizeChangedEventPageZoom) {
      //  WindowUtil().synWindowEventValue([WebConstants.kWinSubEventPageZoom, obj.pageRealZoom]);
      // }
    };

    themePro.tallValueChangesCallBack = (int event, ThemeProvider obj) {
      if (!Utils.isDesktopSystem) {
        return;
      }
      if (WebConstants.kThemeProviderChangedEventTheme == event) {
        _updateWindowsTheme(obj);
        WindowUtil().winInfo.synWindowEventValue([WebConstants.kWinSubEventTheme, obj.currentThemeModeCode()]);
      }
    };

    WindowUtil().winInfo.onMainMessage = (AppWindowInfo info, int event, dynamic value) async {
      int r = 0;
      if (event == WebConstants.kWinEventHead) {
        if (value is List) {
          var key = value[0];
          if (key == WebConstants.kWinSubEventTheme) {
            var val = value[1];
            if (val is int) {
              themePro.synThemeModeFromCode(val);
              _updateWindowsTheme(null);
              //转发给其他窗口
              WindowUtil().winInfo.synWindowValue(event, value, exclude: info);
            }
          } else if (key == WebConstants.kWinSubEventBlackList) {
            var val = value[1];
            if (val is int) {
              var val1 = value[2];
              if (val1 is String) {
                BlackList.synBlacklistChangedStateHandle(val, val1);
                //转发给其他窗口
                WindowUtil().winInfo.synWindowValue(event, value, exclude: info);
              }
            }
          } else if (key == WebConstants.kWinSubEventFavor) {
            var val = value[1];
            if (val is String) {
              var val1 = value[2];
              if (val1 is String) {
                var val2 = value[3];
                if (val2 is int) {
                  var f = await Favorites().updateLookUrl(val, val1, setFavor: val2 == 1 ? true : false);
                  if (f != null) {
                    r = 1;
                  }
                }
              }
            }
          } else if (key == WebConstants.kWinSubEventImageMode) {
            var val = value[1];
            if (val is int) {
              appState.synWebImgMode(val);
              WindowUtil().winInfo.synWindowValue(event, value, exclude: info);
            }
          } else if (key == WebConstants.kWinSubEventSearchEngin) {
            var val = value[1];
            if (val is int) {
              appState.synWebSearchEngin(val);
              WindowUtil().winInfo.synWindowValue(event, value, exclude: info);
            }
          } else if (key == WebConstants.kWinSubEventGallery) {
            var val = value[1];
            if (val is bool) {
              appState.synAutoImageGallery(val);
              WindowUtil().winInfo.synWindowValue(event, value, exclude: info);
            }
          } else if (key == WebConstants.kWinSubEventNotification) {
            var val = value[1];
            if (val is bool) {
              appState.synWebNotificationEnable(val);
              WindowUtil().winInfo.synWindowValue(event, value, exclude: info);
            }
          } else if (key == WebConstants.kWinSubEventBlackListApply) {
            var val = value[1];
            if (val is int) {
              appState.synBlackListApply(val);
              WindowUtil().winInfo.synWindowValue(event, value, exclude: info);
            }
          } else if (key == WebConstants.kWinSubEventMainWebSiteChanged) {
            var val = value[1];
            if (val is String) {
              //收到子窗口改变主站点的事件
              appState.synMainWebViewChanged(val);
              //发给其他子窗口
              WindowUtil().winInfo.synWindowValue(event, value, exclude: info);
            }
          } else if (key == WebConstants.kWinSubEventPressImageSize) {
            var val = value[1];
            if (val is int) {
              //收到子窗口改变主站点的事件
              appState.synPressImageSize(val);
              //发给其他子窗口
              WindowUtil().winInfo.synWindowValue(event, value, exclude: info);
            }
          }
        }
      }
      return r;
    };

    _initTryMenu();
    _windowsChangedSubscription = onWindowsChanged.listen((_) {
      WindowUtil().winInfo.refreshSubWindows();
    });
  }

  void _themeValuesChanged() {
    if (Utils.isDesktopSystem) {
      //跟随系统主题时候休要修改窗口的主题
      _updateWindowsTheme(null);
    }
  }

  @override
  void initState() {
    if (Utils.isDesktopSystem) {
      windowManager.addListener(this);
      trayManager.addListener(this);
    }
    super.initState();
    var appState = Provider.of<AppState>(context, listen: false);
    var webTextSize = Provider.of<WebTextSize>(context, listen: false);
    var themePro = Provider.of<ThemeProvider>(context, listen: false);
    // if (Utils.isDesktopSystem) {
    //   themePro.addListener(_desktopThemeValuesChanged);
    // }

    netMangager = InternetStatusManager()
      ..initInternetStatusManager(
        onInternetChanged: (result) {},
        onInternetConnected: () {
          onNetworkConnected(true);
        },
        onInternetDisconnected: () {
          onNetworkConnected(false);
        },
      );
    if (Utils.isDesktopSystem) {
      _initStateOnDesktopSystem(appState, themePro, webTextSize);
    }
    _goRouter = ZjRouter.mainRouter(navigatorKey, appState, mainPageKey, browserPageKey);
    //在启动页面初始化数据
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    // 在这里获取并缓存，此时 context 有效
    var themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    if (_themeProviderNoListen != themeProvider) {
      _themeProviderNoListen?.removeListener(_themeValuesChanged);
      _themeProviderNoListen = themeProvider;
      _themeProviderNoListen?.addListener(_themeValuesChanged);
    }
    var webTextSize = Provider.of<WebTextSize>(context, listen: false);
    webTextSize.initSysTextZoom(WidgetsBinding.instance.platformDispatcher.textScaleFactor);
  }

  @override
  void dispose() {
    _themeProviderNoListen?.removeListener(_themeValuesChanged);
    _themeProviderNoListen = null;
    if (Utils.isDesktopSystem) {
      windowManager.removeListener(this);
      trayManager.removeListener(this);
      _windowsChangedSubscription?.cancel();
      _windowsChangedSubscription = null;
    }
    netMangager.dispose();
    _windowsChangedSubscription = null;
    ZsLog.d('main widget dispose');
    ZsLog.close();
    super.dispose();
  }

  /// Handle application events.
  // @override
  // Future<void> didChangeAppLifecycleState(
  //     AppLifecycleState lifecycleState) async {
  //   super.didChangeAppLifecycleState(lifecycleState);
  //   // When app has resumed from background.
  //   if (lifecycleState == AppLifecycleState.resumed) {
  //     await updateVersionInfo();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    //Consumer 局部刷新
    var themePro = Provider.of<ThemeProvider>(context, listen: true);
    var appState = Provider.of<AppState>(context, listen: true);
    final virtualWindowFrameBuilder = VirtualWindowFrameInit();
    final mainApp = MaterialApp.router(
      theme: ThemeApp.getTD(),
      darkTheme: ThemeApp.getDarkTD(),
      themeMode: themePro.themeMode,
      debugShowCheckedModeBanner: false,
      title: WebConstants.kAppTitle,
      locale: Locale('zh', 'CN'),
      builder: (context, child) {
        Widget nextW = child ?? Container();
        Widget? content = appState.autoUpgrade ? _upgradeBuilder(context, nextW, appState) : nextW;
        if (Utils.isDesktopSystem) {
          return virtualWindowFrameBuilder(context, content);
        }
        return content;
      },
      routerConfig: goRouter,
    );

    super.build(context);
    return mainApp;
  }

  Widget _upgradeBuilder(BuildContext context, Widget? child, AppState appState) {
    final upgradeWidget = UpgradeView(
      windowsAppcastURL: WebConstants.gWindowsAppcastURL,
      macosAppcastURL: WebConstants.gMacosAppcastURL,
      androidAppcastURL: WebConstants.gAndroidAppcastURL,
      navigatorKey: _goRouter.routerDelegate.navigatorKey,
      callback: (BuildContext context, int event) {
        ZsLog.i('upgrade event :$event');
        if (context.mounted == false) {}
      },
      childWidgetCallBack: (BuildContext context) {
        return child;
      },
    );
    return upgradeWidget;
  }

  //获得第一个widget
  HomePage? getRoot() {
    return mainPageKey.currentWidget as HomePage?;
  }

  Future<void> _initTryMenu() async {
    if (Utils.isDesktopSystem) {
      await WindowUtil.setTryMenu();
      setState(() {});
    }
  }

  @override
  void onTrayIconMouseDown() {
    if (Utils.isDesktopSystem) {
      WindowUtil.show();
    }
  }

  @override
  void onTrayIconRightMouseDown() {
    if (Utils.isMacOS() || Utils.isWindows()) {
      trayManager.popUpContextMenu();
    }
  }

  @override
  Future<void> onTrayMenuItemClick(MenuItem menuItem) async {
    if (Utils.isDesktopSystem) {
      await WindowUtil.onTrayMenuItemClick(context, menuItem, (int event) {
        getRoot()?.windowMenuEvent(event);
      });
    }
  }

  //linux 下会进入两次
  @override
  void onWindowClose() {
    ZsLog.d('收到window close 事件');
    if (Utils.isDesktopSystem) {
      //必须传入当前router 最上面的widget context，否则弹窗将出错
      WindowUtil.windowWillClose(navigatorKey.currentContext, () async {
        //在这里判断
        await AppState().handleExit();
        await getRoot()?.windowClose(true);
      });
    }
  }

  @override
  void onWindowFocus() {
    if (Utils.isDesktopSystem) {
      WindowUtil().setNoMinimize();
      if (Utils.isWindows()) {
        getRoot()?.windowFocus();
      } else {
        //getRoot()?.windowFocus();
        // setState(() {});
      }
    }
  }

  @override
  void onWindowBlur() {
    if (Utils.isWindows()) {
      getRoot()?.windowBlur();
    } else {
      //getRoot()?.windowBlur();
      //  setState(() {});
    }
  }

  @override
  void onWindowMinimize() {
    ZsLog.d('main onWindowMinimize');
    if (Utils.isWindows() && !WindowUtil().winInfo.isWillClose) {
      getRoot()?.windowMinimize();
    } else {}
  }

  // /// Emitted when window is maximized.
  // void onWindowMaximize() {}

  // /// Emitted when the window exits from a maximized state.
  // void onWindowUnmaximize() {}

  // /// Emitted when the window is restored from a minimized state.
  // void onWindowRestore() {}

  // /// Emitted after the window has been resized.
  // void onWindowResize() {}

  // /// Emitted once when the window has finished being resized.
  // ///
  // /// @platforms macos,windows
  // @override
  // void onWindowResized() {}

  // /// Emitted when the window is being moved to a new position.
  // @override
  // void onWindowMove() {}

  // /// Emitted once when the window is moved to a new position.
  // ///
  // /// @platforms macos,windows
  // @override
  // void onWindowMoved() {}

  // /// Emitted when the window enters a full-screen state.
  // @override
  // void onWindowEnterFullScreen() {}

  // /// Emitted when the window leaves a full-screen state.
  // @override
  // void onWindowLeaveFullScreen() {}

  // /// Emitted when the window entered a docked state.
  // ///
  // /// @platforms windows
  // @override
  // void onWindowDocked() {}

  // /// Emitted when the window leaves a docked state.
  // ///
  // /// @platforms windows
  // @override
  // void onWindowUndocked() {}

  /// Emitted all events.
  @override
  void onWindowEvent(String eventName) {
    if (Utils.isDesktopSystem) {
      // debugPrint("------window event: $eventName---------------");
      WindowUtil.onWindowEvent(eventName);
    }
  }
}
