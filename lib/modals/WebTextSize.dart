import 'package:chiphell/data/app_prefs.dart';
import 'package:chiphell/utils/utils.dart';
import 'package:chiphell/web/web_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const kInitialTextZoom = 100;
const kTextZoomPlaceholder = 'TEXT_SIZE_PLACEHOLDER';
const kTextZoomSourceJS =
    """
 window.addEventListener('DOMContentLoaded', function(event) {
  document.body.style.textSizeAdjust = '$kTextZoomPlaceholder%' ;
  document.body.style.webkitTextSizeAdjust = '$kTextZoomPlaceholder%'  ;
});
""";

// <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0">
// try { document.body.classList.remove('no-text-adjust');} catch(e) {}
//document.body.classList.add('no-text-adjust'); // 禁用文本大小调整
//document.body.classList.remove('no-text-adjust'); // 启用文本大小调整

/*
ipad/windows document.body.style.zoom =1
document.body.style.textSizeAdjust = '200%' ;
document.body.style.webkitTextSizeAdjust ='200%' ;
document.body.style.textSizeAdjust = '200% !important' ;
document.body.style.webkitTextSizeAdjust ='200%  !important' ;
//  -webkit-text-size-adjust: 100%;
// -ms-text-size-adjust: 100%;
// text-size-adjust: 100%;
*/

class WebTextSize extends ChangeNotifier {
  void Function(int event, WebTextSize object)? tallValueChangesCallBack;

  //单例
  static final WebTextSize _instance = WebTextSize._();
  factory WebTextSize() {
    return _instance;
  }
  WebTextSize._() : super();

  int _textZoom = kInitialTextZoom;
  //TODO：要支持 windows 必须修改使用 flutter_inappwebview_windows-0.7.0-beta.2--zorro修改
  //参考：patch/windows_webview2_patch
  double _pageZoom = 1.0;
  UserScript? preUserScript;
  UserScript? currentUserScript;
  double _sysTextZoom = -1;

  Future<void> initTextSize() async {
    int? r = await AppPrefs.loadTextZoomFromPref();
    if (r != null) {
      _textZoom = r;
    }
    double? d = await AppPrefs.loadWebPageFromPref();
    if (d != null) {
      _pageZoom = d;
    }
  }

  //android iphone
  set textZoom(int value) {
    if (_textZoom != value) {
      preUserScript = currentUserScript;
      _textZoom = value;
      currentUserScript = null;
      AppPrefs.saveTextZoomToPref(_textZoom);
      notifyListeners();
      if (tallValueChangesCallBack != null) {
        tallValueChangesCallBack?.call(
          WebConstants.kWebTextSizeChangedEventTextZoom,
          this,
        );
      }
    }
  }

  //android iphone
  set sysTextZoom(double value) {
    if (value != _sysTextZoom) {
      var pre = _sysTextZoom;
      preUserScript = currentUserScript;
      _sysTextZoom = value;
      currentUserScript = null;
      if ((pre > 0) && (_sysTextZoom > 0)) {
        notifyListeners();
      }
    }
  }

  void initSysTextZoom(double value) {
    if (value != _sysTextZoom) {
      if (_sysTextZoom < 0) {
        _sysTextZoom = value;
      }
    }
  }

  //macos ipad windows
  set pageZoom(double value) {
    synPageZoom(value, syn: false);
  }

  double get sysTextZoom => _sysTextZoom < 0 ? 1.0 : _sysTextZoom;
  int get textZoom => _textZoom;
  int get textRealZoom => (textZoom.toDouble() * sysTextZoom).toInt();

  double get pageZoom => _pageZoom * sysTextZoom;
  //用于窗口同步  //macos ipad windows
  double get pageRealZoom => _pageZoom;
  void synPageZoom(double value, {bool syn = true}) {
    if (_pageZoom != value) {
      preUserScript = currentUserScript;
      _pageZoom = value;
      currentUserScript = null;
      AppPrefs.savePageZoomToPref(_pageZoom);
      notifyListeners();
      if (syn == false && tallValueChangesCallBack != null) {
        tallValueChangesCallBack?.call(
          WebConstants.kWebTextSizeChangedEventPageZoom,
          this,
        );
      }
    }
  }

  //iphone
  UserScript? textZoomUserScript() {
    var rc = currentUserScript;
    if (Utils.isiPhone()) {
      if (rc == null) {
        String source = kTextZoomSourceJS.replaceAll(
          kTextZoomPlaceholder,
          '$textRealZoom',
        );
        rc = UserScript(
          source: source,
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
        );
        currentUserScript = rc;
      }
    }
    //弃用，修改windows库实现pagezoom
    // else if (defaultTargetPlatform == TargetPlatform.windows) {
    //   if (rc == null) {
    //     String source = """
    //     window.addEventListener('DOMContentLoaded', function(event) {
    //       var runCount = 0;
    //       function setPageZoom() {
    //         runCount++;
    //         try { document.body.style.zoom = $pageZoom; } catch(e) {
    //         if(runCount<60){setTimeout(setPageZoom, 1000);}
    //         }
    //       }
    //       setPageZoom();
    //     });
    //     """;
    //     rc = UserScript(
    //       source: source,
    //       injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
    //     );
    //     currentUserScript = rc;
    //   }
    // }

    return rc;
  }

