import 'dart:convert';

import 'package:chiphell/net/download_file.dart';
import 'package:chiphell/utils/utils.dart';
import 'package:chiphell/utils/zs_log.dart';

class JsonXpathParser {
  static bool ableJsonString(String r) {
    bool res = false;
    if (r.startsWith("{") && r.endsWith("}")) {
      res = true;
    } else if (r.startsWith("[") && r.endsWith("]")) {
      res = true;
    }
    return res;
  }

  static dynamic jsonStringDecode(String? json) {
    try {
      return json != null ? jsonDecode(json) : null;
    } catch (e) {
      ZsLog.e('json decode error:$e, json:$json');
    }
    return null;
  }

  //window.baidu.sug({q:"a",p:false,s:["AI伙伴","a i 人工智能"]});
  //{q:"a",p:false,s:["AI伙伴","a i 人工智能"]}
  static String jsonStringFromQueryResult(String qstr) {
    String r = qstr.trim();
    if (r.isEmpty || JsonXpathParser.ableJsonString(r)) {
      return r;
    }
    // [a-zA-Z0-9|.='\s()]+\s*[(](.*)[\/][*]+\s*[a-z_]+\s+[*][\/][)][;]
    String? v = Utils.stringRegex(r, r'[a-z|A-Z|0-9|.]+\s*[(](.*)[)]');
    if (v != null) {
      v = v.trim();
      if (!JsonXpathParser.ableJsonString(v)) {
        v = null;
      }
    }
    v ??= Utils.stringRegex(
      r,
      r"[a-zA-Z0-9|.='\s()]+\s*[(](.*)[\/][*]+\s*[a-z_]+\s+[*][\/][)][;]",
    );
    r = v ?? r;
    return r;
  }

  static List<String> _firstPath(String xpath) {
    List<String> rs = [];
    int idx = 0;
    String apath = xpath;
    if (xpath.startsWith('./') || xpath.startsWith('//')) {
      apath = xpath.substring(2);
    } else if (xpath.startsWith('/')) {
      apath = xpath.substring(1);
    }
    idx = apath.indexOf('/');
    if (idx < 0) {
      rs.add(apath);
      rs.add('');
    } else {
      rs.add(apath.substring(0, idx));
      if (idx + 1 < apath.length) {
        rs.add(apath.substring(idx + 1));
      } else {
        rs.add('');
      }
    }
    return rs;
  }

  static dynamic _parserDict(Map<dynamic, dynamic> dict, dynamic key) {
    return dict.containsKey(key) ? dict[key] : null;
  }

  static dynamic _parserArray(List<dynamic> array, int index) {
    if (index >= 0 && (index < array.length)) {
      return array[index];
    }
    return null;
  }

  static dynamic _parserArrayAll(List<dynamic> array, String xpath) {
    List<dynamic> rs = [];
    for (int i = 0; i < array.length; i++) {
      var item = array[i];
      var r = parserXpath(item, xpath);
      if (r != null) {
        if (r is List) {
          rs.addAll(r);
        } else {
          rs.add(r);
        }
        //如果是一个map是否要合并呢
      }
    }
    return rs;
  }

  //支持: ./; //a/b/c/0;
  static dynamic parserXpath(dynamic root, String xpath) {
    if (root == null || xpath.isEmpty || xpath == './' || xpath == '/') {
      return root;
    }
    List<String> keys = _firstPath(xpath);
    String name = keys[0];
    String nextPath = keys[1];
    if (root is Map<dynamic, dynamic>) {
      if (name == "*") {
        return _parserArrayAll(root.values.toList(growable: false), nextPath);
      } else {
        var r = _parserDict(root, name);
        if (nextPath.isEmpty) {
          return r;
        } else {
          return parserXpath(r, nextPath);
        }
      }
    } else if (root is List<dynamic>) {
      if (name == "*") {
        return _parserArrayAll(root, nextPath);
      } else {
        String? idxStr = Utils.stringRegex(name, r'([-]{0,1}\d+)');
        if (idxStr != null && idxStr.isNotEmpty) {
          var i = int.tryParse(idxStr);
          if (i == null) {
            return null;
          }
          var r = _parserArray(root, i);
          if (nextPath.isEmpty) {
            return r;
          } else {
            return parserXpath(r, nextPath);
          }
        } else {
          return null;
        }
      }
    } else {
      if (name == "*" || name == "") {
        return root;
      } else {
        return null;
      }
    }
  }

  static void test() async {
    ZsLog.d('JsonXpathParser test start--------');
    String xpath = "./a/b/c/0/2/d";
    while (true) {
      var r = _firstPath(xpath);
      var f = r[0];
      var nx = r[1];
      ZsLog.i('xpath($xpath),first($f),nextXpath($nx) ');
      xpath = nx;
      if (nx == '') {
        break;
      }
    }
    var js = jsonStringFromQueryResult(
      """window.baidu.sug({q:"a",p:false,s:["AI伙伴","a i 人工智能"]});""",
    );
    var js1 = jsonStringFromQueryResult("""
if(typeof window.bing.sug == 'function') window.bing.sug({"AS":{"Query":"a","FullResults":1,"Results":[{"Type":"AS","Suggests":[{"Txt":"atk网页驱动","Type":"FT","Sk":"","HCS":0},{"Txt":"爱奇艺","Type":"SC","Sk":"FT1","HCS":0},{"Txt":"aigc检测","Type":"FT","Sk":"FT1SC1"},{"Txt":"阿里云","Type":"SC","Sk":"FT2SC1"},{"Txt":"ao3镜像发布页","Type":"FT","Sk":"FT2SC2"},{"Txt":"aiyi爱壹帆","Type":"LT","Sk":"FT3SC2"},{"Txt":"amd","Type":"CT","Sk":"FT3SC2LT1"},{"Txt":"阿里巴巴","Type":"SC","Sk":"FT3SC2LT1CT1"}]}]}}/* pageview_candidate */);
""");
    var object = JsonXpathParser.jsonStringDecode(js);
    var object2 = JsonXpathParser.jsonStringDecode(js1);
    ZsLog.i('$object');
    ZsLog.i("$object2");

    //var a = JsonXpathParser.parserXpath(object, './s');
    //var b = JsonXpathParser.parserXpath(object2, './AS/Results/0/Suggests');

    ZsLog.d('JsonXpathParser test end--------');

    await DownloadFile.searchEnginSuggestion('a', engin: SearchEngin.baidu);
    //await DownloadFile.searchEnginSuggestion('a', engin: SearchEngin.bing);
  }
}
