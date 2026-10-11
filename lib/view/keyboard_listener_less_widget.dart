import 'package:flutter/widgets.dart';

class KeyboardListenerLessWidget extends StatelessWidget {
  KeyboardListenerLessWidget({
    super.key,
    required this.keyEventCallBack,
    required this.child,
  });
  final Function(KeyEvent event) keyEventCallBack;
  final Widget child;
  final FocusNode _focusNode = FocusNode();

  void _handleKeyEvent(KeyEvent event) {
    keyEventCallBack(event);
    // if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
    //   controller.nextPage(
    //     duration: const Duration(milliseconds: 400),
    //     curve: Curves.linear,
    //   );
    // } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
    //   controller.previousPage(
    //     duration: const Duration(milliseconds: 400),
    //     curve: Curves.linear,
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      autofocus: true,
      child: child,
    );
  }
}
