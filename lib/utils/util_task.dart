class UtilTask {
  ///优先1, 同步执行
  Future<dynamic> sync(Future<dynamic> Function() call) async {
    return await Future.sync(() async {
      return await call.call();
    });
  }

  Future<dynamic> synValue(Future<dynamic> Function() call) async {
    return await Future.syncValue(() async {
      return await call.call();
    });
  }

  ///优先2，异步
  Future<dynamic> scheduleMicrotask(Future<dynamic> Function() call) async {
    return scheduleMicrotask(() async {
      return await call.call();
    });
  }

  ///优先3，异步
  Future<dynamic> microtask(Future<dynamic> Function() call) async {
    return Future.microtask(() async {
      return await call.call();
    });
  }

  ///优先4，异步
  Future<dynamic> value(Future<dynamic> Function() call, Future<dynamic> Function(dynamic value) valueCall) async {
    return await Future.value(() async {
      return await call.call();
    }).then((val) async {
      return await valueCall.call(val);
    });
  }

  ///优先5
  Future<dynamic> computation(Future<dynamic> Function() call) async {
    return await Future(() async {
      return await call.call();
    });
  }

  ///优先6
  Future<dynamic> delayed(Future<dynamic> Function() call) async {
    return await Future.delayed(Duration.zero, () async {
      return await call.call();
    });
  }

  ///优先7
  Future<dynamic> delayedDuration(Duration delay, Future<dynamic> Function() call) async {
    return await Future.delayed(delay, () async {
      return await call.call();
    });
  }
}
