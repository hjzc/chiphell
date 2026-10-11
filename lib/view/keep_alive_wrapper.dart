// KeepAliveWrapper 实现
import 'package:flutter/material.dart';

//   解决页面状态保持问题：
class KeepAliveWrapper extends StatefulWidget {
  final Widget child;

  const KeepAliveWrapper({super.key, required this.child});

  @override
  KeepAliveWrapperState createState() => KeepAliveWrapperState();
}

class KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

// TabBarView(
//   children: [
//     KeepAliveWrapper(child: Page1()), // 自定义保持状态组件
//     AutomaticKeepAliveClientMixin(
//       wantKeepAlive: true,
//       child: Page2(),
//     ),
//   ],
// )
