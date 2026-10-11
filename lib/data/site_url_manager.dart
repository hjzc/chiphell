import 'dart:convert';

import 'package:chiphell/modals/url_search_resoult.dart';
import 'package:chiphell/utils/zs_log.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'database_manager.dart';

class SiteUrlItem {
  static String columnHost = 'host';
  static String columnTitle = 'title';
  static String columnScheme = 'scheme';
  static String columnWeight = 'weight';
  static String columnUseCount = 'useCount';
  String? host;
  String? title;
  int scheme = 0; //https,1 http
  int weight = 0;
  int useCount = 0;

  SiteUrlItem.copy(SiteUrlItem other) : this.from(other.host, other.title, other.scheme, other.weight);

  Map<String, Object?> toMap() {
    var map = <String, Object?>{columnHost: host, columnTitle: title, columnScheme: scheme, columnWeight: weight, columnUseCount: useCount};
    return map;
  }

  SiteUrlItem.from(this.host, this.title, this.scheme, this.weight);
  SiteUrlItem();
  SiteUrlItem.fromMap(Map<String, Object?> map) {
    host = map[columnHost] as String?;
    title = map[columnTitle] as String?;
    scheme = map[columnScheme] as int;
    weight = map[columnWeight] as int;
    useCount = map[columnUseCount] as int;
  }

  bool isValid() {
    return host != null && host!.isNotEmpty;
  }

  String? _standName() {
    if (title == null || title?.isEmpty == true) {
      return null;
    }
    if (title!.length > 128) {
      return title?.substring(0, 128);
    }
    return title;
  }

  String toAddrssString() {
    String r = '';
    String? sname = _standName();
    if (host != null && host!.isNotEmpty) {
      String v = host!.contains("://") ? host!.substring(host!.indexOf('://') + 3) : host!;
      if (v.length > 128) {
        v = v.substring(0, 128);
      }
      if (sname != null) {
        r = "$sname - $v";
      } else {
        r = v;
      }
    } else {
      r = sname ?? "";
    }
    return r;
  }

  String url() {
    return "${scheme == 0 ? 'https://' : "http://"}$host";
  }

  static String schemeStr(int scheme) {
    return scheme == 0 ? 'https' : 'http';
  }

  static int schemeFromStr(String scheme) {
    return scheme == 'https' ? 0 : (scheme == 'http' ? 1 : -1);
  }
}

class SiteUrlManager {
  static Database? get database => DatabaseManager.db;
  static String get tableName => 'siteurls';

  static Future<void> importDataFromJson(Database db) async {
    int c = await count();
    if (c > 0) {
      return;
    }
    final String response = await rootBundle.loadString('assets/data/siteurls.json');
    final data = json.decode(response); // 解析JSON数据为Dart对象列表或Map列表

    await db.transaction((txn) async {
      for (var item in data) {
        final r = await txn.insert(
          tableName,
          item, // 这里item应该是一个包含字段和值的Map或对象。例如：{'name': 'John', 'value': 123}
          conflictAlgorithm: ConflictAlgorithm.replace, // 根据需要选择冲突解决策略，例如replace或abort等。
        );
        if (r > 0) {
          ZsLog.e('insert ok');
        } else {
          ZsLog.e('insert failed');
        }
      }
    });
    // await database?.transaction((txn) async {
    //   await txn.execute('DELETE FROM users'); // 清除旧数据（如果需要）
    //   await txn.rawInsert(
    //     'INSERT INTO users (name, email) VALUES ("Alice", "alice@example.com")',
    //   );
    //   await txn.rawInsert(
    //     'INSERT INTO users (name, email) VALUES ("Bob", "bob@example.com")',
    //   );
    //   // 添加更多用户数据...
    // });
  }

  static Future<bool> exist(String host) async {
    final rc = await DatabaseManager.db?.rawQuery('SELECT count(*) FROM $tableName where host = ?', [host]);
    if (rc == null || rc.isEmpty) {
      return false;
    }
    int? count = Sqflite.firstIntValue(rc);
    return count != null && count > 0;
  }

  static Future<bool> insert(SiteUrlItem item) async {
    if (!item.isValid()) {
      return false;
    }
    final count = await database?.rawInsert('INSERT INTO $tableName (host,title,scheme,weight,useCount) VALUES(?,?,?,?,?)', [
      item.host,
      item.title ?? '',
      item.scheme,
      item.weight,
      item.useCount,
    ]);
    return count != null && (count > 0);
  }

  static Future<SiteUrlItem?> getItem(String? host) async {
    if (host == null || host.isEmpty || database == null) {
      return null;
    }
    List<Map>? maps = await database?.rawQuery('SELECT * FROM $tableName WHERE host = ?', [host]);
    if (maps!.isNotEmpty) {
      return SiteUrlItem.fromMap(maps.first as Map<String, Object?>);
    }
    return null;
  }

  static Future<bool> autoInsert(Uri uri, String title) async {
    bool r = false;
    String vt = title.trim();
    if (vt.isNotEmpty) {
      String path = uri.path.toLowerCase();
      // String q = uri.query.toLowerCase();
      if ((path.isEmpty ||
          path == '/' ||
          path == 'index.html' ||
          path == '/index/' ||
          path == '/signin' ||
          path == '/index/index.html' ||
          path == 'index.htm')
      //&& (!uri.hasQuery || q == 'next=%2F')
      ) {
        String host = uri.host;
        int scheme = SiteUrlItem.schemeFromStr(uri.scheme);
        if ((scheme == 0 || scheme == 1) && !await exist(host)) {
          SiteUrlItem item = SiteUrlItem();
          item.host = host;
          item.title = vt;
          item.scheme = scheme;
          r = await insert(item);
          if (r) {
            ZsLog.d('----insert site:$host, title:$vt');
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

  static Future<bool> updateUseCount(String host) async {
    if (host.isEmpty) {
      return false;
    }
    int? count = await database?.rawUpdate('UPDATE $tableName SET useCount = useCount + 1 WHERE host = ?', [host]);
    return count != null && (count > 0);
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
        SELECT * FROM $tableName WHERE host like ? ORDER BY useCount DESC,weight DESC LIMIT ? OFFSET ?
        """;
    List<Map<String, Object?>>? list = await database?.rawQuery(sql, ['%$qstr%', limit, offsetCount]);
    List<UrlSearchResult> rets = [];
    if (list != null && list.isNotEmpty) {
      for (int i = 0; i < list.length; i++) {
        var item = list[i];
        var r = SiteUrlItem.fromMap(item);
        if (r.host != null && r.host!.isNotEmpty) {
          var rs = UrlSearchResult(
            name: r.title ?? (r.host ?? ""),
            subName: (r.title == null) ? null : r.host,
            value: r.url(),
            type: USRType.row,
            source: USRSourceType.db,
            other: null,
          );
          rets.add(rs);
        }
      }
    }
    return rets;
  }
}
