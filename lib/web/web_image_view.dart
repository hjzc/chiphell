import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../modals/zj_Image_cacheManager.dart';
import '../utils/zs_log.dart';

class WebImageView extends StatelessWidget {
  final double? width;
  final double? height;
  final double maxWidth;
  final double maxHeight;
  final double minWidth;
  final double minHeight;
  final Uri? url;
  final Widget Function()? defaultIconFn;
  final double progressSize;

  const WebImageView({
    super.key,
    this.url,
    this.width,
    this.height,
    this.maxWidth = double.infinity,
    this.maxHeight = double.infinity,
    this.minWidth = 0.0,
    this.minHeight = 0.0,
    this.progressSize = 20.0,
    this.defaultIconFn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        minHeight: minHeight,
        minWidth: minWidth,
      ),
      width: width,
      height: height,
      child: getImage(context),
    );
  }

  Widget? getImage(BuildContext context) {
    if (url != null) {
      if (url!.scheme == "data") {
        Uint8List bytes = const Base64Decoder().convert(
          url.toString().replaceFirst("data:image/png;base64,", ""),
        );
        return Image.memory(
          bytes,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => getBrokenImageIcon(),
        );
      }
      //android 显示不出来
      return cacheImageDownload(context);
    }
    return getBrokenImageIcon();
  }

  Widget getBrokenImageIcon() {
    if (defaultIconFn != null) {
      var r = defaultIconFn?.call();
      if (r != null) {
        return r;
      }
    }
    return Icon(Icons.broken_image, size: width ?? height ?? maxWidth);
  }

  //在下载web图片（有防盗链）的时候容易失败
  Widget imageNetworkDownload(BuildContext context) {
    return Image.network(
      url.toString(),
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => getBrokenImageIcon(),
    );
  }

  // CachedNetworkImage(
  //   placeholder: (context, url) => CircularProgressIndicator(),
  //   imageUrl: widget.requestFocusNodeHrefResult?.src != null ? widget.requestFocusNodeHrefResult!.src : faviconUrl,
  //   height: 30,
  // )
  double progressWidth() {
    double r = progressSize;
    if (r < 0 || r > 40) {
      r = 20;
    }
    if (width != null && height! > 0) {
      r = min<double>(width! / 2.0, r);
    } else if (height != null && height! > 0) {
      r = min<double>(height! / 2.0, r);
    } else if (minWidth > 0) {
      r = min<double>(minWidth / 2.0, r);
    } else if (minHeight > 0) {
      r = min<double>(minHeight / 2.0, r);
    }
    return r;
  }

  Widget cacheImageDownload(BuildContext context) {
    double pw = progressWidth();
    return CachedNetworkImage(
      imageUrl: url.toString(),
      cacheManager: ZjImageCacheManager(),
      progressIndicatorBuilder: (context, url, progress) {
        return Container(
          alignment: AlignmentGeometry.center,
          child: SizedBox(
            width: pw,
            height: pw,
            child: CircularProgressIndicator(value: progress.progress),
          ),
        );
        //return CircularProgressIndicator(value: progress.progress);
      },
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.fitWidth,
            // colorFilter: ColorFilter.mode(
            //   Colors.red,
            //   BlendMode.colorBurn,
            // ),
          ),
        ),
      ),
      // placeholder: (context, url) {
      //   return Container(
      //     alignment: AlignmentGeometry.center,
      //     child: SizedBox(
      //       width: 40,
      //       height: 40,
      //       child: CircularProgressIndicator(),
      //     ),
      //   );
      // },
      errorWidget: (context, url, error) {
        ZsLog.d('image $url load error:$error');
        return getBrokenImageIcon();
        // Icon(Icons.error, color: Colors.red);
      },
    );
  }
}
