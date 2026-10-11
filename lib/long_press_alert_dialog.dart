import 'package:chiphell/sites/util_site.dart';
import 'package:chiphell/sites/web_site.dart';
import 'package:chiphell/web/web_image_view.dart';
import 'package:chiphell/modals/AppState.dart';
import 'package:chiphell/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:share_plus/share_plus.dart';

import 'common/constants.dart';
import 'modals/zj_Image_cacheManager.dart';
import 'utils/ui_utils.dart';

typedef CallbackFnItem = ({String desc, void Function(String result, int type)? onCall});

class LongPressAlertDialog extends StatefulWidget {
  static const List<InAppWebViewHitTestResultType> hitTestResultSupported = [
    InAppWebViewHitTestResultType.SRC_IMAGE_ANCHOR_TYPE,
    InAppWebViewHitTestResultType.SRC_ANCHOR_TYPE,
    InAppWebViewHitTestResultType.IMAGE_TYPE,
  ];

  const LongPressAlertDialog({
    super.key,
    // required this.webViewModel,
    required this.hitTestResult,
    this.requestFocusNodeHrefResult,
    this.requestImageRefResult,
    required this.callback,
    required this.site,
  });

  // final WebViewModel webViewModel;
  final InAppWebViewHitTestResult hitTestResult;
  final RequestFocusNodeHrefResult? requestFocusNodeHrefResult;
  final RequestImageRefResult? requestImageRefResult;
  final CallbackFnItem callback;
  final WebSite? site;

  bool isValidHttpRequestURL() {
    WebUri? url = requestFocusNodeHrefResult?.url;
    return (url != null) && Utils.validHttpUrl(url.toString());
  }

  String? validExtraOrRequestSrc() {
    String? urlstr = hitTestResult.extra;
    if (urlstr == null || urlstr.isEmpty) {
      urlstr = requestFocusNodeHrefResult?.src;
    }
    return urlstr;
  }

  String? validLinker() {
    String? urlstr;
    if ((requestFocusNodeHrefResult != null) && (requestFocusNodeHrefResult?.url != null)) {
      urlstr = requestFocusNodeHrefResult?.url?.toString();
    }
    if ((urlstr == null) && (hitTestResult.type == InAppWebViewHitTestResultType.SRC_ANCHOR_TYPE) && (hitTestResult.extra != null)) {
      urlstr = hitTestResult.extra!;
    }
    return urlstr;
  }

  //InAppWebViewHitTestResultType (SRC_ANCHOR_TYPE)
  String? validImageUrl() {
    String? urlstr;
    if ((hitTestResult.type == InAppWebViewHitTestResultType.IMAGE_TYPE ||
            hitTestResult.type == InAppWebViewHitTestResultType.SRC_IMAGE_ANCHOR_TYPE) &&
        (hitTestResult.extra != null)) {
      urlstr = hitTestResult.extra!;
    } else if ((requestImageRefResult != null) && (requestImageRefResult?.url != null)) {
      urlstr = requestImageRefResult?.url.toString();
    } else if ((requestFocusNodeHrefResult != null) && (requestFocusNodeHrefResult?.src != null)) {
      urlstr = requestFocusNodeHrefResult?.src;
    }
    return urlstr;
  }

  String? validTitle() {
    String? t;
    if ((requestFocusNodeHrefResult != null) && (requestFocusNodeHrefResult?.title != null)) {
      t = requestFocusNodeHrefResult?.title;
      if (t?.isEmpty == true) {
        t = null;
      }
    }
    return t;
  }

  @override
  State<LongPressAlertDialog> createState() => _LongPressAlertDialogState();
}

class _LongPressAlertDialogState extends State<LongPressAlertDialog> {
  var _isLinkPreviewReady = false;
  final GlobalKey _shareLinkKey = GlobalKey();
  final GlobalKey _shareImageKey = GlobalKey();

