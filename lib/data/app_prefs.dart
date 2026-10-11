import 'package:chiphell/utils/utils.dart';
import 'package:chiphell/multi_windows/window_util.dart';

import '../web/web_constants.dart';
import 'prefs.dart';

enum APType { AT_Bool, AT_Int, AT_String, AT_Double }

class AppPrefs {
  AppPrefs();

  //子窗口 不保存数据
  static bool isNotSave() {
    return (Utils.isDesktopSystem && !WindowUtil().winInfo.isMainWindow());
  }

  static Future<int?> loadThemeModeToPref() async {
    return await Prefs.getInt(WebConstants.kPrefThemeMode);
  }

  static Future<void> saveThemeModeToPref(int value) async {
    if (isNotSave()) {
      return;
    }
    await Prefs.setInt(WebConstants.kPrefThemeMode, value);
  }

  //upgrade
  static Future<bool> loadAutoUpgradeFromPrefs() async {
    return await Prefs.getBoolOrDefault(WebConstants.kPrefAutoUpgrade, value: false);
  }

  static Future<void> saveAutoUpgradeToPrefs(bool value) async {
    if (isNotSave()) {
      return;
    }
    await Prefs.setBool(WebConstants.kPrefAutoUpgrade, value);
  }

  //image mode
  static Future<int> loadWebImgModeFromPrefs() async {
    return await Prefs.getIntOrDefault(WebConstants.kPrefWebImgMode, value: 0);
  }

  static Future<void> saveWebImgModeToPrefs(int value) async {
    if (isNotSave()) {
      return;
    }
    await Prefs.setInt(WebConstants.kPrefWebImgMode, value);
  }

  //web last url
  static Future<String> loadLastUrlFromPref() async {
    return await Prefs.getStringOrDefault(WebConstants.kPrefLastUrl);
  }

  static Future<void> saveLastUrlToPref(String url) async {
    if (isNotSave()) {
      return;
    }
    if (url.isEmpty) {
      await Prefs.remove(WebConstants.kPrefLastUrl);
    } else {
      await Prefs.setString(WebConstants.kPrefLastUrl, url);
    }
  }

  //web view user agent
  static Future<int> loadUATypeFromPref() async {
    return await Prefs.getIntOrDefault(WebConstants.kPrefUAKey, value: 0);
  }

  static Future<void> saveUATypeToPref(int index) async {
    if (isNotSave()) {
      return;
    }
    await Prefs.setInt(WebConstants.kPrefUAKey, index);
  }

  //web size
  static Future<int?> loadTextZoomFromPref() async {
    return await Prefs.getInt(WebConstants.kPrefWebTextZoom);
  }

  static Future<void> saveTextZoomToPref(int textZoom) async {
    if (isNotSave()) {
      return;
    }
    await Prefs.setInt(WebConstants.kPrefWebTextZoom, textZoom);
  }

  //web page
  static Future<double?> loadWebPageFromPref() async {
    return await Prefs.getDouble(WebConstants.kPrefWebPageZoom);
  }

  static Future<void> savePageZoomToPref(double pageZoom) async {
    if (isNotSave()) {
      return;
    }
    await Prefs.setDouble(WebConstants.kPrefWebPageZoom, pageZoom);
  }

  //autoImage gallery
  static Future<bool> loadAutoImageGalleryFromPrefs() async {
    return await Prefs.getBoolOrDefault(WebConstants.kPrefAutoImageGallery, value: true);
  }

  static Future<void> saveAutoImageGalleryToPrefs(bool value) async {
    if (isNotSave()) {
      return;
    }
    await Prefs.setBool(WebConstants.kPrefAutoImageGallery, value);
  }

  static Future<bool?> loadBoolValueFromPrefs(String key, bool? value) async {
    return await Prefs.getBoolValue(key, value: value);
  }

  static Future<dynamic> loadValueFromPrefs(String key, {APType type = APType.AT_Bool, dynamic value}) async {
    if (type == APType.AT_Int) {
      return await Prefs.getIntOrDefault(key, value: value);
    } else if (type == APType.AT_String) {
      return await Prefs.getStringOrDefault(key, value: value);
    } else if (type == APType.AT_Double) {
      return await Prefs.getDoubleOrDefault(key, value: value);
    }
    return await Prefs.getBoolOrDefault(key, value: value);
  }

  static Future<void> saveValueToPrefs(String key, {APType type = APType.AT_Bool, dynamic value}) async {
    if (isNotSave()) {
      return;
    }
    if (type == APType.AT_Int) {
      return await Prefs.setInt(key, value);
    } else if (type == APType.AT_String) {
      return await Prefs.setString(key, value);
    } else if (type == APType.AT_Double) {
      return await Prefs.setDouble(key, value);
    }
    return await Prefs.setBool(key, value);
  }

  static Future<bool> containsKey(String key) async {
    return await Prefs.containsKey(key);
  }

  static Future<void> remove(String key) async {
    await Prefs.remove(key);
  }
}
