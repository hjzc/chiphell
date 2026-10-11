import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThemeApp {
  static SystemUiOverlayStyle androidStatusBar(bool isDark) {
    return isDark
        ? SystemUiOverlayStyle(
            //暗色模式下使用
            statusBarColor: Colors.transparent, // 透明状态栏，适用于深色背景
            statusBarIconBrightness: Brightness.light, // 图标颜色（深色/浅色）
            //statusBarBrightness: Brightness.light, // ios 状态栏亮度（深色/浅色）
          )
        : SystemUiOverlayStyle(
            //亮色模式下使用
            //statusBarColor: Colors.grey[200],  // Android 10以下
            //systemStatusBarContrastEnforced: true, // 仅Android 10+支持
            statusBarColor: Colors.transparent, // 透明状态栏，适用于深色背景
            statusBarIconBrightness: Brightness.dark, // 图标颜色（深色/浅色）
            //statusBarBrightness: Brightness.dark, //ios 状态栏亮度（深色/浅色）
          );
  }

  static SystemUiOverlayStyle statusBar(bool isDark) {
    return isDark
        ? SystemUiOverlayStyle(
            //暗色模式下使用
            statusBarColor: Colors.transparent, // 透明状态栏，适用于深色背景
            // statusBarIconBrightness: Brightness.light, // 图标颜色（深色/浅色）
            // statusBarBrightness: Brightness.light, // 状态栏亮度（深色/浅色）
          )
        : SystemUiOverlayStyle(
            //亮色模式下使用
            statusBarColor: Colors.transparent, // 透明状态栏，适用于深色背景
            //statusBarIconBrightness: Brightness.dark, // 图标颜色（深色/浅色）
            //statusBarBrightness: Brightness.dark, // 状态栏亮度（深色/浅色）
          );
  }

  static ThemeData getTD() {
    return Platform.isAndroid
        ? ThemeData(
            platform: TargetPlatform.iOS,
            brightness: Brightness.light,
            appBarTheme: AppBarTheme(
              backgroundColor: const Color.fromARGB(255, 254, 245, 254),
              systemOverlayStyle: androidStatusBar(false),
            ),
          )
        : ThemeData(
            platform: Platform.isWindows
                ? TargetPlatform.windows
                : TargetPlatform.iOS,
            brightness: Brightness.light,
            //hintColor: Colors.grey,
          );
  }

  static ThemeData getDarkTD() {
    return Platform.isAndroid
        ? ThemeData(
            platform: TargetPlatform.iOS,
            brightness: Brightness.dark,
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.black,
              systemOverlayStyle: androidStatusBar(true),
            ),
          )
        : ThemeData(
            platform: Platform.isWindows
                ? TargetPlatform.windows
                : TargetPlatform.iOS,
            brightness: Brightness.dark,
            // hintColor: Colors.grey,

            // colorScheme: ColorScheme.light().copyWith(
            //   primary: Colors.green,
            //   brightness: Brightness.dark,
            // ),
            // appBarTheme: AppBarTheme(
            //   backgroundColor: const Color.fromARGB(255, 240, 7, 135),
            //   // systemOverlayStyle: androidStatusBar(false),
            // ),
            // scrollbarTheme: ScrollbarThemeData(
            //   thickness: WidgetStateProperty.all(12.0), //MaterialStateProperty
            //   radius: const Radius.circular(8),
            //   thumbColor: WidgetStateProperty.all(
            //     Colors.redAccent,
            //   ), // 设置滚动条颜色为红色
            // ),
          );
  }
}
