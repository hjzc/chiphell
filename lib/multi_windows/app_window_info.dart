import 'dart:async';
import 'dart:convert';
import 'package:chiphell/data/app_prefs.dart';
import 'package:chiphell/multi_windows/window_controller.dart';
import 'package:chiphell/utils/zs_log.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

import '../utils/utils.dart';
import '../web/web_constants.dart';

class WinConstants {
  static const windowRectPrefKey = 'kWindowLastRect';
  static const subWindowRectPrefKey = 'kSubWindowLastRect';
  static const isOnTopPrefKey = 'kWindowIsOnTop';
  static const skipTaskbarPrefKey = 'kWindowSkipTaskbar';
  static const isClosablePrefKey = 'kWindowIsClosable';
}

abstract class WindowArguments {
  const WindowArguments();

  static const String businessIdMain = 'main';
  static const String businessIdBrowser = 'browser';

  factory WindowArguments.fromArguments(String arguments) {
    if (arguments == '') {
      //主窗口启动 无参数
      return const MainWindowArguments();
    }
    final json = jsonDecode(arguments) as Map<String, dynamic>;
    final businessId = json['businessId'] as String? ?? '';
    switch (businessId) {
      case businessIdBrowser:
        return BrowserWindowArguments.fromJson(json);
      default:
        throw Exception('Unknown businessId: $businessId');
    }
  }

  Map<String, dynamic> toJson();
  String get businessId;
  String toArguments() => jsonEncode({"businessId": businessId, ...toJson()});
  @override
  String toString() {
    return 'WindowArguments(businessId: $businessId, data: ${toJson()})';
  }
}

class MainWindowArguments extends WindowArguments {
  const MainWindowArguments();
  @override
  Map<String, dynamic> toJson() {
    return {};
  }

  @override
  String get businessId => WindowArguments.businessIdMain;
}

class BrowserWindowArguments extends WindowArguments {
  const BrowserWindowArguments({required this.url, required this.windowOrder, required this.webWindowId});

  factory BrowserWindowArguments.fromJson(Map<String, dynamic> json) {
    return BrowserWindowArguments(url: json['url'] as String? ?? '', webWindowId: json['webWindowId'], windowOrder: json['windowOrder']);
  }

  final String url;
  final int webWindowId;
  final int windowOrder;
  @override
  Map<String, dynamic> toJson() {
    return {'url': url, 'windowOrder': windowOrder, 'webWindowId': webWindowId};
  }

  @override
  String get businessId => WindowArguments.businessIdBrowser;
}

class AppWindowInfo {
  // ignore: constant_identifier_names
  static const String RESOURT = '';
  WindowMethodChannel? _channel;
  WindowController? _controller;
  //dc7d5028-c843-407b-9371-a0df3294a544
  String? windowId;
  WindowArguments? arguments;

  bool _valid = true;
  bool get valid => _valid;
  bool isMinimized = false;
  bool isWillClose = false;
  bool _isClosed = false;
  bool get isClosed => _isClosed;
  bool _isDestroy = false;
  bool get isDestroy => _isDestroy;

  FutureOr<dynamic> Function(AppWindowInfo info, int event, dynamic value)? onMainMessage;

  bool isMainWindow() {
    return arguments?.businessId == WindowArguments.businessIdMain;
  }

  bool isBrowserWindow() {
    return arguments?.businessId == WindowArguments.businessIdBrowser;
  }

  bool subWin() {
    return !isMainWindow();
  }

  void readyDelloc() {
    isWillClose = true;
    onMainMessage = null;
    if (_channel != null) {
      _channel?.setMethodCallHandler(null);
      _channel = null;
    }
    // mainWinInfo = null;
    _valid = false;
  }

  Future<void> close() async {
    readyDelloc();
    _isClosed = true;
    WindowController ctl = controller();
    ctl.close();
    _controller = null;
  }

  void destroy() {
    readyDelloc();
    _isClosed = true;
    // WindowController ctl = controller();
    _isDestroy = true;
    //ctl.destroy();
    windowManager.destroy();
    //_controller = null;
  }

  void init() {
    _getChannel();
  }

  //初始化主窗口通信通道
  WindowMethodChannel _getChannel() {
    if (_channel == null) {
      _channel = WindowMethodChannel('wc_$windowId');
      _channel?.setMethodCallHandler(otherDesktopWindowCall);
    }
    return _channel!;
  }

  WindowController controller() {
    _controller ??= WindowController.fromWindowId(windowId!);
    return _controller!;
  }

