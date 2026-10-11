import 'package:chiphell/data/database_manager.dart';
import 'package:chiphell/multi_windows/window_util.dart';
import 'package:chiphell/utils/utils.dart';
import 'package:sqflite/sqflite.dart';
import '../modals/url_search_resoult.dart';
import '../utils/zs_log.dart';
import '../web/web_constants.dart';

class Favor {
  //final String tableTodo = 'favorites';
  final String columnUrl = 'url';
  final String columnTitle = 'title';
  final String columnCtime = 'ctime';
  final String columnUtime = 'utime';
  final String columnFavor = 'favor';
  final String columnFtime = 'ftime'; //favor time
  final String columnDel = 'del';
  final String columnViews = 'views';

  String? url;
  String? title;
  String? ctime; //DateTime.now().toIso8601String()
  int utime = 0;
  int favor = 0;
  int ftime = 0;
  int del = 0;
  int views = 0;

  // String get url => _url ?? "";
  // set url(String? value) {
  //   _url = value;
  // }

  Favor.copy(Favor other) : this.from(other.url, other.title, other.ctime, other.utime, other.favor, other.ftime, other.del, other.views);
  //Favor(this.url, this.title, this.ctime, this.utime, this.favor,this.ftime, this.del,this.views);

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      columnUrl: url,
      columnTitle: title,
      columnCtime: ctime,
      columnUtime: utime,
      columnFavor: favor,
      columnFtime: ftime,
      columnDel: del,
      columnViews: views,
    };
    return map;
  }

  Favor.from(this.url, this.title, this.ctime, this.utime, this.favor, this.ftime, this.del, this.views);
  Favor();
  Favor.fromMap(Map<String, Object?> map) {
    url = map[columnUrl] as String?;
    title = map[columnTitle] as String?;
    ctime = map[columnCtime] as String?;
    utime = map[columnUtime] as int;
    favor = map[columnFavor] as int;
    ftime = map[columnFtime] as int;
    del = map[columnDel] as int;
    views = map[columnViews] as int;
  }

  bool isValid() {
    return url != null && url!.isNotEmpty;
  }

  bool isFavor() {
    return favor != 0;
  }

  void unFavor() {
    favor = 0;
  }

  void setFavor() {
    favor = 1;
  }

  void setDel() {
    del = 1;
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

    if (url != null && url!.isNotEmpty) {
      String v = url!.contains("://") ? url!.substring(url!.indexOf('://') + 3) : url!;
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
}

//CREATE TABLE example ( id INTEGER NOT NULL, name TEXT NOT NULL, description TEXT);

class Favorites {
  Database? database = DatabaseManager.db;
  static String get tableName => 'favorites';
  Favorites();
  static String table() {
    return DatabaseManager.favoritesDbTable();
  }

  Future<Favor?> getFavor(String? url) async {
    if (url == null || url.isEmpty || database == null) {
      return null;
    }
    List<Map>? maps = await database?.rawQuery('SELECT * FROM $tableName WHERE url = ?', [url]);
    if (maps!.isNotEmpty) {
      return Favor.fromMap(maps.first as Map<String, Object?>);
    }
    return null;
  }

  Future<bool> exist(String? url) async {
    if (url == null || url.isEmpty || database == null) {
      return false;
    }
    final dburl = await database?.rawQuery('SELECT url FROM $tableName WHERE url = ?', [url]);
    return (dburl != null && dburl.isNotEmpty);
  }

  Future<bool> update(Favor favor) async {
    if (!favor.isValid()) {
      return false;
    }
    DateTime updatedTime = DateTime.now();
    //update
    int utime = updatedTime.millisecondsSinceEpoch;
    // Update some record
    int? count = await database?.rawUpdate(
      'UPDATE $tableName SET title = ?, utime = ?, favor = ?, ftime = ?, del = ?, views = ? WHERE url = ?',
      [favor.title ?? '', utime, favor.favor, favor.ftime, favor.del, favor.views, favor.url],
    );
    if (count == null || count == 0) {
      ZsLog.d("favor update failed : ${favor.url}");
      return false;
    } else {
      favor.utime = utime;
    }
    return count > 0;
  }

  Future<bool> updateDel(Favor favor) async {
    if (!favor.isValid()) {
      return false;
    }
    // Update some record
    int? count = await database?.rawUpdate('UPDATE $tableName SET del = ?  WHERE url = ?', [favor.del, favor.url]);
    if (count == null || count == 0) {
      ZsLog.d("favor del update failed : ${favor.url}");
      return false;
    }
    return count > 0;
  }

  Future<bool> updateFavorVolumn(Favor favor) async {
    if (!favor.isValid()) {
      return false;
    }
    // Update some record
    DateTime updatedTime = DateTime.now();
    int ftime = updatedTime.millisecondsSinceEpoch;
    int? count = await database?.rawUpdate('UPDATE $tableName SET favor = ?,ftime=?  WHERE url = ?', [favor.favor, ftime, favor.url]);
    if (count == null || count == 0) {
      ZsLog.d("favor volumn update failed : ${favor.url}");
      return false;
    } else {
      favor.ftime = ftime;
    }
    return count > 0;
  }

  Future<bool> insert(Favor favor) async {
    if (!favor.isValid()) {
      return false;
    }
    DateTime updatedTime = DateTime.now();
    String ctime = updatedTime.toIso8601String();
    int utime = updatedTime.millisecondsSinceEpoch;
    final count = await database?.rawInsert('INSERT INTO $tableName(url,title,ctime,utime,favor,ftime,del,views) VALUES(?,?,?,?,?,?,?,?)', [
      favor.url,
      favor.title ?? '',
      ctime,
      utime,
      favor.favor,
      favor.ftime,
      favor.del,
      favor.views,
    ]);
    if (count == null || count == 0) {
      ZsLog.d("Cannot insert/update favorites: ${favor.url}");
      return false;
    } else {
      favor.ctime = ctime;
      favor.utime = utime;
    }
    return count > 0;
  }

  Future<bool> remove(String? url) async {
    if (url == null || url.isEmpty || database == null) {
      return false;
    }
    final count = await database?.rawDelete('DELETE FROM $tableName WHERE url = ?', [url]);
    if (count == null || count == 0) {
      ZsLog.d("Cannot delete favor: $url");
      return true;
    }
    return count > 0;
  }

  Future<Favor?> updateLookUrl(String url, String? title, {bool setFavor = false}) async {
    if (url.isEmpty) {
      return null;
    }
    if (Utils.isDesktopSystem) {
      if (!WindowUtil().winInfo.isMainWindow()) {
        var r = await WindowUtil().winInfo.synWindowEventValue([WebConstants.kWinSubEventFavor, url, title ?? '', setFavor ? 1 : 0]);
        return (r is int) ? Favor() : null;
      }
    }

    Favor? ret = await getFavor(url);
    if (ret != null) {
      if (title != null && title.isNotEmpty) {
        ret.title = title;
      }
      if (ret.del != 0) {
        ret.del = 0;
      }
      if (setFavor && !ret.isFavor()) {
        ret.setFavor();
        ret.ftime = DateTime.now().millisecondsSinceEpoch;
      }
      ret.views = ret.views + 1;
      await update(ret);
    } else {
      Favor inst = Favor();
      inst.url = url;
      inst.title = title ?? '';
      inst.views = 1;
      if (setFavor) {
        inst.setFavor();
        inst.ftime = DateTime.now().millisecondsSinceEpoch;
      }
      if (await insert(inst)) {
        ret = inst;
      }
    }
    return ret;
  }

  Future<int> count(bool favor) async {
    final rc = await database?.rawQuery(
      favor ? 'SELECT count(*) FROM $tableName where favor = 1' : 'SELECT count(*) FROM $tableName where del = 0',
    );
    if (rc == null || rc.isEmpty) {
      ZsLog.d("query count: $rc");
      return 0;
    }
    int? count = Sqflite.firstIntValue(rc);
    // Map map = rc.first;
    // String ct = map["count(*)"] as String;
    // int? vs = int.tryParse(ct);
    return count ?? 0;
  }

  Future<List<Favor>> queryAll(bool favor, {int pageSize = 100, int pageIndex = 1, int offset = -1}) async {
    int limit = pageSize > 0 ? pageSize : 1000;
    int offsetCount = offset > 0 ? offset : (((pageIndex < 1 ? 1 : pageIndex) - 1) * limit);
    String sql = favor
        ? 'SELECT * FROM $tableName where favor=1 ORDER BY ftime DESC LIMIT $limit OFFSET $offsetCount'
        : "SELECT * FROM $tableName where del=0 ORDER BY utime DESC  LIMIT $limit OFFSET $offsetCount";
    List<Map<String, Object?>>? list = await database?.rawQuery(sql);
    List<Favor> rets = [];
    if (list != null && list.isNotEmpty) {
      var rc = list.map((item) {
        var r = Favor.fromMap(item);
        return r;
      });
      rets = rc.toList(growable: true);
    }
    return rets;
  }

  ///清除所有收藏标记
  // Future<bool> updateUnFavors(List<Favor>? dels) async {
  //   if (database == null) {
  //     return false;
  //   }
  //   final count = await database?.rawUpdate(
  //     'UPDATE favorites SET favor = ?,  WHERE favor = 1',
  //     [0],
  //   );
  //   //删除
  //   if (dels != null) {
  //     await database?.transaction((txn) async {
  //       var batch = txn.batch();
  //       dels.map((item) {
  //         batch.delete('favorites', where: 'url = ?', whereArgs: [item.url]);
  //         item.del = 1;
  //       });
  //       await batch.commit();
  //     });
  //   }
  //   //删除没有收藏和已经删除
  //   final delcount = await database?.rawDelete(
  //     'DELETE FROM favorites WHERE favor = ? and del = 1 ',
  //     [0],
  //   );
  //   if (delcount != null) {
  //     ZsLog.d(" delete favor: $delcount");
  //   }
  //   return count! >= 0;
  // }

  //清除所有收藏标记
  Future<bool> removeAllNotFavorRecord() async {
    if (database == null) {
      return false;
    }
    final count = await database?.rawUpdate('UPDATE $tableName SET del = ?', [1]);
    //删除没有收藏和已经删除
    final delcount = await database?.rawDelete('DELETE FROM $tableName WHERE favor = 0 and del = 1 ');
    if (delcount != null) {
      ZsLog.d(" delete favor: $delcount");
    }
    return (count != null && count >= 0) || (delcount != null && delcount >= 0);
  }

  Future<List<UrlSearchResult>> queryUrlListFromKey(String urlKey, {int pageSize = 100, int pageIndex = 1, int offset = -1}) async {
    String qstr = urlKey.toLowerCase().trim();
    if (qstr.isEmpty) {
      return [];
    }
    int limit = pageSize > 0 ? pageSize : 1000;
    int offsetCount = offset > 0 ? offset : (((pageIndex < 1 ? 1 : pageIndex) - 1) * limit);
    String sql =
        """
        SELECT * FROM $tableName where del=0 and url like ? ORDER BY ftime DESC,favor DESC LIMIT ? OFFSET ?
        """;

    List<Map<String, Object?>>? list = await database?.rawQuery(sql, ['%$qstr%', limit, offsetCount]);
    List<UrlSearchResult> rets = [];
    if (list != null && list.isNotEmpty) {
      for (int i = 0; i < list.length; i++) {
        var item = list[i];
        var r = Favor.fromMap(item);
        if (r.url != null && r.url!.isNotEmpty) {
          var v = UrlSearchResult(
            name: r.title ?? (r.url ?? ""),
            subName: (r.title == null) ? null : r.url,
            value: r.url,
            type: USRType.row,
            source: USRSourceType.history,
            other: null,
          );
          rets.add(v);
        }
      }
    }
    return rets;
  }
}
