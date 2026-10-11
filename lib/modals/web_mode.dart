import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebMode {
  final String? initUrl;
  final String? initUa;
  final bool multipleWindows;

  ///如果windowid 不为null，则不应该使用url多开新窗口
  final int? windowId;
  final Function() onStateUpdated;
  final bool Function(CreateWindowAction? createWindowAction, String? orUrl) onCreateTabRequested;
  final Function() onCloseTabRequested;
  final Function() onCloseBrowser;
  const WebMode({
    required this.initUrl,
    required this.initUa,
    required this.multipleWindows,
    required this.onStateUpdated,
    required this.onCloseTabRequested,
    required this.onCreateTabRequested,
    required this.onCloseBrowser,
    this.windowId,
  });
}