  void setController(WindowController c) {
    _controller = c;
  }

  Future<dynamic> otherDesktopWindowCall(MethodCall call) async {
    switch (call.method) {
      case 'r':
        {
          var list = call.arguments as List;
          var tmethod = list[0] as String;
          var targuments = list.sublist(1);
          try {
            var r = await _recievie(tmethod, targuments);
            return r;
          } catch (e) {
            ZsLog.e('_sendToChannel error: $e');
          }
          return RESOURT;
        }
      default:
        ZsLog.e('Not implemented: ${call.method}');
        return RESOURT;
    }
  }

  Future<dynamic> _sendToChannel(List<dynamic> arges) async {
    try {
      var r = await _getChannel().invokeMethod('r', arges);
      return r ?? RESOURT;
    } catch (e) {
      ZsLog.e('_sendToChannel error:', error: e);
    }
    return RESOURT;
  }

  Future<dynamic> send(String method, List<dynamic> arges) async {
    List<dynamic> rs = [method];
    rs.addAll(arges);
    var result = await _sendToChannel(rs);
    return result;
  }

  Future<dynamic> _recievie(String method, List<dynamic> arges) async {
    if (method == 'r_synValue') {
      return await _onMeg(arges[0], arges[1]);
    }
    return RESOURT;
  }

  Future<dynamic> _onMeg(int event, dynamic value) async {
    dynamic r = RESOURT;
    //主窗口的子窗口列表对象 不设置这个消息
    if (onMainMessage != null) {
      r = await onMainMessage?.call(this, event, value);
    }
    // if ((mainWinInfo != null) && (mainWinInfo?.onMainMessage != null)) {
    //   dynamic r1 = await mainWinInfo?.onMainMessage?.call(this, event, value);
    //   if (r1 != null) {
    //     r = r1;
    //   }
    // }
    return r;
  }

  Future<dynamic> synValue(int event, dynamic value) async {
    return await send('r_synValue', [event, value]);
  }

  Future<dynamic> synToSelf(int event, dynamic value) async {
    return await _onMeg(event, value);
  }
}

class AppWindowsCenter extends AppWindowInfo {
  List<AppWindowInfo> subWindows = [];
  Debouncer<String>? debouncer;
  String rectString = '';
  bool? _isClosable;

  int get subWindowCount => subWindows.length;
  Future<int> nextWindowOrder() async {
    return isMainWindow() ? subWindowCount + 1 : (await WindowController.getAll()).length + 1;
  }

  int curentWindowOrder() {
    int r = -1;
    if (isMainWindow()) {
      r = 0;
    } else if (arguments is BrowserWindowArguments) {
      BrowserWindowArguments nwa = arguments as BrowserWindowArguments;
      r = nwa.windowOrder;
    }
    return r;
  }

  AppWindowInfo? getSubWinInfo(String winId) {
    AppWindowInfo? r;
    for (int i = 0; i < subWindows.length; i++) {
      AppWindowInfo wc = subWindows[i];
      if (wc.windowId == winId) {
        r = wc;
        break;
      }
    }
    return r;
  }

  Future<void> refreshSubWindows() async {
    if (!isMainWindow()) {
      return;
    }
    List<WindowController> controllers = await WindowController.getAll();
    List<AppWindowInfo> wlist = [];
    List<AppWindowInfo> oldlist = [];
    oldlist.addAll(subWindows);

    for (int i = 0; i < controllers.length; i++) {
      WindowController c = controllers[i];
      if (c.windowId != windowId) {
        AppWindowInfo? w = getSubWinInfo(c.windowId);
        if (w == null) {
          w = AppWindowInfo();
          w.windowId = c.windowId;
          w.arguments = WindowArguments.fromArguments(c.arguments);
          // w.mainWinInfo = this;
          w.onMainMessage = (AppWindowInfo info, int event, dynamic value) {
            if (onMainMessage != null) {
              return onMainMessage!(info, event, value);
            }
            return '';
          };
          w.init();
          w.setController(c);
        } else {
          oldlist.remove(w);
        }
        wlist.add(w);
      }
    }
    subWindows.clear();

    if (wlist.isNotEmpty) {
      subWindows.addAll(wlist);
    }

    //清除关闭的窗口信息
    for (int i = 0; i < oldlist.length; i++) {
      AppWindowInfo c = oldlist[i];
      c.readyDelloc();
    }
    ZsLog.d('main windows , sub windows count is ${wlist.length}');
    if (isWillClose && wlist.isEmpty) {
      ZsLog.d('main windows , delay destroy ....');
      Future.delayed(Duration(milliseconds: 300), () {
        //windowManager.destroy();
        ZsLog.d('main windows will destroy1');
        destroy();
        ZsLog.d('main windows did destroy1');
      });
    }
  }

