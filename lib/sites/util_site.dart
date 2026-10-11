import '../utils/utils.dart';

class UtilSite {
  static String? domainFromUrl({String? url, Uri? uri}) {
    String? domain;
    var u = uri ?? (url != null ? Uri.parse(url) : null);
    if (u != null) {
      var hostName = u.host;
      if (hostName.contains('.')) {
        var list = hostName.split('.');
        if (list.length == 2) {
          domain = hostName;
        } else if (list.length >= 3) {
          if (list.first == 'www' || list.first == 'bbs') {
            list = list.sublist(1);
          } else {
            if (list[list.length - 2].length > 3) {
              //二级域名
              list = list.sublist(list.length - 2);
            } else {
              //三级域名
              list = list.sublist(list.length - 3);
            }
          }
          domain = list.join('.');
        }
      }
    }
    return domain;
  }

  static String? domainFromHost({String? hostName}) {
    String? domain;
    if (hostName != null) {
      if (hostName.contains('/')) {
        //www.baid.com/a
        hostName = hostName.split('/').first;
      }
      if (hostName.contains(':')) {
        //www.baid.com:9999
        hostName = hostName.split(':').first;
      }
      if (hostName.contains('.')) {
        var list = hostName.split('.');
        if (list.length == 2) {
          domain = hostName;
        } else if (list.length >= 3) {
          if (list.first == 'www' || list.first == 'bbs') {
            list = list.sublist(1);
          } else {
            if (list[list.length - 2].length > 3) {
              //二级域名
              list = list.sublist(list.length - 2);
            } else {
              //三级域名
              list = list.sublist(list.length - 3);
            }
          }
          domain = list.join('.');
        }
      }
    }
    return domain;
  }

  static bool isSameDomain(String url1, String url2) {
    bool r = false;
    Uri u1 = Uri.parse(url1);
    Uri u2 = Uri.parse(url2);
    r = (u1.host == u2.host);
    if (!r) {
      String? d1 = domainFromUrl(uri: u1);
      String? d2 = domainFromUrl(uri: u2);
      r = (d1 != null && d2 != null) && (d1 == d2);
    }
    return r;
  }

  //cliff.imwork.net:19999 cliff.imwork.net
  //cliff.imwork.net:19999 cliff.imwork.net
  static bool isSameDomainFromHost(String host1, String host2) {
    bool r = false;
    r = isSampleSameDomainFromHost(host1, host2);
    if (!r) {
      String? d1 = domainFromHost(hostName: host1.toLowerCase());
      String? d2 = domainFromHost(hostName: host2.toLowerCase());
      r = (d1 != null && d2 != null) && (d1 == d2);
    }
    return r;
  }

  static bool isSampleSameDomainFromHost(String host1, String host2, {bool same = true}) {
    bool r = false;
    if (host1 == host2 || host1 == host2) {
      r = true;
    } else if (same && (host1.endsWith(host2) || host2.endsWith(host1))) {
      r = true;
    }
    return r;
  }

  //cliff.imwork.net ->  cliff.imwork.net
  //cliff.imwork.net:19999 ->  cliff.imwork.net_19999
  //cliff.imwork.net:19999/xfbbs ->  cliff.imwork.net-19999_xfbbs
  static String? cssFileNameFromHost(String? host) {
    String? r = host;
    if (r != null) {
      r = r.replaceFirst(RegExp(r':'), '-');
      r = r.replaceAll(RegExp(r'[\\/?*:";<>|]'), '_');
    }
    return r;
  }

  static String? cssFileNameFromUrl(String? url) {
    String? r;
    if (url != null && url.length > 5) {
      Uri uri = Uri.parse(url);
      r = cssFileNameFromHost(uri.authority);
    }
    return r;
  }

  ///chiphell 已经知道的图片链接
  ///  https://www.chiphell.com/data/avatar/000/18/94/15_avatar_small.jpg
  /// 'https://static.chiphell.com/portal/202511/24/084035sd87gymzd5mtmgk9.gif';
  /// 'https://static.chiphell.com/forum/202511/18/142935i0bhlvqkjlkdcg0k.jpg';
  /// // /data/attachment/forum/202604/29/095635gjzwztjm1ejrwwy2.png
  static bool isDiscuzImageUrlPath(String urlPath) {
    const List<String> regexs = [
      r'/[0-9]{4,6}/[0-9]{2}/[a-z|A-Z|0-9]{10,30}.\w+',
      r'/data/avatar/[0-9]+/[0-9]+/[0-9]+/.*',
      r'/static/image/.*',
    ];
    bool r = false;
    for (int i = 0; i < regexs.length; i++) {
      if (Utils.isMatchRegex(urlPath, regexs[i])) {
        r = true;
        break;
      }
    }
    return r;
  }

