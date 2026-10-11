import 'dart:io';

import 'package:chiphell/utils/file_operations.dart';
import 'package:chiphell/utils/file_picker_helper.dart';
import 'package:chiphell/utils/util_image.dart';
import 'package:chiphell/utils/utils.dart';
import 'package:chiphell/utils/zs_log.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_folder/open_folder.dart';
import '../common/type_utils.dart';

class FileSaveHelper {
  //ios /Users/cjxy/Library/Developer/CoreSimulator/Devices/EFE0FB2C-B8F8-4412-8639-175A0148187D/data/Containers/Data/Application/6AE9FDE9-1A90-4E12-BAEB-CA5C657D8FBC/Documents/chiphell/甘孜的微笑 - 原创分享(新) - Chiphell - 分享与交流用户体验.pdf
  static Future<bool> saveFileDataToSystem(
    File srcFilePath, {
    String? outFileName,
    String? sugExtension,
    bool cover = false,
    ResultCallback? callback,
  }) async {
    return await FileOperations.savePathToDownloadDir(
      srcFilePath,
      outFileName: outFileName,
      sugExtension: sugExtension,
      cover: cover,
      callback: callback,
    );
  }

  ///TODO： android 如果打开过，在打开，可能不跳转到指定路径
  static Future<bool> openFolder(String folder) async {
    bool r = false;
    final result = await OpenFolder.openFolder(folder);
    if (result.isSuccess) {
      ZsLog.i('openFolder successfully');
      r = true;
    } else {
      ZsLog.i('openFolder Error: ${result.message}');
    }
    return r;
  }

  ///打开（windows/macos/linux） 用户下载的图片 目录
  static Future<bool> openImageFolder() async {
    String folder = await Utils.getAppPicturePathForDesktopSystem('');
    return await openFolder(folder);
  }

  ///打开 用户 缩略图 路径
  ///android push一个页面，选择应用打开
  ///ios 弹出文件app，显示应用document目录页面
  static Future<bool> openUserThumbsFolder() async {
    String folder = await Utils.getUserCompressImagesFolder();
    return await openFolder(folder);
  }

  ///mobile 可能从相册导入
  static Future<List<int>> importCompressImages(
    void Function(int status, int total, int index, int pressResult, bool finish) callBack,
  ) async {
    int copyNum = 0;
    int pressNum = 0;
    int t = 0;
    List<String?> list = await FilePickerHelper.selectedFileImport(
      type: FileType.image,
      allowMultiple: true,
      //allowedExtensions: ['png', 'gif', 'jpeg', 'jpg'],
    );
    //1
    if (list.isNotEmpty) {
      t = list.length;
      var folder = await Utils.getUserCompressImagesFolder();
      for (var i = 0; i < t; i++) {
        int rc = -1;
        callBack(1, t, i, rc, false);
        String? path = list[i];
        if (path != null) {
          rc = await UtilImage.compressImageFile(path, folder);
          if (rc == 1) {
            //copy
            copyNum++;
          } else if (rc == 2) {
            //压缩图片
            pressNum++;
          }
        }
        callBack(1, t, i, rc, i + 1 >= t);
      }
    } else {
      callBack(2, t, t, 0, true);
    }
    return [copyNum, pressNum];
  }
}


//  void _setDefaultPath() {
//     if (Platform.isWindows) {
//       _controller.text = 'C:\\Users';
//     } else if (Platform.isMacOS) {
//       _controller.text = '/Users';
//     } else if (Platform.isLinux) {
//       _controller.text = '/home';
//     } else if (Platform.isAndroid) {
//       _controller.text = '/storage/emulated/0/Download';
//     } else if (Platform.isIOS) {
//       _controller.text = '/var/mobile/Documents';
//     }
//   }