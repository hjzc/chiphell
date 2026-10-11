import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomCurve extends Curve {
  @override
  double transform(double t) {
    // 创建一个弹跳效果
    if (t < 0.5) {
      return 2 * t * t;
    } else {
      return 1 - 2 * (1 - t) * (1 - t);
    }
  }
}

class RouterTransitionPage {
  static CustomTransitionPage transitionPage(
    BuildContext context,
    GoRouterState state,
    Widget page,
    //TickerProvider vsync,
    // Animation<double> parent,
    int transtion,
  ) {
    // AnimationController(
    //                 duration: const Duration(seconds: 2),
    //                 vsync: vsync,
    //               )..repeat()
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: page,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300), // 返回时长
      transitionsBuilder:
          (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            if (transtion == 1) {
              return SizeTransition(
                sizeFactor: animation,
                // axis: Axis.horizontal, //水平方向
                // axisAlignment: -1.0, //左边开始展开
                // sizeFactor: Tween<double>(begin: 0.0, end: 1.0).animate(
                //   CurvedAnimation(parent: animation, curve: Curves.elasticOut),
                // ),
                // CurvedAnimation(
                //   parent: animation,
                //   curve: CustomCurve(), //Curves.fastOutSlowIn,
                // ),
                child: child,
              );
            } else if (transtion == 2) {
              return ScaleTransition(
                //缩放，从小到大推出，返回，从大到小
                scale: CurvedAnimation(
                  parent: animation,
                  curve: Curves.fastOutSlowIn,
                ),
                child: child,
              );
            } else if (transtion == 3) {
              return RotationTransition(
                //旋转
                turns: CurvedAnimation(
                  parent: animation,
                  curve: Curves.elasticOut,
                ),
                child: child,
              );
            } else if (transtion == 4) {
              return SlideTransition(
                //滑动,右边到左边滑动
                position: animation.drive(
                  Tween(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.ease)),
                ),
                child: child,
              );
            } else if (transtion == 5) {
              //组合动画 从小到大推出，返回，从大到小
              return ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              );
            } else if (transtion == 6) {
              // 从底部滑动进入
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            }
            return FadeTransition(
              //淡入淡出
              opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
              // opacity: CurveTween(
              //   curve: Curves.easeInOutCirc,
              // ).animate(animation),
              child: child,
            );
          },
    );
  }

  static CustomTransitionPage customTransitionPage1(
    BuildContext context,
    GoRouterState state,
    Widget page,
    Animation<double> parent,
    int transtion,
  ) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: page,
      barrierDismissible: true,
      barrierColor: Colors.black38,
      opaque: false,
      transitionDuration: Duration.zero,
      transitionsBuilder: (_, _, _, Widget child) => child,
    );
  }

  static CustomTransitionPage customTransitionPage2(
    BuildContext context,
    GoRouterState state,
    Widget page,
    Animation<double> parent,
    int transtion,
  ) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: page,
      barrierDismissible: true,
      barrierColor: Colors.black38,
      opaque: false,
      transitionDuration: const Duration(milliseconds: 500), // 动画时长
      reverseTransitionDuration: const Duration(milliseconds: 300), // 返回时长
      transitionsBuilder:
          (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut, // 动画曲线
            );
            return FadeTransition(opacity: curvedAnimation, child: child);
            // return FadeTransition(opacity: animation, child: child);
          },
    );
  }
}