  ///图片 https://bbs.pcbeta.com/forum.php?mod=attachment&aid=NDYyMjM2MHxhMmYwZmUyZXwxNzc3NDcwMjAyfDY5NTQ5OXwyMDY5OTk1&nothumb=yes
  static bool isDiscuzImageAttachmentQuerys(Map<String, String> queryParameters) {
    bool r = false;
    Map<String, String> qp = queryParameters;
    if ((qp.containsKey('aid') & qp.containsKey('nothumb') &&
            qp.containsKey('mod') &&
            Utils.isMatchRegex(qp['aid'], r'[a-z|A-Z|0-9|=]{20,}')) &&
        (qp['mod'] == 'attachment') &&
        (qp['nothumb'] == 'yes')) {
      r = true;
    }
    return r;
  }

  ///图片 https://bbs.pcbeta.com/forum.php?mod=attachment&aid=NDYyMjM2MHxhMmYwZmUyZXwxNzc3NDcwMjAyfDY5NTQ5OXwyMDY5OTk1&nothumb=yes
  /// 输出 aid value
  static String? suggestedNameFromDiscuzImageAttachmentQuerys(Map<String, String> queryParameters) {
    String? r;
    Map<String, String> qp = queryParameters;
    if ((qp.containsKey('aid') & qp.containsKey('nothumb') &&
            qp.containsKey('mod') &&
            Utils.isMatchRegex(qp['aid'], r'[a-z|A-Z|0-9|=]{20,}')) &&
        (qp['mod'] == 'attachment') &&
        (qp['nothumb'] == 'yes')) {
      r = qp['aid'];
    }
    return r;
  }

  ///zip https://bbs.pcbeta.com/forum.php?mod=attachment&aid=NDEwNzAxNHxkMGFjMzViYXwxNzc4MTM0MDYwfDY5NTQ5OXwxODEyNTM1&ck=51c4ad42
  ///zip https://bbs.pcbeta.com/forum.php?mod=attachment&aid=NDEwNzAxNHxkMGFjMzViYXwxNzc4MTM0MDYwfDY5NTQ5OXwxODEyNTM1
  static bool isDiscuzBinaryAttachmentQuerys(Map<String, String> queryParameters) {
    bool r = false;
    Map<String, String> qp = queryParameters;
    if ((qp.containsKey('aid') & qp.containsKey('mod') && Utils.isMatchRegex(qp['aid'], r'[a-z|A-Z|0-9|=]{30,}')) &&
        (qp['mod'] == 'attachment')) {
      if (qp.containsKey('ck') || queryParameters.length == 2) {
        r = true;
      }
    }
    return r;
  }

  /// 过渡页面 https://bbs.pcbeta.com/forum.php?mod=misc&action=attachpay&aid=4583422&tid=2052703
  /// 过渡页面 https://bbs.pcbeta.com/forum.php?mod=misc&action=attachcredit&aid=4107014&formhash=3763e3e5
  static bool isDiscuzHtmlAttachmentQuerys(Map<String, String> queryParameters) {
    bool r = false;
    Map<String, String> qp = queryParameters;
    if ((qp.containsKey('aid') & qp.containsKey('action') &&
        qp.containsKey('mod') &&
        (qp['mod'] == 'misc') &&
        (qp['action'] == 'attachpay' || qp['action'] == 'attachcredit') &&
        Utils.isMatchRegex(qp['aid'], r'^[0-9]+$'))) {
      r = true;
    }
    return r;
  }

  static String getFileExtension({String? url, Uri? uri}) {
    String r = '';
    try {
      var u = uri ?? (url != null ? Uri.parse(url) : null);
      if (u != null) {
        final path = u.path;
        if (path.isEmpty) {
          // 无路径的情况
        } else {
          final fileName = path.split('/').last;
          final dotIndex = fileName.lastIndexOf('.');
          // 处理无扩展名或隐藏文件的情况
          if (dotIndex == -1 || dotIndex == fileName.length - 1) {
          } else {
            r = fileName.substring(dotIndex + 1).toLowerCase();
          }
        }
      }
    } catch (e) {
      // 无效URL处理
    }
    return r;
  }

