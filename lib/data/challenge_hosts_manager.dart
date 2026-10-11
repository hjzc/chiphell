import 'package:sqflite/sqflite.dart';
import 'database_manager.dart';

class ChallengeHost {
  static String columnId = 'id';
  static String columnHost = 'host';
  static String columnTrust = 'trust';
  int id = 0;
  String? host;
  int trust = 0;

  ChallengeHost.copy(ChallengeHost other) : this.from(other.id, other.host, other.trust);

  Map<String, Object?> toMap() {
    var map = <String, Object?>{columnId: id, columnHost: host, columnTrust: trust};
    return map;
  }

  ChallengeHost.from(this.id, this.host, this.trust);
  ChallengeHost();
  ChallengeHost.fromMap(Map<String, Object?> map) {
    id = map[columnId] as int;
    host = map[columnHost] as String?;
    trust = map[columnTrust] as int;
  }

  bool isValid() {
    return host != null && host!.isNotEmpty;
  }

  bool get allow {
    return trust != 0;
  }

  Future<void> userTrust(bool flag) async {
    if (flag) {
      if (trust != 1) {
        trust = 1;
        //save
        if (id > 0) {
          await ChallengeHostsManager.updateTrust(id, allow);
        } else {
          await ChallengeHostsManager.autoUpdate(this);
        }
      }
    }
  }
}

class ChallengeHostsManager {
  static Database? get database => DatabaseManager.db;
  static String get tableName => 'challengeHosts';

  static Future<bool> exist(String host) async {
    final rc = await DatabaseManager.db?.rawQuery('SELECT count(*) FROM $tableName where host = ?', [host]);
    if (rc == null || rc.isEmpty) {
      return false;
    }
    int? count = Sqflite.firstIntValue(rc);
    return count != null && count > 0;
  }

  static Future<bool> insert(ChallengeHost item) async {
    if (!item.isValid()) {
      return false;
    }
    final count = await database?.rawInsert('INSERT INTO $tableName (host,trust) VALUES(?,?)', [item.host, item.trust]);
    bool r = count != null && (count > 0);
    if (r) {
      item.id = count;
    }
    return r;
  }

  static Future<ChallengeHost?> getItem(String? host) async {
    if (host == null || host.isEmpty || database == null) {
      return null;
    }
    List<Map>? maps = await database?.rawQuery('SELECT * FROM $tableName WHERE host = ?', [host]);
    if (maps!.isNotEmpty) {
      return ChallengeHost.fromMap(maps.first as Map<String, Object?>);
    }
    return null;
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

  static Future<bool> updateTrust(int id, bool trust) async {
    if (id > 0) {
      return false;
    }
    int v = trust ? 1 : 0;
    int? count = await database?.rawUpdate('UPDATE $tableName SET trust = ? WHERE id = ?', [v, id]);
    return count != null && (count > 0);
  }

  static Future<bool> autoUpdate(ChallengeHost item) async {
    bool r = false;
    if (item.isValid()) {
      final v = await getItem(item.host);
      if (v != null) {
        if (v.id != item.id) {
          item.id = v.id;
        }
        if (v.trust != item.trust) {
          //update
          if (v.trust == 0) {
            if (await updateTrust(v.id, true)) {
              v.trust = 1;
              r = true;
            }
          } else {
            item.trust = v.trust;
            r = false;
          }
        } else {
          r = true;
        }
      } else {
        r = await insert(item);
      }
    }
    return r;
  }
}
