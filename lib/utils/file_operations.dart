import 'dart:io';
import 'dart:typed_data';
import 'package:chiphell/utils/zs_log.dart';
import 'package:path_provider/path_provider.dart';

import '../common/constants.dart';
import '../common/type_utils.dart';
import 'utils.dart';

class FileOperations {
  static Future<Directory> dataSaveDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  /// 将字符串写入文件
  static Future<bool> writeStringToFile(String content, String filename) async {
    try {
      final directory = await dataSaveDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsString(content);
      return true;
    } catch (e) {
      throw Exception('Failed to write file: $e');
    }
  }

  /// 从文件读取字符串
  static Future<String> readStringFromFile(String filename) async {
    try {
      final directory = await dataSaveDirectory();
      final file = File('${directory.path}/$filename');

      if (await file.exists()) {
        return await file.readAsString();
      } else {
        return '';
      }
    } catch (e) {
      throw Exception('Failed to read file: $e');
    }
  }

  /// 获取文件路径（用于显示）
  static Future<String> getFilePath(String filename) async {
    final directory = await dataSaveDirectory();
    return '${directory.path}/$filename';
  }

  /// 检查文件是否存在
  static Future<bool> fileExists(String filename) async {
    try {
      final directory = await dataSaveDirectory();
      final file = File('${directory.path}/$filename');
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// 删除文件
  static Future<bool> deleteFile(String filename) async {
    try {
      final directory = await dataSaveDirectory();
      final file = File('${directory.path}/$filename');

      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  /// 列出所有文件
  static Future<List<String>> listFiles() async {
    try {
      final directory = await dataSaveDirectory();
      final List<FileSystemEntity> files = directory.listSync();

      return files.whereType<File>().map((file) => (file).uri.pathSegments.last).toList();

      // return files
      //     .where((file) => file is File)
      //     .map((file) => (file as File).uri.pathSegments.last)
      //     .toList();
    } catch (e) {
      throw Exception('Failed to list files: $e');
    }
  }

  static Future<bool> saveDataToDownloadDir(
    Uint8List data, {
    String? outFileName,
    String? mimeType, //'application/pdf'
    String? extension, //'pdf'
    bool cover = false,
    ResultCallback? callback,
  }) async {
    bool r = false;
    try {
      String? ex = extension != null && extension.isNotEmpty ? extension : Utils.fileExtensionFromMimeType(mimeType);
      ex ??= Utils.getMimeTypeFromFileHeader(data);
      String name = Utils.dateTimeFileName(outFileName, ex: ex);
      String targPath = await Utils.getDownloadPathForSystem(name);
      if (targPath == '') {
        if (callback != null) {
          callback('下载目录不存在，保存失败', targPath, r);
        }
      } else {
        if (cover == false) {
          targPath = Utils.autoPathNoExist(targPath);
        }

        final file = File(targPath);

        if (cover) {
          if (await file.exists()) {
            file.deleteSync(recursive: true);
          }
        }
        try {
          await file.writeAsBytes(data);
          r = true;
        } catch (e) {
          ZsLog.d('写文件失败: $e');
        }

        if (callback != null) {
          callback(r ? Constants.kPopMesgSaveSuccess : Constants.kPopMesgSaveFailed, targPath, r);
        }
      }
    } catch (e) {
      if (callback != null) {
        callback('保存到下载目录失败：${e.toString()}', null, r);
      }
    }
    return r;
  }

  static Future<bool> savePathToDownloadDir(
    File srcFilePath, {
    String? outFileName,
    String? sugExtension,
    bool cover = false,
    ResultCallback? callback,
  }) async {
    bool r = false;
    try {
      String? ex = sugExtension != null && sugExtension.isNotEmpty ? sugExtension : await Utils.getMimeType(srcFilePath);
      String name = Utils.dateTimeFileName(outFileName, ex: ex);
      String targPath = await Utils.getDownloadPathForSystem(name);
      if (targPath == '') {
        if (callback != null) {
          callback('下载目录不存在，保存失败', targPath, r);
        }
      } else if (srcFilePath.existsSync()) {
        if (cover == false) {
          targPath = Utils.autoPathNoExist(targPath);
        }
        try {
          final file = File(targPath);
          if (cover) {
            if (await file.exists()) {
              file.deleteSync(recursive: true);
            }
          }
        } catch (e) {
          ZsLog.d('删除文件失败: $e');
        }
        try {
          await srcFilePath.copy(targPath);
          r = true;
          srcFilePath.deleteSync(recursive: true);
        } catch (e) {
          ZsLog.d('文件复制失败: $e');
        }
        if (callback != null) {
          callback(r ? Constants.kPopMesgSaveSuccess : Constants.kPopMesgSaveFailed, targPath, r);
        }
      } else {
        if (callback != null) {
          callback('下载的文件不存在', null, r);
        }
      }
    } catch (e) {
      if (callback != null) {
        callback('保存到下载目录失败：${e.toString()}', null, r);
      }
    }
    return r;
  }
}