  // 223101 -> ./data/avatar/000/22/31/01_avatar_middle.jpg
  //https://www.chiphell.com/data/avatar/000/22/31/01_avatar_middle.jpg
  //uid=150944 https://www.chiphell.com/data/avatar/000/15/09/44_avatar_middle.jpg
  // uid=2 --> https://www.chiphell.com/data/avatar/000/00/00/02_avatar_middle.jpg
  static String? authIconUrlFromUID(String uid) {
    String? r;
    String zu1 = '000';
    String zu2 = '00';
    String zu3 = '00';
    String zu4 = '00';
    int len = uid.length;
    if (len <= 0 || uid == '0') {
      return r;
    } else if (len == 1) {
      zu4 = '0$uid';
    } else if (len == 2) {
      zu4 = uid;
    } else if (len == 3) {
      var v3 = Utils.stringRegex(uid, r'([0-9]{1})');
      if (v3 != null) {
        zu3 = '0$v3';
      }
      var v4 = Utils.stringRegex(uid, r'[0-9]{1}([0-9]{2})');
      if (v4 != null) {
        zu4 = v4;
      }
    } else if (len == 4) {
      var v3 = Utils.stringRegex(uid, r'([0-9]{2})');
      if (v3 != null) {
        zu3 = v3;
      }
      var v4 = Utils.stringRegex(uid, r'[0-9]{2}([0-9]{2})');
      if (v4 != null) {
        zu4 = v4;
      }
    } else if (len == 5) {
      var v2 = Utils.stringRegex(uid, r'([0-9]{1})');
      if (v2 != null) {
        zu2 = '0$v2';
      }
      var v3 = Utils.stringRegex(uid, r'[0-9]{1}([0-9]{2})');
      if (v3 != null) {
        zu3 = v3;
      }
      var v4 = Utils.stringRegex(uid, r'[0-9]{1}[0-9]{2}([0-9]{2})');
      if (v4 != null) {
        zu4 = v4;
      }
    } else if (len == 6) {
      var v2 = Utils.stringRegex(uid, r'([0-9]{2})');
      if (v2 != null) {
        zu2 = v2;
      }
      var v3 = Utils.stringRegex(uid, r'[0-9]{2}([0-9]{2})');
      if (v3 != null) {
        zu3 = v3;
      }
      var v4 = Utils.stringRegex(uid, r'[0-9]{2}[0-9]{2}([0-9]{2})');
      if (v4 != null) {
        zu4 = v4;
      }
    } else if (len == 7) {
      var v1 = Utils.stringRegex(uid, r'([0-9]{1})');
      if (v1 != null) {
        zu1 = '00$v1';
      }
      var v2 = Utils.stringRegex(uid, r'[0-9]{1}([0-9]{2})');
      if (v2 != null) {
        zu2 = v2;
      }
      var v3 = Utils.stringRegex(uid, r'[0-9]{1}[0-9]{2}([0-9]{2})');
      if (v3 != null) {
        zu3 = v3;
      }
      var v4 = Utils.stringRegex(uid, r'[0-9]{1}[0-9]{2}[0-9]{2}([0-9]{2})');
      if (v4 != null) {
        zu4 = v4;
      }
    } else if (len == 8) {
      var v1 = Utils.stringRegex(uid, r'([0-9]{2})');
      if (v1 != null) {
        zu1 = '0$v1';
      }
      var v2 = Utils.stringRegex(uid, r'[0-9]{2}([0-9]{2})');
      if (v2 != null) {
        zu2 = v2;
      }
      var v3 = Utils.stringRegex(uid, r'[0-9]{2}[0-9]{2}([0-9]{2})');
      if (v3 != null) {
        zu3 = v3;
      }
      var v4 = Utils.stringRegex(uid, r'[0-9]{2}[0-9]{2}[0-9]{2}([0-9]{2})');
      if (v4 != null) {
        zu4 = v4;
      }
    } else if (len == 9) {
      var v1 = Utils.stringRegex(uid, r'([0-9]{3})');
      if (v1 != null) {
        zu1 = v1;
      }
      var v2 = Utils.stringRegex(uid, r'[0-9]{3}([0-9]{2})');
      if (v2 != null) {
        zu2 = v2;
      }
      var v3 = Utils.stringRegex(uid, r'[0-9]{3}[0-9]{2}([0-9]{2})');
      if (v3 != null) {
        zu3 = v3;
      }
      var v4 = Utils.stringRegex(uid, r'[0-9]{3}[0-9]{2}[0-9]{2}([0-9]{2})');
      if (v4 != null) {
        zu4 = v4;
      }
    } else {
      return r;
    }

    r = 'https://www.chiphell.com/data/avatar/$zu1/$zu2/$zu3/${zu4}_avatar_middle.jpg';
    return r;
  }

  //https://www.chiphell.com/home.php?mod=space&uid=223101&mobile=3
  //https://www.chiphell.com/space-uid-223101.html
  //返回 https://www.chiphell.com/data/avatar/000/22/31/01_avatar_middle.jpg
  static String? authIconUrlFromUserSpaceUrl(String? spaceUrl) {
    const String spaceUrlReg = r'space-uid-([0-9]{1,9})';
    const String mbSpaceUrlReg = r'uid=([0-9]{1,9})';
    String? r;
    if (spaceUrl != null && spaceUrl.contains('space') && spaceUrl.contains('uid')) {
      String? uid = Utils.stringRegex(spaceUrl, spaceUrlReg);
      uid ??= Utils.stringRegex(spaceUrl, mbSpaceUrlReg);
      if (uid != null) {
        r = authIconUrlFromUID(uid);
      }
    }
    return r;
  }
  // bool queryParametersContains(Map<String, String>queryParameters ,List<String>keys)
  // {

