import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:chiphell/pages/splash_screen_page.dart';
import 'package:chiphell/web/home_page.dart';
import 'package:chiphell/modals/AppState.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../black_list_page.dart';
import '../favorites_manager_page.dart';
import '../modals/web_mode.dart';
import '../pages/web_main_site_manager_page.dart';
import '../setting_page.dart';
import '../utils/utils.dart';
import '../utils/zs_log.dart';
import 'router_transition_page.dart';
import '../web/browser_main_view.dart';
import 'zj_navigator_observer.dart';

class ZjRouter {
  static Widget startSplashPage(BuildContext context, bool isDark, VoidCallback init, VoidCallback end, VoidCallback completed) {
    if (Utils.isWindows()) {
      return _splashPageFadeIn(context, isDark, init, end, completed);
    }
    return _splashPageDefault(context, isDark, init, end, completed);
  }

  /// macos 动画无效
  static Widget _splashPageFadeIn(BuildContext context, bool isDark, VoidCallback init, VoidCallback end, VoidCallback completed) {
    return FlutterSplashScreen.fadeIn(
      backgroundColor: isDark ? Colors.black : Colors.white,
      // animationCurve: Curves.easeIn,
      animationDuration: const Duration(milliseconds: 2000),
      // duration: const Duration(milliseconds: 10000),
      useImmersiveMode: true, //hidden status bar
      onInit: () {
        init();
      },
      onEnd: () {
        end();
        completed();
      },
      childWidget: SizedBox(height: 300, width: 300, child: Image.asset("assets/images/splash256.png", width: 300, height: 300)),
      onAnimationEnd: () {
        ZsLog.i("Splash On Fade In End");
        // if (completed || _future == null) {
        //   gotoWebMainPage(context, 0);
        //   // debugPrint("On Fade In End -- gotoWebMainPage");
        // }
      },
    );
  }

  /// macos 动画无效
  // static Widget _splashPageScale(BuildContext context, bool isDark, VoidCallback init, VoidCallback end, VoidCallback completed) {
  //   return FlutterSplashScreen.scale(
  //     gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.lightBlue, Colors.blue]),
  //     childWidget: SizedBox(height: 300, child: Image.asset("assets/images/splash256.png")),
  //     //duration: const Duration(milliseconds: 1500),
  //     animationDuration: const Duration(milliseconds: 40000),
  //     onInit: () {
  //       init();
  //     },
  //     onEnd: () {
  //       end();
  //       completed();
  //     },
  //     onAnimationEnd: () {
  //       //debugPrint("On Fade In End");
  //       //completed();
  //       // if (!_splashEnd) {
  //       //   if (completed) {
  //       //     //gotoWebMainPage(context, true);
  //       //   }
  //       //   _splashEnd = true;
  //       // }
  //     },
  //     nextScreen: null,
  //   );
  // }

