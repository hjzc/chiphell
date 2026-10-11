import 'package:flutter/material.dart';

//复杂手势处理与 PageView 嵌套时的滑动冲突解决方案：
class TabBarViewWrapper extends StatelessWidget {
  final TabController tabController;
  final Widget child;

  const TabBarViewWrapper({
    super.key,
    required this.tabController,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          // 处理横向滑动逻辑
          tabController.animateTo(
            (tabController.offset -
                    notification.scrollDelta! / context.size!.width)
                .toInt(),
          );
        }
        return true;
      },
      child: child,
    );
  }
}

// PageView(
//   physics: ClampingScrollPhysics(), // 禁用页面滑动
//   controller: _pageController,
//   children: [
//     TabBarViewWrapper( // 自定义嵌套容器
//       tabController: _tabController,
//       child: TabBarView(...),
//     ),
//   ],
// )
