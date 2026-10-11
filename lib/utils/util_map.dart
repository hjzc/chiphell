import 'dart:convert';

class UtilMap {
  static Map<String, dynamic> safeConvertSDMap(dynamic ableMap) {
    Map<String, dynamic> r = {};
    if (ableMap is Map<String, dynamic>) {
      r = ableMap;
    } else if (ableMap != null && (ableMap is Map)) {
      ableMap.forEach((k, v) {
        r[k.toString()] = v;
      });
    }
    return r;
  }

  static dynamic safeValueForStringKey(dynamic ableMap, String key) {
    dynamic r;
    if (ableMap != null && (ableMap is Map)) {
      for (var entry in ableMap.entries) {
        final k = entry.key;
        if (k == key) {
          r = entry.value;
          break;
        }
      }
      // ableMap.forEach((k, v) {
      //   if (k is String) {
      //     if (k == key) {
      //       r = v;
      //       hasv = true;
      //     }
      //   }
      // });
    }
    return r;
  }

  static bool safeBoolForKey(dynamic ableMap, String key, {bool defaultValue = false}) {
    dynamic r = safeValueForStringKey(ableMap, key);
    if (r is bool) {
      return r;
    } else {
      return defaultValue;
    }
  }

  static int safeIntForKey(dynamic ableMap, String key, {int defaultValue = -9999, bool forceParse = false}) {
    dynamic r = safeValueForStringKey(ableMap, key);
    if (r is int) {
      return r;
    } else if (r is String) {
      int v = defaultValue;
      if (forceParse) {
        try {
          v = int.parse(r);
        } catch (_) {}
      }
      return v;
    } else {
      return defaultValue;
    }
  }

  static String? safeStringForKey(dynamic ableMap, String key) {
    dynamic r = safeValueForStringKey(ableMap, key);
    if (r is String) {
      return r;
    } else {
      return null;
    }
  }

  static Map? safeMapForKey(dynamic ableMap, String key) {
    var r = safeValueForStringKey(ableMap, key);
    if (r is Map) {
      return r;
    } else {
      return null;
    }
  }

  static bool safeRemoveForKey(dynamic ableMap, String key) {
    bool r = false;
    if (ableMap != null && (ableMap is Map)) {
      if (ableMap.containsKey(key)) {
        ableMap.remove(key);
        r = true;
      }
    }
    return r;
  }

  static Map<String, dynamic> mapKVFromJsonString(String jsonStr) {
    Map<String, dynamic> info = {};
    if (jsonStr.isNotEmpty) {
      try {
        var val = jsonDecode(jsonStr);
        if (val is Map) {
          info = UtilMap.safeConvertSDMap(val);
        }
      } catch (_) {}
    }
    return info;
  }

  static String? jsonStringFromMapKV(Map<String, dynamic> kv) {
    String? rs;
    try {
      rs = jsonEncode(kv);
    } catch (_) {}
    return rs;
  }
}
