import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_cache_manager/file.dart';

class FilePickerHelper {
  static Future<List<String?>> selectedFileImport({
    String? dialogTitle,
    String? fileName,
    FileType? type = FileType.custom,
    bool? allowMultiple = false,
    List<String>? allowedExtensions,
  }) async {
    List<String?> r = [];
    List<PlatformFile> result = await FilePicker.pickFiles(
      dialogTitle: dialogTitle ?? '请选择导入的文件：',
      // allowMultiple: allowMultiple ?? false,
      type: type ?? FileType.custom,
      allowedExtensions: type == FileType.custom ? (allowedExtensions ?? ['*']) : null,
    );
    if (result.isNotEmpty) {
      //final paths = result.map((e) => e.path).where((e) => e != null).toList();
      for (var pt in result) {
        var path = pt.path;
        if (path != null) {
          r.add(path);
        }
      }
      // r = paths; //result.map((e)=>e.path );
    }
    return r;
  }

  static Future<String?> selectedFileExportData(
    Uint8List data, {
    String? dialogTitle,
    String? fileName,
    List<String>? allowedExtensions,
  }) async {
    Uri? outputFile = await FilePicker.saveFile(
      dialogTitle: dialogTitle ?? '请选择导出的文件：',
      type: FileType.custom,
      allowedExtensions: allowedExtensions ?? [],
      bytes: data,
      fileName: fileName ?? '',
    );
    return outputFile?.toFilePath();
  }

  static Future<String?> exportCsvStringToFile(String csvText, {String? fileName}) async {
    return await selectedFileExportData(utf8.encode(csvText), fileName: fileName ?? 'chiphell_filters.csv', allowedExtensions: ['csv']);
  }

  static Future<File?> saveFile(
    File file, {
    String? dialogTitle,
    String? fileName,
    List<String>? allowedExtensions,
    bool isClean = false,
  }) async {
    File? r;
    String? outputFile = await selectedFileExportData(
      Uint8List.fromList([1]),
      dialogTitle: dialogTitle,
      fileName: fileName,
      allowedExtensions: allowedExtensions,
    );
    try {
      if (outputFile != null && await file.exists()) {
        r = await file.copy(outputFile);
        if (isClean) {
          file.delete(recursive: true);
        }
      }
    } catch (_) {}
    return r;
  }
}