  static Widget _splashPageDefault(
    BuildContext context,
    // Widget? nextScreen,
    bool isDark,
    VoidCallback init,
    VoidCallback end,
    VoidCallback completed,
  ) {
    return FlutterSplashScreen(
      useImmersiveMode: true,
      duration: Duration(milliseconds: 2000),
      backgroundColor: isDark ? Colors.black : Colors.white,
      splashScreenBody: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // const SizedBox(height: 100),
            // const Spacer(),
            SizedBox(width: 300, height: 300, child: Image.asset('assets/images/splash256.png')),
            //  const Spacer(),
            // const SizedBox(height: 100),
          ],
        ),
      ),
      onInit: () {
        init();
      },
      onEnd: () {
        end();
        completed();
      },
    );
  }

  static GoRouter mainRouter(
    GlobalKey<NavigatorState> navKey,
    //BuildContext ctx,
    AppState appState,
    GlobalKey homeKey,
    GlobalKey browserKey,
    // Widget Function(BuildContext routerContext, GoRouterState state) rootPage,
  ) {
    return GoRouter(
      navigatorKey: navKey,
      onEnter: (context, currentState, nextState, goRouter) {
        return const Allow();
      },
      onException: (context, state, router) {},
      observers: [ZjNavigatorObserver()],
      initialLocation: '/splash',
      routes: [
        GoRoute(path: '/splash', builder: (context, state) => SplashScreenPage()),
        // GoRoute(
        //   name: '/',
        //   path: '/', // 命名参数 :url
        //   pageBuilder: (context, state) => MaterialPage<void>(child: rootPage(context, state)), //lanuchFutureBuilder(context)
        // ),
        GoRoute(
          name: '/',
          path: '/', // 不需要命名参数，使用查询参数
          pageBuilder: (context, state) => MaterialPage<void>(
            child: HomePage(
              key: homeKey,
              webMode: WebMode(
                initUrl: appState.appRootFirstUrl(),
                initUa: appState.webInitUA() ?? '',
                windowId: null,
                multipleWindows: Utils.multipleWindows,
                onStateUpdated: () {},
                onCloseTabRequested: () {},
                onCreateTabRequested: (createWindowAction, orUrl) {
                  return false;
                },
                onCloseBrowser: () {},
              ),
            ),
          ),
        ),
        // GoRoute(
        //   name: 'blacklist',
        //   path: '/blacklist', // 命名参数 :url
        //   builder: (context, state) {
        //     return BlackListPage();
        //   },
        // ),
        // 使用 GoRouter 的 context 或 Router 类直接导航，并添加查询参数
        //context.goNamed('home', queryParameters: {'url': 'John Doe'});
        // GoRoute(
        //   path: '/home', // 不需要命名参数，使用查询参数
        //   pageBuilder: (context, state) => MaterialPage<void>(
        //     child: Mainpage(
        //       initUrl: state.uri.queryParameters['url'] ?? '', // 获取查询参数 url 的值
        //       initUa: state.uri.queryParameters['ua'] ?? '', // 获取查询参数 ua 的值
        //     ),
        //   ),
        // ),
        //context.goNamed('/blacklist');
        GoRoute(
          name: 'blacklist',
          path: '/blacklist', // 命名参数 :url
          pageBuilder: (context, state) => RouterTransitionPage.transitionPage(context, state, const BlackListPage(), 6),
          // MaterialPage<void>(child: BlackListPage()),
        ),
        GoRoute(
          name: 'sites',
          path: '/sites', // 命名参数 :url
          pageBuilder: (context, state) => RouterTransitionPage.transitionPage(context, state, const WebMainSiteManagerPage(), 6),
          // MaterialPage<void>(child: BlackListPage()),
        ),

        GoRoute(
          name: 'favorites',
          path: '/favorites', // 命名参数 :url
          pageBuilder: (context, state) => RouterTransitionPage.transitionPage(context, state, const FavoritesManagerPage(), 6),
          //MaterialPage<void>(child: FavoritesManagerPage()),
        ),
        GoRoute(
          name: 'settings',
          path: '/settings', // 命名参数 :url
          // pageBuilder: (context, state) =>
          //   MaterialPage<void>(child: SettingPage()),
          pageBuilder: (BuildContext context, GoRouterState state) {
            return RouterTransitionPage.transitionPage(context, state, const SettingPage(), 6);
          },
          // builder: (BuildContext context, GoRouterState state) {
          //   return showModalBottomSheet(
          //     context: context,
          //     isScrollControlled: true,
          //     backgroundColor: Colors.transparent,
          //     builder: (context) => Container(
          //       height: MediaQuery.of(context).size.height * 0.5,
          //       decoration: BoxDecoration(
          //         color: Colors.white,
          //         borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          //       ),
          //       child: SettingPage(), // 你的自定义组件
          //     ),
          //   );

          //return RouterTransitionPage.transitionPage(context, state, const SettingPage(), 6);
          //},
        ),
        // GoRoute(
        //   name: 'splash',
        //   path: '/splash', // 命名参数 :url
        //   pageBuilder: (BuildContext context, GoRouterState state) {
        //     return RouterTransitionPage.transitionPage(context, state, const SettingPage(), 2);
        //   },
        //   // pageBuilder: (context, state) =>
        //   //     MaterialPage<void>(child: splashPage(context)),
        // ),
        GoRoute(
          name: 'browser',
          path: '/browser', // 命名参数 :url
          pageBuilder: (BuildContext context, GoRouterState state) {
            //此方法会替换home context.goNamed('browser', queryParameters: {'url': 'https://www.baidu.com'});
            //使用次方法 context.pushNamed('browser', queryParameters: {'url': 'https://www.baidu.com'});
            String? urlStr;
            int? wid;
            if (state.uri.queryParameters.containsKey('windowid')) {
              String? strWid = state.uri.queryParameters['windowid'];
              if (strWid != null && strWid.isNotEmpty) {
                wid = int.tryParse(strWid);
              }
            }
            if (state.uri.queryParameters.containsKey('url')) {
              urlStr = state.uri.queryParameters['url'];
            }
            return MaterialPage<void>(
              child: BrowserMainView(key: browserKey, urlParam: urlStr, windowId: wid),
            );
          },
        ),
        // GoRoute(
        //   path: '/homesc',
        //   pageBuilder: (context, state) => CustomTransitionPage(
        //     key: state.pageKey,
        //     child: HomeScreen(),
        //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
        //       // 自定义转场动画（从底部向上滑动 + 淡入）
        //       const begin = Offset(0.0, 1.0);
        //       const end = Offset.zero;
        //       const curve = Curves.easeInOut;
        //       var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        //       var offsetAnimation = animation.drive(tween);
        //       var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeIn));
        //       return FadeTransition(
        //         opacity: fadeAnimation,
        //         child: SlideTransition(position: offsetAnimation, child: child),
        //       );
        //     },
        //     transitionDuration: Duration(milliseconds: 500),
        //   ),
        // ),
      ],
    );
  }

  static GoRouter browserRouter(
    GlobalKey<NavigatorState> navKey,
    //BuildContext ctx,
    AppState appState,
    String? windowArg,
    int? windowIdArg,
    GlobalKey homeKey,
  ) {
    return GoRouter(
      navigatorKey: navKey,
      onEnter: (context, currentState, nextState, goRouter) {
        return const Allow();
      },
      onException: (context, state, router) {},
      observers: [ZjNavigatorObserver()],
      initialLocation: 'splash',
      routes: [
        GoRoute(path: '/splash', builder: (context, state) => SplashScreenPage()),
        GoRoute(
          name: '/',
          path: '/', // 命名参数 :url
          pageBuilder: (BuildContext context, GoRouterState state) {
            //此方法会替换home context.goNamed('browser', queryParameters: {'url': 'https://www.baidu.com'});
            //使用次方法 context.pushNamed('browser', queryParameters: {'url': 'https://www.baidu.com'});
            return MaterialPage<void>(
              child: BrowserMainView(key: homeKey, urlParam: windowArg, windowId: windowIdArg),
            );
          },
        ),
        GoRoute(
          name: 'blacklist',
          path: '/blacklist', // 命名参数 :url
          pageBuilder: (context, state) => RouterTransitionPage.transitionPage(context, state, const BlackListPage(), 6),
        ),
        GoRoute(
          name: 'sites',
          path: '/sites', // 命名参数 :url
          pageBuilder: (context, state) => RouterTransitionPage.transitionPage(context, state, const WebMainSiteManagerPage(), 6),
          // MaterialPage<void>(child: BlackListPage()),
        ),
        GoRoute(
          name: 'favorites',
          path: '/favorites', // 命名参数 :url
          pageBuilder: (context, state) => RouterTransitionPage.transitionPage(context, state, const FavoritesManagerPage(), 6),
        ),
        GoRoute(
          name: 'settings',
          path: '/settings', // 命名参数 :url
          pageBuilder: (BuildContext context, GoRouterState state) {
            return RouterTransitionPage.transitionPage(context, state, const SettingPage(), 6);
          },
        ),
      ],
    );
  }
}


