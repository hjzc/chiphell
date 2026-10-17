import 'package:chiphell/common/constants.dart';
import 'package:chiphell/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/utils.dart';

enum WebNavBottomBarEvent {
  //后退所有可能的父亲
  backAllParent,
  //主页
  home,
  //后退
  back,
  //返回打开过的父亲
  backParent,
  //停止
  stop,
  //刷新
  refresh,
  //向前
  forward,
  //更多
  more,
}

class WebNavigationBottomBar extends StatefulWidget {
  final bool isPrompt;
  final Orientation? orientation;
  final void Function(WebNavBottomBarEvent event, {RelativeRect? position}) eventCallBack;
  const WebNavigationBottomBar({super.key, required this.isPrompt, required this.orientation, required this.eventCallBack});
  @override
  State<StatefulWidget> createState() {
    return WebNavigationBottomBarState();
  }
}

class WebNavigationBottomBarState<T> extends State<WebNavigationBottomBar> {
  final GlobalKey moreBtnKey = GlobalKey();
  @override
  void initState() {
    super.initState();
  }

  List<Widget> _buildItems(BuildContext context) {
    List<Widget> items = [
      IconButton(
        icon: const Icon(Icons.first_page),
        onPressed: () {
          widget.eventCallBack(WebNavBottomBarEvent.backAllParent);
          // await _gotoCurrentForum(true);
        },
      ),
      IconButton(
        icon: const Icon(Icons.home),
        onPressed: () {
          //去主页面
          widget.eventCallBack(WebNavBottomBarEvent.home);
        },
      ),
      IconButton(
        icon: const Icon(Icons.arrow_back),
        onLongPress: () {
          //goto current forum
          widget.eventCallBack(WebNavBottomBarEvent.forward);
          // await _gotoCurrentForum(false);
        },
        onPressed: () {
          widget.eventCallBack(WebNavBottomBarEvent.backParent);
          //_handlePopBackGesture();
        },
      ),
    ];
    if (Utils.isDesktopSystem || Utils.isIOSPad || Utils.isAndroidPad) {
      items.add(
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          //onLongPress: () async {
          //goto current forum
          //  await stopLoading();
          // widget.eventCallBack(WebNavBottomBarEvent.stop);
          // },
          onPressed: () {
            widget.eventCallBack(WebNavBottomBarEvent.forward);
            // if ((await canGoForward())) {
            //   await goForward();
            // }
          },
        ),
      );
    }
    items.add(
      IconButton(
        icon: const Icon(Icons.refresh),
        onLongPress: () {
          // if (Utils.isDesktopSystem) {
          widget.eventCallBack(WebNavBottomBarEvent.stop);
          // } else {
          // widget.eventCallBack(WebNavBottomBarEvent.forward);
          //}
          // if ((await canGoForward())) {
          //   await goForward();
          // }
        },
        onPressed: () {
          widget.eventCallBack(WebNavBottomBarEvent.refresh);
          //await _reloadWeb();
        },
      ),
    );
    items.add(
      Container(
        key: moreBtnKey,
        // height: 60,
        child: Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.more_horiz_rounded),
              onPressed: () {
                final RenderBox box = moreBtnKey.currentContext?.findRenderObject() as RenderBox;
                Offset pos = box.localToGlobal(Offset.zero);
                RelativeRect position = RelativeRect.fromLTRB(pos.dx, pos.dy, 16, 60);

                // final RenderBox renderBox = moreBtnKey.currentContext?.findRenderObject() as RenderBox;
                // final position1 = RelativeRect.fromRect(
                //   Rect.fromPoints(renderBox.localToGlobal(Offset.zero), renderBox.localToGlobal(renderBox.size.bottomRight(Offset.zero))),
                //   Offset.zero & renderBox.size,
                // );
                // RelativeRect.fromLTRB(position.dx, position.dy - 116, 16, 80),
                // ZsLog.d('More icon Button 位置: $position');

                widget.eventCallBack(WebNavBottomBarEvent.more, position: position);
                //_handleBottomBarMoreAction();
              },
            ),
            Positioned(
              right: 8,
              top: 8,
              width: 5,
              height: 5,
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(color: Colors.red.withAlpha(widget.isPrompt ? 255 : 0), shape: BoxShape.circle),
              ),
            ),
          ],
        ),
      ),
    );
    return items;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.orientation != null) {
      return _buildBriefBar(context, widget.orientation!);
    } else {
      return DeviceOrientationBuilder(
        builder: (context, orientation) {
          return _buildBriefBar(context, orientation);
        },
      );
    }
  }

  Widget _buildOverflowBar(BuildContext context) {
    return OverflowBar(
      alignment: MainAxisAlignment.spaceAround, //水平排列对齐方式
      overflowDirection: VerticalDirection.down, //垂直排列时候item的排列方式。从下到上
      children: _buildItems(context),
    );
  }

  Widget _buildTopLine(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    return Divider(
      color: themeProvider.isDarkTheme()
          ? Color.fromARGB(255, 42, 42, 42)
          : Color.fromARGB(
              240,
              214,
              214,
              217,
            ), // themeProvider.isDarkTheme() ? const Color.fromARGB(250, 12, 12, 12) : Colors.white, // 分割线颜色
      height: 1, // 分割线高度
      indent: 0, // 分割线缩进
      endIndent: 0, // 分割线末端缩进
      // thickness: 0,
    );
  }

  /// 推荐 更居中一点
  Widget _buildBriefBar(BuildContext context, Orientation orientation) {
    double h = Constants.kMinInteractiveDimension + Constants.kBarDividerLineDimension;
    return SizedBox(
      //width: double.infinity, // 宽度，根据需要调整
      height: h, // 具体高度可以根据需要调整
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [_buildTopLine(context), _buildOverflowBar(context)],
      ),
    );
  }

  ///在竖屏 不居中
  // Widget _buildBar(BuildContext context, Orientation orientation) {
  //   var tOrientation = Utils.isDesktopSystem ? Orientation.portrait : orientation;
  //   //desktop 上窗口的宽高比 变化 orientation会变化
  //   return SizedBox(
  //     //width: double.infinity, // 宽度，根据需要调整
  //     height: tOrientation == Orientation.portrait
  //         ? Constants.kBottomNavigationBarHeight
  //         : Constants.kMinInteractiveDimension, // 具体高度可以根据需要调整
  //     child: Stack(
  //       children: [
  //         _buildOverflowBar(context),
  //         Container(
  //           decoration: BoxDecoration(
  //             border: Border.all(color: Colors.transparent), // 为了确保阴影显示
  //             boxShadow: [
  //               BoxShadow(
  //                 color: const Color.fromARGB(20, 0, 0, 0), // 阴影颜色和透明度
  //                 spreadRadius: 1, // 阴影扩散范围
  //                 blurRadius: 2, // 阴影模糊程度,太大值会影响控件下面的事件接受
  //                 offset: Offset(0, 0), // 阴影偏移
  //               ),
  //             ],
  //           ),
  //           child: Divider(
  //             color: const Color.fromARGB(
  //               10,
  //               0,
  //               0,
  //               0,
  //             ), // themeProvider.isDarkTheme() ? const Color.fromARGB(250, 12, 12, 12) : Colors.white, // 分割线颜色
  //             height: 1, // 分割线高度
  //             indent: 0, // 分割线缩进
  //             endIndent: 0, // 分割线末端缩进
  //           ),
  //         ),

  //         // Container(height: 2, color: Colors.red),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildBriefBar1(BuildContext context, Orientation orientation) {
  //   //double h = orientation == Orientation.portrait ? Constants.kBottomNavigationBarHeight : Constants.kMinInteractiveDimension;
  //   double h = Constants.kMinInteractiveDimension + Constants.kBarDividerLineDimension;
  //   return SizedBox(
  //     //width: double.infinity, // 宽度，根据需要调整
  //     height: h, // 具体高度可以根据需要调整
  //     child: Stack(
  //       clipBehavior: Clip.hardEdge,
  //       alignment: AlignmentGeometry.bottomCenter,
  //       children: [
  //         OverflowBar(
  //           alignment: MainAxisAlignment.spaceAround, //水平排列对齐方式
  //           overflowDirection: VerticalDirection.down, //垂直排列时候item的排列方式。从下到上
  //           children: _buildItems(context),
  //         ),
  //         _buildBarShadow(context, h),
  //       ],
  //     ),
  //   );
  // }

  // //增加阴影，导致divider 首尾少1个像素
  // Widget _buildBarShadow(BuildContext context, double h) {
  //   return SizedBox(
  //     height: h,
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.start,
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //         Container(
  //           height: 1,
  //           alignment: AlignmentGeometry.topCenter,
  //           padding: EdgeInsets.all(0),
  //           decoration: BoxDecoration(
  //             border: Border.all(color: Colors.transparent), // 为了确保阴影显示
  //             boxShadow: [
  //               BoxShadow(
  //                 color: const Color.fromARGB(20, 0, 0, 0), // 阴影颜色和透明度
  //                 spreadRadius: 1, // 阴影扩散范围
  //                 blurRadius: 2, // 阴影模糊程度,太大值会影响控件下面的事件接受
  //                 offset: Offset(0, 0), // 阴影偏移
  //               ),
  //             ],
  //           ),
  //           child: Divider(
  //             color: const Color.fromARGB(
  //               10,
  //               0,
  //               0,
  //               0,
  //             ), // themeProvider.isDarkTheme() ? const Color.fromARGB(250, 12, 12, 12) : Colors.white, // 分割线颜色
  //             height: 1, // 分割线高度
  //             indent: 0, // 分割线缩进
  //             endIndent: 0, // 分割线末端缩进
  //             thickness: 0, //厚度
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