  String? title;
  String? linker;
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    linker = widget.validLinker();
    imageUrl = widget.validImageUrl();
    title = widget.validTitle();
    if (title != null) {
      title = title!.trim();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(0.0),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(mainAxisSize: MainAxisSize.min, children: _buildDialogLongPressHitTestResult()),
        ),
      ),
    );
  }

  List<Widget> _buildDialogLongPressHitTestResult() {
    if ((widget.hitTestResult.type == InAppWebViewHitTestResultType.SRC_ANCHOR_TYPE) &&
        (widget.requestFocusNodeHrefResult?.title != null) &&
        (widget.site?.isAuthorUrl(widget.requestFocusNodeHrefResult?.src) == true ||
            widget.site?.isAuthorUrl(widget.requestFocusNodeHrefResult?.url?.toString()) == true ||
            (widget.site?.isAuthorUrl(widget.hitTestResult.extra) == true))) {
      return <Widget>[
        _buildLinkTitle(),
        const Divider(),
        _buildOpenNewTab(),
        const Divider(),
        _buildCopyAddressLink(),
        const Divider(),
        _buildFilterUser(),
        const Divider(),
        _buildSystemOpen(),
      ];
    } else if ((widget.hitTestResult.type == InAppWebViewHitTestResultType.SRC_ANCHOR_TYPE ||
            widget.hitTestResult.type == InAppWebViewHitTestResultType.SRC_IMAGE_ANCHOR_TYPE ||
            widget.hitTestResult.type == InAppWebViewHitTestResultType.IMAGE_TYPE) &&
        widget.isValidHttpRequestURL()) {
      return <Widget>[
        _buildLinkTitle(),
        const Divider(),
        _buildLinkPreview(),
        const Divider(),
        _buildCopyAddressLink(),
        const Divider(),
        _buildOpenNewTab(),
        const Divider(),
        _buildSystemOpen(),
        const Divider(),
        _buildShareLink(),
      ];
    } else if ((widget.hitTestResult.type == InAppWebViewHitTestResultType.IMAGE_TYPE ||
            widget.hitTestResult.type == InAppWebViewHitTestResultType.SRC_IMAGE_ANCHOR_TYPE) &&
        (widget.hitTestResult.extra != null)) {
      return <Widget>[_buildImageTitle(), const Divider(), _buildDownloadImage(), const Divider(), _buildShareImage()];
    }

    return [];
  }

  Widget _buildLinkTitle() {
    Uri? aurl;
    Uri? imgUri;
    if (imageUrl != null) {
      imgUri = Uri.parse(imageUrl!);
    }
    if (linker != null) {
      aurl = Uri.parse(linker!);
    }
    aurl ??= imgUri;
    if (imgUri == null && aurl != null) {
      //https://www.chiphell.com/home.php?mod=space&uid=129581&do=profile&mobile=2
      String? userIcon = UtilSite.authIconUrlFromUserSpaceUrl(aurl.toString());
      if (userIcon != null) {
        imgUri = Uri.parse(userIcon);
        imageUrl = userIcon;
      } else {
        imgUri = Uri.parse("${aurl.origin}/favicon.ico");
      }
    }
    aurl ??= Uri.parse('about:blank');
    String tt = title != null ? title!.trim() : "";
    if (tt.isEmpty) {
      tt = Constants.kLinker;
    }
    return ListTile(
      leading: SizedBox(
        width: 30,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[WebImageView(url: imgUri, maxWidth: 30.0, height: 30.0)],
        ),
      ),

      title: Text(tt, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(aurl.toString(), maxLines: 2, overflow: TextOverflow.ellipsis),
      isThreeLine: false,
    );
  }

  Widget _buildLinkPreview() {
    return ListTile(
      //  title: const Center(child: Text("Link Preview")),
      subtitle: SizedBox(
        //padding: const EdgeInsets.only(top: 15.0),
        height: 200,
        child: IndexedStack(
          index: _isLinkPreviewReady ? 1 : 0,
          children: <Widget>[
            const Center(child: CircularProgressIndicator()),
            InAppWebView(
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
              },
              webViewEnvironment: AppState.webViewEnvironment,
              initialUrlRequest: URLRequest(url: widget.requestFocusNodeHrefResult?.url),
              initialSettings: InAppWebViewSettings(
                verticalScrollbarThumbColor: const Color.fromRGBO(0, 0, 0, 0.5),
                horizontalScrollbarThumbColor: const Color.fromRGBO(0, 0, 0, 0.5),
              ),
              onProgressChanged: (controller, progress) {
                if (progress > 50) {
                  setState(() {
                    _isLinkPreviewReady = true;
                  });
                }
              },
              onReceivedServerTrustAuthRequest: (controller, challenge) async {
                var sslError = challenge.protectionSpace.sslError;
                if (sslError != null && (sslError.code != null)) {
                  if ((Utils.isIOS() || Utils.isMacOS() || Utils.isAndroid()) && sslError.code == SslErrorType.UNSPECIFIED) {
                    return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
                  }
                  // if (challenge.protectionSpace.host.contains(SiteConstants.kWebSiteSafeIncludeDomain)) {
                  return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
                  // }
                  // return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.CANCEL);
                }
                return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
              },
            ),
          ],
        ),
      ),
    );
  }

  ///"Open address link "
  Widget _buildOpenNewTab() {
    return ListTile(
      title: const Text(Constants.kOpenLinker),
      minTileHeight: 30,
      onTap: () {
        if (linker != null) {
          widget.callback.onCall!(linker!, 1);
        }
        Navigator.pop(context);
        //Ibrowser.iBrowserOutOpenUrl(wu.toString());
      },
    );
  }

  Widget _buildSystemOpen() {
    return ListTile(
      title: const Text(Constants.kSysBrowserOpen),
      minTileHeight: 30,
      onTap: () {
        if (linker != null) {
          widget.callback.onCall!(linker!, 2);
        }
        Navigator.pop(context);
        //Ibrowser.iBrowserOutOpenUrl(wu.toString());
      },
    );
  }

  // Widget _buildOpenNewIncognitoTab() {
  //   final windowModel = Provider.of<WindowModel>(context, listen: false);
  //   return ListTile(
  //     title: const Text("Open in a new incognito tab"),
  //     onTap: () {
  //       windowModel.addTab(WebViewTab(
  //         key: GlobalKey(),
  //         webViewModel: WebViewModel(
  //             url: widget.requestFocusNodeHrefResult?.url,
  //             isIncognitoMode: true),
  //       ));
  //       Navigator.pop(context);
  //     },
  //   );
  // }
  ///Filter user
  Widget _buildFilterUser() {
    return ListTile(
      title: const Text(Constants.kAddToFilter),
      minTileHeight: 30,
      onTap: () async {
        var name = title;
        if (name != null) {
          widget.callback.onCall!(name, 3);
        }
        Navigator.pop(context);
      },
    );
  }

  ///Copy address link
  Widget _buildCopyAddressLink() {
    return ListTile(
      title: const Text(Constants.kCopyLinker),
      minTileHeight: 30,
      onTap: () async {
        String url = (linker ?? imageUrl) ?? '';
        await Uiutils.copyContentToClipboard(context, url);
        if (context.mounted) {
          popView();
        }
      },
    );
  }

  void popView() {
    Navigator.pop(context);
  }

  ///Share link
  Widget _buildShareLink() {
    return ListTile(
      //minTileHeight: 40,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(Constants.kShareLinker),
          Padding(
            padding: const EdgeInsets.only(right: 12.5),
            child: Container(key: _shareLinkKey, child: const Icon(Icons.share, size: 20.0)),
          ),
        ],
      ),
      onTap: () async {
        String? urlstr = linker;
        if (urlstr != null) {
          final box = context.findRenderObject() as RenderBox?;
          SharePlus.instance.share(ShareParams(uri: Uri.parse(urlstr), sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size));
        }
        Navigator.pop(context);
      },
    );
  }

  Widget _buildImageTitle() {
    String? tt = (title ?? imageUrl) ?? Constants.kPictureTilte;
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 15.0, top: 15.0, right: 15.0, bottom: 5.0),
      leading: SizedBox(
        width: 50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[WebImageView(url: Uri.parse(imageUrl ?? widget.hitTestResult.extra!), maxWidth: 50.0, height: 50.0)],
        ),
      ),
      title: Text(tt),
    );
  }

  ///Download image
  Widget _buildDownloadImage() {
    return ListTile(
      title: const Text(Constants.kDownloadImage),
      onTap: () async {
        if (imageUrl != null) {
          widget.callback.onCall!(imageUrl!, 0);
        }
        if (mounted) {
          Navigator.pop(context);
        }
      },
    );
  }

  ///Share image
  Widget _buildShareImage() {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(Constants.kShareImage),
          Padding(
            padding: EdgeInsets.only(right: 12.5),
            child: Container(
              key: _shareImageKey,
              child: const Icon(Icons.share, color: Colors.black54, size: 20.0),
            ),
            //Icon(Icons.share, color: Colors.black54, size: 20.0),
          ),
        ],
      ),
      onTap: () async {
        String? urlStr = imageUrl;
        if (urlStr != null) {
          // Uri suri = Uri.parse(urlStr);
          //XFile? thumb;
          XFile? xfile;
          //android: LocalFile (LocalFile: '/data/user/0/com.zorro.chiphell/cache/zjImageCacheKey/48673320-30b6-11f1-bc1f-efeeb7de8f3c')
          if (!Utils.isLinux()) {
            var fileInfo = await ZjImageCacheManager().getFileFromCache(urlStr);
            if (fileInfo != null) {
              String? mmt = Utils.fileMimeType(fileInfo.file.path, headerCheck: true);
              mmt ??= 'image/jpeg';
              Uint8List buffer = await fileInfo.file.readAsBytes();
              // if (Utils.isAndroid()) {
              //   thumb = XFile(fileInfo.file.path, mimeType: mmt);
              // }
              xfile = XFile.fromData(buffer, name: Utils.baseFileName(fileInfo.file.path), mimeType: mmt);
            }
          }
          BuildContext ctx = context;
          if (ctx.mounted == false) {
            return;
          }
          final box = ctx.findRenderObject() as RenderBox?;
          // if (thumb != null) {
          await SharePlus.instance.share(
            ShareParams(
              //uri: suri,
              text: urlStr,
              // previewThumbnail: thumb,
              files: xfile != null ? [xfile] : null,
              sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
              downloadFallbackEnabled: true,
            ),
          );
          // }
        }
        popView();
      },
    );
  }

  ///Image in a new tab
  // Widget _buildOpenImageNewTab() {
  //   return ListTile(
  //     title: const Text("打开图片"),
  //     onTap: () {
  //       if (widget.hitTestResult.extra != null) {
  //         var url = widget.hitTestResult.extra;
  //         if (url != null) {
  //           Future.delayed(Duration(milliseconds: 1000), () {
  //             Ibrowser.iBrowserOpenUrl(url);
  //           });
  //         }
  //       }
  //       Navigator.pop(context);
  //     },
  //   );
  // }

  //Search this image on Google
  // Widget _buildSearchImageOnGoogle() {
  //   return ListTile(
  //     title: const Text("搜索图片"),
  //     onTap: () {
  //       if (widget.hitTestResult.extra != null) {
  //         var url =
  //             "http://images.google.com/searchbyimage?image_url=${widget.hitTestResult.extra!}";

  //         Future.delayed(Duration(milliseconds: 1000), () {
  //           Ibrowser.iBrowserOpenUrl(url);
  //         });
  //       }
  //       Navigator.pop(context);
  //     },
  //   );
  // }

  // Widget _buildSearchImageOnBaidu() {
  //   return ListTile(
  //     title: const Text("Search this image on Baidu"),
  //     onTap: () {
  //       if (widget.hitTestResult.extra != null) {
  //         var url =
  //             "http://images.baidu.com/searchbyimage?image_url=${widget.hitTestResult.extra!}";
  //         Ibrowser.iBrowserOpenUrl(url);
  //       }
  //       Navigator.pop(context);
  //     },
  //   );
  // }
}
