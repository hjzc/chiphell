import 'package:chiphell/utils/zs_log.dart';

class ZjMemoryCache {
  final Map<String, dynamic> _kvCaches = {};
  final List<String> _keys = [];
  final List<String> _errorKeys = [];
  final List<String> _loadingKeys = [];
  final int maxCache;
  final int maxCacheErrorKey;

  ZjMemoryCache({required this.maxCache, required this.maxCacheErrorKey});

  Future<dynamic> load(String key, Future<dynamic> Function(dynamic param) loading, {dynamic param, bool used = false}) async {
    dynamic r;
    r = null;

    try {
      if (_kvCaches.containsKey(key)) {
        if (used) {
          r = _kvCaches[key];
          if (_keys.contains(key) && (_keys.last != key)) {
            _keys.remove(key);
            _keys.add(key);
          }
        } else {
          ///返回值不需要，不处理
        }
        _removeErrorKey(key);
      } else if (_errorKeys.contains(key)) {
      } else {
        if (!_loadingKeys.contains(key)) {
          _loadingKeys.add(key);
          try {
            r = await loading.call(param);
          } catch (e) {
            // _errorKeys.add(key);
            // if (_errorKeys.length > maxCacheErrorKey) {
            //   _errorKeys.removeAt(0);
            // }
            ZsLog.e('ZjMemoryCache loading key[$key] error', error: e);
          }
          _loadingKeys.remove(key);
          if (r != null) {
            _kvCaches[key] = r;
            _keys.add(key);
            if (_keys.length >= maxCache) {
              _kvCaches.remove(_keys.first);
              _keys.removeAt(0);
            }
            _removeErrorKey(key);
          } else {
            _addErrorKey(key);
          }
        }
      }
    } catch (e) {
      r = null;
      ZsLog.e('ZjMemoryCache loading key[$key] failed!', error: e);
    }
    return r;
  }

  void _addErrorKey(String key) {
    if (_errorKeys.contains(key) == false) {
      _errorKeys.add(key);
      if (_errorKeys.length > maxCacheErrorKey) {
        _errorKeys.removeAt(0);
      }
    }
  }

  void _removeErrorKey(String key) {
    if (_errorKeys.contains(key)) {
      _errorKeys.remove(key);
    }
  }

  dynamic get(String key) {
    dynamic r;
    r = null;
    if (_kvCaches.containsKey(key)) {
      r = _kvCaches[key];
      if (_keys.contains(key) && (_keys.last != key)) {
        _keys.remove(key);
        _keys.add(key);
      }
      _removeErrorKey(key);
    }
    return r;
  }

  void cleanErrorKeys() {
    _errorKeys.clear();
  }

  void clean() {
    _errorKeys.clear();
    _keys.clear();
    _kvCaches.clear();
  }
}
