import 'package:flutter/material.dart';

class NavigatorUtils {
  /// 使用系统的navigator 推出一个页面
  /// 例子 NavigatorUtils.push(
  ///   context,
  ///   (ctx) {
  ///     return SettingPage();
  ///   },
  ///   (val) {
  ///     if (val != null && (val is Favor)) {
  ///       setState(() {});
  ///     }
  ///   },
  /// );
  /// // 在SettingPage页面返回  Navigator.pop(context,[T]); context.pop(results);
  static Future<void> push(BuildContext ctx, Widget Function(BuildContext) builder, void Function(dynamic value)? resultFn) async {
    var val = await Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: builder, // 非全屏页面
        fullscreenDialog: false, // 这里设置为false表示非全屏弹出，但实际效果取决于页面设计（例如使用Scaffold的resizeToAvoidBottomInset等）
      ),
    );
    if (resultFn != null) {
      resultFn(val);
    }
    // var result = await context.pushNamed('settings');
    // if (result != null && (result is Favor)) {
    //   setState(() {});
    // }
  }
}
