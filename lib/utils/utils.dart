import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:chiphell/common/constants.dart';
import 'package:chiphell/utils/zs_log.dart';
import 'package:chiphell/web/web_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
//import 'package:path_provider_master/path_provider_master.dart';
//import 'package:permission_handler/permission_handler.dart';
//import 'package:gallery_saver/gallery_saver.dart'; // 用于保存到相册的插件
import 'package:mime/mime.dart';

class Utils {
  static int _ios26Late = -1;
  static bool isIOSPad = false;
  static bool isAndroidPad = false;
  static int _androidSdkInt = -1;
  static const _imageTypeExtensions = ['jpeg', 'png', 'jpg', 'gif', 'bmp', 'tiff', 'tif', 'svg', 'webp'];
  static const _htmlTypeList = [
    '.html',
    '.htm',
    '.asp',
    '.php',
    '.xml',
    '.js',
    '.csv',
    '.css',
    '.txt',
    '.md',
    '.json',
    '.bat',
    '.py',
    '.java',
    '.doc',
    '.cfg',
    '.ini',
  ];
  static const allowBrowserSchemes = ["http", "https", "file", "chrome", "data", "javascript", "about"];
  static String get httpHeaderContentType => "Content-Type";
  static String get httpHeaderUserAgent => 'User-Agent';
  static String get httpHeaderCookie => 'Cookie';
  static String get httpHeaderReferer => 'Referer';
  static String get httpHeaderHost => 'Host';
  static String get httpHeaderAccept => 'Accept';
  static String get httpHeaderOrigin => 'Origin';
  static String get httpResHeaderContentDisposition => 'Content-Disposition';

  static Future<bool> initDevice() async {
    //sanitizeAttachmentFilename('attachment; filename="IMG_E1006.JPG"');
    if (Platform.isIOS) {
      //Version 18.6 (Build 22G86). Version 26.0.1 (Build 23A8464)
      if (Utils._ios26Late == -1) {
        var version = Platform.operatingSystemVersion;
        String? sver = stringRegex(version, r"Version\s*(\d+)[.]\d+");
        if (sver != null && (int.parse(sver) >= 26)) {
          Utils._ios26Late = 1;
        }
      }
    }

    if (Platform.isAndroid) {
      final view = WidgetsBinding.instance.platformDispatcher.views.first;
      var isIpad = (view.physicalSize / view.devicePixelRatio).shortestSide > 600;
      isAndroidPad = isIpad;
      isIOSPad = false;

      final androidInfo = await DeviceInfoPlugin().androidInfo;
      _androidSdkInt = androidInfo.version.sdkInt; //28,android 9,  31 android 12

      return isIpad;
    } else if (Platform.isIOS) {
      final DeviceInfoPlugin deviceinfo = DeviceInfoPlugin();
      final iosinfo = await deviceinfo.iosInfo;
      //systemname iPadOS
      isIOSPad = iosinfo.model.toLowerCase().contains("ipad");
      isAndroidPad = false;
      return isIOSPad;
    } else if (Platform.isMacOS || Platform.isFuchsia || Platform.isWindows || Platform.isLinux) {
      isIOSPad = false;
      isAndroidPad = false;
      return false;
    } else {
      isIOSPad = false;
      isAndroidPad = false;
      return false;
    }
  }

  static bool isPad() {
    return isIOSPad || isAndroidPad;
  }

  static bool isTablet(BuildContext context) {
    // 获取屏幕的宽度
    double width = MediaQuery.of(context).size.width;
    // 根据你的设计标准，设定一个宽度阈值来判断平板
    // 这个阈值可以根据你的应用需求来调整
    const tabletWidthThreshold = 600.0; // 例如，600.0像素及以上认为是平板
    return width >= tabletWidthThreshold;
  }

  static bool get isDesktopSystem => Platform.isMacOS || Platform.isWindows || Platform.isLinux;

  static bool get multipleWindows => (Utils.isDesktopSystem || Utils.isIPad());

  static bool isMobile() {
    return isAndroid() || isIOS();
  }

  static bool isAndroid() {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  }

  // android sdk 版本 28 = android 9
  static bool isAndroidUnder(int sdkInt) {
    return isAndroid() && (_androidSdkInt < sdkInt);
  }

  static bool isAndroidAbove(int sdkInt) {
    return isAndroid() && (_androidSdkInt >= sdkInt);
  }

  // android 10以下，包括10
  static bool isAndroi10Under() {
    return isAndroidUnder(30);
  }

  // android 10以上，不包括10
  static bool isAndroi10Above() {
    return isAndroidAbove(30);
  }

  static bool isIOS() {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  }

  static bool isMacOS() {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;
  }

  static bool isApple() {
    return !kIsWeb && (defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.iOS);
  }

  static bool isLinux() {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;
  }

  static bool isIPad() {
    return Utils.isIOSPad;
  }

  static bool isiPhone() {
    return isIOS() && (false == isIPad());
  }

  static bool isWindows() {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
  }

  static bool isIOS26Late() {
    return _ios26Late == 1;
  }

  static Future<bool> isMacos27() async {
    final DeviceInfoPlugin deviceinfo = DeviceInfoPlugin();
    final info = await deviceinfo.macOsInfo;
    return info.majorVersion >= 27;
  }

  static bool urlIsSecure(Uri url) {
    return (url.scheme == "https") || Utils.isLocalizedContent(url);
  }

  static int sizeKB(int n) {
    return n * 1024;
  }

  static int sizeMB(int n) {
    return 1024 * sizeKB(n);
  }

  static int sizeGB(int n) {
    return 1024 * sizeMB(n);
  }

  static int sizeTB(int n) {
    return 1024 * sizeGB(n);
  }

  static bool isLocalizedContent(Uri url) {
    return (url.scheme == "file" || url.scheme == "chrome" || url.scheme == "data" || url.scheme == "javascript" || url.scheme == "about");
  }

  static bool stringIsEmpty(String? str) {
    return (str == null || str.isEmpty);
  }

  static bool stringIsNotEmpty(String? str) {
    return stringIsEmpty(str) != true;
  }

  static bool isHttpScheme(String? scheme) {
    return scheme != null && (scheme.toLowerCase() == 'http' || scheme.toLowerCase() == 'https');
  }

  static bool isHttpsScheme(String? scheme) {
    return scheme != null && (scheme.toLowerCase() == 'https');
  }

  //j.mp
  static bool isValidHttpUrl(String? url) {
    return url != null && (url.length >= 11) && (url.toLowerCase().startsWith('http://', 0) || url.toLowerCase().startsWith('https://', 0));
  }

  static bool validHttpUrl(String? url) {
    return isValidHttpUrl(url?.toLowerCase());
  }

  static bool isAboutUrl(String? url) {
    return url != null && (url.length >= 6) && (url.toLowerCase().startsWith('about', 0));
  }

  static bool isEqualUrl(String? url1, String? url2) {
    bool r = false;
    if (url1 == url2 || url1?.toLowerCase() == url2?.toLowerCase()) {
      r = true;
    } else if (url1 != null && url2 != null && (url1.length != url2.length)) {
      bool f1 = url1.endsWith('/');
      bool f2 = url2.endsWith('/');
      if (f1 && (f2 == false) && (url1 == '$url2/')) {
        r = true;
      } else if ((f1 == false) && f2 && (url2 == '$url1/')) {
        r = true;
      }
    }
    return r;
  }

