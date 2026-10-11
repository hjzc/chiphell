import 'dart:io';
import 'dart:typed_data';
import 'package:chiphell/utils/utils.dart';
import 'package:chiphell/utils/zs_log.dart';
import 'package:image/image.dart' as img;

class UtilImage {
  /// 使用
  // File original = File('photo.jpg');
  // Uint8List compressed = await compressImage(original, quality: 60);
  // await File('photo_compressed.jpg').writeAsBytes(compressed);
  // print('原始大小: ${await original.length()} bytes');
  // print('压缩后: ${compressed.length} bytes');
  static Future<Uint8List> compressImage(File file, {int quality = 70}) async {
    final bytes = await file.readAsBytes();
    // 解码
    img.Image? image = img.decodeImage(bytes);
    if (image == null) throw Exception('无法解码图片');
    // 压缩（quality: 0-100，越小文件越小）
    final compressed = img.encodeJpg(image, quality: quality);
    return Uint8List.fromList(compressed);
  }

  static Future<int> compressImageFile(String filePath, String targFolder, {int maxSize = 1024 * 1024}) async {
    int r = 0;
    var filename = Utils.lastFileName(filePath);
    var tPath = Utils.pathAppand(targFolder, filename);
    var targPath = Utils.autoPathNoExist(tPath);
    try {
      File original = File(filePath);
      int olen = await original.length();
      if (olen < maxSize) {
        await original.copy(targPath);
        r = 1;
      } else {
        File targ = File(targPath);
        int qt = (maxSize * 100.0 / olen).toInt();
        Uint8List compressed = await compressImage(original, quality: qt);
        await targ.writeAsBytes(compressed);
        ZsLog.d('压缩quality=$qt, 原始大小: $olen} bytes,压缩后: ${compressed.length} bytes');
        r = 2;
      }
    } catch (e) {
      ZsLog.d('压缩图片失败: $filePath');
    }
    return r;
  }
}
