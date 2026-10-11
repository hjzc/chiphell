import 'dart:io';
import 'dart:typed_data';
//import 'dart:ui' as ui;
// import 'dart:typed_data';
// import 'dart:ui';
// import 'package:chiphell/utils/ui_utils.dart';
import 'package:chiphell/common/constants.dart';
import 'package:chiphell/utils/util_map.dart';
import 'package:chiphell/utils/utils.dart';
import 'package:chiphell/utils/zs_log.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:happy/common/index.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
// import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
// import 'package:get/get.dart';

import '../common/type_utils.dart';

/// ImageSaverHelper 工具类使用说明
///
/// 这个工具类封装了图片保存到相册的功能，包含完整的权限处理
/// 支持保存网络图片和本地图片到设备相册
///
/// ## 功能特性
///
/// ### 权限自动适配
/// - **iOS**: 自动处理照片权限 (NSPhotoLibraryUsageDescription)
/// - **Android**: 根据系统版本自动适配不同的存储权限
///   - Android 11 (API 30) 及以上: 使用 manageExternalStorage
///   - Android 10 (API 29): 使用 photos 权限
///   - Android 9 及以下: 使用 storage 权限
///
/// ### 错误处理
/// - 权限被拒绝时自动引导用户去设置页面
/// - 网络图片下载失败自动提示
/// - 本地文件不存在自动检测
///
/// ### UI交互
/// - 可选择是否显示加载弹窗
/// - 可选择是否显示成功/失败提示
/// - 支持自定义文件名和图片质量
///
/// ## 基础用法
///
/// ```dart
/// // 1. 最简单的用法 - 保存网络图片
/// await ImageSaverHelper.saveNetworkImage('https://example.com/image.jpg');
///
/// // 2. 自定义参数
/// await ImageSaverHelper.saveNetworkImage(
///   'https://example.com/image.jpg',
///   fileName: 'my_image',
///   quality: 85,
///   showLoading: true,
///   showResult: true,
/// );

/// // 3. 保存本地图片
/// await ImageSaverHelper.saveLocalImage('/path/to/local/image.jpg');

/// // 4. 保存二维码图片
///  ImageSaverHelper.saveUint8ListImage(byteData.buffer.asUint8List());

