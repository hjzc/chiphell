import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static SharedPreferencesAsync get p => SharedPreferencesAsync();

  static Future<bool> containsKey(String key) async {
    return await p.containsKey(key);
  }

  static Future<void> remove(String key) async {
    await p.remove(key);
  }

  static Future<int?> getInt(String key) async {
    return await p.getInt(key);
  }

  static Future<int> getIntOrDefault(String key, {int value = -1}) async {
    return await p.getInt(key) ?? value;
  }

  static Future<void> setInt(String key, int? value) async {
    if (value == null) {
      if (await p.containsKey(key)) {
        await p.remove(key);
      }
    } else {
      await p.setInt(key, value);
    }
  }

  static Future<double?> getDouble(String key) async {
    return await p.getDouble(key);
  }

  static Future<double> getDoubleOrDefault(String key, {double value = -1}) async {
    return await p.getDouble(key) ?? value;
  }

  static Future<void> setDouble(String key, double? value) async {
    if (value == null) {
      if (await p.containsKey(key)) {
        await p.remove(key);
      }
    } else {
      await p.setDouble(key, value);
    }
  }

  static Future<bool?> getBool(String key) async {
    return await p.getBool(key);
  }

  static Future<bool> getBoolOrDefault(String key, {bool value = false}) async {
    return await p.getBool(key) ?? value;
  }

  static Future<bool?> getBoolValue(String key, {bool? value}) async {
    return await p.getBool(key) ?? value;
  }

  static Future<void> setBool(String key, bool? value) async {
    if (value == null) {
      if (await p.containsKey(key)) {
        await p.remove(key);
      }
    } else {
      await p.setBool(key, value);
    }
  }

  static Future<String?> getString(String key) async {
    return await p.getString(key);
  }

  static Future<String> getStringOrDefault(String key, {String value = ''}) async {
    return await p.getString(key) ?? value;
  }

  static Future<void> setString(String key, String? value) async {
    if (value == null) {
      if (await p.containsKey(key)) {
        await p.remove(key);
      }
    } else {
      await p.setString(key, value);
    }
  }
}
