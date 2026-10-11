import 'package:chiphell/data/main_site_manager.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../utils/utils.dart';
import '../utils/zs_log.dart';
import 'site_url_manager.dart';

class DatabaseManager {
  static Database? db;

  //andriod  /data/user/0/com.zorro.chiphell/app_flutter/chiphell
  //macos /Users/cjxy/Library/Containers/com.zorro.chiphell/Data/Documents/chiphell
  //ipad /Users/cjxy/Library/Developer/CoreSimulator/Devices/28D0FF14-E388-49F7-A682-78D6999DB693/data/Containers/Data/Application/4316CC4A-FBDD-4278-9851-A1142BF5FB7B/Library/Application Support/chiphell
  //iPhone /Users/cjxy/Library/Developer/CoreSimulator/Devices/28D0FF14-E388-49F7-A682-78D6999DB693/data/Containers/Data/Application/0F6502B0-2A3B-4E67-A41B-8DFCA00C8717/Documents/chiphell
  //windows C:\Users\Zorro\Documents/chiphell
  //linux  /home/zorro/.cache/com.zorro.chiphell/databases/myDb.db
  static Future<void> init() async {
    if (db == null) {
      if (Utils.isWindows() || Utils.isLinux()) {
        //macos
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }

      String path = await Utils.getSupportDbPath();
      ZsLog.d('App data base path: $path');

      if (Utils.isAndroid() || Utils.isMacOS() || Utils.isIOS() || Utils.isWindows()) {
        String old = await Utils.getSupportOldDbPath();
        if (Utils.fileExist(old)) {
          await Utils.moveFile(old, path);
        }
      }
      db = await databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 5,
          singleInstance: false,
          onCreate: (Database db, int version) async {
            ZsLog.i('db create:ov-$version');
            await db.execute(blackListDbTable());
            await db.execute(favoritesDbTable());
            await db.execute(siteUrlDbTable());
            await db.execute(mainSitesDbTable());
            await db.execute(sitePageInfoDbTable());
            await db.execute(challengeHostsDbTable());
            await SiteUrlManager.importDataFromJson(db);
            await MainSiteManager.importDataFromJson(db);
          },
          onUpgrade: (db, oldVersion, newVersion) async {
            ZsLog.i('db upgrade:ov-$oldVersion to nv-$newVersion');
            await db.execute(mainSitesDbTable());
            await db.execute(siteUrlDbTable());
            await db.execute(sitePageInfoDbTable());
            await db.execute(challengeHostsDbTable());
            await SiteUrlManager.importDataFromJson(db);
            await MainSiteManager.importDataFromJson(db);
          },
        ),
      );
      ZsLog.d('App data base init finish');
      //await deleteTableIfExists(db!, 'mainsite');

      // if (await columnExists('mainsite', 'charset') == false) {
      //   await db?.execute("ALTER TABLE mainsite ADD COLUMN charset TEXT");
      // }
      //SQL: ALTER TABLE users ADD COLUMN IF NOT EXISTS email TEXT;
    }
  }

  static Future<bool> columnExists(String tableName, String columnName) async {
    final result = await db?.rawQuery('PRAGMA table_info($tableName)');
    return result != null && result.any((row) => row['name'] == columnName);
  }

  static Future<bool> tableExists(String tableName, String columnName) async {
    final result = await db?.rawQuery('DROP TABLE IF EXISTS ($tableName)');
    return result != null && result.any((row) => row['name'] == columnName);
  }

  static Future<void> deleteTableIfExists(Database? db, String tableName) async {
    // 检查表是否存在
    if (db != null) {
      List<Map<String, dynamic>> result = await db.rawQuery('SELECT name FROM sqlite_master WHERE type=\'table\' AND name=?', [tableName]);
      if (result.isNotEmpty) {
        // 如果表存在，则删除它
        await db.execute('DROP TABLE $tableName');
        ZsLog.i('$tableName table deleted.');
      } else {
        ZsLog.i('$tableName table does not exist.');
      }
    }
  }

  static Future<void> close() async {
    if (db != null) {
      await db?.close();
    }
  }

  /// 黑明单
  static String blackListDbTable() {
    return '''
  CREATE TABLE IF NOT EXISTS blacklist (id TEXT PRIMARY KEY, ctime TEXT);
    ''';
  }

  /// 浏览记录，收藏
  static String favoritesDbTable() {
    return '''
  CREATE TABLE IF NOT EXISTS favorites (url TEXT PRIMARY KEY,title TEXT,ctime TEXT,utime INT,favor INT,ftime INT,del INT,views INT);
    ''';
  }

  //地址栏搜索
  static String siteUrlDbTable() {
    return '''
  CREATE TABLE IF NOT EXISTS siteurls (host TEXT PRIMARY KEY,title TEXT,scheme INT,weight INT,useCount INT);
    ''';
  }

  ///discuz site
  static String mainSitesDbTable() {
    return '''
  CREATE TABLE IF NOT EXISTS mainSites (id INTEGER PRIMARY KEY AUTOINCREMENT,combine TEXT NOT NULL UNIQUE, host TEXT,title TEXT,source INT,scheme INT,selected INT,type INT,domain TEXT,cookiepre TEXT,charset TEXT,udate INT);
    ''';
  }

  static String sitePageInfoDbTable() {
    return '''
  CREATE TABLE IF NOT EXISTS sitePageinfo (id INTEGER PRIMARY KEY AUTOINCREMENT,combine TEXT NOT NULL UNIQUE,space INT,loging INT,thread INT,article INT,forum INT,category TEXT,udate INT,last TEXT,info TEXT);
    ''';
  }

  static String challengeHostsDbTable() {
    return '''
  CREATE TABLE IF NOT EXISTS challengeHosts (id INTEGER PRIMARY KEY,host TEXT NOT NULL UNIQUE,trust INT);
    ''';
  }
}
