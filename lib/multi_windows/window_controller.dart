import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

extension WindowControllerExtension on WindowController {
  Future<void> doCustomInitialize() async {
    return await setWindowMethodHandler(_customWindowCallBack);
  }

  Future<dynamic> _customWindowCallBack(MethodCall call) async {
    switch (call.method) {
      case 'window_center':
        return await windowManager.center();
      case 'window_close':
        return await windowManager.close();
      case 'window_destroy':
        return await windowManager.destroy();
      default:
        throw MissingPluginException('Not implemented method: ${call.method}');
    }
  }

  Future<void> center() async {
    return invokeMethod('window_center');
  }

  Future<void> close() async {
    return invokeMethod('window_close');
  }

  Future<void> clear() async {
    return await setWindowMethodHandler(null);
  }

  Future<void> destroy() {
    return invokeMethod('window_destroy');
  }
}
