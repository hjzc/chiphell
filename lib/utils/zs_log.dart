import 'package:chiphell/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';

//import 'util_date.dart';

class ZsLog {
  static late Logger _logger;
  static bool initFlag = false;
  static int winOrder = 0; //窗口序号

  static Future<void> close() async {
    await ZsLog._logger.close();
  }

  static Future<void> init() async {
    if (!initFlag) {
      initFlag = true;
      String folder = await Utils.getLogsPath(0);
      if (kDebugMode) {
        //UtilDate.test();
        ZsLog._logger = Logger(
          filter: DevelopmentFilter(),
          printer: PrettyPrinter(
            methodCount: 5, // Number of method calls to be displayed
            errorMethodCount: 8, // Number of method calls if stacktrace is provided
            lineLength: 120, // Width of the output
            colors: true, // Colorful log messages
            printEmojis: true, // Print an emoji for each log message
            // Should each log print contain a timestamp
            dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
          ),
          output: ConsoleOutput(),
        );
        Logger.level = Level.all;
        ZsLog.d('log path: $folder');
      } else {
        ZsLog._logger = Logger(
          filter: kDebugMode ? DevelopmentFilter() : ProductionFilter(),
          printer: PrettyPrinter(methodCount: 0, dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart),
          output: AdvancedFileOutput(
            path: folder,
            maxFileSizeKB: 1024, // 10240,
            maxRotatedFilesCount: 5,
            fileNameFormatter: (timestamp) {
              //import 'package:intl/intl.dart';
              // String formatted = DateFormat('yyyy-MM-dd – kk:mm').format(now);
              // print(formatted); // 2023-10-27 – 10:30
              // // Common named formats
              // print(DateFormat.yMd().format(now));    // 10/27/2023
              // print(DateFormat.yMMMMd().format(now)); // October 27, 2023
              // print(DateFormat.Hm().format(now));     // 10:30 (24h)

              //Day, DD Mon YYYY HH:MM:SS Z
              return DateFormat('yyyy-MM-dd - hh-mm').format(timestamp);
            },
          ),
        );
        Logger.level = Level.info;
      }

      // Logger.level = kDebugMode ? Level.all : Level.info;

      // initLogger(path);
      //debugPrint('log path: $path');

      //111AM2026, 111 4on YYYY 09:04:602
      // String txt = DateFormat('Day, DD Mon YYYY HH:MM:SS Z').format(DateTime.now());

      // //Tue, Apr 21, 2026 09:39:10
      // String txt1 = DateFormat("EEE, MMM d, yyyy HH:mm:ss Z").format(DateTime.now());
      // //  Tue, Apr 21, 2026 09:42:30 UTC
      // String txt2 = DateFormat("EEE, MMM d, yyyy HH:mm:ss UTC").format(DateTime.now());

      // var utcTime = DateTime.now().toUtc();
      // //Tue, 21 Apr 2026 01:42:30 GMT
      // var gmtTime = DateFormat('EEE, dd MMM yyyy HH:mm:ss \'GMT\'').format(utcTime);

      // debugPrint('当前时间- RFC 2822 格式 : $txt');
    }
  }

  // /// verbose log
  // static void v(String? message) {
  //   v('[LOG-VERBOSE-]${message ?? 'null'}');
  // }

  // /// debug log
  // static void d(String? message) {
  //   d('[LOG-DEBUG-]${message ?? 'null'}');
  // }

  // /// info log
  // static void i(String? message) {
  //   i('[LOG-INFO-]${message ?? 'null'}');
  // }

  // /// warning log
  // static void w(String? message) {
  //   w('[LOG-WARNING-]${message ?? 'null'}');
  // }

  // /// error log
  // /// [error] the error object
  // /// [stackTrace] the stack trace of the error
  // static void e(String? message, [Object? error, StackTrace? stackTrace]) {
  //   e('[LOG-ERROR-]${message ?? 'null'}', [error, stackTrace]);
  // }

  // /// wtf log
  // static void wtf(String? message) {
  //   wtf('[LOG-WTF-]${message ?? 'null'}');
  // }
  static String megMessage(dynamic message, String tag) {
    return "[LOG[$winOrder]$tag:]${message ?? 'null'}";
  }

  //trace
  static void t(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    if (ZsLog._logger.isClosed()) {
      return;
    }
    ZsLog._logger.t(megMessage(message, 'T'), time: time, error: error, stackTrace: stackTrace);
  }

  //debug
  static void d(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    if (ZsLog._logger.isClosed()) {
      return;
    }
    ZsLog._logger.d(megMessage(message, 'D'), time: time, error: error, stackTrace: stackTrace);
  }

  //info
  static void i(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    if (ZsLog._logger.isClosed()) {
      return;
    }
    ZsLog._logger.i(megMessage(message, 'I'), time: time, error: error, stackTrace: stackTrace);
  }

  //warning
  static void w(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    if (ZsLog._logger.isClosed()) {
      return;
    }
    ZsLog._logger.w(megMessage(message, 'W'), time: time, error: error, stackTrace: stackTrace);
  }

  //error
  static void e(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    if (ZsLog._logger.isClosed()) {
      return;
    }
    ZsLog._logger.e(megMessage(message, 'E'), time: time, error: error, stackTrace: stackTrace);
  }

  /// Log a message at level [Level.fatal]. 致命的
  static void f(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    if (ZsLog._logger.isClosed()) {
      return;
    }
    ZsLog._logger.f(megMessage(message, 'F'), time: time, error: error, stackTrace: stackTrace);
  }
}

// void zsDebugPrint(String? message) async {
//   if (kDebugMode) {
//     ZsLog.d(message);
//   } else {
//     ZsLog.i(message);
//   }
// }
