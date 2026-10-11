//import 'package:flutter/material.dart';
//import 'package:intl/intl.dart';

// import 'package:date_format/date_format.dart';
class UtilDate {
  static void test() {
    // ZZZ：输出时区偏移量，格式为 +/-HHmm（例如 +0800, -0500）。对于UTC时间（now.toUtc()），此格式将输出 +0000。
    // ZZZZZ：输出时区偏移量，格式为 +/-HH:mm（例如 +08:00, -05:00）。对于UTC时间，将输出 +00:00。
    // 如果当前系统时区为UTC，方法1将直接输出 +0000；否则，它将输出您本地时区的偏移量（如 +0800）。
    // var utcTime = DateTime.now();
    // //.toUtc();

    // //111AM2026, 111 4on YYYY 09:04:602
    // String txt = DateFormat('Day, DD Mon YYYY HH:MM:SS Z').format(utcTime);

    // //Tue, Apr 21, 2026 09:39:10,, Z无效
    // String txt1 = DateFormat("EEE, MMM d, yyyy HH:mm:ss ZZZ").format(utcTime);
    // String txt111 = DateFormat("EEE, MMM d, yyyy HH:mm:ss ZZZZ").format(utcTime);
    // String txt222 = DateFormat("EEE, MMM d, yyyy HH:mm:ss ZZZZZ").format(utcTime);

    // //  Tue, Apr 21, 2026 09:42:30 UTC
    // String txt2 = DateFormat("EEE, MMM d, yyyy HH:mm:ss UTC").format(utcTime);

    // //Tue, 21 Apr 2026 01:42:30 GMT
    // var gmtTime = DateFormat('EEE, dd MMM yyyy HH:mm:ss \'GMT\'').format(utcTime);

    // var jus = DateFormat('yyyy-MM-dd', 'en_US').format(utcTime);

    // DateTime now = DateTime.now();

    // // 方法1: 包含本地时区的格式
    // DateFormat localFormatter = DateFormat('yyyy-MM-dd HH:mm:ss z');
    // String localFormatted = localFormatter.format(now);

    // // 方法2: UTC时间带Z标识
    // DateTime utcNow = now.toUtc();
    // DateFormat utcFormatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
    // String utcFormatted = utcFormatter.format(utcNow);

    // // 方法3: ISO8601格式（自动包含偏移量）
    // String iso8601String = now.toIso8601String();

    // //获取当前设备所在的本地化区域和语言环境
    // var currentLocale = Intl.getCurrentLocale();

    // String utcOffsetFormatted = DateFormat('yyyy-MM-dd HH:mm:ss ZZZ').format(utcNow);
    // String utcOffsetFormatted1 = DateFormat('yyyy-MM-dd HH:mm:ss Z').format(utcNow);
    // String utcOffsetFormatted11 = DateFormat('yyyy-MM-dd HH:mm:ss z').format(utcNow);

    // debugPrint('当前区域设置: $currentLocale');
    // debugPrint('本地时间 (含本地时区): $localFormatted');
    // debugPrint('UTC时间 (带Z标识): $utcFormatted');
    // debugPrint('ISO8601格式 (自动偏移量): $iso8601String');

    // //DateFormat.ABBR_STANDALONE_MONTH('en_US').format(utcTime);
    // //DateFormat.yMMMMd('ja_JP').format(now);

    // ///date_format 库
    // //2019-08-28 Wednesday 14:27:29
    // // debugPrint(formatDate(DateTime.now(), [yyyy, "-", mm, "-", dd, " ", DD, " ", HH, ":", nn, ":", ss]));

    // debugPrint('当前时间- RFC 2822 格式 : $txt');
  }
}