///
/// // 4. 检查权限状态
/// bool hasPermission = await ImageSaverHelper.hasPermission();
/// ```
///
/// ## 高级用法
///
/// ### 静默保存（不显示UI）
/// ```dart
/// bool success = await ImageSaverHelper.saveNetworkImage(
///   imageUrl,
///   showLoading: false,
///   showResult: false,
/// );
/// // 根据返回值进行自定义处理
/// ```
///
/// ### 批量保存
/// ```dart
/// for (String url in imageUrls) {
///   await ImageSaverHelper.saveNetworkImage(
///     url,
///     showLoading: false, // 避免多个加载弹窗
///     showResult: false,  // 最后统一显示结果
///   );
/// }
/// ```
///
/// ## 参数说明
///
/// ### saveNetworkImage 方法
/// - `imageUrl` (String): 必需，网络图片链接
/// - `fileName` (String?): 可选，自定义文件名，默认使用时间戳
/// - `quality` (int): 可选，图片质量 0-100，默认100
/// - `showLoading` (bool): 可选，是否显示加载弹窗，默认true
/// - `showResult` (bool): 可选，是否显示结果提示，默认true
/// - 返回值: `Future<bool>` 是否保存成功
///
/// ### saveLocalImage 方法
/// - `imagePath` (String): 必需，本地图片路径
/// - 其他参数与 saveNetworkImage 相同
///
/// ### hasPermission 方法
/// - 返回值: `Future<bool>` 是否已有权限（不会主动请求权限）
///
/// ## 权限配置
///
/// ### iOS 配置
/// 确保 `ios/Runner/Info.plist` 中包含：
/// ```xml
/// <key>NSPhotoLibraryUsageDescription</key>
/// <string>需要访问相册选择图片进行身份认证</string>
/// ```
///
/// ### Android 配置
/// 确保 `android/app/src/main/AndroidManifest.xml` 中包含：
/// ```xml
/// <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
/// <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
/// <!-- Android 11+ -->
/// <uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" />
/// ```
///
/// ## 依赖包
///
/// 确保 `pubspec.yaml` 中包含以下依赖：
/// ```yaml
/// dependencies:
///   permission_handler: ^11.0.0
///   image_gallery_saver_plus: ^3.0.0
///   device_info_plus: ^9.0.0
///   dio: ^5.0.0
/// ```
///
/// ## 错误处理
///
/// 工具类会自动处理以下错误情况：
/// 1. 权限被拒绝 - 自动显示错误提示并引导用户设置
/// 2. 网络错误 - 自动提示下载失败
/// 3. 本地文件不存在 - 自动检测并提示
/// 4. 保存失败 - 显示具体错误信息
///
/// ## 注意事项
///
/// 1. **权限申请**: 第一次调用时会自动申请权限，用户拒绝后会引导去设置页面
/// 2. **网络超时**: 网络图片下载超时时间为30秒
/// 3. **文件名**: 如果不指定文件名，会使用 "image_时间戳" 格式
/// 4. **图片质量**: quality参数影响文件大小，100为最高质量
/// 5. **并发下载**: 批量保存时建议控制并发数量，避免内存压力
///
/// ## 示例场景
///
/// ### 1. 用户分享页面保存二维码
/// ```dart
/// void onSaveQrCode() async {
///   await ImageSaverHelper.saveNetworkImage(qrCodeUrl);
/// }
/// ```
///
/// ### 2. 图片浏览器保存图片
/// ```dart
/// void onLongPress(String imageUrl) async {
///   bool success = await ImageSaverHelper.saveNetworkImage(
///     imageUrl,
///     fileName: 'gallery_image_${DateTime.now().millisecondsSinceEpoch}',
///   );
/// }
/// ```
///
/// ### 3. 批量下载保存
/// ```dart
/// void downloadAllImages(List<String> urls) async {
///   Loading.show('正在下载图片...');
///   int count = 0;
///   for (String url in urls) {
///     bool success = await ImageSaverHelper.saveNetworkImage(
///       url,
///       showLoading: false,
///       showResult: false,
///     );
///     if (success) count++;
///   }
///   Loading.dismiss();
///   Loading.success('成功保存 $count/${urls.length} 张图片');
/// }
/// ```
// class ImageSaverHelperReadme {
//   // 这个类仅用于文档说明，无需实例化
// }
/// 图片保存工具类
/// 支持保存网络图片到本地相册
/// 自动处理iOS和Android的权限适配
class ImageSaverHelper {
  // static final Dio _dio = Dio();

  // /// 保存网络图片到相册
  // /// [imageUrl] 图片链接
  // /// [fileName] 文件名（可选，默认使用时间戳）
  // /// [quality] 图片质量（0-100，默认100）
  // /// [showLoading] 是否显示加载弹窗（默认true）
  // /// [showResult] 是否显示结果提示（默认true）
  // /// Returns: 是否保存成功
  // static Future<bool> saveNetworkImage(
  //   String imageUrl, {
  //   String? fileName,
  //   int quality = 100,
  //   bool showLoading = true,
  //   bool showResult = true,
  // }) async {
  //   if (imageUrl.isEmpty) {
  //     if (showResult) Loading.error('图片地址不能为空'.tr);
  //     return false;
  //   }

  //   if (showLoading) Loading.show();

  //   try {
  //     // 1. 检查权限
  //     if (!await _checkAndRequestPermission()) {
  //       return false;
  //     }

  //     // 2. 下载图片
  //     final imageData = await _downloadImage(imageUrl);
  //     if (imageData == null) {
  //       if (showResult) Loading.error('下载图片失败'.tr);
  //       return false;
  //     }

  //     // 3. 生成文件名
  //     final name = fileName ?? "image_${DateTime.now().millisecondsSinceEpoch}";

