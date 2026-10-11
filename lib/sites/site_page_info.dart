import 'package:chiphell/data/site_page_info_manager_.dart';
import 'package:chiphell/utils/zs_log.dart';

import '../utils/util_map.dart';

enum SitePageInfoEvent { space, loging, thread, article, forum, category, home, last }

/// 站点 页面 浏览 信息 统计
class SitePageInfo {
  static String columnId = 'id';
  static String columnCombine = 'combine';
  static String columnSpace = 'space';
  static String columnLoging = 'loging';
  static String columnThread = 'thread';
  static String columnArticle = 'article';
  static String columnForum = 'forum';
  static String columnCategory = 'category';
  static String columnUdate = 'udate';
  static String columnLastUrl = 'last';
  static String columnInfo = 'info';

  ///data base
  int id;

  ///main site combine/uuid
  String combine;

  ///用户空间/主页
  int space;

  ///输入账号登陆页面
  int loging;

  ///用户帖子，内容页面
  int thread;

  ///用户文章，内容页面
  int article;

  ///板块（帖子列表）
  int forum;

  ///分类(包括多个板块)
  int category;

  ///最后更新时间
  int udate;

  ///最后登陆
  String lastUrl;

  String info;

  final Map<String, dynamic> infoMap = {};

  final Map<String, dynamic> _lastUpdateMaps = {};
  Map<String, dynamic> get lastUpdateMaps => Map.from(_lastUpdateMaps);
  void _setUpdateMapKV(String k, dynamic v) {
    if (_lastUpdateMaps.containsKey(k) == false || _lastUpdateMaps[k] != v) {
      _lastUpdateMaps[k] = v;
      udate = DateTime.now().millisecondsSinceEpoch;
      _lastUpdateMaps[columnUdate] = udate;
    }
  }

  SitePageInfo({
    required this.id,
    required this.combine,
    required this.space,
    required this.loging,
    required this.thread,
    required this.article,
    required this.forum,
    required this.category,
    required this.udate,
    required this.lastUrl,
    required this.info,
  });

  SitePageInfo.from(
    this.id,
    this.combine,
    this.space,
    this.loging,
    this.thread,
    this.article,
    this.forum,
    this.category,
    this.udate,
    this.lastUrl,
    this.info,
  );

  static SitePageInfo? fromMap(Map<String, dynamic> map) {
    final instance = SitePageInfo(
      id: UtilMap.safeIntForKey(map, columnId, defaultValue: 0, forceParse: true),
      combine: UtilMap.safeStringForKey(map, columnCombine) ?? '',
      space: UtilMap.safeIntForKey(map, columnSpace, defaultValue: 0, forceParse: true),
      loging: UtilMap.safeIntForKey(map, columnLoging, defaultValue: 0, forceParse: true),
      thread: UtilMap.safeIntForKey(map, columnThread, defaultValue: 0, forceParse: true),
      article: UtilMap.safeIntForKey(map, columnArticle, defaultValue: 0, forceParse: true),
      forum: UtilMap.safeIntForKey(map, columnForum, defaultValue: 0, forceParse: true),
      category: UtilMap.safeIntForKey(map, columnCategory, defaultValue: 0, forceParse: true),
      udate: UtilMap.safeIntForKey(map, columnUdate, defaultValue: 0, forceParse: true),
      lastUrl: UtilMap.safeStringForKey(map, columnLastUrl) ?? '',
      info: UtilMap.safeValueForStringKey(map, columnInfo) ?? '',
    );
    Map<String, dynamic> info = UtilMap.mapKVFromJsonString(instance.info);
    instance.infoMap.addAll(info);
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      columnId: id,
      columnCombine: combine,
      columnSpace: space,
      columnLoging: loging,
      columnThread: thread,
      columnArticle: article,
      columnForum: forum,
      columnCategory: category,
      columnUdate: udate,
      columnLastUrl: lastUrl,
      columnInfo: info,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'SitePageInfo{id:$id,combine:$combine,space:$space,loging:$loging,thread:$thread,article:$article,forum:$forum,category:$category,lastUrl:$lastUrl,udate:$udate}';
  }

  bool get valid {
    return combine.length > 4;
  }

  void cleanLastUpdateMaps() {
    _lastUpdateMaps.clear();
  }

