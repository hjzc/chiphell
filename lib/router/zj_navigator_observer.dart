import 'package:flutter/material.dart';

import '../utils/zs_log.dart';

class ZjNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    ZsLog.d('nav observer did push route ${route.toString()}');
    // if(route.settings.name == ''){
    //   windowManager.addListener(this);
    // }
    // _configureStatusBarForRoute(route);
  }

  /// 路由重新活跃时调用（如子页面弹出）
  void didPopNext(Route route, Route? previousRoute) {
    ZsLog.d('nav observer did pop next route ${route.toString()}');
    //super.didPopNext(route, previousRoute);
    // _configureStatusBarForRoute(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    ZsLog.d('nav observer did pop route ${route.toString()}');
    //_configureStatusBarForRoute(route);
  }

  /// 根据路由配置状态栏样式
  // void _configureStatusBarForRoute(Route route) {
  //   // 1. 获取路由设置（包含模块名称）
  //   final routeSettings = route.settings;
  //   if (routeSettings is! MaterialPageRouteSettings) return;
  //   // 2. 从路由参数中获取模块名称（需在路由跳转时传入）
  //   final moduleName = routeSettings.arguments as String?;
  //   if (moduleName == null) return;
  //   // 3. 根据模块名称获取对应的状态栏样式
  //   final statusBarStyle = AppStatusBarStyles.getByModuleName(moduleName);

  //   // 4. 应用状态栏样式（使用Future.microtask确保在UI构建完成后执行）
  //   Future.microtask(() {
  //     SystemChrome.setSystemUIOverlayStyle(statusBarStyle);
  //   });
  // }
}
