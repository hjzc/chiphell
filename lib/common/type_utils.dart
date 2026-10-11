import 'package:flutter/material.dart';

import 'zj_status.dart';

enum WVUATypes { uaAuto, uaMobile, uaPC }

enum WebThemeSyncState { start, loading, visiable, complete, delayCompleted, none }

typedef ResultCallback = void Function(String? result, String? other, bool success);
typedef AsynResultCallBack = Future<void> Function(String? result, String? other, bool success);
typedef OptionButtonItem = ({String label, void Function() onPressed});
typedef CtxCallback = void Function(BuildContext ctx);

enum MenuButtonItemEvent {
  login,
  userHome,
  home,
  area,
  copy,
  inBrowser,
  outBrowser,
  userAgent,
  addFilter,
  delFilter,
  imgGallery,
  more,
  setting,
  blackList,
  history,
  siteManger,
}

typedef MenuButtonItem = ({String label, Icon icon, MenuButtonItemEvent event, void Function()? onPressed});

typedef StatusCallback = void Function(ZjStatus status);

class TypeUtils {}