  Map<String, dynamic> updateSiteInfo({
    int? pspace,
    int? ploging,
    int? pthread,
    int? particle,
    int? pforum,
    int? pcategory,
    String? plastUrl,
    String? infoKey,
    dynamic infoVal,
  }) {
    // int c = 0;
    if (pspace != null && pspace != space) {
      space = pspace;
      _setUpdateMapKV(columnSpace, pspace);
      // c++;
    }
    if (ploging != null && ploging != space) {
      loging = ploging;
      _setUpdateMapKV(columnLoging, loging);
      // c++;
    }
    if (pthread != null && pthread != thread) {
      thread = pthread;
      _setUpdateMapKV(columnThread, thread);
      //c++;
    }
    if (particle != null && particle != article) {
      article = particle;
      _setUpdateMapKV(columnArticle, article);
      //c++;
    }
    if (pforum != null && pforum != forum) {
      forum = pforum;
      _setUpdateMapKV(columnForum, forum);
      // c++;
    }
    if (pcategory != null && pcategory != category) {
      category = pcategory;
      _setUpdateMapKV(columnCategory, category);
      //c++;
    }
    if (plastUrl != null && plastUrl.isNotEmpty && plastUrl != lastUrl) {
      lastUrl = plastUrl;
      _setUpdateMapKV(columnLastUrl, lastUrl);
      //c++;
    }

    if (infoKey != null && infoMap.containsKey(infoKey)) {
      if (infoMap[infoKey] != infoVal) {
        infoMap[infoKey] = infoVal;
      }
    }

    String? rs = UtilMap.jsonStringFromMapKV(infoMap);
    if (rs != null && rs != info) {
      info = rs;
      _setUpdateMapKV(columnInfo, info);
    }
    return Map.from(lastUpdateMaps);
  }

  int merage(SitePageInfo existPage) {
    if (existPage.id <= 0) {
      return 0;
    }
    if (id > 0) {
      if (id != existPage.id) {
        return -1;
      }
    } else {
      id = existPage.id;
    }
    int c = 0;
    if (existPage.infoMap.isNotEmpty) {
      for (var key in existPage.infoMap.keys) {
        var val = existPage.infoMap[key];
        if (infoMap.containsKey(key) == false) {
          infoMap[key] = val;
          c++;
        }
      }
    }
    if (c > 0) {
      String? rs = UtilMap.jsonStringFromMapKV(infoMap);
      if (rs != null && rs != info) {
        info = rs;
        _setUpdateMapKV(columnInfo, info);
      }
    }

    if (existPage.space > space) {
      space = existPage.space;
      updateSiteInfo(pspace: existPage.space);
      c++;
    }
    if (existPage.loging > loging) {
      loging = existPage.loging;
      updateSiteInfo(ploging: existPage.loging);
      c++;
    }
    if (existPage.thread > thread) {
      thread = existPage.thread;
      updateSiteInfo(pthread: existPage.thread);
      c++;
    }

    if (existPage.article > article) {
      article = existPage.article;
      updateSiteInfo(particle: existPage.article);
      c++;
    }
    if (existPage.forum > forum) {
      forum = existPage.forum;
      updateSiteInfo(pforum: existPage.forum);
      c++;
    }
    if (existPage.category > category) {
      category = existPage.category;
      updateSiteInfo(pcategory: existPage.category);
      c++;
    }
    if (existPage.lastUrl.isNotEmpty && lastUrl.isEmpty) {
      lastUrl = existPage.lastUrl;
      updateSiteInfo(plastUrl: existPage.lastUrl);
      c++;
    }
    return c;
  }

  Future<void> saveToDb() async {
    try {
      if (valid) {
        if (id > 0) {
          //update
          if (lastUpdateMaps.isNotEmpty) {
            var v = await SitePageInfoManager.updateSiteInfoId(id, lastUpdateMaps);
            if (v) {
              cleanLastUpdateMaps();
            }
          }
        } else {
          //insert
          if (udate < 100) {
            udate = DateTime.now().millisecondsSinceEpoch;
          }
          var v = await SitePageInfoManager.insert(this);
          if (v) {
            cleanLastUpdateMaps();
          }
        }
      }
    } catch (e) {
      ZsLog.e('save to db failed ', error: e);
    }
  }
}