  //iphone android
  Future<void> updateTextZoom(
    InAppWebViewController? webViewController, {
    required InAppWebViewSettings settings,
  }) async {
    if (webViewController == null) {
      return;
    }
    if ((!kIsWeb) && (Utils.isAndroid())) {
      await webViewController.setSettings(settings: settings);
    } else if (Utils.isiPhone()) {
      await webViewController.evaluateJavascript(
        source:
            """
            document.body.style.textSizeAdjust = '$textRealZoom%';
            document.body.style.webkitTextSizeAdjust = '$textRealZoom%';
          """,
      );
      var pre = preUserScript;
      if (pre != null) {
        await webViewController.removeUserScript(userScript: pre);
        preUserScript = null;
      }
      var rc = textZoomUserScript();
      if (rc != null) {
        await webViewController.addUserScript(userScript: rc);
      }
    }
    // else if (Utils.isWindows()) {
    //   await webViewController.evaluateJavascript(
    //     source: 'document.body.style.zoom = $pageZoom;',
    //   );
    //   var pre = preUserScript;
    //   if (pre != null) {
    //     await webViewController.removeUserScript(userScript: pre);
    //     preUserScript = null;
    //   }
    //   var rc = textZoomUserScript();
    //   if (rc != null) {
    //     await webViewController.addUserScript(userScript: rc);
    //   }
    // }
  }

  static List<String> fontSetDescList() {
    return ['小', '标准', '中', '大'];
  }

  static List<int> fontSetDescCodes() {
    return [80, 100, 120, 150];
  }

  static int fontSetCodeFromDescIndex(int index) {
    return fontSetDescCodes()[index];
  }

  static int fontSetCodeIndex(int code) {
    var codes = fontSetDescCodes();
    int idx = codes.indexOf(code);
    return (idx < 0) ? 0 : idx;
  }

  static String fontSetDescFromCode(int code) {
    var codes = fontSetDescCodes();
    int idx = codes.indexOf(code);
    if (idx > -1) {
      return fontSetDescList()[idx];
    }
    return '';
  }

  //页面缩放 macos windows 效果好
  static List<String> pageZoomSetDescList() {
    return ['小', '标准', '中', '大', '特大'];
  }

  static List<double> pageZoomSetDescCodes() {
    return Utils.isWindows()
        ? [0.8, 1.0, 1.35, 1.7, 2.0]
        : [0.75, 1.0, 1.5, 2.0, 3.0];
  }

  static double pageZoomSetCodeFromDescIndex(int index) {
    return pageZoomSetDescCodes()[index];
  }

  static int pageZoomSetCodeIndex(double code) {
    final List<double> list = pageZoomSetDescCodes();
    int idx = 0;
    final double ofs = 0.1;
    if ((code > list[1] - ofs) && (code < list[2] - ofs)) {
      idx = 1;
    } else if ((code > list[2] - ofs) && (code < list[3] - ofs)) {
      idx = 2;
    } else if ((code > list[3] - ofs) && (code < list[4] - ofs)) {
      idx = 3;
    } else if ((code > list[4] - ofs) && (code < list[4] + ofs)) {
      idx = 4;
    }
    return idx;
  }

  static String pageZoomSetDescFromCode(double code) {
    int idx = pageZoomSetCodeIndex(code);
    if (idx > -1) {
      return pageZoomSetDescList()[idx];
    }
    return '';
  }

  bool nextPageZoom() {
    final List<double> list = pageZoomSetDescCodes();
    int idx = pageZoomSetCodeIndex(_pageZoom);
    if (idx >= list.length - 2) {
      idx++;
      pageZoom = list[idx];
      return true;
    }
    return false;
  }

  bool previousPageZoom() {
    final List<double> list = pageZoomSetDescCodes();
    int idx = pageZoomSetCodeIndex(_pageZoom);
    if (idx >= 1) {
      idx--;
      pageZoom = list[idx];
      return true;
    }
    return false;
  }

  // void _gotoAndroidZoom(bool inFlag, void Function(bool val)? result) {
  //   if (_androidZoomDoing == false) {
  //     _androidZoomDoing = true;
  //     if (this.zoomCallBack != null) {
  //       this.zoomCallBack!(inFlag, (bool val) {
  //         if (val) {
  //           if (inFlag) {
  //             _androidZoomCount += 1;
  //           } else {
  //             _androidZoomCount -= 1;
  //           }
  //         }
  //         if (result != null) {
  //           result(val);
  //         }
  //         _androidZoomDoing = false;
  //       });
  //     }
  //   }
  // }
}
