import 'dart:typed_data';
import 'package:chiphell/utils/file_operations.dart';
import '../common/type_utils.dart';

class PdfSaveHelper {
  //ios /Users/cjxy/Library/Developer/CoreSimulator/Devices/EFE0FB2C-B8F8-4412-8639-175A0148187D/data/Containers/Data/Application/6AE9FDE9-1A90-4E12-BAEB-CA5C657D8FBC/Documents/chiphell/甘孜的微笑 - 原创分享(新) - Chiphell - 分享与交流用户体验.pdf
  static Future<bool> savePdfDataToSystem(
    Uint8List data, {
    String? outFileName,
    String? mimeType = 'application/pdf',
    String? extension = 'pdf',
    bool cover = false,
    ResultCallback? callback,
  }) async {
    return await FileOperations.saveDataToDownloadDir(
      data,
      outFileName: outFileName,
      mimeType: mimeType,
      extension: extension,
      cover: cover,
      callback: callback,
    );
    //   bool r = false;
    //   try {
    //     String name = outFileName ?? Utils.dateTimeFileName();
    //     String targPath = await Utils.getDownloadPathForSystem(name);

    //     if (targPath == '') {
    //       if (callback != null) {
    //         callback('下载目录不存在，保存失败', targPath, r);
    //       }
    //     } else {
    //       if (extension != null && extension.isNotEmpty) {
    //         targPath = Utils.pathSetExtension(targPath, extension);
    //       } else if (mimeType != null) {
    //         String? ex = Utils.fileExtensionFromMimeType(mimeType);
    //         if (ex != null) {
    //           targPath = Utils.pathSetExtension(targPath, ex);
    //         }
    //       }
    //       final file = File(targPath);
    //       if (await file.exists()) {
    //         file.deleteSync(recursive: true);
    //       }
    //       await file.writeAsBytes(data);
    //       r = true;
    //       if (callback != null) {
    //         callback(Constants.kPopMesgSaveSuccess, targPath, r);
    //       }
    //     }
    //   } catch (e) {
    //     if (callback != null) {
    //       callback('保存到下载目录失败：${e.toString()}', null, r);
    //     }
    //   }
    //   return r;
  }
}