  static bool isValidExtension(String? fileName) {
    String? mt;
    if (fileName != null && fileName.isNotEmpty) {
      mt = lookupMimeType(fileName);
    }
    return mt != null;
  }

  //时间生成的文件名称
  static String dateTimeFileName(String? srcName, {String? ex}) {
    String r = '';
    if (srcName != null && srcName.isNotEmpty) {
      r = srcName;
      if (pathExtension(srcName) != null && isValidExtension(srcName)) {
        return r;
      }
      if (ex != null && ex.isNotEmpty) {
        r = '$r${ex.startsWith('.') ? '' : '.'}$ex';
      }
      //r = pathSetExtension(r, ex);
    } else {
      r = DateFormat('yyyy-MM-dd-hh-mm-ss').format(DateTime.now());
      if (ex != null && ex.isNotEmpty) {
        r = '$r${ex.startsWith('.') ? '' : '.'}$ex';
      }
    }
    return r;
  }

  //标准化文件名称 mte3ndg2njd8m2y3ytu3yje5y2qynjmwmtm3ogjmmwyxoti5yjexmtd8mtc3odexmjawma==
  //forum.php?mod=attachment&aid=mte1otuyoth8nmyxn2qzzmnmnzqzowe3zmvinjm5njhmztq0mtbjmdr8mtc3ntuymdawma%3d%3d&nothumb=yes
  static String? sanitizeFilename(String? filename) {
    String? r = filename;
    if (r == null) {
      return null;
    }
    r = r.trim();
    if (r.isEmpty) {
      return null; // 或者你可以返回一个默认值或者抛出异常
    }
    r = autoDecodeComponentUrl(r, decoded: true);
    //attachment; filename="IMG_E1006.JPG"
    String? v = getFirstAttachmentFilename(r);
    if (v != null && v.isNotEmpty) {
      return v;
    }

    r = r.replaceAll(RegExp(r'[\\/?*:";<>|]'), '_'); // 替换非法字符为管道符
    if (isWindows() && (r.length > 255)) {
      // 对于NTFS，确保不超过255个字符（文件名部分）
      r = r.substring(0, 255); // 截断字符串到最大长度
    }
    // 可选：将文件名转换为小写以适应NTFS的大小写敏感性（视情况而定）
    // filename = filename.toLowerCase();
    return r;
  }

  ////windows suggestedFilename： attachment; filename="IMG_E1006.JPG"
  static String? getOnlyAttachmentFilename(String port, {bool onlyImg = false}) {
    String? r;
    var str = port.trim();
    if (str.isEmpty) {
      return r; // 或者你可以返回一个默认值或者抛出异常
    }
    //attachment; filename="IMG_E1006.JPG"
    //attachment; filename="%E7%99%BD%E7%82%B9.jpg"; filename*=utf-8''%E7%99%BD%E7%82%B9.jpg
    const String regx = """filename\\s*=\\s*["]\\s*([a-z|A-Z|0-9|_\\W]+[.][jpegJPEG]{3,8})""";
    const String comRegx = """filename\\s*=\\s*["]\\s*([a-z|A-Z|0-9|_\\W]+[.][a-zA-Z0-9]{3,8})""";
    try {
      if (isMatchRegex(str, onlyImg ? regx : comRegx)) {
        r = stringRegex(str, onlyImg ? regx : comRegx);
      } else {}
    } catch (e) {
      ZsLog.e('get attache error:$e');
    }
    return r;
  }

  ////windows suggestedFilename： attachment; filename="IMG_E1006.JPG"
  ///"content-disposition" -> "attachment; filename="%E7%99%BD%E7%82%B9.jpg"; filename*=utf-8''%E7%99%BD%E7%82%B9.jpg"
  static List<String> getAttachmentFilename(String? filename, {bool onlyImg = false}) {
    List<String> r = [];
    if (filename == null) {
      return r;
    }
    filename = filename.trim();
    if (filename.isEmpty) {
      return r; // 或者你可以返回一个默认值或者抛出异常
    }
    filename = autoDecodeComponentUrl(filename, decoded: true);
    if (filename.contains(';')) {
      var list = filename.split(';');
      for (int i = 0; i < list.length; i++) {
        var sp = list[i];
        if (sp.contains('filename')) {
          var res = getOnlyAttachmentFilename(filename, onlyImg: onlyImg);
          if (res != null && res.isNotEmpty) {
            r.add(res);
          }
        }
      }
    } else {
      var res = getOnlyAttachmentFilename(filename, onlyImg: onlyImg);
      if (res != null && res.isNotEmpty) {
        r.add(res);
      }
    }
    return r;
  }

  static String? getFirstAttachmentFilename(String? filename, {bool onlyImg = false}) {
    var r = getAttachmentFilename(filename, onlyImg: onlyImg);
    return r.isNotEmpty ? r.first : null;
  }

