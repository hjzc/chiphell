import 'dart:async';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

// import 'package:file/file.dart' hide FileSystem;
// import 'package:file/local.dart';
// import 'package:flutter_cache_manager/src/storage/file_system/file_system.dart';
// import 'package:path/path.dart' as p;
// import 'package:path_provider/path_provider.dart';

/// 缓存管理
// CachedNetworkImage(
//     imageUrl: url,
//     fit: BoxFit.cover,
//     cacheManager: ZjImageCacheManager()
// )
//key目录：
//macos   /Users/cjxy/Library/Containers/com.zorro.chiphell/Data/Library/Caches/zjImageCacheKey
//windows C:\Users\Zorro\AppData\Roaming\com.example\chiphell\zjImageCacheKey.json
//iphone:  /Users/cjxy/Library/Developer/CoreSimulator/Devices/28D0FF14-E388-49F7-A682-78D6999DB693/data/Containers/Data/Application/7BA1CDE1-6A5D-4E06-923A-0A22A9C73710/Library/Caches/zjImageCacheKey
//图片cache目录
//windows :C:\Users\Zorro\AppData\Local\Temp\zjImageCacheKey
//cache path getApplicationSupportDirectory()
// class ZjImageCacheManager {
//   static const key = 'zjImageCacheKey';
//   static CacheManager instance = CacheManager(
//     Config(
//       key,
//       stalePeriod: const Duration(days: 7),
//       maxNrOfCacheObjects: 20,
//       repo: JsonCacheInfoRepository(databaseName: key),
//       fileSystem: IOFileSystem(key),
//       fileService: ZjHttpFileService(), // HttpFileService(),
//     ),
//   );
// }

// class ZJIOFileSystem implements FileSystem {
//   final Future<Directory> _fileDir;
//   final String _cacheKey;

//   ZJIOFileSystem(this._cacheKey) : _fileDir = createDirectory(_cacheKey);

//   static Future<Directory> createDirectory(String key) async {
//     final baseDir = await getTemporaryDirectory();
//     final path = p.join(baseDir.path, key);

//     const fs = LocalFileSystem();
//     final directory = fs.directory(path);
//     await directory.create(recursive: true);
//     return directory;
//   }

//   @override
//   Future<File> createFile(String name) async {
//     final directory = await _fileDir;
//     if (!(await directory.exists())) {
//       await createDirectory(_cacheKey);
//     }
//     return directory.childFile(name);
//   }
// }

class ZjImageCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'zjImageCacheKey';
  static final ZjImageCacheManager _instance = ZjImageCacheManager._();

  factory ZjImageCacheManager() {
    return _instance;
  }

  ZjImageCacheManager._()
    : super(
        Config(
          key,
          stalePeriod: const Duration(days: 7),
          maxNrOfCacheObjects: 20,
          repo: JsonCacheInfoRepository(databaseName: key),
          fileSystem: IOFileSystem(key),
          fileService: ZjHttpFileService(), //
        ),
      );

  void delCache() {
    ZjImageCacheManager().emptyCache();
  }
}

//解决https 证书问题
class ZjHttpFileService extends FileService {
  HttpClient? _httpClient;
  ZjHttpFileService({HttpClient? httpClient}) {
    _httpClient = httpClient ?? HttpClient();
    _httpClient?.badCertificateCallback = (cert, host, port) => true;
  }

  @override
  Future<FileServiceResponse> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    final Uri resolved = Uri.base.resolve(url);
    final HttpClientRequest? req = await _httpClient?.getUrl(resolved);
    if (headers != null) {
      headers.forEach((key, value) {
        req?.headers.add(key, value);
      });
    }

    final HttpClientResponse httpResponse = await req!.close();
    final http.StreamedResponse response = http.StreamedResponse(
      httpResponse.timeout(Duration(seconds: 60)),
      httpResponse.statusCode,
      contentLength: httpResponse.contentLength,
      reasonPhrase: httpResponse.reasonPhrase,
      isRedirect: httpResponse.isRedirect,
    );
    return HttpGetResponse(response);
  }
}
// }
// class HttpFileService extends FileService {
//   final http.Client _httpClient;

//   HttpFileService({http.Client? httpClient})
//       : _httpClient = httpClient ?? http.Client();

//   @override
//   Future<FileServiceResponse> get(String url,
//       {Map<String, String>? headers}) async {

//     final req = http.Request('GET', Uri.parse(url));
//     if (headers != null) {
//       req.headers.addAll(headers);
//     }
//     final httpResponse = await _httpClient.send(req);

//     return HttpGetResponse(httpResponse);

//   }
// }
