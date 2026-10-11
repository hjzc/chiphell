import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ZjCache {
  static void init() {
    CachedNetworkImage.logLevel = kDebugMode
        ? CacheManagerLogLevel.debug
        : CacheManagerLogLevel.none;
    CacheManager.logLevel = kDebugMode
        ? CacheManagerLogLevel.verbose
        : CacheManagerLogLevel.none;
  }
}
