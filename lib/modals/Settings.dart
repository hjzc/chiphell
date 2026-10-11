import 'package:chiphell/modals/zj_Image_cacheManager.dart';
import 'package:chiphell/utils/utils.dart';
import 'package:chiphell/utils/zs_log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../common/zj_status.dart';

typedef SettingCallback = void Function(BuildContext context, SetItem item);

class SetItem {
  IconData? leading;
  String? title;
  String? content;

  List<String>? popMenus;
  int selectedPopMenuIndex;

  bool isShowSwitch = false;
  bool switchValue = false;
  bool switchUIValue = false;
  bool isShowArrow = false;

  SettingCallback? callback;

  SetItem({
    this.leading,
    this.title,
    this.content,
    this.popMenus,
    this.selectedPopMenuIndex = 0,
    this.isShowSwitch = false,
    this.switchValue = false,
    this.isShowArrow = false,
    this.callback,
  });

  void eninit() {
    switchUIValue = switchValue;
  }

  void onChanged(bool value) {
    switchUIValue = value;
  }

  Map<String, dynamic>? resutl() {
    Map<String, dynamic>? ret;
    if (isShowSwitch && (switchUIValue != switchValue)) {
      ret = {};
      ret['switch'] = true;
      ret['new'] = switchUIValue;
    }
    return ret;
  }
}

class Settings {
  static List<ZjCleanCache> cleanCacheDesList() {
    return [ZjCleanCache.base, ZjCleanCache.all];
  }

  static Future<void> cleanCache(ZjCleanCache val) async {
    // if (Utils.isDesktopSystem  || Utils.isLinux()) {
    //   await WindowUtil.cleanCache();
    // }
    await ZjImageCacheManager().emptyCache();
    if (!kIsWeb) {
      if (defaultTargetPlatform == TargetPlatform.windows) {
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        WebStorageManager webStorageManager = WebStorageManager.instance();
        await webStorageManager.deleteAllData();
      } else if (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux) {
        WebStorageManager webStorageManager = WebStorageManager.instance();

        final dtc = WebsiteDataType.WKWebsiteDataTypeCookies;
        var records = await webStorageManager.fetchDataRecords(dataTypes: WebsiteDataType.values);
        Set<WebsiteDataType> values = Set.from(WebsiteDataType.ALL); //WebsiteDataType.ALL;
        if (val == ZjCleanCache.base && values.contains(dtc)) {
          values.remove(dtc);
        }
        // var recordsToDelete = <WebsiteDataRecord>[];
        // for (var record in records) {
        //   if (record.displayName == null || !record.displayName!.contains('chiphell.com'))
        //   {
        //     recordsToDelete.add(record);
        //   }
        // }
        if (!kDebugMode) {
          await webStorageManager.removeDataFor(dataTypes: values, dataRecords: records);
          await webStorageManager.removeDataModifiedSince(dataTypes: values, date: DateTime(2000));
        }

        if (val == ZjCleanCache.all) {
          cleanCompressImages();
        }

        ZsLog.i('clean cache finish');
      }
    }
  }

  static Future<void> cleanCompressImages() async {
    try {
      String folder = await Utils.getUserCompressImagesFolder();
      await Utils.deleteFilesInDir(folder);
    } catch (e) {
      ZsLog.i('clean compress images cache error');
    }
  }

  static List<SetItem> mainSettingDataSources() {
    List<SetItem> list = [];
    list.add(SetItem(leading: Icons.storage, title: "清除缓存", isShowArrow: true)..eninit());
    list.add(SetItem(leading: Icons.storage, title: "外观", content: "系统", isShowArrow: true)..eninit());
    list.add(
      SetItem(leading: Icons.storage, title: "清除缓存", content: "飞速前进", isShowSwitch: true, switchValue: true, isShowArrow: true)..eninit(),
    );

    return list;
  }
}