  Future<bool> closeSubWindows(bool includeSelf) async {
    if (!isMainWindow()) {
      return false;
    }
    if (includeSelf) {
      isWillClose = true;
    }

    List<AppWindowInfo> awis = [];
    awis.addAll(subWindows);
    int total = awis.length;
    int i = total - 1;
    while (i >= 0) {
      AppWindowInfo info = awis[i];
      if (!info.isWillClose) {
        try {
          info.close();
        } catch (e) {
          ZsLog.d('close sub windows error:$e');
        }
      }
      i--;
    }

    //有子窗口，则延时300，否则100ms
    ZsLog.d('main windows sub windows[$total] did close');
    if (includeSelf) {
      if ((total == 0)) {
        // await trayManager.destroy();
        ZsLog.d('main windows will destroy');
        destroy();
        ZsLog.d('main windows did destroy');
        //await trayManager.destroy();
        //await windowManager.destroy();
      } else {}
    } else {
      ZsLog.d('main windows close all sub windows finished!');
    }
    return true;
  }

  /// 消息交互  subwindows<->subwindows<->main
  //窗口间的交互
  Future<dynamic> synWindowValue(int event, dynamic value, {AppWindowInfo? exclude}) async {
    dynamic rc = '';
    if (isMainWindow()) {
      List<AppWindowInfo> list = [];
      list.addAll(subWindows);
      for (int i = 0; i < list.length; i++) {
        AppWindowInfo a = list[i];
        if (a.windowId == null || a.valid == false) {
          break;
        } else if ((exclude != null) && (a.windowId == exclude.windowId)) {
        } else {
          rc = await a.synValue(event, value);
        }
      }
    } else {
      rc = await synValue(event, value);
    }
    return rc;
  }

  Future<dynamic> synWindowEventValue(dynamic value, {AppWindowInfo? exclude}) async {
    return await synWindowValue(WebConstants.kWinEventHead, value, exclude: exclude);
  }

  Future<dynamic> sendToSubWindowValue(AppWindowInfo sub, dynamic value) async {
    dynamic rc = '';
    if (isMainWindow()) {
      rc = await sub.synValue(WebConstants.kWinM2SEventHead, value);
    }
    return rc;
  }

  //发送给自己
  Future<dynamic> sendToSelfWindowValue(dynamic value) async {
    dynamic rc = await synToSelf(WebConstants.kWinSelfEventHead, value);
    return rc;
  }

  Future<dynamic> sendToTopSubWindowValue(dynamic value) async {
    dynamic rc = '';
    bool ism = isMainWindow();
    if (ism && subWindows.isNotEmpty) {
      AppWindowInfo a = subWindows.last;
      rc = await sendToSubWindowValue(a, value);
    } else if (!ism) {
      rc = await sendToSelfWindowValue(value);
    }
    return rc;
  }

  Future<void> savePosToPref() async {
    await AppPrefs.saveValueToPrefs(
      isMainWindow() ? WinConstants.windowRectPrefKey : WinConstants.subWindowRectPrefKey,
      type: APType.AT_String,
      value: rectString,
    );
  }

  //update pos
  void updateWindowRectString(String pos) {
    if (debouncer == null) {
      debouncer = Debouncer<String>(
        Duration(seconds: 2),
        initialValue: pos,
        onChanged: (value) {
          if (rectString != value) {
            rectString = value;
          }
          savePosToPref();
        },
      );
    } else {
      debouncer?.value = pos;
    }
  }

  //windows is close
  bool? get isClosable => _isClosable;

  bool isCloseWindowsSet() {
    return (isClosable == null || isClosable == false) ? false : true;
  }

  void setIsCloseWindows(bool val) {
    _isClosable = val;
    saveIsClosableToPref();
  }

  Future<void> saveIsClosableToPref() async {
    if (isMainWindow()) {
      if (isClosable == null) {
        if (await AppPrefs.containsKey(WinConstants.isClosablePrefKey)) {
          await AppPrefs.remove(WinConstants.isClosablePrefKey);
        }
      } else {
        await AppPrefs.saveValueToPrefs(WinConstants.isClosablePrefKey, type: APType.AT_Bool, value: isClosable!);
      }
    }
  }