  //     // 4. 保存到相册
  //     final result = await ImageGallerySaverPlus.saveImage(
  //       imageData,
  //       quality: quality,
  //       name: name,
  //     );
  //     if (result != null && result['isSuccess']) {
  //       if (showResult) Loading.success('保存成功'.tr);
  //       return true;
  //     } else {
  //       if (showResult) Loading.error('保存失败，请确保已授予存储权限'.tr);
  //       return false;
  //     }
  //   } catch (e) {
  //     if (showResult) Loading.error('保存失败：${e.toString()}'.tr);
  //     return false;
  //   } finally {
  //     if (showLoading) Loading.dismiss();
  //   }
  // }
  // static Future<ui.Image> bytesToImage(Uint8List imgBytes) async {
  //   ui.Codec codec = await ui.instantiateImageCodec(imgBytes);
  //   ui.FrameInfo frame = await codec.getNextFrame();
  //   return frame.image;
  // }
  static Future<bool> saveImageDataToSystem(
    Uint8List imgData, {
    String? outFileName,
    String? mimeType = 'image/jpeg',
    String? extension = 'jpeg',
    int quality = 100,
    bool cover = false,
    ResultCallback? callback,
  }) async {
    bool r = false;

    try {
      if (Utils.isDesktopSystem) {
        String? ex = extension ?? Utils.fileExtensionFromMimeType(mimeType);
        ex ??= Utils.fileExtensionFromMimeType(Utils.getMimeTypeFromFileHeader(imgData));

        String name = Utils.dateTimeFileName(outFileName);
        String targPath = await Utils.getAppPicturePathForDesktopSystem(name);
        if (targPath == '') {
          if (callback != null) {
            callback('图片目录不存在，保存失败', targPath, r);
          }
        } else {
          if (extension != null && extension.isNotEmpty) {
            targPath = Utils.pathSetExtension(targPath, extension);
          } else if (ex != null) {
            targPath = Utils.pathSetExtension(targPath, ex);
          }
          if (cover == false) {
            targPath = Utils.autoPathNoExist(targPath);
          }

          final file = File(targPath);
          if (cover) {
            if (await file.exists()) {
              file.deleteSync(recursive: true);
            }
          }

          await file.writeAsBytes(imgData);
          r = true;
          if (callback != null) {
            callback(Constants.kPopMesgSaveSuccess, targPath, r);
          }
        }
      } else {
        String name = outFileName ?? "image_${DateTime.now().millisecondsSinceEpoch}";

        if (extension != null && extension.isNotEmpty) {
          name = Utils.pathSetExtension(name, extension);
        } else if (mimeType != null) {
          String? ex = Utils.fileExtensionFromMimeType(mimeType);
          if (ex != null) {
            name = Utils.pathSetExtension(name, ex);
          }
        }

        bool granted = await hasPermission();
        if (!granted) {
          granted = await _checkAndRequestStoragePermission();
        }
        if (granted == false) {
          ZsLog.e('没有授权写存储权限！');
        }

        final result = await ImageGallerySaverPlus.saveImage(imgData, quality: quality, name: name);
        if (result != null && UtilMap.safeBoolForKey(result, 'isSuccess')) {
          r = true;
          if (callback != null) {
            callback(Constants.kPopMesgSaveSuccess, UtilMap.safeValueForStringKey(result, 'filePath'), r);
          }
        } else {
          if (callback != null) {
            callback('保存失败，请确保已授予存储权限', null, r);
          }
        }
      }
    } catch (e) {
      if (callback != null) {
        callback('保存失败：${e.toString()}', null, r);
      }
    }
    return r;
  }

