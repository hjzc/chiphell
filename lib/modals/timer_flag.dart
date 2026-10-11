import 'dart:async';

class TimerFlag {
  bool flag = true;
  int seconds = 3;
  Timer? _timer;
  bool _cancelled = false;
  TimerFlag({
    required this.seconds,
    required this.flag,
    required this.timerOutBlock,
  });
  int token = 0;
  final void Function(int token)? timerOutBlock;

  void reset() {
    if (token > 999999) {
      token = 0;
    } else {
      token++;
    }
    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
    } else {
      _cancelled = false;
    }
  }

  int start() {
    if (_timer == null) {
      _cancelled = false;
      int tt = token;
      //Timer.periodic 每1秒执行一次
      _timer = Timer(Duration(seconds: seconds), () {
        _handleTimer(tt);
      });
      return tt;
    } else {
      return -1;
    }
  }

  void _handleTimer(int tk) {
    if (tk != token || _cancelled) {
      return;
    }
    if (timerOutBlock != null) {
      timerOutBlock!(tk);
    }
    reset();
  }

  void cancel() {
    _cancelled = true;
    reset();
  }
}
