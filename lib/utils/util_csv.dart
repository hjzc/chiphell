import 'dart:convert';
import 'dart:io';
import 'package:chiphell/utils/file_picker_helper.dart';
import 'package:csv/csv.dart';

class UtilCsv {
  static List<String> stringFromCsvDecode(List<List<dynamic>> decoded) {
    List<String> r = [];
    for (var i = 0; i < decoded.length; i++) {
      final item = decoded[i];
      for (var j = 0; j < item.length; j++) {
        final v = item[j];
        String? s;
        if (v is int) {
          s = '$v';
        } else if (v is String) {
          s = v;
        }
        if (s != null) {
          if (!r.contains(v)) {
            r.add(v);
          }
        }
      }
    }
    return r;
  }

  static Future<List<String>> parserCsvText(String text) async {
    return stringFromCsvDecode(csv.decode(text));
  }

  ///导入 csv文件
  static Future<List<String>> importCsvFile() async {
    List<String> r = [];
    List<String?> result = await FilePickerHelper.selectedFileImport(allowedExtensions: ['csv']);
    if (result.length == 1) {
      String? path = result.first;
      if (path != null) {
        try {
          final file = File(path);
          final List<List<dynamic>> rows = await file.openRead().transform(utf8.decoder).transform(csv.decoder).toList();
          r = stringFromCsvDecode(rows);
        } catch (_) {}
        //ZsLog.d(r);
      }
    }
    return r;
  }

  ///字符串内容导出csv文件
  static Future<String?> exportCsvFile(String csvText) async {
    return FilePickerHelper.exportCsvStringToFile(csvText);
  }
}
