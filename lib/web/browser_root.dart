import 'package:chiphell/modals/AppState.dart';
import 'package:chiphell/router/zj_router.dart';
import 'package:chiphell/theme/theme_provider.dart';
import 'package:chiphell/multi_windows/window_util.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../data/black_list.dart';
import '../modals/WebTextSize.dart';
import '../multi_windows/app_window_info.dart';
import '../theme/theme_app.dart';
import '../net/net_state.dart';
import '../utils/utils.dart';
import 'web_constants.dart';
import 'browser_main_view.dart';
import '../utils/zs_log.dart';

class BrowserRoot extends StatefulWidget {
  final String? url;
  final int webWindowId;
  final int windowOrder;
  const BrowserRoot({super.key, required this.url, required this.webWindowId, required this.windowOrder});
  @override
  State<BrowserRoot> createState() => _BrowserRootState();

  int? validWebWindowId() {
    return webWindowId == -1 ? null : webWindowId;
  }
}

class _BrowserRootState extends State<BrowserRoot> with AutomaticKeepAliveClientMixin, WindowListener {
  late GoRouter _goRouter;
  GlobalKey mainPageKey = GlobalKey();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  bool shouldExit = false;
  @override
  bool get wantKeepAlive => !shouldExit;
  GoRouter get goRouter => _goRouter;

  bool windowListenerFlag = false;

  ThemeProvider? _themeProviderNoListen;

  //获得第一个widget
  BrowserMainView? getRoot() {
    return mainPageKey.currentWidget as BrowserMainView?;
  }

  void _updateWindowsTheme(ThemeProvider? themePro) {
    if (Utils.isDesktopSystem) {
      var theme = themePro ?? Provider.of<ThemeProvider>(context, listen: false);
      WindowUtil().winInfo.setBrightness(theme.isDarkTheme() ? Brightness.dark : Brightness.light);
    }
  }

