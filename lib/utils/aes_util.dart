import 'dart:io';
import 'package:chiphell/pkg/aes_crypt_null_safe.dart';
import 'package:chiphell/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'zs_log.dart';

class AesUtil {
  static String aesPassword = 'chiphell_aes_zzc';
  //static String assetsWbSdkFile = 'assets/js/wbsdk.js';
  static String assetsWbSdkFile = 'assets/js/wbsdk_release.js';
  static String assetsWbSdkAesFile = 'assets/js/wbsdk';

  static Future<void> initAes() async {
    if (kDebugMode && Utils.isMacOS()) {
      //修改assets/js/wbsdk.js 或者wbsdk_release.js 文件
      //在pubspec.yaml文件打开 - assets/js/wbsdk.js
      //执行下面方法
      //encodeWBSDKJS();
      //替换assets/js/wbsdk 文件
    }
  }

  static Future<void> encodeWBSDKJS() async {
    var crypt = AesCrypt(AesUtil.aesPassword);
    crypt.setOverwriteMode(AesCryptOwMode.on);
    Directory? directory = await getDownloadsDirectory();
    if (directory != null) {
      String path = directory.absolute.path;
      String aespath = p.join(path, 'wbsdk');
      // '$path/wbsdk';

      String sdkString = await Utils.loadAsset(assetsWbSdkFile);
      String encFilepath = crypt.encryptTextToFileSync(sdkString, aespath, utf16: true);
      ZsLog.d('Encrypted file:$aespath  to: $encFilepath');
      // String decText = crypt.decryptTextFromFileSync(encFilepath, utf16: true);
      // ZsLog.d('Decrypted file $encFilepath string: $decText');
      //crypt.encryptFileSync('wbsdk.js', path);
    }
  }

  static Future<String> decodeWBSDKJS() async {
    String rc = '';
    var crypt = AesCrypt(AesUtil.aesPassword);
    crypt.setOverwriteMode(AesCryptOwMode.on);
    Uint8List srcData = await Utils.loadAssetFileData(assetsWbSdkAesFile);
    try {
      rc = crypt.decryptTextFromEncriptyFileDataSync(srcData, utf16: true);
    } on AesCryptDataException catch (e) {
      // It goes here in the case of wrong password or corrupted file.
      ZsLog.d('Decrypt data 0 Error: $e');
      rc = '';
    } on AesCryptFsException catch (e) {
      ZsLog.d('Decrypt file 0 Error: $e');
      rc = '';
    }

    //ZsLog.d('Decrypted file string: $rc');
    return rc;
  }

  // static Future<String> decodeWBSDKJS1() async {
  //   int preVersion = 0;
  //   int version = 1;

  //   String rc = '';
  //   var crypt = AesCrypt(AesUtil.aesPassword);
  //   crypt.setOverwriteMode(AesCryptOwMode.on);

  //   Directory directory = await getTemporaryDirectory();
  //   String path = directory.absolute.path;

  //   String preDestPath = '$path/wbsdk_v$preVersion';
  //   if (Utils.fileExist(preDestPath)) {
  //     Utils.deleteFile(preDestPath);
  //   }
  //   String destPath = '$path/wbsdk_v$version';
  //   bool ixs = Utils.fileExist(destPath);
  //   if (!ixs) {
  //     await Utils.copyAssetsFileToPath('assets/js/wbsdk', destPath);
  //   }
  //   try {
  //     rc = crypt.decryptTextFromFileSync(destPath, utf16: true);
  //   } on AesCryptDataException catch (e) {
  //     // It goes here in the case of wrong password or corrupted file.
  //     ZsLog.d('Decrypt data 0 Error: $e');
  //     rc = '';
  //   } on AesCryptFsException catch (e) {
  //     ZsLog.d('Decrypt file 0 Error: $e');
  //     rc = '';
  //   }

  //   if ((rc == '') && ixs) {
  //     Utils.deleteFile(destPath);
  //     await Utils.copyAssetsFileToPath('assets/js/wbsdk', destPath);
  //     try {
  //       rc = crypt.decryptTextFromFileSync(destPath, utf16: true);
  //     } on AesCryptDataException catch (e) {
  //       // It goes here in the case of wrong password or corrupted file.
  //       ZsLog.d('Decrypt data Error: $e');
  //     } on AesCryptFsException catch (e) {
  //       ZsLog.d('Decrypt file Error: $e');
  //     }
  //   }
  //   return rc;
  // }
}
