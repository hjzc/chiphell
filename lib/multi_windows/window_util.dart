import 'dart:async';
import 'dart:io';
import 'package:desktop_lifecycle/desktop_lifecycle.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'app_window_info.dart';
import '../web/web_constants.dart';
import '../utils/utils.dart';
import '../utils/zs_log.dart';

class WindowUtil {
  static String initTitle = WebConstants.kAppTitle;
  static String? title;
  late AppWindowsCenter winInfo;

  ValueListenable<bool>? _windowsActiveEvent;
  bool active = false;
  //单例
  static final WindowUtil _instance = WindowUtil._();
  factory WindowUtil() {
    return _instance;
  }
  WindowUtil._() : super();

  ///窗口初始化设置
  static Future ensureInitialized() async {
    return await windowManager.ensureInitialized();
  }

  //初始化参数配置，这里根据自己的模块业务而定，我窗口默认是140,210
  static Future<void> setWindowFunctions(AppWindowsCenter info, bool isDark) async {
    WindowUtil().winInfo = info;
    info.initConfigWindowOptions(isDark);
    WindowUtil().init();
  }

  void init() {
    winInfo.init();
    if (winInfo.isMainWindow()) {
      _windowsActiveEvent = DesktopLifecycle.instance.isActive;
      _windowsActiveEvent?.addListener(_windowActiveCallback);
    }
  }

  bool minimized() {
    return winInfo.isMinimized;
  }

  void setNoMinimize() {
    if (winInfo.isMinimized) {
      winInfo.isMinimized = false;
    }
  }

  void _windowActiveCallback() {
    if (_windowsActiveEvent != null) {
      active = _windowsActiveEvent!.value;
    }
    // debugPrint("window main(${winInfo.isMainWindow()}) activate: $active");
  }

  void removeWindowActiveCallback() async {
    if (_windowsActiveEvent != null) {
      _windowsActiveEvent?.removeListener(_windowActiveCallback);
      _windowsActiveEvent = null;
      ZsLog.d('main windows removeWindowActiveCallback');
    }
  }

  static Future<int> appWindowCount() async {
    List<WindowController> controllers = await WindowController.getAll();
    return controllers.length;
  }

  //手动调用close
  static Future<void> closeSubWindow() async {
    WindowUtil wu = WindowUtil();
    if (!wu.winInfo.isMainWindow()) {
      WindowUtil().winInfo.close();
    }
  }

  static Future<bool> isVisible() async {
    return await windowManager.isVisible();
  }

  //linux
  static Future<bool> isMinimized() async {
    //linux 下一直返回false，返回不正确
    if (Utils.isLinux()) {
      return WindowUtil().minimized();
    } else {
      return await windowManager.isMinimized();
    }
  }

  static void onWindowEvent(String eventName, {String? windowId}) async {
    Offset offset = await windowManager.getPosition();
    Size size = await windowManager.getSize();
    // debugPrint(
    //   "------window event: $eventName, offset:$offset, size:$size ---------------",
    // );
    if (size.width < 600 || size.height < 600) {
      return;
    }
    String str = Utils.sizePositionToString(size, offset);
    WindowUtil().winInfo.updateWindowRectString(str);
  }

  static Future<void> show() async {
    await windowManager.show();
    await windowManager.focus();
  }

  /*
   * 必须在macos 工程中设置
   *  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {return false}
   */
  static Future<void> hide() async {
    WindowUtil().winInfo.isMinimized = true;
    await windowManager.hide();
  }

  static Future<void> minimize() async {
    WindowUtil().winInfo.isMinimized = true;
    await windowManager.blur();
    await windowManager.minimize();
  }

  static Future<void> _mainWindowClose() async {
    ZsLog.i('执行window close _mainWindowClose');
    WindowUtil().removeWindowActiveCallback();
    await trayManager.destroy();
    await WindowUtil().winInfo.closeSubWindows(true);
    ZsLog.i('执行window close _mainWindowClose end');
  }

