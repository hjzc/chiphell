import 'package:chiphell/data/main_site_manager.dart';
import 'package:chiphell/data/site_page_info_manager_.dart';
import 'package:chiphell/sites/site_constants.dart';
import 'package:chiphell/sites/site_page_info.dart';
import 'package:chiphell/sites/util_site.dart';
import 'package:chiphell/utils/util_map.dart';

/// 站点来源
///print('${MainSiteSourceType.values}'); //[MainSiteSourceType.recommend, MainSiteSourceType.user, MainSiteSourceType.detect]
///print('${MainSiteSourceType.detect.index}'); // 2
enum MainSiteSourceType { none, recommend, user, detect }

/// 站点类型，
enum SiteType { none, discuz, other }

///
enum SiteUrlScheme { none, http, https }

class MainSite {
  static bool sourceTypeIndexValid(int index) {
    return (index >= MainSiteSourceType.values.first.index && index <= MainSiteSourceType.values.last.index);
  }

  static bool siteTypeIndexValid(int index) {
    return (index >= SiteType.values.first.index && index <= SiteType.values.last.index);
  }

  static bool siteUrlSchemeIndexValid(int index) {
    return (index >= SiteUrlScheme.values.first.index && index <= SiteUrlScheme.values.last.index);
  }

  /// index:0->'',index:1-> http, index:2->https
  static String siteUrlSchemeValueForIndex(int index) {
    String r = '';
    if (siteUrlSchemeIndexValid(index)) {
      r = siteUrlSchemeListString[index];
    }
    return r;
  }

  /// http->1,https->2, other 0
  static int siteUrlSchemeIndexFromString(String schemeStr) {
    int r = -1;
    if (siteUrlSchemeListString.contains(schemeStr)) {
      r = siteUrlSchemeListString.indexOf(schemeStr);
    }
    return r;
  }

  static String siteUrlSchemeNone = '';
  static String siteUrlSchemeHttp = 'http';
  static String siteUrlSchemeHttps = 'https';
  static List<String> siteUrlSchemeListString = [siteUrlSchemeNone, siteUrlSchemeHttp, siteUrlSchemeHttps];

  static String columnId = 'id';
  static String columnCombine = 'combine';
  static String columnHost = 'host';
  static String columnTitle = 'title';
  static String columnSource = 'source';
  static String columnScheme = 'scheme';
  static String columnSelected = 'selected';
  static String columnType = 'type';
  static String columnDomain = 'domain';
  static String columnCookiepre = 'cookiepre';
  static String columnCharset = 'charset';
  static String columnUdate = 'udate';

  /// data base id main key
  int id;
  // data base 唯一标识字符串,uuid "$scheme-$domain-$host";
  String combine;

  /// bbs.pcbeta.com:999, cliff.imwork.net:19999/xfbbs
  String host;

  /// 名称
  String title;

  /// MainSiteSourceType.none.index; 0:MainSiteSourceType.none; 1:MainSiteSourceType.recommend ,2: MainSiteSourceType.user,3:MainSiteSourceType.detect
  int source;

  /// 0 https, 1 http;
  int scheme;

  int selected;

  /// SiteType.none.index
  int type;

  /// pcbeta.com, site带path的可能为空'',子站点 host 为i.pcbeta.com,域名为pcbeta.com，则判断为同一个site
  String domain;

  ///"v2x4_48dd_",
  String cookiepre;

  String charset;

  ///最后更新时间
  int udate;

  bool? isDb;

  SitePageInfo pageInfo = SitePageInfo.from(0, '', 0, 0, 0, 0, 0, 0, 0, '', '');

  final Map<String, dynamic> _lastUpdateMaps = {};
  Map<String, dynamic> get lastUpdateMaps => Map.from(_lastUpdateMaps);
  void _setUpdateMapKV(String k, dynamic v) {
    if (_lastUpdateMaps.containsKey(k) == false || _lastUpdateMaps[k] != v) {
      _lastUpdateMaps[k] = v;
      udate = DateTime.now().millisecondsSinceEpoch;
      _lastUpdateMaps[columnUdate] = udate;
    }
  }

  void cleanLastUpdateMaps() {
    _lastUpdateMaps.clear();
  }

  MainSite({
    required this.id,
    required this.combine,
    required this.host,
    required this.title,
    required this.source,
    required this.scheme,
    required this.selected,
    required this.type,
    required this.domain,
    required this.cookiepre,
    required this.charset,
    required this.udate,
  });

  MainSite.from(
    this.id,
    this.combine,
    this.host,
    this.title,
    this.source,
    this.scheme,
    this.selected,
    this.type,
    this.domain,
    this.cookiepre,
    this.charset,
    this.udate,
  );