  bool _isOnTop = false;
  bool get isOnTop => _isOnTop;
  Future<void> _saveisOnTopToPref(bool top) async {
    if (top != _isOnTop) {
      _isOnTop = top;
      //设置窗口是否总是显示在其他窗口的顶部
      await windowManager.setAlwaysOnTop(isOnTop);
      await AppPrefs.saveValueToPrefs(WinConstants.isOnTopPrefKey, type: APType.AT_Bool, value: _isOnTop);
    }
  }

  //设置浮窗
  void setAutoAlwaysOnTop() {
    if (isMainWindow()) {
      _saveisOnTopToPref(!_isOnTop);
    }
  }

  bool _skipTaskbar = false;
  bool get skipTaskbar => _skipTaskbar;
  Future<void> _saveSkipTaskbarToPref(bool val) async {
    if (val != _skipTaskbar) {
      _skipTaskbar = val;
      await windowManager.setSkipTaskbar(_skipTaskbar);
      await AppPrefs.saveValueToPrefs(WinConstants.skipTaskbarPrefKey, type: APType.AT_Bool, value: _skipTaskbar);
    }
  }

  void setAutoSkipTaskBar() {
    _saveSkipTaskbarToPref(!_skipTaskbar);
  }

  void setBrightness(Brightness brightness) {
    windowManager.setBrightness(brightness);
    ZsLog.d('window set ${brightness == Brightness.dark ? 'Dark' : 'light'}');
  }

  Future<void> initConfigWindowOptions(bool isDark) async {
    Offset? launchPosition;
    if (isMainWindow()) {
      _isOnTop = await await AppPrefs.loadValueFromPrefs(WinConstants.isOnTopPrefKey, type: APType.AT_Bool, value: false);

      _skipTaskbar = await await AppPrefs.loadValueFromPrefs(WinConstants.skipTaskbarPrefKey, type: APType.AT_Bool, value: false);

      bool? flag = await AppPrefs.loadBoolValueFromPrefs(WinConstants.isClosablePrefKey, null);
      if (flag != null) {
        //TODO:调试关掉最后一个窗口 弹出窗口确认
        if (kDebugMode) {
        } else {
          _isClosable = flag;
        }
      }
    }

    String? spString = await AppPrefs.loadValueFromPrefs(
      isMainWindow() ? WinConstants.windowRectPrefKey : WinConstants.subWindowRectPrefKey,
      type: APType.AT_String,
      value: '',
    );

    /**
     * 在macos 中设置了保存window状态。
     * override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {return true}
     */
    ///macos 27 透明色 会导致标题背景色透明
    bool isMac27 = await Utils.isMacos27();
    Color wbgc = isMac27 ? const Color.fromARGB(0, 239, 6, 6) : Colors.transparent;
    WindowOptions windowOptions = WindowOptions(
      size: Size(1024, 768),
      minimumSize: Size(600, 400),
      center: true,
      backgroundColor: wbgc,
      //设置窗口是否显示在 任务栏或 Dock 上
      skipTaskbar: skipTaskbar,
      titleBarStyle: TitleBarStyle.normal,
      windowButtonVisibility: true,
    );

    if (spString != null && spString.length > 10) {
      rectString = spString;
      Utils.stringToSizePosition(spString, (Size size, Offset offset) {
        windowOptions = WindowOptions(
          size: size,
          minimumSize: Size(600, 400),
          backgroundColor: wbgc,
          //设置窗口是否显示在 任务栏或 Dock 上
          skipTaskbar: skipTaskbar,
          titleBarStyle: TitleBarStyle.normal,
          windowButtonVisibility: true,
        );
        launchPosition = offset;
        windowManager.setPosition(launchPosition!);
      });
    }

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    //主窗口拦截关闭窗口的信号
    //TODO:desktop_multi_window在linux bug,关闭子窗口时候，确关闭了主窗口；拦截子窗口关闭事件
    await windowManager.setPreventClose(Utils.isLinux() ? true : isMainWindow());
    // await windowManager.setPreventClose( isMainWindow);
    //窗口可以关闭
    //TODO:desktop_multi_window在linux bug,关闭子窗口时候，确关闭了主窗口；子窗口关闭事件
    //if(Utils.isLinux() && !isMainWindow){
    // windowManager.setClosable(false);
    //}

    setBrightness(isDark ? Brightness.dark : Brightness.light);
  }
}
