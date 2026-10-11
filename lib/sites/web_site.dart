import 'dart:convert';
import 'package:chiphell/data/prefs.dart';
import 'package:chiphell/modals/web_user.dart';
import 'package:chiphell/sites/site_page_info.dart';
import 'package:chiphell/sites/util_site.dart';
import 'package:chiphell/utils/utils.dart';
import 'package:chiphell/utils/zs_log.dart';
import '../utils/util_map.dart';
import 'site_constants.dart';
import 'main_site.dart';

abstract class SiteContext {
  String? get title;

  /// http/https
  String get scheme;

  /// pcbeta.com
  String get domain;

  ///bbs.pcbeta.com:999,cliff.imwork.net:19999/xfbbs
  String get host;

  /// https://bbs.pcbeta.com:999/ https://bbs.pcbeta.com:999/bbs/
  String get url;

  ///SiteType.discuz
  SiteType get type;

  /// https://bbs.pcbeta.com:999
  /// https://bbs.pcbeta.com:19999/xfbbs
  String get origin;

  //来源
  String get sourceUrl;

  WebUser get user;

  String get lastUrl;

  Map<String, dynamic> get info;

  /// ['https://cliff.imwork.net:19999/xfbbs/']
  //List<String> get subHosts;

  bool isDiscuz();
  MainSite? mainSite;

  ///  https://bbs.pcbeta.com:999/
  String? siteUrl(bool mobileUa);
  String? authority();
  String? uriHost();
  String? firstUrl(bool mobileUa);
  String? homeUrl(bool mobileUa);
  String? areaUrl(bool mobileUa);
  String? loginUrl(bool mobileUa);

  bool canSaveLast(String? url);

  // bool isSupportMobile();
  // bool isMobileUA();
  bool isMobileUrl(String url);
  bool isChallengeHost(String? paramHost);
  bool isSite(String? url);
  bool isHomeUrl(String? url, {bool onlyMode = false});
  bool isAreaUrl(String? url, {bool onlyMode = false});
  bool isForumUrl(String? url, {bool onlyMode = false}); //topic
  bool isThreadUrl(String? url, {bool onlyMode = false});
  bool isArticleUrl(String? url, {bool onlyMode = false});
  bool isAuthorUrl(String? url, {bool onlyMode = false});
  bool isAuthorAbout(String? url, {bool onlyMode = false});
  bool isAuthorImageUrl(String? url, {bool onlyMode = true});
  bool isContentImageUrl(String? url, {bool decoded = false, bool onlyMode = true});
  bool isImageAttachment(String? url, {bool decoded = false, bool onlyMode = true});
  String? imageAttachmentSuggestedFileName(String? url, {bool decoded = false, bool onlyMode = true});
  bool isAttachment(String? url, {bool decoded = false, bool onlyMode = true});
  bool isLoginUrl(String? url, {bool onlyMode = false});
  bool isReplyUrl(String? url, {bool onlyMode = false});
  bool isPostNewthreadUrl(String? url, {bool onlyMode = false});
  bool isSearchUrl(String? url, {bool onlyMode = false});
  //  bool addSubHost(String? host);
  String? authorNameFromTitle(String? title);
  String? convertUrlFromForumUrl(String? url, String? forumId, bool mobile);
  String? convertUrlFromUrl(String? url, bool toPC, bool mobile);

  Future<void> save({bool force = false});

  Future<void> didShowUrl(String? url);
}

class WebSite implements SiteContext {
  int? changed;
  @override
  String? title;
  @override
  String scheme;
  @override
  String domain;
  @override
  String host;
  @override
  String url;
  @override
  String origin;
  @override
  String sourceUrl;

  // @override
  // String get title => _title;
  // set title(String? val) {
  //   if (val != null && _title != val) {
  //     _title = val;
  //   }
  // }

  // @override
  // String get domain => _domain;
  // set domain(String? val) {
  //   if (val != null && val.isEmpty && _domain != val) {
  //     _domain = val;
  //   }
  // }

  // @override
  // String get host => _host;
  // set host(String? val) {
  //   if (val != null && val.isEmpty && _host != val) {
  //     _host = val;
  //   }
  // }

  // @override
  // String get url => _url;
  // set url(String? val) {
  //   if (val != null && val.isEmpty && _url != val) {
  //     _url = val;
  //   }
  // }

  // @override
  // String get origin => _origin;
  // set origin(String? val) {
  //   if (val != null && val.isEmpty && _origin != val) {
  //     _origin = val;
  //   }
  // }

  // @override
  // String get sourceUrl => _sourceUrl;
  // set sourceUrl(String? val) {
  //   if (val != null && val.isEmpty && _sourceUrl != val) {
  //     _sourceUrl = val;
  //   }
  // }

  @override
  SiteType get type => mainSite != null ? mainSite!.siteType : SiteType.none;

  @override
  MainSite? mainSite;

  @override
  WebUser user;

  @override
  String lastUrl;

  @override
  Map<String, dynamic> info;

  /// [https://cliff.imwork.net:19999/xfbbs/]
  //@override
  //List<String> subHosts;

  List<MainSite> sameDomainSites = [];
  MainSite? currentSameDomainSite;

  WebSite(
    this.title,
    this.scheme,
    this.domain,
    this.host,
    this.url,
    this.origin,
    this.sourceUrl, {
    required this.user,
    required this.lastUrl,
    required this.info,
    //required this.subHosts,
  });

  // WebSite._(this.host); // 私有构造函数

  // @override
  // bool operator == (Object other) {
  //   bool r = false;
  //   if (other is WebSite) {
  //     r = other.scheme == scheme || other.host == host;
  //   } else {
  //     r = super == other;
  //   }
  //   return r;
  // }

  // @override
  // int get hashCode {
  //   // 使用关键字段的组合生成哈希值
  //   return Object.hash(origin, host);
  // }
  // @override
  // bool operator ==(other) {
  //   if (identical(this, other)) return true;
  //   return other is WebSite && other.host == host;
  // }

  // @override
  // int get hashCode => host.hashCode;

  static WebSite parserMainSite(MainSite ms, {List<MainSite>? sameSites}) {
    var url = ms.url;
    var u = Uri.parse(url);
    var origin = ms.origin;
    var host = ms.host;
    WebUser user = WebUser();
    user.msg ??= PromptMsg(name: '', uid: '', count: 0, stamp: 0);
    String domain = ms.domain;
    if (domain.isEmpty == true) {
      var rv = UtilSite.domainFromUrl(uri: u);
      if (rv != null) {
        domain = rv;
      }
    }
    var r = WebSite(
      ms.title,
      ms.schemeString,
      domain,
      host,
      url,
      origin,
      url,
      user: user,
      lastUrl: '',
      info: <String, dynamic>{},
      //subHosts: [],
    );
    r.mainSite = ms;
    if (sameSites != null) {
      r.sameDomainSites = sameSites;
    }
    return r;
  }