  static MainSite? fromMap(Map<String, dynamic> map) {
    final instance = MainSite(
      id: UtilMap.safeIntForKey(map, columnId, defaultValue: 0, forceParse: true),
      combine: UtilMap.safeStringForKey(map, columnCombine) ?? '',
      host: map[columnHost],
      title: UtilMap.safeStringForKey(map, columnTitle) ?? '',
      source: UtilMap.safeIntForKey(map, columnSource, defaultValue: MainSiteSourceType.detect.index, forceParse: true),
      scheme: UtilMap.safeIntForKey(map, columnScheme, defaultValue: SiteUrlScheme.none.index, forceParse: true),
      selected: UtilMap.safeIntForKey(map, columnSelected, defaultValue: 0, forceParse: true),
      type: UtilMap.safeIntForKey(map, columnType, defaultValue: SiteType.none.index, forceParse: true),
      domain: UtilMap.safeStringForKey(map, columnDomain) ?? '',
      cookiepre: UtilMap.safeStringForKey(map, columnCookiepre) ?? '',
      charset: UtilMap.safeStringForKey(map, columnCharset) ?? '',
      udate: UtilMap.safeIntForKey(map, columnUdate, defaultValue: 0),
    );
    if (instance.combine.length < 4) {
      instance.combine = instance.uuid;
    }
    if (instance.udate < 100) {
      instance.udate = DateTime.now().millisecondsSinceEpoch;
    }
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      columnId: id,
      columnCombine: combine,
      columnHost: host,
      columnTitle: title,
      columnSource: source,
      columnScheme: scheme,
      columnSelected: selected,
      columnType: type,
      columnDomain: domain,
      columnCookiepre: cookiepre,
      columnCharset: charset,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'MainSite{id:$id,combine:$combine,host:$host,title:$title,source:$source,scheme:$scheme,selected:$selected,type:$type,domain:$domain,cookiepre:$cookiepre,charset:$charset,udate:$udate}';
  }

  // @override
  // bool operator ==(other) {
  //   if (identical(this, other)) return true;
  //   return other is MainSite && other.host == host;
  // }
  // @override
  // int get hashCode => host.hashCode;
  //唯一标识 "$scheme-$domain-$host";

  Future<void> loadPageInfoFromDb() async {
    if (pageInfo.valid == false) {
      String cbStr = combine;
      if (cbStr.length < 2) {
        cbStr = uuid;
      }
      if (cbStr.length > 2) {
        pageInfo.combine = cbStr;
      }
    }
    if (pageInfo.valid) {
      var p = await SitePageInfoManager.getItem(combine: pageInfo.combine);
      if (p != null) {
        pageInfo = p;
      } else {
        if (pageInfo.valid) {
          await pageInfo.saveToDb();
        }
      }
    }
  }

  bool get valid {
    return combine.length > 4 || uuid.length > 4;
  }

  /// 2-chiphell.com-www.chiphell.com
  /// 2--cliff.imwork.net:19999/xfbbs
  String get uuid {
    if (host.length < 2) {
      return '';
    }
    return "$scheme-$domain-$host";
  }

  bool get validDomain {
    return domain.length > 2 && host.contains(domain);
  }

  String get url {
    var sc = origin;
    return sc.isEmpty ? siteUrlSchemeNone : "$sc/";
  }

  String get origin {
    var sc = schemeString;
    return sc.isEmpty ? siteUrlSchemeNone : "$sc://$host";
  }

  bool get validScheme {
    return siteUrlSchemeIndexValid(scheme);
  }

  String get schemeString {
    return siteUrlSchemeValueForIndex(scheme);
  }

  bool get hasPath {
    return host.contains('/');
  }

  String get path {
    return hasPath ? host.split('/').last : '';
  }

  ///可能包括端口 www.baidu.com or www.baidu.com:9999
  String get authority {
    return hasPath ? host.split('/').first : host;
  }

  ///不包括端口 www.baidu.com
  String get uriHost {
    Uri u = Uri.parse(url);
    return u.host;
  }

  String get favicon {
    return '$origin/favicon.ico';
  }

  Uri get faviconUri {
    return Uri.parse(favicon);
  }

  bool get isDiscuz {
    return siteType == SiteType.discuz;
  }

  bool get isSelected => selected == 1;
  void unSelecte() {
    selected = 0;
  }

  void setSelected() {
    selected = 1;
  }

  /// discuz cookie name
  String cookieFullNameKey(String key) {
    return '$cookiepre$key';
  }

  String get authCookieFullNameKey {
    return siteType == SiteType.discuz ? cookieFullNameKey(SiteConstants.kWebCookieDiscuzSuffixAuth) : '';
  }

  String get authCookieSuffix {
    return SiteConstants.kWebCookieDiscuzSuffixAuth;
  }

  String get cookieDomain {
    return domain.startsWith('.') ? domain : '.$domain';
  }

  String? get cssExtensionName {
    return UtilSite.cssFileNameFromHost(host);
  }

