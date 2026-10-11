import 'package:chiphell/common/constants.dart';

enum ZjCodes {
  er(-1, desc: Constants.kStatusFailed, other: Constants.kStrNull),
  ok(0, desc: Constants.kStatusOk, other: Constants.kStrNull);
  //  notFound(404, 'Not Found'),
  //  internalServerError(500, 'Internal Server Error');

  final int code;
  final String? desc;
  final String? other;

  const ZjCodes(this.code, {this.desc, this.other});

  @override
  String toString() => "code:$code,description:${desc ?? 'null'},other:${other ?? 'null'}";
  bool get success => code == 0;
}

// // 使用
// print(ZjResultStatus.ok.code); // 0

class ZjStatus {
  String? desc;
  String? other;
  int code = -1;
  ZjStatus({this.code = -1, this.desc, this.other});

  bool get success => code == 0;
  String get description => "code:$code,desc:${desc ?? 'null'},other:${other ?? 'null'}";
  @override
  String toString() => description;
}

enum ZjCleanCache {
  base(0, desc: Constants.kCleanCacheBase),
  all(1, desc: Constants.kCleanCacheAll);

  final int code;
  final String? desc;
  const ZjCleanCache(this.code, {this.desc});

  @override
  String toString() => "code:$code,description:${desc ?? 'null'}";
  bool get success => code == 0;
}