  ///返回一个以 origin 为url的对象
  static WebSite parserUrl(String url, Uri? uri, {String? title, String? orgUrl}) {
    var u = uri ?? Uri.parse(url);
    var scheme = u.scheme;
    var hostName = u.host;
    var origin = u.origin;
    var port = u.hasPort ? u.port : 0;
    var host = u.hasAuthority
        ? u.authority
        : port > 0
        ? '$hostName:$port'
        : hostName;
    WebUser user = WebUser();
    user.msg ??= PromptMsg(name: '', uid: '', count: 0, stamp: 0);
    String? domain = UtilSite.domainFromUrl(uri: u);
    Map<String, dynamic> info = <String, dynamic>{};
    if (orgUrl != null) {
      info['orgUrl'] = orgUrl;
    }
    return WebSite(
      title ?? url,
      scheme,
      domain ?? '',
      host,
      url,
      origin,
      orgUrl ?? url,
      user: user,
      lastUrl: '',
      info: info, //subHosts: []
    );
  }

  static WebSite fromMap(Map<String, dynamic> map) {
    WebUser user = map['user'] is WebUser ? map['user'] : (WebUser.fromJson(map['user'] as Map<String, dynamic>));
    //List<String> subs = [];
    // var rs = map['subHosts'];
    // if (rs != null && rs is List<dynamic> && rs.isNotEmpty) {
    //   List<String> v = rs.map((e) => e.toString()).toList();
    //   subs.addAll(v);
    // }
    var scheme = UtilMap.safeStringForKey(map, 'scheme');
    var sourceUrl = UtilMap.safeStringForKey(map, 'sourceUrl');

    var info = map['info'];
    if (info != null && info is Map) {
      var orgUrl = UtilMap.safeStringForKey(info, 'orgUrl');
      sourceUrl ??= orgUrl;
    }

    var origin = UtilMap.safeStringForKey(map, 'origin');
    String? originScheme;
    if (origin != null) {
      sourceUrl ??= '$origin/';
      if (origin.startsWith('http://')) {
        originScheme = 'http';
      } else if (origin.startsWith('https://')) {
        originScheme = 'https';
      }
    }

    scheme ??= originScheme;
    final instance = WebSite(
      map['title'],
      scheme ?? '',
      map['domain'],
      map['host'],
      map['url'],
      map['origin'],
      sourceUrl ?? '',
      user: user,
      lastUrl: map['lastUrl'],
      info: info,
      // subHosts: subs,
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "scheme": scheme,
      "domain": domain,
      "host": host,
      "url": url,
      'origin': origin,
      'sourceUrl': sourceUrl,
      "user": user,
      "lastUrl": lastUrl,
      'info': info,
      //'subHosts': subHosts,
    };
  }

