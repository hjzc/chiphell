import 'dart:io';
import 'dart:typed_data';

import 'package:chiphell/net/json_xpath_parser.dart';
import 'package:chiphell/utils/file_operations.dart';
import 'package:chiphell/utils/util_list.dart';
import 'package:chiphell/utils/utils.dart';
import 'package:chiphell/utils/zs_log.dart';
import 'package:http/http.dart' as http;

import '../common/type_utils.dart';

enum SearchEngin { baidu, bing, google }

class DownloadFile {
  static void test() {
    JsonXpathParser.test();
  }

  // ignore: non_constant_identifier_names
  static HttpClient DownloadClient() {
    var ioClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // 证书无效 或者没有认证，报错
        /// HandshakeException (HandshakeException: Handshake error in client (OS Error:
        /// CERTIFICATE_VERIFY_FAILED: application verification failure(handshake.cc:298)))
        return true;
      };
    return ioClient;
  }

  /// 使用 HttpClient 流式下载大文件
  /// [url] 文件下载地址
  /// [savePath] 文件保存的本地路径
  /// [onProgress] 用于更新进度的回调函数（可选）
  /// [targetFilePath] 目的文件
  /// [sugFileName] 建议的文件名称
  /// [sugExtension] 建议的文件扩展名
  /// [cover] 是否覆盖文件,true 覆盖，false，自动生成可用文件名称
  static Future<bool> downloadLargeFile(
    String url, {
    Map<String, String>? header,
    String? sugFileName,
    String? sugExtension,
    String? targetFilePath,
    bool cover = false,
    void Function(int received, int total)? onProgress,
    ResultCallback? callback,
  }) async {
    bool r = false;
    final client = DownloadClient();
    try {
      // 1. 发起请求
      Uri uri = Uri.parse(url);
      var request = await client.getUrl(uri);
      if (header != null) {
        header.forEach((key, value) {
          request.headers.add(key, value);
        });
      }
      var response = await request.close();
      var redirectCount = 0;
      const redirectMax = 5;
      Uri srcUri = uri;
      while (response.isRedirect && (redirectCount <= redirectMax)) {
        redirectCount++;
        response.drain();
        final location = response.headers.value(HttpHeaders.locationHeader);
        if (location != null) {
          srcUri = uri.resolve(location);
          request = await client.getUrl(srcUri);
          if (header != null) {
            header.forEach((key, value) {
              request.headers.add(key, value);
            });
          }
          if (redirectCount >= redirectMax) {
            request.followRedirects = false;
          }
          response = await request.close();
        }
      }

      // 2. 检查 HTTP 状态码
      if (response.statusCode == HttpStatus.ok) {
        String savePath = '';
        if (targetFilePath != null && targetFilePath.isNotEmpty) {
          savePath = targetFilePath;
        } else {
          String? mmt = response.headers.contentType?.mimeType;
          //attachment; filename="site.json.zip"
          String? cd = response.headers.value(Utils.httpResHeaderContentDisposition);
          //var resHeaderList = response.headersSplitValues;
          String path = srcUri.path;
          String? filename;
          String? ex = Utils.httpUrlExtensionFromResponse(
            srcUri.toString(),
            resHeader: null,
            resMimeType: mmt,
            resContentDisposition: cd,
            sugExtension: sugExtension,
            body: null,
            result: (name, ex) {
              filename = name;
            },
          );
          filename ??= sugFileName;
          filename ??= Utils.pathBasename(path);
          filename ??= Utils.dateTimeFileName(filename, ex: ex);
          savePath = await Utils.getDownloadPathForSystem(filename!);
        }
        if (cover == false) {
          savePath = Utils.autoPathNoExist(savePath);
        } else if (Utils.fileExist(savePath)) {
          Utils.deleteFile(savePath);
        }

        // 3. 获取文件总大小 (用于计算进度)
        final contentLength = response.contentLength;
        int receivedBytes = 0;

        // 4. 打开文件写入流 (关键: 避免一次性加载整个文件)
        final file = File(savePath);
        final sink = file.openWrite();

        // 5. 监听数据流，边接收边写入
        await for (final List<int> chunk in response) {
          // 将数据块写入文件
          sink.add(chunk);
          // 更新进度 (如果提供了回调)
          if (onProgress != null) {
            receivedBytes += chunk.length;
            if (contentLength > 0) {
              onProgress(receivedBytes, contentLength);
            }
          }
        }
        // 6. 关闭写入流
        await sink.close();
        r = true;
        ZsLog.i('下载完成，文件已保存至: $savePath');
        if (callback != null) {
          callback('下载目录失败}', savePath, r);
        }
      } else {
        ZsLog.e('HTTP请求失败，状态码: ${response.statusCode}');
        if (callback != null) {
          callback('下载失败', null, false);
        }
      }
    } catch (e) {
      ZsLog.e('下载出错: ', error: e);
      // 如果出错，可以考虑删除未完成的不完整文件
      // await File(savePath).delete();
      if (callback != null) {
        callback('下载异常', null, false);
      }
    } finally {
      // 7. 关闭 HTTP 客户端，释放资源
      client.close();
    }
    return r;
  }

  static Future<bool> downloadHttpFile(
    String url, {
    Map<String, String>? header,
    String? sugFileName,
    String? sugExtension,
    bool cover = false,
    ResultCallback? callback,
  }) async {
    bool r = false;
    Uri uri = Uri.parse(url);
    var client = DownloadClient();
    try {
      HttpClientRequest request = await client.getUrl(uri);
      if (header != null) {
        header.forEach((key, value) {
          request.headers.add(key, value);
        });
      }
      HttpClientResponse response = await request.close();
      var redirectCount = 0;
      const redirectMax = 5;
      Uri srcUri = uri;
      while (response.isRedirect && (redirectCount <= redirectMax)) {
        redirectCount++;
        response.drain();
        final location = response.headers.value(HttpHeaders.locationHeader);
        if (location != null) {
          srcUri = uri.resolve(location);
          request = await client.getUrl(srcUri);
          if (header != null) {
            header.forEach((key, value) {
              request.headers.add(key, value);
            });
          }
          if (redirectCount >= redirectMax) {
            request.followRedirects = false;
          }
          response = await request.close();
        }
      }
      if (response.statusCode == HttpStatus.ok) {
        // 打印所有头部信息
        // response.headers.forEach((name, value) {
        //   ZsLog.i('$name: $value');
        // });
        //String body = await response.transform(utf8.decoder).join();
        List<List<int>> nestedList = await response.toList();
        Uint8List bodyBytes = Utils.convertToUint8List(nestedList);
        //application/octet-stream  获得后缀确实.so
        String? mmt = response.headers.contentType?.mimeType;
        //attachment; filename="site.json.zip"
        String? cd = response.headers.value(Utils.httpResHeaderContentDisposition);

        //var resHeaderList = response.headersSplitValues;
        String path = srcUri.path;
        String? filename;
        String? ex = Utils.httpUrlExtensionFromResponse(
          srcUri.toString(),
          resHeader: null,
          resMimeType: mmt,
          resContentDisposition: cd,
          sugExtension: sugExtension,
          body: bodyBytes,
          result: (name, ex) {
            filename = name;
          },
        );
        filename ??= sugFileName;
        filename ??= Utils.pathBasename(path);
        client.close();
        r = await FileOperations.saveDataToDownloadDir(bodyBytes, outFileName: filename, extension: ex, cover: cover, callback: callback);
      } else {
        if (callback != null) {
          callback('下载失败', null, r);
        }
        ZsLog.d('downloadFile [$url] status: ${response.statusCode}.');
      }
    } catch (e) {
      if (callback != null) {
        callback('下载异常', null, r);
      }
    } finally {
      // 7. 关闭 HTTP 客户端，释放资源
      client.close();
    }
    return r;
  }

  static Future<bool> downloadSampleFile(
    String url, {
    Map<String, String>? header,
    String? sugFileName,
    String? sugExtension,
    bool cover = false,
    ResultCallback? callback,
  }) async {
    bool r = false;
    Uri uri = Uri.parse(url);

    /// 证书无效 或者没有认证，报错
    /// HandshakeException (HandshakeException: Handshake error in client (OS Error:
    /// CERTIFICATE_VERIFY_FAILED: application verification failure(handshake.cc:298)))
    final response = await http.get(uri, headers: header);
    if (response.statusCode == 200) {
      // 打印所有头部信息
      // response.headers.forEach((name, value) {
      //   ZsLog.i('$name: $value');
      // });
      Uri srcUri = uri;
      if (response.isRedirect) {
        Uri? rs = response.request?.url;
        if (rs != null && rs != srcUri) {
          srcUri = rs;
        }
      }
      var bodyBytes = response.bodyBytes;
      var resHeader = response.headers;
      //var resHeaderList = response.headersSplitValues;
      String path = srcUri.path;
      String? filename;
      String? ex = Utils.httpUrlExtensionFromResponse(
        srcUri.toString(),
        resHeader: resHeader,
        sugExtension: sugExtension,
        body: bodyBytes,
        result: (name, ex) {
          filename = name;
        },
      );
      filename ??= sugFileName;
      filename ??= Utils.pathBasename(path);
      r = await FileOperations.saveDataToDownloadDir(bodyBytes, outFileName: filename, extension: ex, cover: cover, callback: callback);
    } else {
      if (callback != null) {
        callback('下载失败}', null, r);
      }
      ZsLog.d('downloadFile [$url] status: ${response.statusCode}.');
    }
    return r;
  }

  static Future<dynamic> fetchJsonData(String queryUrl) async {
    final response = await http.get(Uri.parse(queryUrl));
    if (response.statusCode == 200) {
      //utf8.decode(response.bodyBytes)
      var body = response.body;
      try {
        var jsonStr = JsonXpathParser.jsonStringFromQueryResult(body);
        var jsonData = JsonXpathParser.jsonStringDecode(jsonStr);
        ZsLog.d('Request response body:$body,  parser json:${jsonData ?? ' null'}');
        return jsonData;
      } catch (e) {
        ZsLog.d('Request response json decode failed:$e');
      }
    } else {
      ZsLog.d('Request failed with status: ${response.statusCode}.');
    }
    return '';
  }

  //baidu
  //  https://www.baidu.com/sugrec?pre=1&p=3&ie=utf-8&json=1&prod=pc&from=pc_web&imod=2&wd=$content
  //{"q":"nn","p":false,"g":[{"type":"sug","sa":"s_1","q":"南宁天气","no_ai_sug":false},{"type":"direct_new","sa":"s_2_ti","q":"nnn reit宣布分红","info":{"vec_str_raw":["{\"flag\":\"hot_flow\",\"type\":\"1020\",\"versionControl\":{\"a0\":{\"max\":\"\",\"min\":\"11.31.0.0\"},\"i0\":{\"max\":\"\",\"min\":\"11.31.0.0\"}},\"value\":{\"name\":[{\"color\":\"#000\",\"text\":\"nnn reit宣布分红\"}],\"query\":\"nnn reit宣布分红\",\"btnKuang\":1,\"tag_style\":{\"tag_type\":1,\"text\":\"新\",\"text_color\":\"#FFFFFFFF\",\"border_color\":\"#7FFF4267\",\"bg_color\":\"#FFFF4267\",\"dark_text_color\":\"#FFFFFFFF\",\"dark_border_color\":\"#7FFF4267\",\"dark_bg_color\":\"#FFFF4267\",\"night_text_color\":\"#FFFFFFFF\",\"night_border_color\":\"#7FFF4267\",\"night_bg_color\":\"#FFFF4267\"}}}"]},"no_ai_sug":false},{"type":"sug","sa":"s_3","q":"倪妮个人资料","no_ai_sug":false},{"type":"sug","sa":"s_4","q":"nna","no_ai_sug":false},{"type":"sug","sa":"s_5","q":"nn二甲基甲酰胺","no_ai_sug":true},{"type":"sug","sa":"s_6","q":"nn是什么意思","no_ai_sug":false},{"type":"sug","sa":"s_7","q":"男女爱情视频","no_ai_sug":false},{"type":"sug","sa":"s_8","q":"南宁在哪个省市","no_ai_sug":false},{"type":"sug","sa":"s_9","q":"nnu是哪个大学","no_ai_sug":false},{"type":"sug","sa":"s_10","q":"nnd是什么意思网络用语","no_ai_sug":false}],"slid":"227725010849336","queryid":"0x337cf1d5c60ce38"}
  //  http://suggestion.baidu.com/su?wd=$content&cb=window.baidu.sug
  //  window.baidu.sug({q:"a",p:false,s:["AI伙伴","a i 人工智能"]});
  //if(typeof window.bing.sug == 'function') window.bing.sug({"AS":{"Query":"a","FullResults":1,"Results":[{"Type":"AS","Suggests":[{"Txt":"atk网页驱动","Type":"FT","Sk":"","HCS":0},{"Txt":"爱奇艺","Type":"SC","Sk":"FT1","HCS":0},{"Txt":"aigc检测","Type":"FT","Sk":"FT1SC1"},{"Txt":"阿里云","Type":"SC","Sk":"FT2SC1"},{"Txt":"ao3镜像发布页","Type":"FT","Sk":"FT2SC2"},{"Txt":"aiyi爱壹帆","Type":"LT","Sk":"FT3SC2"},{"Txt":"amd","Type":"CT","Sk":"FT3SC2LT1"},{"Txt":"阿里巴巴","Type":"SC","Sk":"FT3SC2LT1CT1"}]}]}}/* pageview_candidate */);
  static Future<List<String>>? searchEnginSuggestion(
    String content, {
    SearchEngin engin = SearchEngin.baidu,
    void Function(List<String> result, SearchEngin from)? result,
  }) async {
    List<String> r = [];
    if (engin == SearchEngin.baidu) {
      // String url1 =
      //     "http://suggestion.baidu.com/su?wd=$content&cb=window.baidu.sug";
      String url = "https://www.baidu.com/sugrec?pre=1&p=3&ie=utf-8&json=1&prod=pc&from=pc_web&imod=2&wd=$content";
      var result = await fetchJsonData(url);
      if (result != null) {
        //var list1 = JsonXpathParser.parserXpath(result, './s');
        var rs = JsonXpathParser.parserXpath(result, './g/*/q');
        var list = UtilList.dyToListStrings(rs);
        if (list != null) {
          r.addAll(list);
        }
      }
    } else {
      String url = "http://api.bing.com/qsonhs.aspx?type=cb&q=$content&cb=window.bing.sug";
      var result = await fetchJsonData(url);
      if (result != null) {
        var rs = JsonXpathParser.parserXpath(result, './AS/Results/0/Suggests/*/Txt');
        var list = UtilList.dyToListStrings(rs);
        if (list != null) {
          r.addAll(list);
        }
        // var rs = JsonXpathParser.parserXpath(result, './AS/Results/0/Suggests');
        // if (rs != null && (rs is List)) {
        //   rs.forEach((item) {
        //     if (item.containsKey('Txt')) {
        //       r.add(item['Txt']);
        //     }
        //   });
        // }
      }
    }
    // else {
    //   url =
    //       "http://suggestqueries.google.com/complete/search?client=youtube&q=$content&jsonp=window.google.ac.h";
    // }
    if (result != null) {
      result(r, engin);
    }
    return r;
  }
}
