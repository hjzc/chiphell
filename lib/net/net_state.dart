import 'package:flutter/material.dart';

class NetState {
  DateTime startDate;
  DateTime? updateDate;
  bool connected;
  NetState({required this.startDate, this.updateDate, required this.connected});
}

class NetStateQueue extends ChangeNotifier {
  int maxCount = 3;
  //单例
  static final NetStateQueue _instance = NetStateQueue._();
  factory NetStateQueue() {
    return _instance;
  }
  NetStateQueue._() : super();

  final List<NetState> _queue = [];

  bool addNetState(bool connected) {
    DateTime current = DateTime.now();
    NetState? st = getLastNetState();
    if (st != null && (st.connected == connected)) {
      st.updateDate = current;
      return false;
    }
    _queue.add(
      NetState(startDate: current, updateDate: current, connected: connected),
    );
    if (_queue.length > maxCount) {
      _queue.removeAt(0);
    }
    notifyListeners();
    return true;
  }

  NetState? getLastNetState() {
    return _queue.isNotEmpty ? _queue.last : null;
  }
}
