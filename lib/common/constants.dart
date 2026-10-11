class Constants {
  // 位于 flutter/packages/flutter/lib/src/material/constants.dart
  /// 工具栏（即AppBar的主体部分）的标准高度。
  static const double kToolbarHeight = 56.0;

  /// 底部导航栏的标准高度。
  static const double kBottomNavigationBarHeight = 56.0;

  /// 最小可交互尺寸，确保触摸目标易于操作。横屏适用
  static const double kMinInteractiveDimension = 48.0;
  static const double kBarDividerLineDimension = 1;

  //folder
  static const String kDirPressImageFolderName = '压缩图片';

  static const String kStrNull = '';
  static const String kTip = '提示';
  static const String kTipCancel = '取消';
  static const String kTipClose = '关闭';
  static const String kTipOk = '确认';
  static const String kTipLogin = '登陆';
  static const String kTipUser = '用户名';
  static const String kTipPwd = '密码';
  static const String kSelectOptions = '选择操作';
  static const String kTipInputContentDecoration = '请输入内容';

  static const String kStatusOk = '成功';
  static const String kStatusFailed = '失败';

  static const String kCleanCacheBase = '基本';
  static const String kCleanCacheAll = '所有';

  static const String kPermissionDeny = '拒绝';
  static const String kPermissionGrant = '同意';

  static const String kCopy = '复制';
  static const String kCopyTitle = '复制标题';
  static const String kCopyLinker = '复制链接';
  static const String kLinker = '链接';
  static const String kShareLinker = '共享链接';
  static const String kCopyOptions = '复制选项';

  static const String kSysBrowserOpen = '浏览器打开';
  static const String kNewTabOpen = '新标签打开';
  static const String kOpenLinker = '打开链接';
  static const String kDownloadImage = '下载图片';
  static const String kShareImage = '共享图片';

  static const String kWebFind = '页内查找';
  static const String kWebFindExit = '退出查找';
  static const String kWebScreenShot = '截图保存';
  static const String kWebExportPdf = '导出PDF';
  static const String kWebPrint = '打印...';

  static const String kWebScreenShotFailed = '截图失败';
  static const String kWebExportPdfFailed = '导出PDF失败';

  static const String kPictureTilte = '图片';

  static const String kSeting = "设置";
  static const String kSiteManager = "站点管理";
  static const String kImageLook = "图片查看";
  static const String kMoreOptions = '更多操作';
  static const String kCancelFiltering = '取消过滤';
  static const String kAddToFilter = '过滤用户';
  static const String kOutBrowserOpen = '外部打开';
  static const String kDesktopUA = '请求桌面站';
  static const String kMobileUA = '请求移动站';
  static const String kMGRecord = '管理记录';
  static const String kMGFilterUser = '管理过滤';
  static const String kSiteForumOpen = '打开板块';
  static const String kSiteHomeOpen = '打开主页';
  static const String kSiteUserHomeOpen = '用户主页';
  static const String kUrlNewWindowsOpen = "新窗口打开";
  static const String kUrlInPageOpen = '内部打开';

  static const String kPageTitleWebTabList = '窗口列表';
  static const String kPageTitleFilterList = '过滤列表';
  static const String kPageTitleMainsiteList = '站点管理';

  static const String kPopMesgImageDownloadedStart = '开始下载！';
  static const String kPopMesgFileDownloadFailed = '文件下载失败！';
  static const String kPopMesgFileDownloadComplate = '文件下载完成！';
  static const String kPopMesgImageDownloadFailed = '图片下载失败！';
  static const String kPopMesgImageDownloadComplate = '图片下载完成！';
  static const String kPopMesgImageDownloaded = '已经下载！';
  static const String kPopMesgImageDownloadALL = '下载所有图片';

  static const String kPopMesgSaveSuccess = '保存成功！';
  static const String kPopMesgSaveFailed = '保存失败！';

  static const String kPopMesgReadyExist = '已经存在';
  static const String kPopMesgAddFailted = '增加失败';
  static const String kPopMesgAddsuccess = '增加成功';

  static const String kAlertBtnSave = '保存';
  static const String kPopMesgContentListClear = '请确认清空列表?';

  static const String kAlertTitleAddFilterUserName = "增加过滤用户名称";
  static const String kInputPromptUserName = "用户名称";

  static const String kAlertButtonAdd = '增加';
  static const String kAlertButtonClean = '清空';
  static const String kAlertButtonDelete = '删除';
  static const String kAlertButtonEdit = '编辑';

  static const String kAlertButtonCSVFile = "导入导出(CSV文件)";
  static const String kAlertButtonPastboard = "导入导出(剪贴板)";

  static const String kAlertButtonExportPB = '导出到剪贴板';
  static const String kAlertButtonImportPB = "从剪贴板导入(csv格式)";

  static const String kAlertButtonImportFile = "导入(CSV文件)";
  static const String kAlertButtonExportFile = "导出(CSV文件)";

  static const String kWebRequestError503 = '服务器繁忙，请稍后。。。。。。';

  static const String kWebDetectDiscuzSite = '发现Discuz站点';
  static const String kAlertTitleAddDiscuzSite = "增加站点";
  static const String kInputPromptDiscuzSite = "Discuz网址";
  static const String kInputPromptEditDiscuzSite = "输入站点名称";

  static const String kDownloadSaveFolderGuideIOS = "文件App>浏览>chiphell";
}

class CTMimeTypeExe {
  static const String kMTJpeg = 'jpeg';
  static const String kMTPng = 'png';
  static const String kMTPdf = 'pdf';
}

class CTMimeTypeString {
  static const String kMTJpeg = 'image/jpeg';
  static const String kMTPng = 'image/png';
  static const String kMTPdf = 'application/pdf';
}
