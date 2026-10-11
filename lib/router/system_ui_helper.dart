import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SystemUIHelper {
  // 全屏模式（启动页使用）
  static void setFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  static void showStatusBar({bool show = true}) {
    if (show) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } else {
      // 全局隐藏状态栏
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  // 正常模式（内容页使用）
  static void setNormalScreen({
    bool showStatusBar = true,
    bool showNavBar = false,
    Color statusBarColor = Colors.transparent,
    Brightness statusBarIconBrightness = Brightness.light,
  }) {
    List<SystemUiOverlay> overlays = [];
    if (showStatusBar) overlays.add(SystemUiOverlay.top);
    if (showNavBar) overlays.add(SystemUiOverlay.bottom);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: overlays);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: statusBarColor, statusBarIconBrightness: statusBarIconBrightness),
    );
  }
}