  /*
 *  ···
  final Uri emailLaunchUri = Uri(
    scheme: 'mailto',
    path: 'smith@example.com',
    query: encodeQueryParameters(<String, String>{
      'subject': 'Example Subject & Symbols are allowed!',
    }),
  );
  launchUrl(emailLaunchUri);
 */
  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries.map((MapEntry<String, String> e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');
  }

  static Future<Directory>? getAppDocDirectory() async {
    // 获取应用文档目录（不会被系统清理）
    return await getApplicationDocumentsDirectory();
  }

  static Future<Directory>? getAppCacheDirectory() async {
    // 获取应用文档目录（不会被系统清理）
    // Future<Directory> _appCacheDir  = await getApplicationCacheDirectory();
    return getApplicationCacheDirectory();
  }

  static Future<Directory> getAppTempDirectory() async {
    // 获取应用文档目录（不会被系统清理）
    // Future<Directory> _appTempDir  = await getTemporaryDirectory();
    return getTemporaryDirectory();
  }

  static String stringMaxLength(String text, int maxlen) {
    String showurl = text;
    if (showurl.length > maxlen) {
      showurl = showurl.substring(0, maxlen);
      showurl = '$showurl ...';
    }
    return showurl;
  }

  static String? stringRegex(String? string, String reg, {int index = 1}) {
    if (string == null) {
      return string;
    }
    RegExp regExp = RegExp(reg);
    // final regExp = RegExp(r'(\w+)');
    //const string = 'Parse my string';
    final Iterable<RegExpMatch> matches = regExp.allMatches(string);
    for (final m in matches) {
      return m[index];
    }
    return null;
  }

  static bool isMatchRegex(String? string, String reg) {
    if (string == null) {
      return false;
    }
    RegExp regExp = RegExp(reg);
    return regExp.hasMatch(string);
  }

  //后缀判断是否为图片链接
  static bool isImageExtensionUrl(String url, {bool decoded = false}) {
    bool r = false;
    String lw = url.toLowerCase();
    lw = autoDecodeUrl(lw, decoded: decoded);
    String? ex = fileExt(lw);
    if (ex != null) {
      // if (isTextExtension(ex)) {
      //   return false;
      // } else {
      r = isImageExtension(ex);
      // }
    }
    return r;
  }

  ///自动解码url
  static String autoDecodeUrl(String url, {bool decoded = false}) {
    String r = url;
    if (url.isEmpty) {
      return url;
    }
    try {
      //r.contains('%3d')
      r = decoded ? (url.contains('%') ? Uri.decodeFull(url) : url) : Uri.decodeFull(url);
    } catch (_) {}
    return r;
  }

  ///自动解码url query部分，或者cookie部分，https response header value
  static String autoDecodeComponentUrl(String url, {bool decoded = false}) {
    String r = url;
    if (url.isEmpty) {
      return r;
    }
    //r.contains('%3d')
    try {
      r = decoded ? (url.contains('%') ? Uri.decodeComponent(url) : url) : Uri.decodeComponent(url);
    } catch (_) {}
    return r;
  }

  // chiphell 站点图片附件链接
  // String url3 =
  //     'https://www.chiphell.com/forum.php?mod=attachment&aid=MTE1NjYzMjl8MGFkZDAxZDF8MTc2MzkwOTMzMnwyMzM0OHwyNzU4NjA2&nothumb=yes';
  //      https://www.chiphell.com/forum.php?mod=attachment&aid=MTE1Nzg1NjF8NmZmY2JiN2R8MTc2NDU5ODkxOHwyMzM0OHwyNzYxMTM2&nothumb=yes
  static bool isDiscuzAttachmentImageUrl(String url, {bool decoded = false}) {
    const String reg = r'mod=attachment&aid=[a-z|A-Z|0-9|=]+&nothumb=yes';
    String lw = url.toLowerCase();
    lw = autoDecodeUrl(lw, decoded: decoded);
    return isMatchRegex(lw, reg);
  }

  //chiphell 已经知道的图片链接
  //  https://www.chiphell.com/data/avatar/000/18/94/15_avatar_small.jpg
  // String url1 =
  //     'https://static.chiphell.com/portal/202511/24/084035sd87gymzd5mtmgk9.gif';
  // String url2 =
  //     'https://static.chiphell.com/forum/202511/18/142935i0bhlvqkjlkdcg0k.jpg';
  static bool isDiscuzImageUrl(String url, {bool decoded = false}) {
    String lw = url.toLowerCase();
    lw = autoDecodeUrl(lw, decoded: decoded);
    const List<String> regexs = [
      r'/[0-9]{4,6}/[0-9]{2}/[a-z|A-Z|0-9]{10,30}.\w+',
      r'/data/avatar/[0-9]+/[0-9]+/[0-9]+/.*',
      r'/static/image/.*',
    ];
    bool r = false;
    for (int i = 0; i < regexs.length; i++) {
      if (Utils.isMatchRegex(lw, regexs[i])) {
        r = true;
        break;
      }
    }
    return r;
  }

  static bool isDiscuzContentImageUrl(String url, {bool decoded = false}) {
    String lw = url.toLowerCase();
    lw = autoDecodeUrl(lw, decoded: decoded);
    bool r = isImageExtensionUrl(lw);
    if (!r) {
      r = isDiscuzAttachmentImageUrl(lw);
      if (!r) {
        r = isDiscuzImageUrl(lw);
      }
    }
    return r;
  }

  static bool isDiscuzComContentImageUrl(String url, {bool decoded = false}) {
    String lw = url.toLowerCase();
    lw = autoDecodeUrl(lw, decoded: decoded);
    bool r = isImageExtensionUrl(lw);
    if (!r) {
      r = isDiscuzImageUrl(lw);
    }
    return r;
  }

  static String textToUrlOrSearch(String text, {int search = 0}) {
    String r = '';
    if (text.isNotEmpty) {
      String ltext = text.toLowerCase();
      if (ltext.startsWith('http://', 0) || ltext.startsWith('https://', 0)) {
        r = text;
      } else if (ltext.startsWith('chiphell.com', 0)) {
        r = 'https://www.$text';
      } else if (ltext.startsWith('www', 0)) {
        r = 'https://$text';
      } else if (isMatchRegex(ltext, r'^[0-9a-zA-Z]{1,15}[.][0-9a-zA-Z]{1,15}[.][a-zA-Z]{2,7}[/]*')) {
        //三级域名 a.b.com.长度不超过20
        r = 'https://$text';
      } else if (isMatchRegex(ltext, r'^[0-9a-zA-Z]{1,15}[.][a-zA-Z]{2,7}[/]*')) {
        //二级域名 b.com
        r = 'https://$text';
      } else {
        if (search == 0) {
          r = 'https://www.baidu.com/s?wd=$text';
        } else if (search == 1) {
          r = 'https://cn.bing.com/search?q=$text';
        } else if (search == 2) {
          r = 'https://www.google.com/search?hl=zh-CN&client=opera&q=$text';
        } else {
          r = 'https://m.baidu.com/s?wd=$text';
        }
      }

      //  url = 'https://cn.bing.com/search?q=$text';
      // _textEditingController.text = url;
    }
    return r;
  }

  //保存图片到相册
  // static Future<void> saveImageToGallery(Uint8List imageBytes) async {
  //   // 请求存储权限
  //   var status = await Permission.storage.request();
  //   if (status.isGranted) {
  //     // 获取临时目录路径
  //     final directory = await getTemporaryDirectory();
  //     final imagePath = '${directory.path}/temp_image.png';
  //     // 将图片保存到临时目录
  //     File imgFile = File(imagePath);
  //     await imgFile.writeAsBytes(imageBytes);
  //     // 使用gallery_saver插件保存到相册
  //     await GallerySaver.saveImage(imgFile.path);
  //     ZsLog.d('Image saved to gallery');
  //   } else {
  //     ZsLog.d('Permission denied');
  //   }
  // }

  //  controller.loadRequest(Uri.parse('https://'),
  //     headers: {
  //       "Custom-Name": "IAM17",
  //     },
  //     method: LoadRequestMethod.post,
  //     body: toUint8List("我们见过的！"));
  //非utf8
  static Uint8List stringToUint8List(String str) {
    final List<int> codeUnits = str.codeUnits;
    final unit8List = Uint8List.fromList(codeUnits);
    return unit8List;
  }

  static Uint8List stringToUtf8Uint8List(String str) {
    final unit8List = utf8.encode(str);
    return unit8List;
  }

  static String stringEncodeBase64(String original) {
    List<int> bytes = utf8.encode(original);
    return base64.encode(bytes);
  }

  static String stringFromUint8List(Uint8List utf8Buffer) {
    String r = '';
    bool f = false;
    // GbkCodec().decode(bytes);
    //latin1.decode(bytes);
    try {
      r = utf8.decode(utf8Buffer);
      f = true;
    } catch (e) {
      ZsLog.e('uint8 decode to string failed', error: e);
    }
    if (!f) {
      try {
        r = String.fromCharCodes(utf8Buffer);
        f = true;
      } catch (e) {
        ZsLog.e('String.fromCharCodes string failed', error: e);
      }
    }
    if (!f) {
      try {
        r = latin1.decode(utf8Buffer);
        f = true;
      } catch (e) {
        ZsLog.e('latin1 decocde to failed', error: e);
      }
    }
    return r;
  }
  // FutureBuilder(
  //   future: _fetchData(), // 异步操作, 比如通过 api 拉取数据
  //   builder: (context, snapshot) {
  //     // 根据异步操作的状态更新UI
  //     if (snapshot.connectionState == ConnectionState.waiting) {
  //       return CircularProgressIndicator(); // 正在加载
  //     } else if (snapshot.hasError) {
  //       return Text('Error: ${snapshot.error}'); // 发生错误
  //     } else {
  //       final data = snapshot.data;
  //       return ListView.builder(
  //         itemCount: data.length,
  //         itemBuilder: (context, index) {
  //           return Text('Item ${index}: $data[index]');
  //         },
  //       ); // 加载成功
  //     }
  //   },
  // )

  //读取assets path:'assets/config.txt'
  static Future<String> loadAsset(String assetFilePath) async {
    //widget DefaultAssetBundle.of(context).loadString('assets/config.txt')
    var data = await rootBundle.load(assetFilePath);
    return utf8.decode(data.buffer.asUint8List());
    //return await rootBundle.loadString(assetFilePath);//启动会卡
  }

  static Future<ByteData> loadAssetFileByteData(String assetFilePath) async {
    var data = await rootBundle.load(assetFilePath);
    return data;
  }

  static Future<Uint8List> loadAssetFileData(String assetFilePath) async {
    var data = await rootBundle.load(assetFilePath);
    return data.buffer.asUint8List();
  }

  static Future<File> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return File(path).writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  static Future<File> writeUint8ListToFile(Uint8List buffer, String path) {
    return File(path).writeAsBytes(buffer);
  }

  static Future<File> writeStringToFile(String content, String path) {
    return File(path).writeAsBytes(content.codeUnits);
  }

  static Future<File> copyAssetsFileToPath(String assetFilePath, String destPath) async {
    var data = await rootBundle.load(assetFilePath);
    final buffer = data.buffer;
    return File(destPath).writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  //删除URL Path 扩展后缀
  ///  '/space/' -> '/space/' , split['','space','']
  ///  '/space' -> '/space/' , split['','space']
  ///  '/space-uid-695499.html' -> '', split['','space-uid-695499.html']
  ///  '/b/space-uid-695499.html' -> '/b' , split['','b','space-uid-695499.html']
  ///  '/' => '/', split['','']
  ///  'space-uid-695499.html' -> '/'
  ///  'space' -> '/space/', split['space']
  static String delUrlPathExtension(String path) {
    String r = '';
    if (path.contains('/')) {
      var list = path.split('/');
      var lastEx = list.last;
      if (lastEx == '') {
        r = path;
      } else if (lastEx.contains('.')) {
        var vals = [];
        vals.addAll(list);
        vals[list.length - 1] = '';
        r = vals.join('/');
      } else {
        r = '$path/';
      }
    } else if (path.contains('.')) {
      r = '/';
    } else {
      r = '/$path/';
    }
    return r;
  }

  // p.basename('path/to/foo.dart'); // -> 'foo.dart'
  static String pathBasename(String path) {
    return p.basename(path);
  }

  static String? pathExtension(String? path) {
    if (path == null || path.isEmpty) {
      return null;
    }
    String? r = p.extension(path);
    if (r.isEmpty) {
      r = null;
    }
    return r;
  }

  ///   p.basenameWithoutExtension('path/to/foo.dart/'); // -> 'foo'
  static String pathBasenameWithoutExtension(String path) {
    return p.basenameWithoutExtension(path);
  }

  static String pathSetExtension(String path, String? ex, {bool forceSet = false}) {
    if ((ex == null || ex.isEmpty)) {
      return path;
    }
    String? oex = pathExtension(path);
    if (stringIsNotEmpty(oex)) {
      if (ex == oex) {
        return path;
      } else if (forceSet == false) {
        return path;
      }
    }
    return '$path${ex.startsWith('.') ? '' : '.'}$ex';
    //return p.setExtension(path, ex.startsWith('.') ? ex : '.$ex');//会删除一些关键部分
  }

  //自动生成一个不存在的文件路径
  static String autoPathNoExist(String path) {
    if (!fileExist(path)) {
      return path;
    }
    String dir = p.dirname(path);
    String ex = p.extension(path).trim();
    String name = p.basenameWithoutExtension(path);
    int i = 1;
    String rPath = '';
    while (true) {
      var trPath = p.join(dir, '${name}_$i');
      rPath = '$trPath${ex.startsWith('.') ? '' : '.'}$ex';
      if ((rPath == trPath) || !fileExist(rPath)) {
        break;
      }
      i++;
    }
    return rPath;
  }

  /// Image cache manager folder
  static Future<String> getImageCacheDir() async {
    return p.join((await getTemporaryDirectory()).path, DefaultCacheManager.key);
    //  return '${directory.path}/${DefaultCacheManager.key}';
  }

  static Future<void> createDir(String? path, bool recursive) async {
    if (path != null) {
      Directory? cDir = Directory(path);
      if (!await cDir.exists()) {
        await cDir.create(recursive: recursive);
      }
    }
  }

  //"/Users/zorro/Library/Containers/com.zorro.chiphell/Data/"
  //这个目录下有 软引用： Desktop Documents Downloads Movies Music Pictures 真正目录是/Users/zorro/ 目录下的对应目录
  //          子目录 SystemData Documents
  static Future<String> getDataDirForMacos() async {
    Directory? directory = await getDownloadsDirectory();
    if (directory != null) {
      return directory.parent.absolute.path;
    }
    directory = await getLibraryDirectory();
    return directory.parent.absolute.path;
  }

  // /Users/cjxy/Library/Containers/com.zorro.chiphell/Data/Pictures 指向 /Users/cjxy/Pictures
  static Future<String> getPictureDirForMacos() async {
    String dataDir = await getDataDirForMacos();
    return p.join(dataDir, WebConstants.kAppPictureFolder); // '$dataDir/Pictures';
  }

  //如果存在C:\Users\Zorro\Pictures，则返回
  //否则返回C:\Users\Zorro\Documents\Pictures
  static Future<String> getPictureDirForWindow() async {
    final dtr = 'Documents';
    var r = await getDocumentsDir();
    if (r.endsWith(dtr)) {
      var rb = r.substring(0, r.length - dtr.length);
      rb = p.join(rb, WebConstants.kAppPictureFolder);
      if (dirExist(rb)) {
        return rb;
      }
    }
    return p.join(await getDocumentsDir(), WebConstants.kAppPictureFolder);
  }

  static bool isZhLocation() {
    Locale systemLocale = WidgetsBinding.instance.platformDispatcher.locale; // 获取系统语言环境
    return systemLocale.languageCode == 'zh';
  }

  // 主目录通常位于/home/用户名
  // 用户文档通常位于/home/用户名/文档（Documents）
  // 桌面文件夹位于/home/用户名/桌面（Desktop）
  // 图片文件夹位于/home/用户名/图片（Pictures）
  // 音乐文件夹位于/home/用户名/音乐（Music）
  // 视频文件夹位于/home/用户名/视频（Videos）
  // 下载文件夹通常位于/home/用户名/下载（Downloads）
  static Future<String> getPictureDirForLinux() async {
    // Directory? directory = await PathProviderMaster.getPublicPicturesDirectory();
    // if(directory!=null){
    //   return directory.absolute.path;
    // }
    String pt = await getDocumentsDir();
    if (isZhLocation()) {
      String r = p.join(pt, WebConstants.kAppPictureCNFolder);
      if (dirExist(r)) {
        return r;
      }
    }
    return p.join(pt, WebConstants.kAppPictureFolder);
  }

  //kAppFolder /Users/zorro/Library/Containers/com.zorro.chiphell/Data/Pictures/chiphell  指向 /Users/cjxy/Pictures/chiphell
  static Future<String> getAppPictureDirForMacos() async {
    String pic = await getPictureDirForMacos();
    pic = p.join(pic, WebConstants.kAppLocalFolder);
    await createDir(pic, true);
    return pic;
  }

  //kAppFolder  C:\Users\Zorro\Pictures\chiphell
  static Future<String> getAppPictureDirForWindow() async {
    String pic = await getPictureDirForWindow();
    pic = p.join(pic, WebConstants.kAppLocalFolder);
    await createDir(pic, true);
    return pic;
  }

  static Future<String> getAppPictureDirForLinux() async {
    String pic = await getPictureDirForLinux();
    pic = p.join(pic, WebConstants.kAppLocalFolder);
    await createDir(pic, true);
    return pic;
  }

  static Future<String> getAppPictureDirForDesktopSystem() async {
    String pic = '';
    if (isWindows()) {
      pic = await getAppPictureDirForWindow();
    } else if (isMacOS()) {
      pic = await getAppPictureDirForMacos();
    } else if (isLinux()) {
      pic = await getAppPictureDirForLinux();
    } else {}
    return pic;
  }

  static Future<String> getAppPicturePathForDesktopSystem(String name) async {
    String pic = '';
    if (isWindows()) {
      pic = await getAppPictureDirForWindow();
    } else if (isMacOS()) {
      pic = await getAppPictureDirForMacos();
    } else if (isLinux()) {
      pic = await getAppPictureDirForLinux();
    } else {}
    if (name.isNotEmpty) {
      pic = p.join(pic, name);
    }
    return pic;
  }

  /// 获得用户通用（会贴，发帖）的图片路径
  static Future<String> getUserCompressImagesFolder({String? fileName}) async {
    String thumbsDir = await getDownloadPathForSystem(Constants.kDirPressImageFolderName);
    if (!dirExist(thumbsDir)) {
      await createDir(thumbsDir, false);
    }
    if (fileName != null && fileName.isNotEmpty) {
      thumbsDir = p.join(thumbsDir, fileName);
    }
    return thumbsDir;
  }

  static Future<String> getDocumentsDir() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String d = dir.path;
    // await createDir(d, true);
    return d;
  }

  static Future<String> getAppDocumentsDir() async {
    String d = p.join(await getDocumentsDir(), WebConstants.kAppFolder);
    await createDir(d, true);
    return d;
  }

  ///ios getDownloadsDirectory不存在 /Users/cjxy/Library/Developer/CoreSimulator/Devices/EFE0FB2C-B8F8-4412-8639-175A0148187D/data/Containers/Data/Application/A6463540-8435-4FE6-BE71-1F6ACD4E1E78/Downloads
  ///linux
  ///ios 使用doc目录，系统文件App 能访问 /Users/cjxy/Library/Developer/CoreSimulator/Devices/61871ABD-04DE-48C4-969D-E66BEB4E7D4B/data/Containers/Data/Application/D48357B9-A5F8-460C-9126-BA5EC6DF21BA/Documents/chiphell
  ///macos  /Users/cjxy/Library/Containers/com.zorro.chiphell/Data/Downloads
  ///android 应用内的downloads目录 /storage/emulated/0/Android/data/com.zorro.chiphell/files/downloads/
  ///        不是设备的Download目录 /storage/emulated/0/Download
  ///windows
  static Future<String> getDownloadPathForSystem(String name) async {
    if (Utils.isIOS()) {
      ///Users/cjxy/Library/Developer/CoreSimulator/Devices/61871ABD-04DE-48C4-969D-E66BEB4E7D4B/data/Containers/Data/Application/D48357B9-A5F8-460C-9126-BA5EC6DF21BA/Documents/chiphell
      return p.join(await getAppDocumentsDir(), name);
    }
    Directory? downloadsDir = await getDownloadsDirectory();
    if (downloadsDir != null) {
      if (!downloadsDir.existsSync()) {
        await createDir(downloadsDir.path, false);
      }
      return p.join(downloadsDir.path, name);
    } else {
      return p.join(await getAppDocumentsDir(), name);
    }
  }

  static Future<String> getSupportPath() async {
    String sp = '';
    if (Utils.isLinux()) {
      //  /home/zorro/.cache/com.zorro.chiphell
      sp = (await getApplicationCacheDirectory()).absolute.path;
    } else {
      //linux /home/zorro/.local/share
      //ios
      //macos /Users/cjxy/Library/Containers/com.zorro.chiphell/Data/Library/Application Support/com.zorro.chiphell
      //android      /data/user/0/com.zorro.chiphell/files
      //windows     //windows C:\Users\Zorro\AppData\Roaming\com.zorro.chiphell\chiphell
      sp = (await getApplicationSupportDirectory()).absolute.path;
    }
    return sp;
  }

  //数据库存放位置 android /data/user/0/com.zorro.chiphell/files/databases/myDb.db
  //windows  C:\Users\Zorro\AppData\Roaming\com.zorro.chiphell\chiphell\databases\myDb.db
  static Future<String> getSupportDbPath() async {
    String dbFolder = await Utils.getSupportPath();
    dbFolder = p.join(dbFolder, "databases");
    Utils.createDir(dbFolder, true);
    String path = p.join(dbFolder, "myDb.db");
    //ZsLog.d('App data base path: $path');
    return path;
  }

  //不推荐使用了
  @Deprecated('兼容 v1.0.11以下版本')
  static Future<String> getSupportOldDbPath() async {
    String old = p.join(await getDocumentsDir(), WebConstants.kAppFolder, "databases", "myDb.db");
    return old;
  }

  //linux
  //ios 使用doc目录，系统文件App 能访问
  //macos
  //android
  //windows
  static Future<String> getLogsPath(int order) async {
    String folder = '';
    if (Utils.isLinux()) {
      //  /home/zorro/.cache/com.zorro.chiphell
      folder = (await getApplicationCacheDirectory()).absolute.path;
    } else {
      // macos /Users/cjxy/Library/Containers/com.zorro.chiphell/Data/Library/Caches/com.zorro.chiphell/logs
      //android /data/user/0/com.zorro.chiphell/cache/logs
      //windows C:\Users\Zorro\AppData\Local\Temp
      folder = (await getTemporaryDirectory()).absolute.path;
      if (Utils.isWindows()) {
        //windows C:\Users\Zorro\AppData\Local\Temp\chiphell\logs
        folder = p.join(folder, WebConstants.kAppFolder);
      }
      //folder = p.join(folder, WebConstants.kAppFolder);
    }
    folder = p.join(folder, WebConstants.kLogFolder, order > 0 ? '$order' : null);
    createDir(folder, true);
    return folder;
  }

  //linux /home/zorro/Documents/chiphell/web
  //ios 使用doc目录，系统文件App 能访问
  //macos /Users/cjxy/Library/Containers/com.zorro.chiphell/Data/Documents/chiphell/web
  //android /data/user/0/com.zorro.chiphell/app_flutter/web
  //windows C:\Users\Zorro\Documents\chiphell\web
  static Future<String> webViewAllowingReadAccessToFolder() async {
    String d = '';
    if (Utils.isDesktopSystem) {
      d = p.join(await getDocumentsDir(), WebConstants.kAppFolder, WebConstants.kWebAllowingReadAccessFolder);
    } else {
      d = p.join(await getDocumentsDir(), WebConstants.kWebAllowingReadAccessFolder);
    }
    await createDir(d, true);
    return d;
  }

  static Future<String> webViewSiteExtensionUserFolder() async {
    String fd = p.join(await webViewAllowingReadAccessToFolder(), WebConstants.kWebViewSiteExtensionUserFolder);
    await createDir(fd, true);
    return fd;
  }

  ///Users/cjxy/Library/Containers/com.zorro.chiphell/Data/Documents/chiphell/web/sites/cliff.imwork.net.css
  ///Users/cjxy/Library/Containers/com.zorro.chiphell/Data/Documents/chiphell/web/sites/cliff.imwork.net.js
  static Future<String?> webViewSiteExtensionUserConfigContent(String filename) async {
    String? r;
    try {
      String path = p.join(await webViewSiteExtensionUserFolder(), filename);

      File f = File(path);
      r = await f.readAsString();
    } catch (e) {
      ZsLog.e('load web site extension user config[$filename] error', error: e);
    }
    return r;
  }

  //参考 https://inappwebview.dev/docs/webview/process-global-config/
  //android /data/user/0/com.zorro.chiphell/app_flutter/chiphell/cache
  static Future<String> androidWebCacheDirectoryBasePath() async {
    String d = p.join(await getDocumentsDir(), WebConstants.kAppFolder, 'cache');
    await createDir(d, true);
    return d;
  }

  //android /data/user/0/com.zorro.chiphell/app_flutter/chiphell/data
  static Future<String> androidWebDataDirectoryBasePath() async {
    String d = p.join(await getDocumentsDir(), WebConstants.kAppFolder, 'data');
    await createDir(d, true);
    return d;
  }

  static Future<File?> copyFile(String source, String destination) async {
    File? rc;
    try {
      File sf = File(source);
      rc = await sf.copy(destination);
    } catch (e) {
      ZsLog.d('文件复制失败: $e');
    }
    return rc;
  }

  static Future<File?> moveFile(String source, String destination) async {
    File? rc;
    try {
      File sf = File(source);
      rc = await sf.copy(destination);
      await sf.delete(recursive: false);
    } catch (e) {
      ZsLog.d('文件复制失败: $e');
    }
    return rc;
  }

  static String? splitLastString(String orgString, String sp) {
    final index = orgString.lastIndexOf(sp);
    if (index < 0 || index + 1 >= orgString.length) {
      return null;
    }
    return orgString.substring(index + 1).toLowerCase();
  }

  static String lastFileName(String path) {
    String? ret = splitLastString(path, isWindows() ? '\\' : '/');
    ret ??= path;
    return ret;
  }

  static String? ableFileName(String path) {
    String? ret = splitLastString(path, isWindows() ? '\\' : '/');
    return ret;
  }

  static String? baseFileName(String path) {
    String? ret = p.basename(path);
    return ret;
  }

  static String? fileExt(String path) {
    //p.extension(path);
    String folder = lastFileName(path);
    int index = folder.lastIndexOf('.');
    if (index < 0 || index + 1 >= folder.length) {
      return null;
    }
    //  ?mobile=2
    String lastPart = folder.substring(index + 1).toLowerCase();
    index = lastPart.lastIndexOf('?');
    if (index < 0 || index + 1 >= lastPart.length) {
      //php_mod=attachment&aid=mte1otuyoth8nmyxn2qzzmnmnzqzowe3zmvinjm5njhmztq0mtbjmdr8mtc3ntuymdawma==&nothumb=yes
      if (lastPart.contains('=') || lastPart.contains('&')) {
        lastPart = p.extension(lastPart);
      }
      return lastPart;
    }
    lastPart = lastPart.substring(0, index);
    return lastPart;
  }

  static bool isImageExt(String path, {void Function(String ex)? callFn}) {
    String? ex = Utils.fileExt(path);
    if (ex == null) {
      return false;
    }
    if (callFn != null) {
      callFn.call(ex);
    }
    return isImageExtension(ex);
  }

  ///判断扩展名称是否为 文本文件扩展名
  static bool isTextExtension(String? extension) {
    bool r = false;
    if (extension != null && extension.isNotEmpty) {
      if (!extension.startsWith('.')) {
        extension = '.$extension';
      }
      r = _htmlTypeList.contains(extension.toLowerCase());
    }
    return r;
  }

  ///判断扩展名称是否为 图片文件扩展名
  static bool isImageExtension(String? extension) {
    bool r = false;
    if (extension != null && extension.isNotEmpty) {
      if (extension.startsWith('.')) {
        extension = extension.substring(1);
      }
      r = _imageTypeExtensions.contains(extension.toLowerCase());
    }
    return r;
  }

  static String getFitImageNameFrom(String? orgName, String orgPath, {String? sugExtension}) {
    String name = orgName ?? (lastFileName(orgPath));
    String? fext = Utils.fileExt(name);
    if (fext == "" || fext == 'html' || fext == 'htm' || fext == 'php' || fext == 'php_mod' || fext == 'js' || fext == 'file') {
      fext = null;
    }
    if (fext == null || fext.isEmpty) {
      fext = sugExtension != null && sugExtension.isNotEmpty ? sugExtension : Utils.fileExt(orgPath);
      if (fext == "" || fext == 'html' || fext == 'htm' || fext == 'php' || fext == 'php_mod' || fext == 'js' || fext == 'file') {
        fext = null;
      }
      fext ??= fileExtensionFromMimeType(fileMimeType(orgPath, headerCheck: true));
      if (fext != null) {
        name = '$name.$fext';
      }
    } else if (sugExtension != null && sugExtension.isNotEmpty) {
      if (fext != sugExtension) {
        name = '$name.$sugExtension';
      }
    }
    return name;
  }

  static String pathAppand(String path, String name) {
    return p.join(path, name);
    //isWindows() ? '$path\\$name' : '$path/$name';
  }

  static String dirAppand(Directory dir, String name) {
    return p.join(dir.path, name);
    //isWindows() ? '$path\\$name' : '$path/$name';
  }

  static String sizePositionToString(Size size, Offset offset) {
    return '${size.width.toStringAsFixed(1)},${size.height.toStringAsFixed(1)}|${offset.dx.toStringAsFixed(1)},${offset.dy.toStringAsFixed(1)}';
  }

  static void stringToSizePosition(String spString, void Function(Size size, Offset offset) callBack) {
    List<String> list = spString.split('|');
    List<String> sizeWidthAndHight = list[0].split(',');
    List<String> offsetXY = list[1].split(',');
    Size size = Size(double.parse(sizeWidthAndHight[0]), double.parse(sizeWidthAndHight[1]));

    Offset offset = Offset(double.parse(offsetXY[0]), double.parse(offsetXY[1]));
    callBack(size, offset);
  }

  static bool fileExist(String path) {
    File file = File(path);
    return file.existsSync();
  }

  static bool dirExist(String path) {
    Directory file = Directory(path);
    return file.existsSync();
  }

  static void deleteFile(String path) {
    File file = File(path);
    if (file.existsSync()) {
      try {
        file.deleteSync();
      } on FileSystemException catch (e) {
        ZsLog.e('Delete file error: ', error: e);
      }
      //.then((_) {
      //   print('文件已删除');
      // }).catchError((error) {
      //   print('删除文件时发生错误: $error');
      // });
    } else {
      // print('文件不存在');
    }
  }

  /// 删除目录下所有文件
  static Future<void> deleteFilesInDir(String dirPath) async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) return;
    final files = dir.listSync().whereType<File>();
    // 并发删除（比 for 循环快）
    await Future.wait(files.map((file) => file.delete()));
    //print('✅ 已删除 ${files.length} 个文件');
  }

  /// 使用：删除7天前的文件
  static Future<void> deleteOldFiles(String dirPath, {int days = 7}) async {
    final dir = Directory(dirPath);
    final now = DateTime.now();
    final cutoff = now.subtract(Duration(days: days));
    final files = dir.listSync().whereType<File>();
    for (var file in files) {
      final modified = await file.lastModified();
      if (modified.isBefore(cutoff)) {
        await file.delete();
        //print('🗑️ 删除旧文件: ${file.path}');
      }
    }
  }

  /// 删除目录下ext后缀文件
  static Future<void> deleteByExtension(String dirPath, String ext) async {
    final dir = Directory(dirPath);

    final files = dir.listSync().whereType<File>().where((f) => f.path.endsWith(ext));

    for (var file in files) {
      await file.delete();
    }
    // print('✅ 已删除所有 $ext 文件');
  }

  /// 通过文件扩展名，获得mimtype
  /// getMimeTypeFromFileExtension('/..././a.jpg');
  static String? getMimeTypeFromFileExtension(String? fileExtension) {
    String? r;
    if (fileExtension != null && fileExtension.isNotEmpty) {
      r = lookupMimeType(fileExtension);
    }
    return r;
  }

  /// 通过文件内容的头，获得mimtype
  ///   final jpegHeader = [0xFF, 0xD8, 0xFF, 0xE0]; getMimeTypeFromFileHeader(jpegHeader);
  static String? getMimeTypeFromFileHeader(List<int>? headerBytes, {String? path = 'unknown'}) {
    String? r;
    if (headerBytes != null && headerBytes.isNotEmpty) {
      var hd = headerBytes;
      if (headerBytes.length > 12) {
        hd = headerBytes.sublist(0, 12);
      }
      r = lookupMimeType(path != null && path.isNotEmpty ? path : 'unknown', headerBytes: hd);
    }
    return r;
  }

  static Future<String?> getMimeType(File? file) async {
    String? r;
    if (file != null && await file.exists()) {
      // 读取文件头部
      try {
        final stream = file.openRead(0, 12);
        final List<int> headerBytes = await stream.first;
        // 获取 MIME 类型
        r = lookupMimeType(file.path, headerBytes: headerBytes);
      } catch (e) {
        ZsLog.e('getMimeType error:', error: e);
      }
      if (r == null) {
        try {
          final RandomAccessFile raf = await file.open(mode: FileMode.read);
          final List<int> headerBytes = await raf.read(12);
          r = lookupMimeType(file.path, headerBytes: headerBytes);
        } catch (e) {
          ZsLog.e('getMimeType error:', error: e);
        }
      }
    }
    return r;
  }

  static Future<String?> getMimeTypeFromPath(String? file) async {
    String? r;
    if (file != null && file.isNotEmpty) {
      r = await getMimeType(File(file));
    }
    return r;
  }

  static String? getMimeTypeFromPathSync({String? path, File? file}) {
    String? r;
    String? vpath = path;
    if (file != null) {
      vpath = file.path;
    }
    File? vfile = file;
    if (vfile == null && (path != null && path.isNotEmpty)) {
      vfile = File(path);
    }
    try {
      if (vfile != null && vfile.existsSync()) {
        Uint8List headerBytes = vfile.readAsBytesSync(); // 读取前8个字节
        r = getMimeTypeFromFileHeader(headerBytes, path: vpath);
        r ??= getMimeTypeFromFileHeader(headerBytes);
      }
    } catch (e) {
      ZsLog.e('getMimeTypeFromPathSync error ', error: e);
    }
    return r;
  }

  static String? fileMimeType(String path, {bool headerCheck = false}) {
    String? r = getMimeTypeFromFileExtension(path);
    if (headerCheck && r == null) {
      r = getMimeTypeFromPathSync(path: path);
    }
    return r;
  }

  /// 从mimeType 获得一个文件扩展名
  /// print(extensionFromMime('text/html'));  // Prints "html".
  /// print(extensionFromMime('image/jpeg'));  // Prints "jpg".
  /// print(extensionFromMime('application/pdf'));  // Prints "pdf".
  /// print(extensionFromMime("application/pkix-cert")); // .crt
  static String? fileExtensionFromMimeType(String? mimeType) {
    String? r = mimeType != null && mimeType.isNotEmpty ? extensionFromMime(mimeType) : null; //'text/html'
    if (r == '') {
      r = null;
    }
    return r;
  }

  static bool isImageMimeType(String? mimeType) {
    return mimeType != null && (mimeType.startsWith('image/') || mimeType == 'image');
  }

  static Future<bool> isImageFile(File file, {void Function(String? mmt, String? ex, bool isImage)? callFun}) async {
    String? mimeType = await Utils.getMimeType(file);
    bool r = Utils.isImageMimeType(mimeType);
    if (callFun != null) {
      callFun(mimeType, fileExtensionFromMimeType(mimeType), r);
    }
    return r;
  }

  bool isImageFileSync(File file) {
    bool r = Utils.isImageMimeType(getMimeTypeFromFileExtension(file.path));
    if (!r) {
      r = Utils.isImageMimeType(Utils.getMimeTypeFromPathSync(file: file));
    }
    return r;
  }

  ///从http 响应数据 获得 数据扩展名
  /// "content-disposition" -> "attachment; filename="8.PNG""
  /// "content-type" -> "image"
  static String? httpUrlExtensionFromResponse(
    String url, {
    Map<String, String>? resHeader,
    String? resMimeType,
    String? resContentDisposition,
    Uint8List? body,
    String? sugFileName,
    String? sugExtension,
    void Function(String? name, String? ex)? result,
  }) {
    String path = Uri.parse(url).path;
    // String name = Utils.pathBasename(path);
    String? ex;
    String? contentType = resMimeType;
    String? contentDisposition = resContentDisposition;
    String? filename;
    bool isImg = false;

    if (contentDisposition == null && resHeader != null) {
      if (resHeader.containsKey(httpResHeaderContentDisposition.toLowerCase())) {
        contentDisposition = resHeader[httpResHeaderContentDisposition.toLowerCase()];
      } else if (resHeader.containsKey(httpResHeaderContentDisposition)) {
        contentDisposition = resHeader[httpResHeaderContentDisposition];
      }
    }

    if (stringIsNotEmpty(contentDisposition)) {
      //attachment; filename="2026-05-08_112014.jpg"
      contentDisposition = autoDecodeComponentUrl(contentDisposition!, decoded: true);
      filename = getFirstAttachmentFilename(contentDisposition);
      if (stringIsEmpty(ex) && stringIsNotEmpty(filename) && filename?.contains('.') == true) {
        ex = p.extension(filename!);
      }
    }

    if (ex == null) {
      if (contentType == null && resHeader != null) {
        if (resHeader.containsKey(httpHeaderContentType.toLowerCase())) {
          contentType = resHeader[httpHeaderContentType.toLowerCase()];
        } else if (resHeader.containsKey(httpHeaderContentType)) {
          contentType = resHeader[httpHeaderContentType];
        }
      }
      if (stringIsNotEmpty(contentType)) {
        //text/html; charset=utf-8
        if (contentType!.contains(";")) {
          List<String> list = contentType.split(';');
          for (int i = 0; i < list.length; i++) {
            var v = list[i];
            if (v.contains('/')) {
              ex = Utils.fileExtensionFromMimeType(v);
              if (stringIsNotEmpty(ex)) {
                if (!isImg) {
                  isImg = isImageMimeType(v);
                }
                break;
              }
            }
          }
        } else {
          ex = Utils.fileExtensionFromMimeType(contentType);
          if (stringIsNotEmpty(ex) && !isImg) {
            isImg = isImageMimeType(contentType);
          }
        }
      }
    }

    if (body != null && (ex == null || ex.isEmpty)) {
      String? mimetype = getMimeTypeFromFileHeader(body);
      if (mimetype != null) {
        ex = Utils.fileExtensionFromMimeType(mimetype);
        if (!isImg) {
          isImg = isImageMimeType(mimetype);
        }
      }
    }

    if (stringIsEmpty(ex)) {
      String? mimetype = Utils.fileMimeType(path, headerCheck: false);
      if (mimetype != null) {
        if (!isImg) {
          isImg = isImageMimeType(mimetype);
        }
        if (stringIsEmpty(sugExtension)) {
          ex = Utils.fileExtensionFromMimeType(mimetype);
        }
      }
    }

    filename ??= sugFileName;
    ex ??= sugExtension;
    if (!isImg) {
      isImg = isImageExtension(ex);
    }
    if (stringIsEmpty(ex) && path.contains(".")) {
      ex = p.extension(path);
      if (isImg && !isImageExtension(ex)) {
        //ex = null;
        ZsLog.w('http res body is image, ex not image!');
      }
    }

    if (result != null) {
      result.call(filename, ex);
    }
    return ex;
  }

  static Uint8List convertToUint8List(List<List<int>> nestedList) {
    // 使用 expand 扁平化二维数组
    List<int> flattened = nestedList.expand((i) => i).toList();
    // 转换为 Uint8List
    return Uint8List.fromList(flattened);
  }

  Uint8List convertToUint8ListAll(List<List<int>> nestedList) {
    List<int> flattened = [];
    for (var innerList in nestedList) {
      flattened.addAll(innerList);
    }
    return Uint8List.fromList(flattened);
  }

  static int? queueBackTraverse(int current, int max, int? Function(int index) check) {
    int? fd;
    for (int v = current; v >= 0; v--) {
      var c = check(v);
      if (c != null) {
        fd = c;
        break;
      }
    }
    return fd;
  }

  static int? queueForwardTraverse(int current, int max, int? Function(int index) check) {
    int? fd;
    for (int v = current; v < max; v++) {
      var c = check(v);
      if (c != null) {
        fd = c;
        break;
      }
    }
    return fd;
  }

  /// WebHistoryList遍历优化算法，先向小的方向遍历，后玩大的方向遍历
  /// [all]: 为0时候，先向小，后向大,
  ///        为-1时候，先向大，后向小
  ///        为1时候，只向小，
  ///        为2时候，往大遍历
  static int? backOrForwardTraverse(int all, int current, int max, int? Function(int index) check) {
    int? fd;
    if (all == 0 || all == 1) {
      fd = queueBackTraverse(current, max, check);
    }
    if (fd == null) {
      if (all == 0 || all == -1 || all == 2) {
        fd = queueForwardTraverse(current, max, check);
      }
      if (fd == null) {
        if (all == -1) {
          fd = queueBackTraverse(current, max, check);
        }
      }
    }
    return fd;
  }

  static void debugTest() {
    // getAttachmentFilename(' attachment; filename="IMG_E1006.JPG"');
    // getAttachmentFilename(' attachment; filename="IMG_我哦E1006.JPG"');
    // getAttachmentFilename(' attachment; filename="IMG_E100的6.JPG"');
    // getAttachmentFilename(' attachment; filename="IMG_E1 e e006 .JPG"');

    // getAttachmentFilename(' attachment; filename="IMG_E1 e e006 .JPG"', onlyImg: false);
    // getAttachmentFilename(' attachment; filename="IMG_我哦E1006.zip"', onlyImg: false);
  }

  //   Directory appDir;
  // //临时目录，适用于下载的缓存文件，此目录随时可以清除，此目录为应用程序私有目录，其他应用程序无法访问此目录。
  // appDir = await getTemporaryDirectory

  // //获取应用程序的支持目录。这个函数返回一个Future<Directory>对象，表示应用程序的支持目录。
  // appDir= await  getApplicationSupportDirectory

  // //返回应用程序的库目录。这个目录通常用于存储应用程序的共享库或插件。
  // appDir = await  getLibraryDirectory

  // //应用程序的文档目录。文档目录是应用程序可以使用的持久性存储空间，通常用于存储用户生成的文件或其他数据。
  // appDir = await  getApplicationDocumentsDirectory

  // //应用程序可以访问顶级存储的目录的路径。由于此功能仅在Android上可用，因此应在发出此函数调用之前确定当前操作系统。
  // appDir = await  getExternalStorageDirectory

  // //存储特定于应用程序的外部缓存数据的目录的路径。
  // appDir = await  getExternalCacheDirectories

  // //存储下载文件的目录的路径，这通常仅与台式机操作系统有关。 在Android和iOS上，此函数将引发[UnsupportedError]异常。
  // appDir = await  getDownloadsDirectory
  // dart
  // 运行
}
