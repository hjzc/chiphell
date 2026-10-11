import 'package:chiphell/common/constants.dart';
import 'package:chiphell/utils/ui_utils.dart';
import 'package:chiphell/utils/utils.dart';
import 'package:chiphell/utils/zs_log.dart';
import 'package:chiphell/web/web_view_helper.dart';
import 'package:flutter/material.dart';

import '../common/type_utils.dart';
import '../utils/Toast.dart';

class WebViewMoreOptions {
  static Future<void> menuMoreOptions(BuildContext context, WebViewHelper help) async {
    List<OptionButtonItem> list = [];

    if (await help.hasWebPageImage()) {
      list.add((
        label: Constants.kPopMesgImageDownloadALL,
        onPressed: () {
          help.downloadWebPageAllImageUrls();
        },
      ));
    }

    if (help.suppertOnPageFind()) {
      bool flag = false;
      if (Utils.isIOS()) {
        flag = await help.iosIsFindInteractionEnabled();
      } else {
        flag = help.isFindInteractionEnabled;
      }

      list.add((
        label: flag ? Constants.kWebFindExit : Constants.kWebFind,
        onPressed: () async {
          if (Utils.isIOS()) {
            help.isFindInteractionEnabled = !(await help.iosIsFindInteractionEnabled());
          } else {
            help.isFindInteractionEnabled = !help.isFindInteractionEnabled;
          }
        },
      ));
    }

    list.add((
      label: Constants.kWebScreenShot,
      onPressed: () {
        help.saveScreenShotToLocal(
          callback: (String? result, String? other, bool success) {
            ZsLog.i('success:$success result:${result ?? 'null'}, other:${other ?? 'null'}');
            if (result != null) {
              Toast.toastAtBottom(context, result);
            }
          },
        );
      },
    ));

    if (help.suppertPdf()) {
      list.add((
        label: Constants.kWebExportPdf,
        onPressed: () {
          help.saveWebPdfToLocal(
            callback: (String? result, String? other, bool success) {
              ZsLog.i('success:$success result:${result ?? 'null'}, other:${other ?? 'null'}');
              if (result != null) {
                if (success) {
                  if (Utils.isIOS()) {
                    result = '$result,${Constants.kDownloadSaveFolderGuideIOS}';
                  }
                }
                Toast.toastAtBottom(context, result);
              }
            },
          );
        },
      ));
    }
    if (help.suppertPrintJob()) {
      list.add((
        label: Constants.kWebPrint,
        onPressed: () {
          help.printJob(
            callback: (String? result, String? other, bool success) {
              ZsLog.i('success:$success result:${result ?? 'null'}, other:${other ?? 'null'}');
              if (result != null && result.isNotEmpty) {
                Toast.toastAtBottom(context, result);
              }
            },
          );
        },
      ));
    }

    return context.mounted ? Uiutils.simpleSelectOptionsDialog(context, list) : null;
  }
}