// import 'package:go_transitions/go_transitions.dart';

// GoRoute(
//   path: '/home',
//   pageBuilder: GoTransitions.slide.toLeft.withFade.build(
//     builder: (context, state) => HomeScreen(),
//   ),
//   // 或者更简洁的写法：
//   // pageBuilder: GoTransitions.slide.toLeft.withFade,
// )


// import 'package:flutter_route_shifter/flutter_route_shifter.dart';

// GoRoute(
//   path: '/details',
//   pageBuilder: (context, state) {
//     return RouteShifterBuilder()
//       .fade(duration: Duration(milliseconds: 400))
//       .slideFromRight()
//       .toPage(child: DetailsPage());
//   },
// ),



// _goRouter = GoRouter(
    //   onEnter: (context, currentState, nextState, goRouter) {
    //     return const Allow();
    //   },
    //   onException: (context, state, router) {},
    //   observers: [ZjNavigatorObserver()],
    //   initialLocation: '/',
    //   routes: [
    //     GoRoute(
    //       name: '/',
    //       path: '/', // 命名参数 :url
    //       pageBuilder: (context, state) =>
    //           MaterialPage<void>(child: lanuchFutureBuilder(context)),
    //     ),
    //     GoRoute(
    //       name: 'home',
    //       path: '/home', // 不需要命名参数，使用查询参数
    //       pageBuilder: (context, state) => MaterialPage<void>(
    //         child: HomePage(
    //           key: mainPageKey,
    //           webMode: WebMode(
    //             initUrl: appState.appRootFirstUrl(),
    //             initUa: appState.webInitUA() ?? '',
    //             multipleWindows: false,
    //             onStateUpdated: () {},
    //             onCloseTabRequested: () {},
    //             onCreateTabRequested: (createWindowAction) {},
    //             onCloseBrowser: () {},
    //           ),
    //         ),
    //       ),
    //     ),
    //     // GoRoute(
    //     //   name: 'blacklist',
    //     //   path: '/blacklist', // 命名参数 :url
    //     //   builder: (context, state) {
    //     //     return BlackListPage();
    //     //   },
    //     // ),
    //     // 使用 GoRouter 的 context 或 Router 类直接导航，并添加查询参数
    //     //context.goNamed('home', queryParameters: {'url': 'John Doe'});
    //     // GoRoute(
    //     //   path: '/home', // 不需要命名参数，使用查询参数
    //     //   pageBuilder: (context, state) => MaterialPage<void>(
    //     //     child: Mainpage(
    //     //       initUrl: state.uri.queryParameters['url'] ?? '', // 获取查询参数 url 的值
    //     //       initUa: state.uri.queryParameters['ua'] ?? '', // 获取查询参数 ua 的值
    //     //     ),
    //     //   ),
    //     // ),
    //     //context.goNamed('/blacklist');
    //     GoRoute(
    //       name: 'blacklist',
    //       path: '/blacklist', // 命名参数 :url
    //       pageBuilder: (context, state) => RouterTransitionPage.transitionPage(
    //         context,
    //         state,
    //         const BlackListPage(),
    //         6,
    //       ),
    //       // MaterialPage<void>(child: BlackListPage()),
    //     ),
    //     GoRoute(
    //       name: 'favorites',
    //       path: '/favorites', // 命名参数 :url
    //       pageBuilder: (context, state) => RouterTransitionPage.transitionPage(
    //         context,
    //         state,
    //         const FavoritesManagerPage(),
    //         6,
    //       ),
    //       //MaterialPage<void>(child: FavoritesManagerPage()),
    //     ),
    //     GoRoute(
    //       name: 'settings',
    //       path: '/settings', // 命名参数 :url
    //       // pageBuilder: (context, state) =>
    //       //   MaterialPage<void>(child: SettingPage()),
    //       pageBuilder: (BuildContext context, GoRouterState state) {
    //         return RouterTransitionPage.transitionPage(
    //           context,
    //           state,
    //           const SettingPage(),
    //           6,
    //         );
    //       },
    //     ),
    //     GoRoute(
    //       name: 'splash',
    //       path: '/splash', // 命名参数 :url
    //       pageBuilder: (BuildContext context, GoRouterState state) {
    //         return RouterTransitionPage.transitionPage(
    //           context,
    //           state,
    //           const SettingPage(),
    //           2,
    //         );
    //       },
    //       // pageBuilder: (context, state) =>
    //       //     MaterialPage<void>(child: splashPage(context)),
    //     ),
    //     GoRoute(
    //       name: 'browser',
    //       path: '/browser', // 命名参数 :url
    //       pageBuilder: (BuildContext context, GoRouterState state) {
    //         //此方法会替换home context.goNamed('browser', queryParameters: {'url': 'https://www.baidu.com'});
    //         //使用次方法 context.pushNamed('browser', queryParameters: {'url': 'https://www.baidu.com'});
    //         return MaterialPage<void>(
    //           child: BrowserMainView(
    //             urlParam: state.uri.queryParameters['url'],
    //           ),
    //         );
    //       },
    //       // pageBuilder: (context, state) =>
    //       //     MaterialPage<void>(child: splashPage(context)),
    //     ),

    //     //context.go( '/list${url}' )
    //     // GoRoute(
    //     //   path: '/list/:url', // 命名参数 :url
    //     //   pageBuilder: (context, state) => MaterialPage<void>(
    //     //     child: Mainpage(
    //     //       initUa: '',
    //     //       initUrl: state.pathParameters['url'].toString(),
    //     //     ),
    //     //   ),
    //     // ),
    //     // //context.go( '/list',extra:userInfo)
    //     // GoRoute(
    //     //   path: '/list', // 命名参数 :url
    //     //   pageBuilder: (context, state) {
    //     //     final userinfo = state.extra as Map;
    //     //     return MaterialPage<void>(
    //     //       child: Mainpage(
    //     //         initUa: userinfo['ua'],
    //     //         initUrl: userinfo['url'] ?? '',
    //     //       ),
    //     //     );
    //     //   },
    //     // ),
    //   ],
    // );
    //await themePro.loadThemeModeFromPref();