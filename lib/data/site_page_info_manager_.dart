import 'package:chiphell/utils/zs_log.dart';
import 'package:sqflite/sqflite.dart';
import '../sites/site_page_info.dart';
import 'database_manager.dart';

class SitePageInfoManager {
  static Database? get database => DatabaseManager.db;
  static String get tableName => 'sitePageinfo';

  static Future<bool> exist({int? id, String? combine}) async {
    bool r = false;

    if (database == null) {
      return r;
    }
    List<dynamic> args = [];
    String sql = 'SELECT count(*) FROM $tableName where ';
    if (id != null && id > 0) {
      sql = '$sql id = ?';
      args.add(id);
    }
    if (combine != null && combine.length > 3) {
      if (args.isNotEmpty) {
        sql = '$sql , combine = ?';
      } else {
        sql = '$sql combine = ?';
      }
      args.add(combine);
    }
    if (args.isNotEmpty) {
      List<Map<String, dynamic>>? rc = await database?.rawQuery(sql, args);
      if (rc != null && rc.isNotEmpty) {
        var count = Sqflite.firstIntValue(rc);
        r = count != null && count > 0;
      }
    }
    return r;
  }

  static Future<bool> insert(SitePageInfo item) async {
    bool r = false;
    if (item.valid) {
      final count = await database?.rawInsert(
        'INSERT INTO $tableName (combine,space,loging,thread,article,forum,category,udate,last,info) VALUES(?,?,?,?,?,?,?,?,?,?)',
        [item.combine, item.space, item.loging, item.thread, item.article, item.forum, item.category, item.udate, item.lastUrl, item.info],
      );
      r = count != null && (count > 0);
      if (r) {
        item.id = count;
      }
    }
    return r;
  }

  static Future<SitePageInfo?> getItem({int? id, String? combine}) async {
    SitePageInfo? r;
    if (database == null) {
      return null;
    }
    List<dynamic> args = [];
    String sql = 'SELECT * FROM $tableName where ';
    if (id != null && id > 0) {
      sql = '$sql id = ?';
      args.add(id);
    }
    if (combine != null && combine.length > 3) {
      if (args.isNotEmpty) {
        sql = '$sql , combine = ?';
      } else {
        sql = '$sql combine = ?';
      }
      args.add(combine);
    }
    if (args.isNotEmpty) {
      List<Map<String, dynamic>>? rc = await database?.rawQuery(sql, args);
      if (rc != null && rc.isNotEmpty) {
        r = SitePageInfo.fromMap(rc.first);
      }
    }
    return r;
  }

  static Future<int> count() async {
    var sql = 'SELECT count(*) FROM $tableName';
    final rc = await database?.rawQuery(sql);
    if (rc == null || rc.isEmpty) {
      return 0;
    }
    int? count = Sqflite.firstIntValue(rc);
    return count ?? 0;
  }

  static Future<bool> updateSiteInfoId(int id, Map<String, dynamic> vals) async {
    if (id <= 0 || vals.isEmpty || database == null) {
      return false;
    }
    List<dynamic> args = [];
    String setStr = '';
    vals.forEach((String key, dynamic val) {
      if (setStr.isNotEmpty) {
        setStr = '$setStr,';
      }
      setStr = "$setStr $key = ?";
      args.add(val);
    });
    String sql = "UPDATE $tableName SET $setStr WHERE id = ? ";
    args.add(id);
    int? count = await database?.rawUpdate(sql, args);
    return count != null && (count > 0);
  }

  static Future<bool> deleteSiteInfo({int? id}) async {
    if (id == null || id <= 0 || database == null) {
      return false;
    }
    final count = await database?.rawDelete('DELETE FROM $tableName WHERE id = ?', [id]);
    if (count == null || count == 0) {
      ZsLog.d("Cannot delete id: $id");
      return true;
    }
    return count > 0;
  }
}
