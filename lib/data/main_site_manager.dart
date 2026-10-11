import 'dart:convert';
import 'package:chiphell/modals/url_search_resoult.dart';
import 'package:chiphell/sites/main_site.dart';
import 'package:chiphell/utils/zs_log.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'database_manager.dart';

class MainSiteManager {
  static Database? get database => DatabaseManager.db;
  static String get tableName => 'mainSites';
  //static late MainSite site;
  static Future<MainSite> initDataReady() async {
    MainSite? v = await getSelectedItem(true);
    v?.isDb = true;
    v ??= MainSite.fromMap({
      "combine": "2-chiphell.com-www.chiphell.com",
      "host": "www.chiphell.com",
      "title": "Chiphell",
      "source": 1,
      "scheme": 2,
      "selected": 1,
      "type": 1,
      "domain": "chiphell.com",
      "cookiepre": "v2x4_48dd_",
      "charset": "utf-8",
    });
    return v!;
  }

  static Future<void> importDataFromJson(Database db) async {
    int c = await count();
    if (c > 0) {
      return;
    }
    final String response = await rootBundle.loadString('assets/data/discuz.json');
    final List<dynamic> data = json.decode(response); // 解析JSON数据为Dart对象列表或Map列表
    await db.transaction((txn) async {
      for (var item in data) {
        item['udate'] = DateTime.now().millisecondsSinceEpoch;
        final r = await txn.insert(
          tableName,
          item, // 这里item应该是一个包含字段和值的Map或对象。例如：{'name': 'John', 'value': 123}
          conflictAlgorithm: ConflictAlgorithm.replace, // 根据需要选择冲突解决策略，例如replace或abort等。
        );
        if (r > 0) {
          ZsLog.e('insert discuz.json ok');
        } else {
          ZsLog.e('insert discuz.json failed');
        }
      }
    });
  }

  static Future<bool> exist({int? id, String? combine}) async {
    if ((id == null && combine == null) || database == null || (id != null && id <= 0) || (combine != null && combine.isEmpty)) {
      return false;
    }
    int? count;
    if (id! > 0) {
      List<Map<String, dynamic>>? rc = await database?.rawQuery('SELECT count(*) FROM $tableName where id = ?', [id]);
      if (rc == null || rc.isEmpty) {
        return false;
      }
      count = Sqflite.firstIntValue(rc);
    } else if (combine != null && combine.isNotEmpty) {
      List<Map<String, dynamic>>? rc = await database?.rawQuery('SELECT count(*) FROM $tableName where combine = ?', [combine]);
      if (rc == null || rc.isEmpty) {
        return false;
      }
      count = Sqflite.firstIntValue(rc);
    }
    return count != null && count > 0;
  }

  static Future<bool> insert(MainSite item) async {
    bool r = false;
    if (item.valid) {
      if (item.combine.length < 4) {
        item.combine = item.uuid;
      }
      final count = await database?.rawInsert(
        'INSERT INTO $tableName (combine,host,title,source,scheme,selected,type,domain,cookiepre,charset,udate) VALUES(?,?,?,?,?,?,?,?,?,?,?)',
        [
          item.combine,
          item.host,
          item.title,
          item.source,
          item.scheme,
          item.selected,
          item.type,
          item.domain,
          item.cookiepre,
          item.charset,
          item.udate,
        ],
      );
      r = count != null && (count > 0);
      if (r) {
        item.id = count;
        item.isDb = true;
      }
    }
    return r;
  }

  static Future<MainSite?> getItem(String? host, bool siteInfo, {List<String>? paths, int? schemeVal}) async {
    MainSite? r;
    if (host == null || host.isEmpty || database == null) {
      return r;
    }
    List<Map>? maps = [];
    if (schemeVal != null) {
      maps = await database?.rawQuery('SELECT * FROM $tableName WHERE scheme = ? and host = ?', [schemeVal, host]);
    } else {
      maps = await database?.rawQuery('SELECT * FROM $tableName WHERE host = ?', [host]);
    }
    if (maps == null || maps.isEmpty) {
      if (paths != null && paths.isNotEmpty) {
        for (int i = 0; i < paths.length; i++) {
          var sb = paths.sublist(0, i + 1);
          String nk = '$host/${sb.join('/')}';
          var c = await getItem(nk, siteInfo);
          if (c != null) {
            r = c;
            break;
          }
        }
        // var item = paths[0];
        // if (!item.contains('.')) {
        //   String v = '$host/$item';
        //   var c = await getItem(v, paths: paths.sublist(1));
        //   if (c != null) {
        //     r = c;
        //   }
        // }
      }
    } else {
      r = MainSite.fromMap(maps.first as Map<String, Object?>);
      if (r != null && siteInfo) {
        r.loadPageInfoFromDb();
      }
      r?.isDb = true;
    }
    return r;
  }