  factory WebSite.fromJson(Map<String, dynamic> json) => WebSite.fromMap(json);

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "scheme": scheme,
      "domain": domain,
      "host": host,
      "url": url,
      'origin': origin,
      'sourceUrl': sourceUrl,
      "user": user.toJson(),
      "lastUrl": lastUrl,
      'info': info,
      //'subHosts': subHosts,
    };
  }

  @override
  String toString() {
    return 'WebSite{title:$title,scheme:$scheme,domain:$domain,host:$host,url:$url,origin:$origin,sourceUrl:$sourceUrl,user:$user,lastUrl:$lastUrl,info:$info}';
  }

  String get schemeString {
    String r = '';
    if (mainSite != null) {
      r = mainSite!.schemeString;
    } else if (scheme.length > 2) {
      r = scheme;
    } else {
      r = Uri.parse(url).scheme;
    }
    return r;
  }

  @override
  bool isDiscuz() {
    return type == SiteType.discuz;
  }

  String mainSiteJsonString() {
    String r = '';
    if (mainSite != null) {
      r = jsonEncode(mainSite);
    }
    return r;
  }

  @override
  String? siteUrl(bool mobileUa) {
    String? r;
    if (isDiscuz() && mainSite != null) {
      r = mainSite?.url;
    } else if (origin.isNotEmpty) {
      if (origin.endsWith('/')) {
        r = origin;
      } else {
        r = '$origin/';
      }
    }
    return r;
  }

  ///返回域名，可能包括端口
  @override
  String? authority() {
    String? r;
    if (origin.isNotEmpty) {
      Uri u = Uri.parse(origin);
      r = u.hasAuthority ? u.authority : null;
    }
    return r;
  }

  /// 返回域名，不包括端口
  @override
  String? uriHost() {
    String? r;
    if (origin.isNotEmpty) {
      Uri u = Uri.parse(origin);
      r = u.host;
    }
    return r;
  }

  @override
  String? firstUrl(bool mobileUa) {
    String? r;
    if ((lastUrl.length > 5)) {
      r = lastUrl;
    } else if (mainSite != null) {
      r = mainSite?.pageInfo.lastUrl;
      if (r == null || r.length < 5) {
        r = homeUrl(mobileUa);
      }
    }
    return r; // ((lastUrl.isNotEmpty) && (lastUrl.length > 5)) ? lastUrl : homeUrl(mobileUa);
  }

  @override
  String? homeUrl(bool mobileUa) {
    String? r;
    if (isDiscuz()) {
      if (mobileUa) {
        r = "${_getSiteOrigin(SitePageInfoEvent.home)}/index.php?mobile=2";
      } else {
        r = _getSiteOrigin(SitePageInfoEvent.home); //siteUrl(mobileUa);
      }
    } else {
      r = siteUrl(mobileUa);
    }
    return r;
  }

  @override
  String? areaUrl(bool mobileUa) {
    String? r;
    if (isDiscuz()) {
      if (mobileUa) {
        r = "${_getSiteOrigin(SitePageInfoEvent.category)}/forum.php?forumlist=1&mobile=2";
      } else {
        r = '${_getSiteOrigin(SitePageInfoEvent.category)}/forum.php';
      }
    }
    return r;
  }

  @override
  String? loginUrl(bool mobileUa) {
    String? r;
    if (isDiscuz()) {
      if (mobileUa) {
        r = "${_getSiteOrigin(SitePageInfoEvent.loging)}/member.php?mod=logging&action=login&mobile=2";
      } else {
        r = '${_getSiteOrigin(SitePageInfoEvent.loging)}/member.php?mod=logging&action=login';
      }
    }
    return r;
  }

  // @override
  // bool isSupportMobile() {
  //   return isDiscuz();
  // }

  String _fixDiscuzPath(String strPath) {
    String r = UtilSite.fixDiscuzPath(mainSite?.path, strPath);
    if (mainSite != null) {
    } else {}
    // var bpath = mainSite?.path;
    // if (bpath != null && bpath.isNotEmpty) {
    //   String prefix = '/$bpath';
    //   if (strPath.startsWith(prefix)) {
    //     r = strPath.substring(prefix.length);
    //   } else {
    //     //返回无效
    //     r = '';
    //   }
    // }
    return r;
  }

  /// macos mobile user agent, https://www.chiphell.com/forum-319-1.html?mobile=3"
  /// ios/android mobile user agent, https://www.chiphell.com/forum-319-1.html?mobile=2"
  @override
  bool isMobileUrl(String url) {
    if (url.contains('mobile=2') || (Utils.isMacOS() && url.contains('mobile=3'))) {
      return true;
    }
    if (url.contains('mobile=1')) {
      return true;
    }
    // if ( isDiscuz() && isMobileUA() && !Utils.isMacOS()) {
    //   return true;
    // }
    return false;
  }

  // bool _isSiteSubHost(String? url) {
  //   bool r = false;
  //   if (url != null && url.isNotEmpty) {
  //     for (int i = 0; i < subHosts.length; i++) {
  //       var v = subHosts[i];
  //       r = url.startsWith(v);
  //       if (r) {
  //         break;
  //       }
  //     }
  //   }
  //   return r;
  // }

  MainSite? _getMainSiteContent(SitePageInfoEvent event) {
    MainSite? r = mainSite;
    int total = 0;
    if (r != null) {
      if (event == SitePageInfoEvent.thread || event == SitePageInfoEvent.article) {
        total = r.pageInfo.thread + r.pageInfo.article;
      } else if (event == SitePageInfoEvent.forum) {
        total = r.pageInfo.forum;
      } else if (event == SitePageInfoEvent.category) {
        total = r.pageInfo.category;
      } else if (event == SitePageInfoEvent.home) {
        total = r.pageInfo.forum + r.pageInfo.category;
      } else if (event == SitePageInfoEvent.space) {
        total = r.pageInfo.space;
      } else if (event == SitePageInfoEvent.loging) {
        total = r.pageInfo.loging;
      }
    }
    for (int i = 0; i < sameDomainSites.length; i++) {
      var v = sameDomainSites[i];
      var t = 0;
      if (event == SitePageInfoEvent.thread || event == SitePageInfoEvent.article) {
        t = v.pageInfo.thread + v.pageInfo.article;
      } else if (event == SitePageInfoEvent.forum) {
        t = v.pageInfo.forum;
      } else if (event == SitePageInfoEvent.category) {
        t = v.pageInfo.category;
      } else if (event == SitePageInfoEvent.home) {
        t = v.pageInfo.forum + v.pageInfo.category;
      } else if (event == SitePageInfoEvent.space) {
        t = v.pageInfo.space;
      } else if (event == SitePageInfoEvent.loging) {
        t = v.pageInfo.loging;
      }
      if (t > total) {
        total = t;
        r = v;
      }
    }
    return r;
  }

  String _getSiteOrigin(SitePageInfoEvent event) {
    String r = origin;
    MainSite? v = _getMainSiteContent(event);
    if (v != null) {
      r = v.origin;
    }
    return r;
  }

  /// url 匹配的MainSite
  MainSite? _getMainSiteOfUrl(String? url) {
    MainSite? r;
    if (url != null) {
      if (mainSite != null) {
        if (mainSite?.isSite(url) == true) {
          r = mainSite;
          currentSameDomainSite = mainSite;
        } else if (currentSameDomainSite != null && mainSite != currentSameDomainSite && (currentSameDomainSite?.isSite(url) == true)) {
          r = currentSameDomainSite;
        } else {
          for (int i = 0; i < sameDomainSites.length; i++) {
            var v = sameDomainSites[i];
            if (v.isSite(url) == true) {
              currentSameDomainSite = v;
              r = v;
              break;
            }
          }
        }
      }
    }
    return r;
  }

  void _autoAddMainSitePageInfo(String url, MainSite? site, SitePageInfoEvent event, {dynamic value}) {
    SitePageInfo? pi;
    if (site != null) {
      pi = site.pageInfo;
    } else if (currentSameDomainSite != null && currentSameDomainSite!.isSite(url)) {
      pi = currentSameDomainSite?.pageInfo;
    }
    if (pi != null) {
      if (event == SitePageInfoEvent.thread) {
        pi.updateSiteInfo(pthread: value ?? pi.thread + 1);
      } else if (event == SitePageInfoEvent.article) {
        pi.updateSiteInfo(particle: value ?? pi.article + 1);
      } else if (event == SitePageInfoEvent.category) {
        pi.updateSiteInfo(pcategory: value ?? pi.category + 1);
      } else if (event == SitePageInfoEvent.forum) {
        pi.updateSiteInfo(pforum: value ?? pi.forum + 1);
      } else if (event == SitePageInfoEvent.home) {
        pi.updateSiteInfo(pcategory: value ?? pi.category + 1);
      } else if (event == SitePageInfoEvent.space) {
        pi.updateSiteInfo(pspace: value ?? pi.space + 1);
      }
    }
  }

  /// url 以 origin 开头，或者 mainsite的url开头
  bool _startsWith(String? url, {void Function(String urlStr, MainSite? s)? siteCall}) {
    var r = false;
    if (url != null) {
      if (mainSite != null) {
        MainSite? v = _getMainSiteOfUrl(url);
        if (v != null) {
          r = true;
          if (siteCall != null) {
            siteCall.call(url, v);
          }
        } else if (isSubSiteUrl(url)) {
          r = true;
        }
      } else {
        r = origin.length > 5 && (url.startsWith(origin));
      }
    }
    return r;
  }

  bool _subDomainWith(String? urlDomain, String? schemeStr, {void Function(String urlStr, MainSite? s)? siteCall}) {
    var v = false;
    if ((urlDomain != null && urlDomain.length > 3) && (schemeStr != null && schemeStr.length > 2)) {
      if (mainSite != null) {
        v = mainSite?.isSiteDomain(null, schemeStr: schemeStr, domainStr: urlDomain) == true;
        if (v) {
          if (siteCall != null) {
            siteCall.call(url, mainSite);
          }
        }
      } else if (domain.isNotEmpty && scheme.isNotEmpty) {
        v = (schemeStr == scheme) && (urlDomain == domain || urlDomain.endsWith(domain));
      }
    }
    return v;
  }

  Uri? _getSiteUri(String? url, {void Function(String urlStr, MainSite? s)? siteCall}) {
    Uri? r;
    if (url != null && url.isNotEmpty) {
      Uri u = Uri.parse(url);
      var v = u.authority == host || (u.origin == origin) || _startsWith(url, siteCall: siteCall);
      if (!v) {
        v = _subDomainWith(u.authority, u.scheme, siteCall: siteCall);
      }
      if (v) {
        r = u;
      }
    }
    return r;
  }

  Uri? _autoUriFromUrl(String url, {bool decoded = false, bool onlyMode = true, void Function(String urlStr, MainSite? s)? siteCall}) {
    String lw = Utils.autoDecodeUrl(url, decoded: decoded);
    return onlyMode ? Uri.parse(lw) : _getSiteUri(lw, siteCall: siteCall);
  }

  ///返回域名 不包括端口
  @override
  bool isChallengeHost(String? paramHost) {
    bool r = false;
    if (paramHost != null && paramHost.isNotEmpty) {
      if (mainSite != null) {
        r = mainSite?.uriHost == paramHost;
      }
      if (!r) {
        for (int i = 0; i < sameDomainSites.length; i++) {
          var v = sameDomainSites[i];
          if (v.uriHost == paramHost) {
            r = true;
            break;
          }
        }
      }
      if (!r) {
        r = uriHost() == paramHost;
      }
    }
    return r;
  }

  @override
  bool isSite(String? url, {void Function(String urlStr, MainSite? s)? siteCall}) {
    bool r = false;
    if (url != null && url.isNotEmpty) {
      if (mainSite != null) {
        MainSite? v = _getMainSiteOfUrl(url);
        if (v != null) {
          r = true;
          if (siteCall != null) {
            siteCall.call(url, v);
          }
        } else if (isSubSiteUrl(url)) {
          r = true;
        }
      } else {
        Uri u = Uri.parse(url);
        r = (u.origin == origin);
        if (r == false) {
          if (domain.isNotEmpty) {
            r = u.host.endsWith(domain);
          }
          if (r == false) {
            // www.chiphell.com  i.chiphell.com
            r = UtilSite.isSameDomain(origin, url);
          }
        }
      }
    }
    return r;
  }

  bool isSubSite(MainSite? subSite) {
    bool r = false;
    r = mainSite?.isSubSite(subSite) == true;
    if (r == false) {
      for (int i = 0; i < sameDomainSites.length; i++) {
        var v = sameDomainSites[i];
        if (v.isEqualSite(subSite) == true) {
          r = true;
          break;
        }
      }
    }
    return r;
  }

  bool isSubSiteUrl(String url, {void Function(Uri)? uriCall}) {
    bool r = false;
    Uri u = Uri.parse(url);
    if (mainSite != null && u.scheme == schemeString && mainSite!.validDomain) {
      r = u.host == mainSite!.domain || u.host.endsWith(mainSite!.cookieDomain);
      if (uriCall != null) {
        uriCall(u);
      }
    }
    return r;
  }

  Future<bool> updateMainSite(MainSite subSite) async {
    bool r = false;
    if (mainSite != null) {
      MainSite? vItem;
      if (mainSite?.isEqualSite(subSite) == true) {
        vItem = mainSite;
      } else if (currentSameDomainSite != null &&
          (currentSameDomainSite != mainSite) &&
          (currentSameDomainSite?.isEqualSite(subSite) == true)) {
        vItem = currentSameDomainSite;
      } else if (mainSite?.isSubSite(subSite) == true) {
        for (int i = 0; i < sameDomainSites.length; i++) {
          var v = sameDomainSites[i];
          r = v.isEqualSite(subSite) == true;
          if (r) {
            currentSameDomainSite = v;
            vItem = v;
            break;
          }
        }
        if (vItem == null) {
          await subSite.saveToDb();
          sameDomainSites.add(subSite);
          await subSite.loadPageInfoFromDb();
          currentSameDomainSite = subSite;
          r = true;
        }
      }
      if (vItem != null) {
        subSite.source = vItem.source;
        subSite.type = vItem.type;
        var vals = vItem.updateFromMap(subSite.toMap());
        if (vals.isNotEmpty) {
          r = await vItem.saveToDb();
          if (r) {
            ZsLog.i('main site [${vItem.host}] update to db success');
          }
        } else {
          r = true;
        }
      }
    }
    return r;
  }

  /// https://bbs.pcbeta.com/index.php?mobile=2
  /// https://bbs.pcbeta.com/index.php
  /// https://bbs.pcbeta.com/
  /// https://cliff.imwork.net:19999/xfbbs/
  /// https://www.chiphell.com/portal.php 主页
  @override
  bool isHomeUrl(String? url, {bool onlyMode = false}) {
    bool r = false;
    if (isDiscuz() && url != null) {
      MainSite? tsite;
      Uri? u = onlyMode
          ? Uri.parse(url)
          : _getSiteUri(
              url,
              siteCall: (urlStr, s) {
                tsite = s;
              },
            );
      if (u != null) {
        if (u.hasEmptyPath) {
          r = true;
        } else if (mainSite?.hasPath == true && url == mainSite?.url) {
          r = true;
        } else {
          String strPath = u.path;
          strPath = _fixDiscuzPath(strPath);
          String query = u.query;
          if (strPath != '' && (strPath == '/' || strPath == '/index.php' || strPath == '/portal.php')) {
            if (query.isEmpty || Utils.isMatchRegex(query, r'mobile=(\d)$')) {
              r = true;
            }
          }
          // else if (strPath.endsWith('portal.php') && query.isNotEmpty) {
          //   //https://www.chiphell.com/portal.php 主页
          //   r = true;
          // }
        }
        if (r) {
          _autoAddMainSitePageInfo(url, tsite, SitePageInfoEvent.home);
        }
      }
    }
    return r;
  }

  /// https://www.chiphell.com/forum.php?mobile=2
  /// https://www.chiphell.com/forum.php?gid=223
  /// https://bbs.pcbeta.com/forum.php?gid=86
  /// https://bbs.pcbeta.com/forum.php
  /// https://www.chiphell.com/forum.php?forumlist=1&mobile=no
  @override
  bool isAreaUrl(String? url, {bool onlyMode = false}) {
    bool r = false;
    if (isDiscuz() && url != null) {
      MainSite? tsite;
      Uri? u = onlyMode
          ? Uri.parse(url)
          : _getSiteUri(
              url,
              siteCall: (urlStr, s) {
                tsite = s;
              },
            );
      if (u != null) {
        String strPath = u.path;
        String query = u.query;
        strPath = _fixDiscuzPath(strPath);
        if (strPath.endsWith('/forum.php')) {
          if (query.isEmpty || query.contains('gid=')) {
            r = true;
          } else if (query.contains('forumlist=')) {
            r = true;
          } else if (query == 'mobile=2' || query == 'mobile=3') {
            r = true;
          }
        }
        if (r) {
          _autoAddMainSitePageInfo(url, tsite, SitePageInfoEvent.category);
        }
      }
    }
    return r;
  }

  /// https://www.chiphell.com/forum-146-1.html
  /// https://www.chiphell.com/portal.php?mod=list&catid=2
  /// https://bbs.pcbeta.com/forum-HarmonyOS-2.html
  /// https://bbs.pcbeta.com/forum.php?mod=forumdisplay&fid=255
  /// https://www.birdnet.cn/mammal.php?mod=show&action=atlaslist
  /// https://www.birdnet.cn/video.php
  /// https://www.birdnet.cn/forum.php?mod=allpics&type=mrjz
  /// https://www.birdnet.cn/forum.php?mod=guide&view=todaytt,
  /// https://www.birdnet.cn/trade.php
  /// https://www.birdnet.cn/trade.php?mod=tradeinfo
  /// lookbird.php
  @override
  bool isForumUrl(String? url, {bool onlyMode = false}) {
    bool r = false;
    if (isDiscuz() && url != null) {
      MainSite? tsite;
      Uri? u = onlyMode
          ? Uri.parse(url)
          : _getSiteUri(
              url,
              siteCall: (urlStr, s) {
                tsite = s;
              },
            );
      if (u != null) {
        String strPath = u.path;
        strPath = _fixDiscuzPath(strPath);
        String query = u.query;
        if (strPath.contains('forum-') ||
            query.contains('mod=forumdisplay') ||
            query.contains('mod=list') ||
            query.contains('mod=guide') ||
            query.contains('mod=allpics')) {
          r = true;
        } else if (strPath.contains('mammal.php') || query.contains('mod=show') || query.contains('action=atlaslist')) {
          r = true;
        } else if (query == '' && (strPath.contains('video.php') || strPath.contains('trade.php') || strPath.contains('lookbird.php'))) {
          r = true;
        } else if (query == 'mod=tradeinfo' && (strPath.contains('trade.php'))) {
          r = true;
        }

        if (r) {
          _autoAddMainSitePageInfo(url, tsite, SitePageInfoEvent.forum);
        }
      }
    }
    return r;
  }

  /// https://bbs.pcbeta.com/forum.php?mod=viewthread&tid=2070897&extra=page%3D1
  /// https://bbs.pcbeta.com/forum.php?mod=viewthread&tid=2070897&extra=page=1
  @override
  bool isThreadUrl(String? url, {bool onlyMode = false}) {
    bool r = false;
    if (isDiscuz() && url != null) {
      MainSite? tsite;
      Uri? u = onlyMode
          ? (Uri.parse(url))
          : _getSiteUri(
              url,
              siteCall: (urlStr, s) {
                tsite = s;
              },
            );
      if (u != null) {
        String strPath = _fixDiscuzPath(u.path);
        String query = u.query;
        r = strPath.contains('thread-') || (query.contains('viewthread&') && query.contains('tid='));
        if (r) {
          _autoAddMainSitePageInfo(url, tsite, SitePageInfoEvent.thread);
        }
      }
    }
    return r;
  }

  /// https://www.birdnet.cn/mammal.php?mod=show&action=atlasinfo&aid=12289
  @override
  bool isArticleUrl(String? url, {bool onlyMode = false}) {
    bool r = false;
    if (isDiscuz() && url != null) {
      MainSite? tsite;
      Uri? u = onlyMode
          ? (Uri.parse(url))
          : _getSiteUri(
              url,
              siteCall: (urlStr, s) {
                tsite = s;
              },
            );
      if (u != null) {
        String strPath = _fixDiscuzPath(u.path);
        String query = u.query;
        r = query.contains('&aid=') || strPath.contains('article-');
        if (r) {
          _autoAddMainSitePageInfo(url, tsite, SitePageInfoEvent.article);
        }
      }
    }
    return r;
  }

  /// https://www.chiphell.com/home.php?mod=space
  /// https://www.chiphell.com/home.php?mod=space&uid=23348&do=thread&view=me&from=space
  /// https://www.chiphell.com/home.php?mod=space&do=pm
  /// https://www.chiphell.com/home.php?mod=space&do=notice&view=interactive
  /// https://i.pcbeta.com/home.php?mod=space&uid=695499&do=doing&view=me&from=space
  /// https://i.pcbeta.com/home.php?mod=task&item=doing
  /// https://i.pcbeta.com/home.php?mod=magic
  /// https://i.pcbeta.com/home.php?mod=medal
  /// https://i.pcbeta.com/home.php?mod=spacecp&ac=plugin&id=myrepeats:memcp
  /// https://www.birdnet.cn/home.php?mod=space&uid=808760&do=profile&mycenter=1&mobile=2
  /// https://tongda.nb5.cn/space-uid-671667.html
  @override
  bool isAuthorUrl(String? url, {bool onlyMode = false}) {
    bool r = false;
    if (isDiscuz() && url != null) {
      MainSite? tsite;
      Uri? u = onlyMode
          ? (Uri.parse(url))
          : _getSiteUri(
              url,
              siteCall: (urlStr, s) {
                tsite = s;
              },
            );
      if (u != null) {
        String strPath = _fixDiscuzPath(u.path);
        String query = u.query;
        r =
            (strPath == 'home.php' &&
                (query.startsWith('mod=space') ||
                    query.startsWith('mod=task') ||
                    query.startsWith('mod=magic') ||
                    query.startsWith('mod=medal'))) ||
            query.contains('mod=space&username=') ||
            query.contains('mod=space&uid=') ||
            strPath.contains('space-uid-') ||
            strPath.contains('space-username-') ||
            (strPath == '/' && Utils.isMatchRegex(query, r'\d+$'));
        if (r) {
          _autoAddMainSitePageInfo(url, tsite, SitePageInfoEvent.space);
        }
      }
    }
    return r;
  }

  /// 用户相关的链接
  /// https://www.chiphell.com/plugin.php?id=jzsjiale_isms:security
  /// https://www.chiphell.com/plugin.php?id=jzsjiale_isms:security&op=bindmobile
  /// https://i.pcbeta.com/home.php?mod=spacecp&ac=avatar
  /// https://tongda.nb5.cn/plugin.php?id=it618_members:home&ac=bdabout&mobile=2"
  /// https://tongda.nb5.cn/plugin.php?id=it618_credits:wap&dotype=zhuan&ctype=1
  @override
  bool isAuthorAbout(String? url, {bool onlyMode = false}) {
    bool r = false;
    if (isDiscuz() && url != null) {
      MainSite? tsite;
      Uri? u = onlyMode
          ? (Uri.parse(url))
          : _getSiteUri(
              url,
              siteCall: (urlStr, s) {
                tsite = s;
              },
            );
      if (u != null) {
        String strPath = _fixDiscuzPath(u.path);
        String query = u.query;
        if ((strPath.contains('plugin.php') &&
            query.contains('id=') &&
            (query.contains(':security') || query.contains('ac=bdabout') || query.contains('dotype=')))) {
          r = true;
        } else if ((strPath.contains('home.php?') && (query.contains('mod=spacecp') && query.contains('ac=')))) {
          r = true;
        }
        if (r) {
          _autoAddMainSitePageInfo(url, tsite, SitePageInfoEvent.space);
        }
      }
    }
    return r;
  }

  //https://www.chiphell.com/data/avatar/000/18/94/15_avatar_small.jpg
  @override
  bool isAuthorImageUrl(String? url, {bool onlyMode = true}) {
    bool r = false;
    if (url != null && isDiscuz()) {
      Uri? u = _autoUriFromUrl(url, onlyMode: onlyMode);
      if (u != null) {
        String strPath = u.path;
        //strPath = _fixDiscuzPath(strPath);
        r = Utils.isMatchRegex(strPath, r'data/avatar/\d{3}/\d{2}/\d{2}/\d{2}/\d{2}_');
      }
    }
    return r;
  }

  @override
  bool isContentImageUrl(String? url, {bool decoded = false, bool onlyMode = true}) {
    bool r = false;
    if (url != null && isDiscuz()) {
      Uri? u = _autoUriFromUrl(url, decoded: decoded, onlyMode: onlyMode);
      if (u != null) {
        String ex = UtilSite.getFileExtension(uri: u);
        if (ex.isNotEmpty) {
          var rex = Utils.isImageExtension(ex);
          if (rex) {
            r = UtilSite.isDiscuzImageUrlPath(u.path);
          }
        }
        // else {
        //   r = UtilSite.isDiscuzImageAttachmentQuerys(u.queryParameters);
        // }
      }
    }
    return r;
  }

  @override
  bool isImageAttachment(String? url, {bool decoded = false, bool onlyMode = true}) {
    bool r = false;
    if (url != null && isDiscuz()) {
      Uri? u = _autoUriFromUrl(url, decoded: decoded, onlyMode: onlyMode);
      if (u != null) {
        r = UtilSite.isDiscuzImageAttachmentQuerys(u.queryParameters);
      }
    }
    return r;
  }

  @override
  String? imageAttachmentSuggestedFileName(String? url, {bool decoded = false, bool onlyMode = true}) {
    String? r;
    if (url != null && isDiscuz()) {
      Uri? u = _autoUriFromUrl(url, decoded: decoded, onlyMode: onlyMode);
      if (u != null) {
        r = UtilSite.suggestedNameFromDiscuzImageAttachmentQuerys(u.queryParameters);
      }
    }
    return r;
  }

  ///图片 https://bbs.pcbeta.com/forum.php?mod=attachment&aid=NDYyMjM2MHxhMmYwZmUyZXwxNzc3NDcwMjAyfDY5NTQ5OXwyMDY5OTk1&nothumb=yes
  ///zip文件 https://bbs.pcbeta.com/forum.php?mod=attachment&aid=NDEwNzAxNHxkMGFjMzViYXwxNzc4MTM0MDYwfDY5NTQ5OXwxODEyNTM1&ck=51c4ad42
  /// 过渡页面 https://bbs.pcbeta.com/forum.php?mod=misc&action=attachpay&aid=4583422&tid=2052703
  /// 过渡页面 https://bbs.pcbeta.com/forum.php?mod=misc&action=attachcredit&aid=4107014&formhash=3763e3e5
  /// https://cliff.imwork.net:19999/xfbbs/forum.php?mod=attachment&aid=MXxlYjJlOGVhMHwxNzc4Mjk5NTQ4fDF8Mg%3D%3D
  /// https://cliff.imwork.net:19999/xfbbs/forum.php?mod=attachment&aid=MXwzM2U0ZjFiZHwxNzc4MzAwNTAxfDF8Mg==
  @override
  bool isAttachment(String? url, {bool decoded = false, bool onlyMode = true}) {
    bool r = false;
    if (url != null && isDiscuz()) {
      Uri? u = _autoUriFromUrl(url, decoded: decoded, onlyMode: onlyMode);
      if (u != null) {
        r = UtilSite.isDiscuzBinaryAttachmentQuerys(u.queryParameters);
      }
    }
    return r;
  }

  /// https://www.chiphell.com/home.php?mod=spacecp&ac=search&username=%E7%83%AD%E9%97%A8%E4%B8%BB%E6%9D%BF&searchsubmit=yes
  /// https://bbs.pcbeta.com/search.php?searchsubmit=yes
  /// https://www.birdnet.cn/plugin.php?id=one_sms&action=login
  /// https://www.birdnet.cn/plugin.php?id=one_sms&action=user_login&mobile=2
  @override
  bool isLoginUrl(String? url, {bool onlyMode = false}) {
    bool r = false;
    if (isDiscuz() && url != null) {
      MainSite? tsite;
      Uri? u = onlyMode
          ? (Uri.parse(url))
          : _getSiteUri(
              url,
              siteCall: (urlStr, s) {
                tsite = s;
              },
            );
      if (u != null) {
        String strPath = u.path;
        //strPath = _fixDiscuzPath(strPath);
        String query = u.query;
        if (strPath.contains('member.php') &&
            (query.contains('mod=logging&action=login&mobile=2') || query.contains('mod=logging&action=login'))) {
          r = true;
          _autoAddMainSitePageInfo(url, tsite, SitePageInfoEvent.loging);
        } else if (strPath.contains('plugin.php') && (query.contains('action=login') || query.contains('action=user_login'))) {
          r = true;
          _autoAddMainSitePageInfo(url, tsite, SitePageInfoEvent.loging);
        } else if (user.isLogin() == false) {
          if (strPath.contains('home.php') && (query.contains('mod=spacecp&ac=search&username=') || query.contains('searchsubmit=yes'))) {
            r = true;
            _autoAddMainSitePageInfo(url, tsite, SitePageInfoEvent.loging);
          } else if (url == 'https://bbs.pcbeta.com/search.php?searchsubmit=yes') {
            r = true;
          }
        }
      }
    }
    return r;
  }

  /// 发帖 url
  /// https://cliff.imwork.net:19999/xfbbs/forum.php?mod=post&action=newthread&fid=4
  @override
  bool isPostNewthreadUrl(String? url, {bool onlyMode = false}) {
    bool r = false;
    if (url != null && isDiscuz()) {
      Uri? u = onlyMode ? Uri.parse(url) : _getSiteUri(url);
      if (u != null) {
        String strPath = u.path;
        String query = u.query;
        if (strPath.contains('forum.php') &&
            (query.contains('mod=post&action=newthread&mobile=2') || query.contains('mod=post&action=newthread'))) {
          r = true;
        }
      }
    }
    return r;
  }

  /// 高级 回帖 url
  ///https://cliff.imwork.net:19999/xfbbs/forum.php?mod=post&action=reply&fid=2&extra=&tid=1&reppost=1
  @override
  bool isReplyUrl(String? url, {bool onlyMode = false}) {
    bool r = false;
    if (url != null && isDiscuz()) {
      Uri? u = onlyMode ? Uri.parse(url) : _getSiteUri(url);
      if (u != null) {
        String strPath = u.path;
        String query = u.query;
        if (strPath.contains('forum.php') &&
            (query.contains('mod=post&action=reply&mobile=2') || query.contains('mod=post&action=reply'))) {
          r = true;
        }
      }
    }
    return r;
  }

  ///https://bbs.pcbeta.com/search.php?mod=forum&searchid=1407&orderby=lastpost&ascdesc=desc&searchsubmit=yes&kw=%E5%8D%8E%E4%B8%BA%E6%89%8B%E6%9C%BA
  ///https://i.pcbeta.com/home.php?mod=spacecp&ac=search&username=%E5%8D%8E%E4%B8%BA%E6%89%8B%E6%9C%BA&searchsubmit=yes
  ///https://www.chiphell.com/search.php?mod=forum&searchid=2033&orderby=lastpost&ascdesc=desc&searchsubmit=yes&kw=%E7%83%AD%E9%97%A8%E4%B8%BB%E6%9D%BF
  /// 如果没有登陆，这个是登陆页面 https://www.chiphell.com/home.php?mod=spacecp&ac=search&username=%E7%83%AD%E9%97%A8%E4%B8%BB%E6%9D%BF&searchsubmit=yes
  /// 如果没有登陆，这个是登陆页面 https://bbs.pcbeta.com/search.php?searchsubmit=yes
  /// 按照-文章搜索  https://www.chiphell.com/search.php?mod=portal&searchid=2041&searchsubmit=yes&kw=%E4%B8%80%E4%BD%93%E6%95%A3%E7%83%AD%E6%8E%A8%E8%8D%90
  /// 按照-用户搜索  https://www.chiphell.com/home.php?mod=spacecp&ac=search&username=%E4%B8%80%E4%BD%93%E6%95%A3%E7%83%AD%E6%8E%A8%E8%8D%90&searchsubmit=yes
  /// 按照-帖子搜索 https://www.chiphell.com/search.php?mod=forum&searchid=2057&orderby=lastpost&ascdesc=desc&searchsubmit=yes&kw=%E4%B8%80%E4%BD%93%E6%95%A3%E7%83%AD%E6%8E%A8%E8%8D%90
  @override
  bool isSearchUrl(String? url, {bool onlyMode = false}) {
    bool r = false;
    if (url != null && isDiscuz()) {
      Uri? u = onlyMode ? Uri.parse(url) : _getSiteUri(url);
      if (u != null) {
        String strPath = u.path;
        String query = u.query;
        if (strPath.contains('search.php') && query.contains('&kw=') && (query.contains('searchid=') || query.contains('searchsubmit'))) {
          r = true;
        } else if (user.isLogin()) {
          if (strPath.contains('home.php') && (query.contains('mod=spacecp&ac=search&username=') || query.contains('searchsubmit=yes'))) {
            r = true;
          } else if (url == 'https://bbs.pcbeta.com/search.php?searchsubmit=yes') {
            r = true;
          }
        }
      }
    }
    return r;
  }

  @override
  String? authorNameFromTitle(String? title) {
    String? ret;
    if (title == null || title.isEmpty) {
      return ret;
    }
    for (var dstr in ['的帖子', '的个人资料']) {
      if (title.contains(dstr)) {
        ret = title.split(dstr)[0];
        if (ret.isNotEmpty) {
          break;
        } else {
          ret = null;
        }
      }
    }
    return ret;
  }

  @override
  String? convertUrlFromForumUrl(String? url, String? forumId, bool mobile, {bool onlyMode = false}) {
    String? r;
    if (isDiscuz() && url != null) {
      Uri? u = onlyMode ? Uri.parse(url) : _getSiteUri(url);
      if (u != null) {
        String strPath = u.path;
        String query = u.query;
        Map<String, String> qp = u.queryParameters;
        if (strPath.contains('member.php') &&
            (query.contains('mod=logging&action=login&mobile=2') || query.contains('mod=logging&action=login'))) {
        } else {
          String? ret;
          String? page = '1';
          int type = qp.containsKey('catid') ? 1 : 0;
          //forum-3-1.html'; &page=2
          if (qp.containsKey('page')) {
            page = qp['page'];
          } else if (Utils.isMatchRegex(strPath, r"forum-\d+-\d+.html")) {
            page = Utils.stringRegex(strPath, r"forum-\d+-(\d)+.html");
          }
          if (forumId != null && forumId.isNotEmpty) {
            if (type == 0) {
              if (page == null || page == '' || page == '1') {
                ret = '$origin/portal.php?mod=list&catid=$forumId';
              } else {
                ret = '$origin/portal.php?mod=list&catid=$forumId&page=$page';
              }
            } else {
              ret = '$origin/forum-$forumId-$page.html';
            }
            if (query.contains('mobile=2')) {
              ret = '$ret?mobile=2';
            } else if (query.contains('mobile=3')) {
              ret = '$ret?mobile=3';
            }
          }
          return ret;
        }
      }
    }
    return r;
  }

  @override
  String? convertUrlFromUrl(String? url, bool toPC, bool mobile, {bool onlyMode = false}) {
    String? r;
    if (isDiscuz() && url != null) {
      Uri? u = onlyMode ? Uri.parse(url) : _getSiteUri(url);
      if (u != null) {
        String strPath = u.path;
        String query = u.query;
        strPath = _fixDiscuzPath(strPath);
        if (strPath == '' || strPath == '/' || (strPath == 'portal.php' && query.isEmpty)) {
          r = url;
        } else {
          if (toPC) {
            //mob to pc
            if (strPath == 'member.php' && query.contains('mod=logging&action=login')) {
              r = url;
            } else if (strPath == 'forum.php' && query.isEmpty) {
              r = url;
            } else if (strPath == 'forum.php' && query.isEmpty) {
              r = url;
            } else if (url.contains(RegExp(r'[&?]mobile=\d+'))) {
              r = url.replaceFirst(RegExp(r'[&?]mobile=\d+'), '');
            } else {
              r = url;
            }
          } else {
            if (Utils.isMacOS()) {
              if (url.contains(RegExp(r'mobile=[no12]'))) {
                return url.replaceFirst(RegExp(r'mobile=[no12]'), 'mobile=3');
              }
              if (url.contains('?')) {
                return '$url&mobile=3';
              }
              return '$url?mobile=3';
            } else {
              if (url.contains(RegExp(r'mobile=[no13]'))) {
                return url.replaceFirst(RegExp(r'mobile=[no13]'), 'mobile=2');
              }
              if (url.contains('?')) {
                return '$url&mobile=2';
              }
              return '$url?mobile=2';
            }
          }
        }
      }
    }
    return r;
  }

  static Future<WebSite?> fromPref(String urlOrigin) async {
    WebSite? r;
    if (urlOrigin.isNotEmpty) {
      var str = await Prefs.getStringOrDefault('${SiteConstants.kPrefWebSitePrefix}$urlOrigin');
      if (str.isNotEmpty) {
        try {
          var mp = jsonDecode(str);
          r = WebSite.fromMap(mp);
        } catch (e) {
          ZsLog.e('WebSite fromPref[$urlOrigin] jsondecode error:', error: e);
        }
      }
    }
    return r;
  }

  /// discuz 的类型才保存
  @override
  Future<void> save({bool force = false}) async {
    if (mainSite != null) {
      await mainSite!.saveToDb();
      for (int i = 0; i < sameDomainSites.length; i++) {
        var v = sameDomainSites[i];
        await v.saveToDb();
      }
    }
  }

  ///webview 成功打开一个页面
  @override
  Future<void> didShowUrl(String? url) async {
    if (url == null || url.isEmpty) {
      return;
    }
    if (mainSite != null && mainSite?.isSite(url) == true) {
      mainSite!.updateLastUrl(url);
      return;
    }
    if (currentSameDomainSite != null && (currentSameDomainSite != mainSite) && currentSameDomainSite?.isSite(url) == true) {
      currentSameDomainSite!.updateLastUrl(url);
      return;
    }
    for (int i = 0; i < sameDomainSites.length; i++) {
      var v = sameDomainSites[i];
      if (v.isSite(url) == true) {
        currentSameDomainSite = v;
        await v.updateLastUrl(url);
        break;
      }
    }
  }

  @override
  bool canSaveLast(String? url) {
    bool r = false;
    if (isDiscuz() && url != null && url.isNotEmpty) {
      Uri? u = _autoUriFromUrl(url, onlyMode: false);
      r =
          (u != null &&
          (Utils.isHttpScheme(u.scheme)) &&
          isSite(url) &&
          (isHomeUrl(url, onlyMode: true) ||
              isThreadUrl(url, onlyMode: true) ||
              isArticleUrl(url, onlyMode: true) ||
              isForumUrl(url, onlyMode: true) ||
              isAreaUrl(url, onlyMode: true)));
    }
    return r;
  }

  void _changedAdd() {
    changed ??= 0;
    changed = changed! + 1;
  }

  void updateLastUrl(String val) {
    if (val != lastUrl && (val.length > 5) && canSaveLast(val)) {
      lastUrl = val;
      didShowUrl(val);
      _changedAdd();
    }
  }

  bool updatePromptMessage(PromptMsg val) {
    bool r = false;
    if (user.updatePromptMessage(val)) {
      _changedAdd();
      r = true;
    }
    return r;
  }

  bool updateUserInfo({String? name, String? userUrl, String? userIcon, String? uid, String? authCookie}) {
    int i = 0;
    if (user.updateCookieAuth(authCookie)) {
      i++;
    }
    if (user.updateName(name)) {
      i++;
    }
    if (user.updateUrl(userUrl)) {
      i++;
    }
    if (user.updateIconUrl(userIcon)) {
      i++;
    }
    if (user.updateUid(uid)) {
      i++;
    }
    if (i > 0) {
      _changedAdd();
    }
    return i > 0;
  }

  bool updateSiteInfo({String? ptitle, String? pdomain, String? porigin}) {
    int i = 0;
    if (ptitle != null && title != ptitle) {
      title = ptitle;
      i++;
    }
    if (pdomain != null && pdomain != domain) {
      domain = pdomain;
      i++;
    }
    if (porigin != null && porigin != origin) {
      origin = porigin;
      i++;
    }
    if (i > 0) {
      _changedAdd();
    }
    return i > 0;
  }

  /// mainsite 更新的keys
  bool updateMainSiteMaps(Map<String, dynamic> map) {
    int i = 0;
    String? t = UtilMap.safeStringForKey(map, MainSite.columnTitle);
    if (t != null && t != title) {
      title = t;
      i++;
    }
    t = UtilMap.safeStringForKey(map, MainSite.columnDomain);
    if (t != null && t != domain) {
      domain = t;
      i++;
    }
    if (i > 0) {
      _changedAdd();
    }
    return i > 0;
  }

  static final cookieKey = 'Cookie';
  String? get cookieFromInfo => UtilMap.safeStringForKey(info, cookieKey);
  bool updateCookieToInfo(String? cookie) {
    bool r = false;
    final value = UtilMap.safeStringForKey(info, cookieKey);
    if (value != cookie) {
      if (cookie == null) {
        info.remove(cookieKey);
        r = true;
      } else {
        info[cookieKey] = cookie;
        r = true;
      }
    }
    if (r) {
      _changedAdd();
    }
    return r;
  }

  String? get cssExtensionName {
    String? r = mainSite?.cssExtensionName;
    if (r == null && host.isNotEmpty) {
      r = UtilSite.cssFileNameFromHost(host);
    }
    return r;
  }
}