  // 1. 检查权限
  // if (!await _checkAndRequestPermission()) {
  //   callback('请在设置中开启照片访问权限', false);
  //   return false;
  // }
  /// 保存本地图片文件到相册
  /// [imagePath] 本地图片路径
  /// [fileName] 文件名（可选，默认使用时间戳）
  /// [quality] 图片质量（0-100，默认100）
  /// [showLoading] 是否显示加载弹窗（默认true）
  /// [showResult] 是否显示结果提示（默认true）
  /// Returns: 是否保存成功
  static Future<bool> saveLocalImage(
    String imagePath,
    String? filename, {
    String? sugExtension,
    int quality = 100,
    bool cover = false,
    ResultCallback? callback,
  }) async {
    bool r = false;
    try {
      //标准化filename
      String? bzFileName = Utils.sanitizeFilename(filename);
      if (bzFileName != null) {
        bzFileName = Utils.pathSetExtension(bzFileName, sugExtension);
      }
      final file = File(imagePath);
      if (!await file.exists()) {
        if (callback != null) {
          callback('图片文件不存在', null, r);
        }
      } else if (Utils.isDesktopSystem) {
        String name = Utils.getFitImageNameFrom(bzFileName, imagePath, sugExtension: sugExtension);
        String targPath = await Utils.getAppPicturePathForDesktopSystem(name);
        if (targPath == '') {
          if (callback != null) {
            callback('图片目录不存在，保存失败', targPath, r);
          }
        } else {
          if (cover == false) {
            targPath = Utils.autoPathNoExist(targPath);
          } else {
            final file = File(targPath);
            if (await file.exists()) {
              file.deleteSync(recursive: true);
            }
          }
          File? newfile = await Utils.copyFile(imagePath, targPath);
          if (newfile != null) {
            r = true;
            if (callback != null) {
              callback(Constants.kPopMesgSaveSuccess, targPath, r);
            }
          } else {
            if (callback != null) {
              callback(Constants.kPopMesgSaveFailed, targPath, r);
            }
          }
        }
      } else {
        String name = "";
        if (bzFileName == null || bzFileName.isEmpty) {
          name = "image_${DateTime.now().millisecondsSinceEpoch}.${sugExtension != null && sugExtension.isNotEmpty ? sugExtension : 'jpg'}";
        } else {
          name = Utils.pathSetExtension(bzFileName, sugExtension);
        }

        bool granted = await hasPermission();
        if (!granted) {
          granted = await _checkAndRequestStoragePermission();
        }
        if (granted == false) {
          ZsLog.e('没有授权写相册！');
        }
        String? targetPath;
        bool isReturnPath = true; // Utils.isIOS() ? false : true;

        ///TODO：ios 保存失败 ，gif保存后成了jpg
        var result = await ImageGallerySaverPlus.saveFile(file.path, isReturnPathOfIOS: isReturnPath, name: name);
        if (result != null && UtilMap.safeBoolForKey(result, 'isSuccess') == true) {
          r = true;
          targetPath = UtilMap.safeValueForStringKey(result, 'filePath');
        } else {
          //"errorMessage" -> "Failed to save, please check whether the permission is enabled"
          final imageData = await file.readAsBytes();
          if (imageData.isNotEmpty) {
            result = await ImageGallerySaverPlus.saveImage(imageData, quality: quality, name: name, isReturnImagePathOfIOS: isReturnPath);
            if (result != null && UtilMap.safeBoolForKey(result, 'isSuccess') == true) {
              r = true;
              targetPath = UtilMap.safeValueForStringKey(result, 'filePath');
            }
          }
        }
        //map {"filePath":null,'"errorMessage":"saveImageToGallery fail", "isSuccess" : false}
        if (r) {
          if (callback != null) {
            callback(Constants.kPopMesgSaveSuccess, targetPath, r);
          }
        } else {
          if (callback != null) {
            callback('保存失败，请确保已授予存储权限', null, r);
          }
        }
      }
    } catch (e) {
      if (callback != null) {
        callback('保存失败：${e.toString()}', null, r);
      }
    }
    return r;
  }

  //Permission.manageExternalStorage

  // /// 保存内存图片到相册（Uint8List）
  // static Future<bool> saveUint8ListImage(
  //   Uint8List imageData, {
  //   String? fileName,
  //   int quality = 100,
  // }) async {
  //   if (imageData.isEmpty) {
  //     if (showResult) Loading.error('图片数据为空'.tr);
  //     return false;
  //   }