  static Future<MainSite?> getSelectedItem(bool siteInfo) async {
    MainSite? r;
    if (database != null) {
      List<Map<String, dynamic>>? maps = await database?.rawQuery('SELECT * FROM $tableName WHERE selected = ?', [1]);
      if (maps!.isNotEmpty) {
        r = MainSite.fromMap(maps.first as Map<String, Object?>);
        if (r != null) {
          await r.loadPageInfoFromDb();
        }
        r?.isDb = true;
      }
    }
    return r;
  }

  static Future<List<MainSite>> getAll({bool siteInfo = true, void Function(MainSite s, int index)? selectedFn}) async {
    List<MainSite> r = [];
    if (database != null) {
      List<Map<String, dynamic>>? list = await database?.rawQuery('SELECT * FROM $tableName ORDER BY id ASC');
      if (list!.isNotEmpty) {
        for (int i = 0; i < list.length; i++) {
          var item = list[i];
          var v = MainSite.fromMap(item);
          if (v != null) {
            v.isDb = true;
            if (v.isSelected) {
              if (selectedFn != null) {
                selectedFn(v, i);
              }
            }
            if (siteInfo) {
              await v.loadPageInfoFromDb();
            }
            r.add(v);
          }
        }
      }
    }
    return r;
  }

  static Future<List<MainSite>> getSameDomainItems(
    String domain,
    int scheme, {
    bool siteInfo = true,
    bool Function(MainSite s, int index)? filterFn,
  }) async {
    List<MainSite> r = [];
    if (database != null && (domain.length > 2)) {
      //SELECT * FROM mainsite where domain = 'chiphell.com' and scheme ='0' ORDER BY id ASC
      List<Map<String, dynamic>>? list = await database?.rawQuery(
        'SELECT * FROM $tableName where domain = ? and scheme = ? ORDER BY id ASC',
        [domain, scheme],
      );
      if (list!.isNotEmpty) {
        for (int i = 0; i < list.length; i++) {
          var item = list[i];
          var v = MainSite.fromMap(item);
          if (v != null && filterFn != null && false == filterFn(v, i)) {
            v.isDb = true;
            if (siteInfo) {
              await v.loadPageInfoFromDb();
            }
            r.add(v);
          }
        }
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

  static Future<bool> updateHost(int id, Map<String, dynamic> vals) async {
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
    //UPDATE mainSites SET  charset = ?, udate = ? WHERE id = ?
    // 'UPDATE $tableName SET title = ?, source = ?, scheme = ?, domain = ?, cookiepre = ? WHERE host/id = ?'
    int? count = await database?.rawUpdate(sql, args);
    return count != null && (count > 0);
  }

  static Future<bool> deleteSite({int? id}) async {
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

  static Future<bool> selecteSite(MainSite oldSite, MainSite newSite) async {
    bool r = false;
    if (oldSite.isDb != true || newSite.isDb != true || database == null || oldSite.id <= 0 || newSite.id <= 0) {
      return r;
    }
    int? count = await database?.rawUpdate('UPDATE $tableName SET selected = ? WHERE id = ?', [1, newSite.id]);
    if (count != null && count > 0) {
      int? oldcount = await database?.rawUpdate('UPDATE $tableName SET selected = ? WHERE id = ?', [0, oldSite.id]);
      if (oldcount != null && oldcount > 0) {
        oldSite.isDb = true;
        newSite.isDb = true;
        newSite.setSelected();
        oldSite.unSelecte();
        r = true;
      } else {
        await database?.rawUpdate('UPDATE $tableName SET selected = ? WHERE id = ?', [0, newSite.id]);
      }
    }
    return r;
  }

  ///windows 异常: like "%$qstr%" 需要改成 like '%$qstr%'
  /// String sql =
  ///     """
  ///     SELECT * FROM siteurls where host like "%$qstr%" ORDER BY useCount DESC,weight DESC LIMIT $limit OFFSET $offsetCount
  ///     """;
  ///  list = await database?.rawQuery(sql);
  static Future<List<UrlSearchResult>> queryUrlListFromKey(String urlKey, {int pageSize = 3, int pageIndex = 1, int offset = -1}) async {
    String qstr = urlKey.toLowerCase().trim();
    if (qstr.isEmpty) {
      return [];
    }
    int limit = pageSize > 0 ? pageSize : 1000;
    int offsetCount = offset > 0 ? offset : (((pageIndex < 1 ? 1 : pageIndex) - 1) * limit);

    String sql =
        """
        SELECT * FROM $tableName WHERE host like ? LIMIT ? OFFSET ?
        """;
    List<Map<String, Object?>>? list = await database?.rawQuery(sql, ['%$qstr%', limit, offsetCount]);
    List<UrlSearchResult> rets = [];
    if (list != null && list.isNotEmpty) {
      for (int i = 0; i < list.length; i++) {
        var item = list[i];
        var r = MainSite.fromMap(item);
        if (r != null && r.host.isNotEmpty) {
          r.isDb = true;
          var rs = UrlSearchResult(name: r.title, subName: r.host, value: r.url, type: USRType.row, source: USRSourceType.db, other: null);
          rets.add(rs);
        }
      }
    }
    return rets;
  }
}
