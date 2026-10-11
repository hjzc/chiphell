import 'package:chiphell/utils/aes_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../modals/AppState.dart';
import '../modals/WebTextSize.dart';
import '../router/zj_router.dart';
import '../theme/theme_provider.dart';
import '../utils/zs_log.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});
  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  Future<void>? _future;
  int _step = 0;

  @override
  void initState() {
    super.initState();
    var appState = Provider.of<AppState>(context, listen: false);
    var webTextSize = Provider.of<WebTextSize>(context, listen: false);
    var themePro = Provider.of<ThemeProvider>(context, listen: false);
    _future = _initLoading(themePro, appState, webTextSize);
  }

  void goHome() {
    context.go('/');
  }

  Future<void> _initLoading(ThemeProvider themePro, AppState appState, WebTextSize websize) async {
    // _initLoadState = false;
    await AesUtil.initAes();
    await themePro.initLoad();
    await websize.initTextSize();
    await appState.initLoad();
    _updateStep();
  }

  void _updateStep() {
    _step++;
    if (_step > 2) {
      goHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppState>(context, listen: true);
    //var webTextSize = Provider.of<WebTextSize>(context, listen: false);
    var themePro = Provider.of<ThemeProvider>(context, listen: true);
    //全屏 所以不需要安全区域,隐藏statusbar
    return _annotatedRegionWidget(context, appState, themePro);
    //   body: SafeArea(child: _lanuchFutureBuilder(context, appState, themePro))
  }

  Widget _annotatedRegionWidget(BuildContext context, AppState appState, ThemeProvider themeProvider) {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // 该页面专属的状态栏样式
      value: SystemUiOverlayStyle(
        //暗色模式下使用
        //statusBarColor: Colors.transparent, // 透明状态栏，适用于深色背景
        // statusBarIconBrightness: Brightness.light, // 图标颜色（深色/浅色）
        //statusBarBrightness: Brightness.light, // ios 状态栏亮度（深色/浅色）
      ),
      child: _scaffoldBuilder(context, appState, themeProvider),
    );
  }

  Widget _scaffoldBuilder(BuildContext context, AppState appState, ThemeProvider tp) {
    return Scaffold(
      body: _lanuchFutureBuilder(context, appState, tp),
      //   body: SafeArea(child: _lanuchFutureBuilder(context, appState, themePro))
    );
  }

  Widget _lanuchFutureBuilder(BuildContext context, AppState appState, ThemeProvider tp) {
    return FutureBuilder(
      future: _future, // 异步操作, 比如通过 api 拉取数据
      builder: (context, snapshot) {
        //根据异步操作的状态更新UI
        if (snapshot.connectionState == ConnectionState.waiting) {
        } else {
          if (snapshot.hasError) {
            ZsLog.e('Init Future data error:', error: snapshot.error); // 发生错误
          }
          //gotoWebMainPage(context, 600);
          Future.delayed(Duration(milliseconds: 200), () {
            if (_future != null) {
              _future = null;
              setState(() {
                _updateStep();
              });
            }
          });
        }
        return ZjRouter.startSplashPage(
          context,
          tp.isDarkThreme(),
          () {
            ZsLog.i('Splash Init', time: DateTime.now());
          },
          () {
            ZsLog.i('Splash end', time: DateTime.now());
          },
          () {
            ZsLog.i('Splash completed', time: DateTime.now());
            setState(() {
              _updateStep();
            });
          },
        );
      },
    );
  }
}