  ///相同站点
  bool isEqualSite(MainSite? site) {
    return site?.uuid == uuid;
  }

  /// i.pcbeta.com  为bbs.beta.com站点的子站点
  bool isSubSite(MainSite? site) {
    bool r = false;
    if (site != null) {
      if (site.url != url && site.domain.isNotEmpty) {
        // i.pcbeta.com  |  i.pcbeta.com == .pcbeta.com
        r = site.domain == domain;
      }
    }
    return r;
  }

  bool isSite(String? turl) {
    bool r = false;
    if (turl != null) {
      String tempUrl = url;
      if (tempUrl.isNotEmpty && turl.startsWith(tempUrl)) {
        r = true;
      }
    }
    return r;
  }

  ///如果domain:pcbeta.com , i.pcbeta.com 返回true
  bool isSiteDomain(String? turl, {String? schemeStr, String? domainStr}) {
    bool r = false;
    if (domain.isNotEmpty) {
      if (turl != null) {
        Uri i = Uri.parse(turl);
        r = i.host == domain || i.host.endsWith(cookieDomain);
      } else if (schemeStr != null && domainStr != null) {
        r = schemeStr == schemeString && (domainStr == domain || domainStr.endsWith(cookieDomain));
      }
    }
    return r;
  }

  MainSiteSourceType get sourceType {
    return sourceTypeIndexValid(source) == true ? MainSiteSourceType.values[source] : MainSiteSourceType.none;
  }

  bool updateSource(MainSiteSourceType sourcetype) {
    bool r = false;
    if (sourcetype.index != source && sourceTypeIndexValid(sourcetype.index)) {
      source = sourcetype.index;
      _setUpdateMapKV(columnSource, source);
    }
    return r;
  }

  /// 站点类型
  SiteType get siteType {
    return siteTypeIndexValid(type) == true ? SiteType.values[type] : SiteType.none;
  }

  bool updateSiteType(SiteType stype) {
    bool r = false;
    if (stype.index != type && siteTypeIndexValid(stype.index)) {
      type = stype.index;
      _setUpdateMapKV(columnType, type);
    }
    return r;
  }

  Map<String, dynamic> updateTitle(String str) {
    if (str.isNotEmpty && str != title) {
      _setUpdateMapKV(columnTitle, str);
    }
    return Map.from(lastUpdateMaps);
  }

  Future<void> updateLastUrl(String str) async {
    Map<String, dynamic> rs = pageInfo.updateSiteInfo(plastUrl: str);
    if (rs.isNotEmpty) {
      await saveToDb();
    }
  }

  Map<String, dynamic> updateFromMap(Map<String, dynamic>? map) {
    int c = 0;
    String? t = UtilMap.safeStringForKey(map, columnTitle);
    if (t != null && t.isNotEmpty && t != title) {
      title = t;
      _setUpdateMapKV(columnTitle, title);
      c++;
    }

    int it = UtilMap.safeIntForKey(map, columnSelected, defaultValue: selected, forceParse: true);
    if (it != selected) {
      selected = it;
      _setUpdateMapKV(columnSelected, selected);
      c++;
    }

    it = UtilMap.safeIntForKey(map, columnType, defaultValue: type, forceParse: true);
    if (it != type && (it >= SiteType.values.first.index && it <= SiteType.values.last.index)) {
      type = it;
      _setUpdateMapKV(columnType, type);
      c++;
    }

    t = UtilMap.safeStringForKey(map, columnCookiepre);
    if (t != null && t.isNotEmpty && t != cookiepre) {
      cookiepre = t;
      _setUpdateMapKV(columnCookiepre, cookiepre);
      c++;
    }

    t = UtilMap.safeStringForKey(map, columnCharset);
    if (t != null && t.isNotEmpty && t != charset) {
      charset = t;
      _setUpdateMapKV(columnCharset, charset);
      c++;
    }
    if (c > 0) {}
    return Map.from(lastUpdateMaps);
  }

  Future<bool> saveToDb() async {
    bool r = false;
    if (valid) {
      if (combine.length < 4) {
        combine = uuid;
      }
      if (id > 0) {
        //update
        if (lastUpdateMaps.isNotEmpty) {
          r = await MainSiteManager.updateHost(id, lastUpdateMaps);
          if (r) {
            cleanLastUpdateMaps();
          }
        }
      } else {
        //insert
        if (udate < 100) {
          udate = DateTime.now().millisecondsSinceEpoch;
        }
        r = await MainSiteManager.insert(this);
        if (r) {
          cleanLastUpdateMaps();
        }
      }
      if (pageInfo.valid) {
        var p = await SitePageInfoManager.getItem(combine: pageInfo.combine);
        if (p != null) {
          pageInfo.merage(p);
        }
      }
      await pageInfo.saveToDb();
    }
    return r;
  }
}