  //    Map<String, String> qp = u.queryParameters;
  // }

  static String fixDiscuzPath(String? basePath, String strPath) {
    String r = strPath;
    var bpath = basePath; // mainSite?.path;
    if (bpath != null && bpath.isNotEmpty) {
      String prefix = '/$bpath';
      if (strPath.startsWith(prefix)) {
        r = strPath.substring(prefix.length);
      } else {
        //返回无效
        r = '';
      }
    }
    return r;
  }
}



//  Uri u = Uri.parse(
//         'https://www.bilibili.com/video/BV1K29yBMEjA/?spm_id_from=333.1007.tianma.2-3-6.click&vd_source=be08631a16a6e96ec93e5c0faa1ddd1d');
//     String v1 = u.path;//  /video/BV1K29yBMEjA/
//     String v2 = u.query;//spm_id_from=333.1007.tianma.2-3-6.click&vd_source=be08631a16a6e96ec93e5c0faa1ddd1d
//     String v3 = u.fragment;
//     String v4 = u.host; //不包括端口 www.bilibili.com
//     String v5 = u.scheme; //https
//     String v6 = u.userInfo; // ""
//     int v7 = u.port;//https返回443    ； http返回80
//     var v8 = u.pathSegments; // List (3 items) 'video','BV1K29yBMEjA','' 
//     var v9 = u.queryParameters; //v9.keys.length=2; keys{'spm_id_from'; 'vd_source'}
//     var v10 = u.queryParametersAll;
//     var v11 = u.origin; //https://www.bilibili.com https://www.chiphell.com:999
//     u.authority;  www.bilibili.com ; www.chiphell.com:999
//     print('dd');
//   u.query = mod=viewthread&tid=2070897&extra=page%3D1 //不会解码


// 'styleid':STYLEID,
//                 'uid':discuz_uid,
//                 'cookiepre': cookiepre,
//                 'cookiedomain':cookiedomain,
//                 'cookiepath':cookiepath,
//                 'imgdir':IMGDIR,
//                 'staticurl':STATICURL,
//                 'verhash':VERHASH,
//                 'charset':charset,
//                 'reporturl':REPORTURL,
//                 'siteurl':SITEURL,
//                 'dynamicurl':DYNAMICURL,
// var STYLEID = '6',
// STATICURL = 'static/',
// IMGDIR = 'static/image/common',
// VERHASH = 'OnV', charset = 'utf-8',
// discuz_uid = '695499',
// cookiepre = 'jqCP_887f_',
// cookiedomain = 'pcbeta.com',
// cookiepath = '/',
// showusercard = '0',
// attackevasive = '0',
// disallowfloat = 'login|newthread|viewvote|tradeorder|activity|debate|task',
// creditnotice = '1|PB币|,2|威望|,3|贡献|,4|技术|,5|活跃|',
// defaultstyle = '',
// REPORTURL = 'aHR0cHM6Ly9iYnMucGNiZXRhLmNvbS9mb3J1bS01NzYtMS5odG1s',
// SITEURL = 'https://bbs.pcbeta.com/',
// JSPATH = 'data/cache/',
// CSSPATH = 'data/cache/style_',
// DYNAMICURL = '';

//   jqCP_887f_auth	"6dfcftstRb9WN18OKCFXIdZHEyBWUGxxpwcPw6li80Bapc8++mR/zxWDnz3BGjr5NsyrQhn3fdcD/2amnhOh8bT8Fpk"
// jqCP_887f_forum_lastvisit	"D_571_1774486228D_574_1776505077D_548_1777182224D_563_1777182226D_497_1777470164D_576_1777472948"
// jqCP_887f_home_readfeed	"1777182196"
// jqCP_887f_lastact	"1777474818\tforum.php\tajax"
// jqCP_887f_lastcheckfeed	"695499|1777167426"
// jqCP_887f_lastvisit	"1777163821"
// jqCP_887f_saltkey	"b0I3a657"
// jqCP_887f_sid	"0"
// jqCP_887f_smile	"9D1"
// jqCP_887f_st_p	"695499|1777470202|87574f78051258548efac461b8b9da8b"
// jqCP_887f_st_t	"695499|1777472948|8194aa8c5affd276140a168b4ef7a5d2"
// jqCP_887f_ulastactivity	"1777472948|0"
// jqCP_887f_uuid	"695499"
// jqCP_887f_viewid	"tid_2069995"