  //   if (showLoading) Loading.show();

  //   try {
  //     // 1. 检查权限
  //     if (!await _checkAndRequestPermission()) {
  //       return false;
  //     }

  //     // 2. 生成文件名
  //     final name = fileName ?? "image_${DateTime.now().millisecondsSinceEpoch}";

  //     // 3. 保存到相册
  //     final result = await ImageGallerySaverPlus.saveImage(
  //       imageData,
  //       quality: quality,
  //       name: name,
  //     );

  //     if (result != null && result['isSuccess']) {
  //       if (showResult) Loading.success('保存成功'.tr);
  //       return true;
  //     } else {
  //       if (showResult) Loading.error('保存失败，请确保已授予存储权限'.tr);
  //       return false;
  //     }
  //   } catch (e) {
  //     if (showResult) Loading.error('保存失败：${e.toString()}'.tr);
  //     return false;
  //   } finally {
  //     if (showLoading) Loading.dismiss();
  //   }
  // }

  // /// 下载网络图片
  // /// [imageUrl] 图片链接
  // /// Returns: 图片字节数据
  // static Future<Uint8List?> _downloadImage(String imageUrl) async {
  //   try {
  //     final response = await _dio.get(
  //       imageUrl,
  //       options: Options(
  //         responseType: ResponseType.bytes,
  //         // 设置超时时间
  //         sendTimeout: const Duration(seconds: 30),
  //         receiveTimeout: const Duration(seconds: 30),
  //       ),
  //     );

  //     if (response.statusCode == 200) {
  //       return Uint8List.fromList(response.data);
  //     }
  //     return null;
  //   } catch (e) {
  //     print('下载图片失败: $e');
  //     return null;
  //   }
  // }

  /// 检查并请求权限
  /// Returns: 是否获得权限
  static Future<bool> _checkAndRequestStoragePermission() async {
    try {
      if (Platform.isIOS) {
        // iOS权限处理
        var status = await Permission.photos.status;
        if (status.isDenied) {
          status = await Permission.photos.request();
        }
        if (status.isPermanentlyDenied) {
          ZsLog.d('请在设置中开启照片访问权限');
          // 可以引导用户去设置页面
          await openAppSettings();
          return false;
        }
        return status.isGranted;
      } else if (Platform.isAndroid) {
        // Android权限处理
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt;
        PermissionStatus status;
        if (sdkInt >= 30) {
          // Android 11 (API 30) 及以上，使用 manageExternalStorage
          status = await Permission.manageExternalStorage.status;
          if (status.isDenied) {
            status = await Permission.manageExternalStorage.request();
          }
        } else {
          // Android 10 (API 29) 及以下，使用存储权限
          status = await Permission.storage.status;
          if (status.isDenied) {
            status = await Permission.storage.request();
          }
        }
        if (status.isPermanentlyDenied) {
          ZsLog.d('请在设置中开启存储权限');
          await openAppSettings();
          return false;
        }
        if (!status.isGranted) {
          ZsLog.d('需要存储权限才能保存图片');
          return false;
        }
        return true;
      }
      return true;
    } catch (e) {
      ZsLog.d('权限检查失败：${e.toString()}');
      return false;
    }
  }

  /// 检查是否有权限（不请求）
  /// Returns: 是否有权限
  static Future<bool> hasPermission() async {
    try {
      if (Platform.isIOS) {
        var status = await Permission.photos.status;
        return status.isGranted;
      } else if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt;
        ZsLog.i('android device Info $androidInfo ; sdk int version:$sdkInt');
        PermissionStatus status;
        if (sdkInt >= 30) {
          status = await Permission.manageExternalStorage.status;
        } else {
          status = await Permission.storage.status;
        }
        return status.isGranted;
      }
      return true;
    } catch (e) {
      ZsLog.e('hasPermission error:$e');
      return false;
    }
  }
}
