import 'package:chiphell/multi_windows/window_util.dart';
import 'package:chiphell/utils/utils.dart';

import '../utils/zs_log.dart';
import 'database_manager.dart';
import 'package:sqflite/sqflite.dart';
import '../web/web_constants.dart';

class BlackList {
  static List<String> userBlackList = [];
  static bool userBlackListChanged = false;
  static String filterChar = ",";
  static String filterCharRep = "_";

  Database? database = DatabaseManager.db;

  static Future<void> initLoad() async {
    BlackList.userBlackList = await BlackList.queryBlacklist();
  }

  static String correctName(String name) {
    String r = name;
    if (r.contains(BlackList.filterChar)) {
      r = r.replaceAll(BlackList.filterChar, BlackList.filterCharRep);
    }
    return r;
  }

  static int count() {
    return BlackList.userBlackList.length;
  }

  static String exportBlackList() {
    return BlackList.userBlackList.join(filterChar);
  }

  // static Future<int> importBlackListFromCSV(String content) async {
  //   int r = 0;
  //   List<String> rs = content.split(',');
  //   for (int i = 0; i < rs.length; i++) {
  //     String t = rs[i];
  //     if (!BlackList.userBlackList.contains(t)) {
  //       if (await apiInsertToBlacklist(t)) {
  //         r++;
  //       }
  //     }
  //   }
  //   return r;
  // }

  static Future<int> importBlackListFromCSVArray(List<String> items) async {
    int r = 0;
    List<String> rs = items;
    for (int i = 0; i < rs.length; i++) {
      String t = rs[i];
      if (!BlackList.userBlackList.contains(t)) {
        if (await apiInsertToBlacklist(t)) {
          r++;
        }
      }
    }
    return r;
  }

  static Future<void> cleanAllBlockList() async {}

  static Future<bool> isExistBlacklist(String? name) async {
    if (name == null || name.isEmpty) {
      return false;
    }
    final dbname = await DatabaseManager.db?.rawQuery('SELECT * FROM blacklist WHERE id = ?', [name]);
    return (dbname != null && dbname.isNotEmpty);
  }

  static Future<bool> insertToBlacklist(String? name) async {
    if (name == null || name.isEmpty) {
      return false;
    }

    // if (await AppState.isExistBlacklist(name)) {
    //   return true;
    // }

    DateTime updatedTime = DateTime.now();
    final count = await DatabaseManager.db?.rawInsert('INSERT INTO blacklist(id,ctime) VALUES(?,?)', [name, updatedTime.toIso8601String()]);

    if (count == null || count == 0) {
      ZsLog.d("Cannot insert/update blacklist: $name");
      return false;
    }
    return count > 0;
  }

  static Future<bool> removeBlacknameFromDb(String? name) async {
    if (name == null || name.isEmpty) {
      return false;
    }
    final count = await DatabaseManager.db?.rawDelete('DELETE FROM blacklist WHERE id = ?', [name]);
    if (count == null || count == 0) {
      ZsLog.d("Cannot delete blacklist: $name");
      return false;
    }
    return count > 0;
  }

  static Future<bool> removeAllBlacknameFromDb() async {
    if (userBlackList.isEmpty) {
      return false;
    }
    await DatabaseManager.db?.rawDelete('DELETE FROM blacklist');
    return true;
  }

  static Future<List<String>> queryBlacklist() async {
    List<Map<String, Object?>>? list = await DatabaseManager.db?.rawQuery('SELECT id FROM blacklist');
    List<String> rets = [];
    for (var i in list!) {
      var name = i.values.first;
      if (name != null) {
        rets.add(name as String);
      }
    }
    return rets;
  }

  //-----------------api-----------------
  static Future<int> apiAddBlacklist(String? name) async {
    if (name == null || name.isEmpty) {
      return -1;
    }
    bool ex = await BlackList.isExistBlacklist(name);
    if (ex) {
      return 0;
    }
    return await apiAddOrDelBlacklist(name, false);
  }

  static Future<int> apiAddOrDelBlacklist(String? name, bool isExist) async {
    int r = -1;
    if (name == null || name.isEmpty) {
    } else if (isExist) {
      if (await BlackList.removeBlacknameFromDb(name)) {
        BlackList.userBlackList.remove(name);
        // await _webJsUpdateBlackList(name, false);
        ZsLog.d('取消过滤成功:$name');
        r = 1;
      } else {
        r = 0;
        ZsLog.d('取消过滤失败:$name');
      }
    } else {
      if (await BlackList.insertToBlacklist(name)) {
        BlackList.userBlackList.add(name);
        r = 2;
        // await _webJsUpdateBlackList(name, true);
        ZsLog.d('添加过滤成功:$name');
      } else {
        ZsLog.d('添加过滤失败:$name');
        r = 0;
      }
      if (Utils.isDesktopSystem && (r == 1 && r == 2)) {
        synBlacklistChangedState(r == 1 ? 0 : 1, name);
      }
    }
    return r;
  }

  static Future<bool> apiInsertToBlacklist(String? name) async {
    bool r = false;
    if ((name != null) && await BlackList.insertToBlacklist(name)) {
      BlackList.userBlackList.add(name);
      BlackList.userBlackListChanged = true;
      if (Utils.isDesktopSystem) {
        synBlacklistChangedState(1, name);
      }
      r = true;
    }
    return r;
  }

  static Future<bool> apiRemoveBlacknameFromDb(int idx) async {
    bool r = false;
    var name = (idx < 0 || idx >= userBlackList.length) ? null : BlackList.userBlackList[idx];
    if ((name != null) && await BlackList.removeBlacknameFromDb(name)) {
      BlackList.userBlackList.removeAt(idx);
      BlackList.userBlackListChanged = true;
      if (Utils.isDesktopSystem) {
        synBlacklistChangedState(0, name);
      }
      r = true;
    }
    return r;
  }

  static Future<bool> apiRemoveAllBlacknameFromDb() async {
    bool r = false;
    if (await BlackList.removeAllBlacknameFromDb()) {
      BlackList.userBlackList.clear();
      BlackList.userBlackListChanged = true;
      if (Utils.isDesktopSystem) {
        synBlacklistChangedState(-1, '');
      }
      r = true;
    }
    return r;
  }

  //type : 0 del,1 add, -1 remove all,
  static Future<void> synBlacklistChangedState(int type, String name) async {
    if (Utils.isDesktopSystem) {
      WindowUtil().winInfo.synWindowEventValue([WebConstants.kWinSubEventBlackList, type, name]);
    }
  }

  static Future<void> synBlacklistChangedStateHandle(int type, String name) async {
    if (type == 0) {
      //del
      if (userBlackList.contains(name)) {
        userBlackList.remove(name);
        BlackList.userBlackListChanged = true;
      }
    } else if (type == 1) {
      //add
      if (!userBlackList.contains(name)) {
        userBlackList.add(name);
        BlackList.userBlackListChanged = true;
      }
    } else if (type == -1) {
      //remove all
      userBlackList.clear();
      BlackList.userBlackListChanged = true;
    } else {}
  }
}
