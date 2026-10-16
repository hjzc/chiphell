import 'dart:async';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../utils/zs_log.dart';

// 定义回调函数类型
// 网络状态变化时的回调函数，参数为当前的网络状态列表
typedef InternetStatusCallback = void Function(InternetStatus result);
// 网络连接时的回调函数，无参数
typedef InternetConnectedCallback = void Function();
// 网络断开时的回调函数，无参数
typedef InternetDisconnectedCallback = void Function();

class InternetStatusManager {
  // 使用 Connectivity 插件实例来监听网络状态变化
  late final InternetConnection _connection;
  late final StreamSubscription<InternetStatus> _subscription;
  InternetStatus _internetStatus = InternetStatus.disconnected;

  // 定义回调函数
  // 网络状态变化时的回调函数
  late InternetStatusCallback _onInternetChanged;
  // 网络连接时的回调函数
  late InternetConnectedCallback _onInternetConnected;
  // 网络断开时的回调函数
  late InternetDisconnectedCallback _onInternetDisconnected;

  // 初始化网络状态管理器
  // 参数：
  // - onInternetChanged：网络状态变化时的回调函数
  // - onInternetConnected：网络连接时的回调函数
  // - onInternetDisconnected：网络断开时的回调函数
  void initInternetStatusManager({
    required InternetStatusCallback onInternetChanged,
    required InternetConnectedCallback onInternetConnected,
    required InternetDisconnectedCallback onInternetDisconnected,
  }) {
    // 保存回调函数
    _onInternetChanged = onInternetChanged;
    _onInternetConnected = onInternetConnected;
    _onInternetDisconnected = onInternetDisconnected;
    _connection = InternetConnection.createInstance(
      checkInterval: Duration(seconds: 20),
      useDefaultOptions: false,
      customCheckOptions: [
        InternetCheckOption(uri: Uri.parse('https://www.chiphell.com/')),
        InternetCheckOption(uri: Uri.parse('https://www.baidu.com')),
      ],
    );
    _subscription = _connection.onStatusChange.listen((status) {
      _handleConnectivityChange(status);
    });
  }

  void _handleConnectivityChange(InternetStatus result) {
    _onInternetChanged.call(result);
    if (_internetStatus != result) {
      _internetStatus = result;
      if (_internetStatus == InternetStatus.disconnected) {
        _onInternetDisconnected.call();
      } else {
        _onInternetConnected.call();
      }
    }
  }

  // 取消监听
  // 释放资源，取消对网络状态变化事件的订阅
  void dispose() {
    _subscription.cancel();
  }

  Future<bool> hasInternetAccess() async {
    final bool isConnected = await _connection.hasInternetAccess;
    if (isConnected) {
      ZsLog.i('Connected!');
    } else {
      ZsLog.i('No internet connection.');
    }
    return isConnected;
  }
}