  void _initStateOnDesktopSystem(AppState appState) {
    var webTextSize = Provider.of<WebTextSize>(context, listen: false);
    var themePro = Provider.of<ThemeProvider>(context, listen: false);
    var queue = Provider.of<NetStateQueue>(context, listen: false);

    appState.tallValueChangesCallBack = (int event, AppState obj) {
      //发个消息给主窗口
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
      // if (Utils.isDesktopSystem && event == WebConstants.kWebTextSizeChangedEventTextZoom) {
      //   WindowUtil().synWindowEventValue([WebConstants.kWinSubEventTextZoom, obj.textRealZoom]);
      // }
      //else if (Utils.isDesktopSystem && event == WebConstants.kWebTextSizeChangedEventPageZoom) {
      //  WindowUtil().synWindowEventValue([WebConstants.kWinSubEventPageZoom, obj.pageRealZoom]);
      // }
    };

    themePro.tallValueChangesCallBack = (int event, ThemeProvider obj) {
      if (event == WebConstants.kThemeProviderChangedEventTheme) {
        _updateWindowsTheme(obj);
        //发个消息给主窗口
        WindowUtil().winInfo.synWindowEventValue([WebConstants.kWinSubEventTheme, obj.currentThemeModeCode()]);
      }
    };

    windowManager.addListener(this);
    windowListenerFlag = true;
    //收到主窗口要关闭了，子窗口应该清空资源
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
            }
          } else if (key == WebConstants.kWinSubEventNet) {
            var val = value[1];
            if (val is int) {
              queue.addNetState(val == 1);
            }
          } else if (key == WebConstants.kWinSubEventBlackList) {
            var val = value[1];
            if (val is int) {
              var val1 = value[2];
              if (val1 is String) {
                BlackList.synBlacklistChangedStateHandle(val, val1);
              }
            }
          } else if (key == WebConstants.kWinSubEventGallery) {
            var val = value[1];
            if (val is bool) {
              appState.synAutoImageGallery(val);
            }
          } else if (key == WebConstants.kWinSubEventNotification) {
            var val = value[1];
            if (val is bool) {
              appState.synWebNotificationEnable(val);
            }
          }
          // else if (key == WebConstants.kWinSubEventPageZoom) {
          //   var val = value[1];
          //   if (val is double) {
          //     webTextSize.synPageZoom(val);
          //   }
          //}
          else if (key == WebConstants.kWinSubEventImageMode) {
            var val = value[1];
            if (val is int) {
              appState.synWebImgMode(val);
            }
          } else if (key == WebConstants.kWinSubEventSearchEngin) {
            var val = value[1];
            if (val is int) {
              appState.synWebSearchEngin(val);
            }
          } else if (key == WebConstants.kWinSubEventBlackListApply) {
            var val = value[1];
            if (val is int) {
              appState.synBlackListApply(val);
            }
          } else if (key == WebConstants.kWinSubEventMainWebSiteChanged) {
            var val = value[1];
            if (val is String) {
              appState.synMainWebViewChanged(val);
            }
          } else if (key == WebConstants.kWinSubEventPressImageSize) {
            var val = value[1];
            if (val is int) {
              appState.synPressImageSize(val);
            }
          }
        }
      } else if (event == WebConstants.kWinM2SEventHead || event == WebConstants.kWinSelfEventHead) {
        if (value is List) {
          var key = value.first;
          if (key == WebConstants.kWinSubEventNewWebTab) {
            var val = value[1];
            if (val is String) {
              getRoot()?.addNewWebTab(val);
              r = 1;
            }
          }
        }
      }
      return r;
    };
  }

  void _themeValuesChanged() {
    if (Utils.isDesktopSystem) {
      //跟随系统主题时候休要修改窗口的主题
      _updateWindowsTheme(null);
    }
  }

  @override
  void initState() {
    super.initState();
    //var appState = Provider.of<AppState>(context, listen: true); 注册依赖不能调用
    var appState = Provider.of<AppState>(context, listen: false);

    // var webTextSize = Provider.of<WebTextSize>(context, listen: false);
    if (Utils.isDesktopSystem) {
      _initStateOnDesktopSystem(appState);
    }
    _goRouter = ZjRouter.browserRouter(navigatorKey, appState, widget.url, widget.validWebWindowId(), mainPageKey);
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

    if (shouldExit) {
    } else {
      var webTextSize = Provider.of<WebTextSize>(context, listen: false);
      webTextSize.initSysTextZoom(WidgetsBinding.instance.platformDispatcher.textScaleFactor);
    }
  }

  @override
  void dispose() {
    _themeProviderNoListen?.removeListener(_themeValuesChanged);
    _themeProviderNoListen = null;
    if (Utils.isDesktopSystem) {
      AppState().tallValueChangesCallBack = null;
      ThemeProvider().tallValueChangesCallBack = null;
      WebTextSize().tallValueChangesCallBack = null;
      WindowUtil().winInfo.onMainMessage = null;
      if (windowListenerFlag) {
        windowManager.removeListener(this);
        windowListenerFlag = false;
      }
      //fix 桌面版本关掉log，移动设备版本不需要关闭
      //ZsLog.close();
    }
    _themeProviderNoListen = null;
    ZsLog.d("browser root dispose");
    super.dispose();
  }

  @override
  void deactivate() {
    //Widget从树中移除时触发
    super.deactivate();
    ZsLog.d('did changd app lifecycle :  deactivate');
  }

  @override
  Widget build(BuildContext context) {
    //Consumer 局部刷新
    // var appState = Provider.of<AppState>(context, listen: false);
    var themePro = Provider.of<ThemeProvider>(context, listen: true);
    //var webTextSize = Provider.of<WebTextSize>(context, listen: false);
    final virtualWindowFrameBuilder = VirtualWindowFrameInit();
    final mainApp = MaterialApp.router(
      theme: ThemeApp.getTD(),
      darkTheme: ThemeApp.getDarkTD(),
      themeMode: themePro.themeMode,
      debugShowCheckedModeBanner: false,
      title: WebConstants.kAppTitle,
      locale: Locale('zh', 'CN'),
      builder: (context, child) {
        Widget content = child ?? Container();
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

  Future<void> _willExit() async {
    if (Utils.isDesktopSystem) {
      AppState().tallValueChangesCallBack = null;
      ThemeProvider().tallValueChangesCallBack = null;
      WebTextSize().tallValueChangesCallBack = null;
      WindowUtil().winInfo.onMainMessage = null;
    }
    await getRoot()?.windowClose(true);
  }

  //用户点击窗口的close按钮会调用，同时使用window controller 调用close也会调用，这样容易执行多次
  @override
  void onWindowClose() async {
    //TODO:desktop_multi_window在linux bug,关闭子窗口时候，确关闭了主窗口；先不关闭窗口
    if (Utils.isDesktopSystem && !Utils.isLinux()) {
      await WindowUtil.windowWillClose(navigatorKey.currentContext, () async {
        //子窗口都应该退出
        if (!shouldExit) {
          await _willExit();
          shouldExit = true;
        }
      });
    }
    ZsLog.d("browser root onWindowClose");
  }

  @override
  void onWindowFocus() {
    if (getRoot() != null) {
      getRoot()?.windowFocus();
    } else {
      setState(() {});
    }
  }

  @override
  void onWindowBlur() {
    if (getRoot() != null) {
      getRoot()?.windowBlur();
    } else {
      setState(() {});
    }
  }

  @override
  void onWindowMinimize() {
    if (getRoot() != null) {
      getRoot()?.windowMinimize();
    } else {
      setState(() {});
    }
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
      WindowUtil.onWindowEvent(eventName);
    }
  }
}