  static Future<void> windowWillClose(BuildContext? context, Future<void> Function() shouldExit) async {
    ZsLog.i('执行window close 事件开始');
    WindowUtil wu = WindowUtil();
    bool ism = wu.winInfo.isMainWindow();
    if (ism) {
      if (context != null && context.mounted && (wu.winInfo.isClosable == null)) {
        showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: const Text('确认关掉窗口或退出应用吗?'),
              actions: [
                TextButton(
                  child: const Text('最小化'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    wu.winInfo.setIsCloseWindows(false);
                    minimize();
                  },
                ),
                TextButton(
                  child: const Text('退出'),
                  onPressed: () async {
                    wu.winInfo.setIsCloseWindows(true);
                    Navigator.of(context).pop();
                    Future.delayed(Duration(milliseconds: 100), () async {
                      // WindowUtil().winInfo.isWillClose = true;
                      await shouldExit();
                      await _mainWindowClose();
                    });
                  },
                ),
              ],
            );
          },
        );
      } else if ((wu.winInfo.isClosable != null) && (wu.winInfo.isClosable!)) {
        // wu.winInfo.isWillClose = true;
        await shouldExit();
        await _mainWindowClose();
      } else if (Utils.isLinux() && (await WindowUtil.isMinimized() == true)) {
        //wu.winInfo.isWillClose = true;
        await shouldExit();
        await _mainWindowClose();
      } else {
        //判断是否为minimize
        minimize();
      }
    } else {
      //同步执行
      await shouldExit();
      //不拦截关闭窗口事件
      wu.winInfo.readyDelloc();
    }
    ZsLog.i('执行window close 事件结束');
  }

  static void updateWindowTitle(String? text) {
    if (title != text) {
      title = text;
      bool ism = WindowUtil().winInfo.isMainWindow();
      windowManager.setTitle(text != null ? (ism ? ('$initTitle      $text') : text) : initTitle);
      if (ism && (Utils.isWindows() || Utils.isMacOS())) {
        //鼠标放在try icon上提示的标题,linux 不可用
        trayManager.setToolTip(text ?? initTitle);
      }
    }
  }

  static Future<void> setTryMenu() async {
    if (Utils.isWindows()) {
      //鼠标放在try icon上提示的标题
      await trayManager.setToolTip(WebConstants.kAppTitle);
    } else {
      //不支持设置title
      await trayManager.setTitle(WebConstants.kAppTitle);
    }

    await trayManager.setIcon(Platform.isWindows ? 'assets/images/tray_icon_original.ico' : 'assets/images/tray_icon_original.png');
    Menu menu = Menu(
      items: [
        MenuItem(key: 'show_window', label: '显示窗口', onClick: (menuItem) {}),
        MenuItem(key: 'hide_window', label: '隐藏窗口'),
        MenuItem(key: 'top_window', label: '置顶窗口'),
        MenuItem(key: 'taskBar_window', label: Platform.isMacOS ? 'Dock显示' : '任务栏显示'),
        MenuItem(key: 'center_window', label: '居中窗口'),

        MenuItem(key: 'new_window', label: '新建窗口'),

        MenuItem.separator(),
        MenuItem(key: 'exit_app', label: '退出应用'),
      ],
    );

    await trayManager.setContextMenu(menu);
  }

  static Future<void> removeTryMenu() async {
    await trayManager.destroy();
  }

  static Future<void> onTrayMenuItemClick(BuildContext context, MenuItem menuItem, void Function(int event) callBack) async {
    int event = 0;

    switch (menuItem.key) {
      case 'show_window':
        WindowUtil.show();
        event = 1;
        break;
      case 'hide_window':
        await WindowUtil.hide();
        event = 2;
      case 'top_window':
        WindowUtil().winInfo.setAutoAlwaysOnTop();
        event = 3;
        break;
      case 'taskBar_window':
        {
          WindowUtil().winInfo.setAutoSkipTaskBar();
          event = WindowUtil().winInfo.skipTaskbar ? 4 : 5;
        }
        break;
      case 'center_window':
        {
          Size size = await windowManager.getSize();
          if (size.width < 100 || size.height < 100) {
            size = Size(400, 400);
            windowManager.setMinimumSize(size);
          }
          await windowManager.center();
          event = 6;
        }
        break;
      case 'new_window':
        {
          pushBrowser(null);
          break;
        }
      case 'exit_app':
        event = 7;
        _mainWindowClose();
        break;
    }
    callBack(event);
  }

  static Future<bool> shouldTopWindowOpen() async {
    return (await appWindowCount()) > 1;
  }

  static Future<void> pushBrowser(String? url, {int? windowid}) async {
    // final controller =
    WindowController.create(
      WindowConfiguration(
        hiddenAtLaunch: true,
        arguments: BrowserWindowArguments(
          url: url ?? '',
          webWindowId: windowid ?? -1,
          windowOrder: await WindowUtil().winInfo.nextWindowOrder(),
        ).toArguments(),
      ),
    );
    ZsLog.d('Created new web window: ');
  }

  static Future<void> topBrowserOpen(String? url) async {
    WindowUtil().winInfo.sendToTopSubWindowValue([WebConstants.kWinSubEventNewWebTab, url]);
  }
}
