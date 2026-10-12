import 'package:chiphell/modals/AppState.dart';
import 'package:chiphell/modals/Settings.dart';
import 'package:chiphell/modals/WebTextSize.dart';
import 'package:chiphell/radio_options_alert_dialog.dart';
import 'package:chiphell/sites/site_constants.dart';
import 'package:chiphell/theme/theme_provider.dart';
import 'package:chiphell/utils/file_save_helper.dart';
import 'package:chiphell/utils/ui_utils.dart';
import 'package:chiphell/utils/utils.dart';
import 'package:chiphell/multi_windows/window_util.dart';
import 'package:chiphell/web/web_view_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'common/type_utils.dart';
import 'common/zj_status.dart';
import 'web/zj_web_notification.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key, this.title});
  final String? title;

  @override
  SettingPageState createState() => SettingPageState();
}

class SettingPageState extends State<SettingPage>
//  with AutomaticKeepAliveClientMixin
{
  List<SetItem> setList = [];
  List<Map<String, dynamic>> results = [];
  bool cleanDoing = false;

  //切换页面，如何保持当前页的状态 with AutomaticKeepAliveClientMixin
  // @override
  // bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    bool isMainWin = true;
    if (Utils.isDesktopSystem) {
      isMainWin = WindowUtil().winInfo.isMainWindow();
    }
    var ctt = context;
    var appState = Provider.of<AppState>(ctt, listen: false);
    var websize = Provider.of<WebTextSize>(ctt, listen: false);
    var themePro = Provider.of<ThemeProvider>(ctt, listen: false);

    setList.add(
      SetItem(
        leading: Icons.image,
        title: "图片管理",
        content: '回帖/发帖图片',
        isShowArrow: true,
        callback: (context, item) {
          ///下载目录
          ///回帖/发帖图片
          imageManager();
        },
      )..eninit(),
    );

    setList.add(
      SetItem(
        leading: Icons.scale,
        title: "图片压缩",
        content: appState.pressImageSizeSelectedDesc(),
        isShowArrow: true,
        callback: (context, item) {
          showDialog(
            context: context,
            builder: (context) {
              return RadioOptionsAlertDialog(
                title: item.title ?? "",
                rows: AppState.pressImageSizeDesc,
                selecedIndex: appState.pressImageSizeDescIndex(),
                call: (
                  desc: '',
                  onCall: (int? changedValue) async {
                    if (changedValue != null) {
                      int newIndex = appState.setPressImageSizeDescIndex(changedValue);
                      if (newIndex > -1) {
                        setState(() {
                          item.content = appState.pressImageSizeSelectedDesc();
                        });
                      }
                    }
                  },
                ),
              );
            },
          );
        },
      )..eninit(),
    );

    // webview 不支持用户设置主题，支持跟随系统模式
    setList.add(
      SetItem(
        leading: Icons.sunny,
        title: "外观",
        content: themePro.themeModeDes(),
        isShowArrow: true,
        callback: (context, item) {
          //alert
          showDialog(
            context: context,
            builder: (context) {
              return RadioOptionsAlertDialog(
                title: item.title ?? "",
                rows: ThemeProvider.themeModeDesList(),
                selecedIndex: themePro.currentThemeModeCode(),
                call: (
                  desc: '',
                  onCall: (int? changedValue) async {
                    if (changedValue != null) {
                      themePro.synThemeModeFromCode(changedValue, syn: true);
                      setState(() {
                        item.content = themePro.themeModeDes();
                      });
                    }
                  },
                ),
              );
            },
          );
        },
      )..eninit(),
    );
    //有效 ios
    //无效 macos
    if (!kIsWeb && (Utils.isiPhone() || Utils.isAndroid())) {
      setList.add(
        SetItem(
          leading: Icons.text_increase_outlined,
          title: "字体大小",
          content: WebTextSize.fontSetDescFromCode(websize.textZoom),
          isShowArrow: true,
          callback: (context, item) {
            //alert
            showDialog(
              context: context,
              builder: (context) {
                return RadioOptionsAlertDialog(
                  title: item.title ?? "",
                  rows: WebTextSize.fontSetDescList(),
                  selecedIndex: WebTextSize.fontSetCodeIndex(websize.textZoom),
                  call: (
                    desc: '',
                    onCall: (int? changedValue) async {
                      if (changedValue != null) {
                        int textSize = WebTextSize.fontSetCodeFromDescIndex(changedValue);
                        websize.textZoom = textSize;
                        //item
                        setState(() {
                          item.content = WebTextSize.fontSetDescFromCode(websize.textZoom);
                        });
                      }
                    },
                  ),
                );
              },
            );
          },
        )..eninit(),
      );
    }

    if (!kIsWeb && (Utils.isMacOS() || Utils.isIPad() || Utils.isWindows())) {
      setList.add(
        SetItem(
          leading: Icons.zoom_in,
          title: "缩放",
          content: WebTextSize.pageZoomSetDescFromCode(websize.pageZoom),
          isShowArrow: true,
          callback: (context, item) {
            //alert
            showDialog(
              context: context,
              builder: (context) {
                return RadioOptionsAlertDialog(
                  title: item.title ?? "",
                  rows: WebTextSize.pageZoomSetDescList(),
                  selecedIndex: WebTextSize.pageZoomSetCodeIndex(websize.pageZoom),
                  call: (
                    desc: '',
                    onCall: (int? changedValue) async {
                      if (changedValue != null) {
                        double pageZoom = WebTextSize.pageZoomSetCodeFromDescIndex(changedValue);
                        websize.pageZoom = pageZoom;
                        //item
                        setState(() {
                          item.content = WebTextSize.pageZoomSetDescFromCode(websize.pageZoom);
                        });
                      }
                    },
                  ),
                );
              },
            );
          },
        )..eninit(),
      );
    }

    //if (Utils.isAndroid() || true) {
    setList.add(
      SetItem(
        leading: Icons.image_outlined,
        title: "图片模式",
        content: AppState.webImageLoadModeDesc[appState.webImgMode],
        isShowArrow: true,
        callback: (context, item) {
          //alert
          showDialog(
            context: context,
            builder: (context) {
              return RadioOptionsAlertDialog(
                title: item.title ?? "",
                rows: AppState.webImageLoadModeDesc,
                selecedIndex: appState.webImgMode,
                call: (
                  desc: '',
                  onCall: (int? changedValue) async {
                    if (changedValue != null) {
                      appState.webImgMode = changedValue;
                      setState(() {
                        item.content = AppState.webImageLoadModeDesc[appState.webImgMode];
                      });
                    }
                  },
                ),
              );
            },
          );
        },
      )..eninit(),
    );

    setList.add(
      SetItem(
        leading: Icons.block,
        title: "过滤模式",
        content: AppState.blackListApplyDesc[appState.blackListApply],
        isShowArrow: true,
        callback: (context, item) {
          //alert
          showDialog(
            context: context,
            builder: (context) {
              return RadioOptionsAlertDialog(
                title: item.title ?? "",
                rows: AppState.blackListApplyDesc,
                selecedIndex: appState.blackListApply,
                call: (
                  desc: '',
                  onCall: (int? changedValue) async {
                    if (changedValue != null) {
                      appState.blackListApply = changedValue;
                      setState(() {
                        item.content = AppState.blackListApplyDesc[appState.blackListApply];
                      });
                    }
                  },
                ),
              );
            },
          );
        },
      )..eninit(),
    );
    setList.add(
      SetItem(
        leading: Icons.search_outlined,
        title: "搜索引擎",
        content: AppState.webSearchEnginDesc[appState.webSearchEngin],
        isShowArrow: true,
        callback: (context, item) {
          //alert
          showDialog(
            context: context,
            builder: (context) {
              return RadioOptionsAlertDialog(
                title: item.title ?? "",
                rows: AppState.webSearchEnginDesc,
                selecedIndex: appState.webSearchEngin,
                call: (
                  desc: '',
                  onCall: (int? changedValue) async {
                    if (changedValue != null) {
                      appState.webSearchEngin = changedValue;
                      //item
                      setState(() {
                        item.content = AppState.webSearchEnginDesc[appState.webSearchEngin];
                      });
                    }
                  },
                ),
              );
            },
          );
        },
      )..eninit(),
    );
    setList.add(
      SetItem(
        leading: Icons.storage,
        title: "清除缓存",
        isShowArrow: true,
        callback: (context, item) {
          if (cleanDoing) {
            Uiutils.showSnackBar(context, "请稍后，正在清除！", milliseconds: 2000);
            return;
          }
          _showCleanOptions();
        },
      )..eninit(),
    );
    setList.add(
      SetItem(
        leading: Icons.browse_gallery,
        title: '自动画廊模式',
        content: "",
        isShowSwitch: true,
        switchValue: appState.autoImageGallery,
        callback: (context, item) {
          setState(() {
            appState.autoImageGallery = !appState.autoImageGallery;
          });
        },
      )..eninit(),
    );

    if (WebViewHelper.isSupportNotification) {
      setList.add(
        SetItem(
          leading: Icons.notification_important,
          title: '通知',
          content: "",
          isShowSwitch: true,
          switchValue: appState.webNotificationEnable,
          callback: (context, item) {
            setState(() {
              appState.webNotificationEnable = !appState.webNotificationEnable;
              //关闭的话也会把 webChiphellNotificationEnable 关闭
              if (appState.webNotificationEnable == true) {
                //是否清空通知设置 resetWebNotificationPerimission
                if (ZjWebNotificationPermissionDb.deniedCounts > 0) {
                  Uiutils.showAlertDialog(
                    context.mounted ? context : null,
                    barrierDismissible: true,
                    content: "重置通知（已拒绝），请确认！",
                    callBackFun: (isOk) {
                      if (isOk) {
                        ZjWebNotificationPermissionDb.resetDenieds();
                      }
                    },
                  );
                }
              } else {
                if (ZjWebNotificationPermissionDb.length > 0) {
                  Uiutils.showAlertDialog(
                    context.mounted ? context : null,
                    barrierDismissible: true,
                    content: "重置所有通知权限，请确认！",
                    callBackFun: (isOk) {
                      if (isOk) {
                        ZjWebNotificationPermissionDb.clear();
                      }
                    },
                  );
                }
              }
            });
          },
        )..eninit(),
      );
      setList.add(
        SetItem(
          leading: Icons.notification_important,
          title: '接收通知',
          content: "",
          isShowSwitch: true,
          switchValue: appState.webChiphellNotificationEnable,
          callback: (context, item) {
            setState(() {
              appState.webChiphellNotificationEnable = !appState.webChiphellNotificationEnable;
              if (appState.webChiphellNotificationEnable) {
                if (ZjWebNotificationPermissionDb.getPermission(SiteConstants.kWebSiteAllHost) == ZjWebNotificationPermission.DENIED) {
                  ZjWebNotificationPermissionDb.clearHost(SiteConstants.kWebSiteAllHost);
                }
              }
            });
          },
        )..eninit(),
      );
    }

    if (Utils.isMobile()) {
      setList.add(
        SetItem(
          leading: Icons.swipe_right,
          title: '侧边右滑退出',
          content: "快速两次",
          isShowSwitch: true,
          switchValue: appState.swipeRightExit,
          callback: (context, item) {
            setState(() {
              appState.swipeRightExit = !appState.swipeRightExit;
            });
          },
        )..eninit(),
      );
    }

    if (Utils.isDesktopSystem && isMainWin) {
      setList.add(
        SetItem(
          leading: Icons.window,
          title: '窗口关闭',
          content: WindowUtil().winInfo.isCloseWindowsSet() ? "退出应用" : "最小化",
          isShowSwitch: true,
          switchValue: WindowUtil().winInfo.isCloseWindowsSet(),
          callback: (context, item) {
            setState(() {
              WindowUtil().winInfo.setIsCloseWindows(!WindowUtil().winInfo.isCloseWindowsSet());
              item.content = WindowUtil().winInfo.isCloseWindowsSet() ? "退出应用" : "最小化";
            });
          },
        )..eninit(),
      );
    }

    if (isMainWin) {
      setList.add(
        SetItem(
          leading: Icons.upgrade,
          title: '自动更新',
          content: appState.appVersion,
          isShowSwitch: true,
          switchValue: appState.autoUpgrade,
          callback: (context, item) {
            appState.autoUpgrade = !appState.autoUpgrade;
          },
        )..eninit(),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // var appState =
    Provider.of<AppState>(context, listen: true);
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    //var themeProvider = Provider.of<WebTextSize>(context, listen: true);
    //ThemeData td = Theme.of(context);
    //ListTileThemeData ltt = td.listTileTheme;
    // super.build(context);
    //var appState = Provider.of<AppState>(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          //延时一下，否则会出问题，不能在build时候返回 Duration.zero, Duration(seconds: 1)
          Future.delayed(Duration.zero, () {
            if (context.mounted) {
              context.pop(results);
            }
          });
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leadingWidth: 60,
          //automaticallyImplyLeading: true, //自动添加返回按钮
          centerTitle: true, // 标题是否居中（ios默认居中，Android默认居左）
          leading: BackButton(
            onPressed: () {
              context.pop(results);
              //Navigator.pop(context,results);
              //context.go('/');
            },
          ),

          // flexibleSpace: BlurWidget(child: SizedBox.expand()),
          title: Text(widget.title ?? '设置'),
          // actions: <Widget>[
          //   IconButton(onPressed: () {}, icon: Icon(Icons.add_circle_outline)),
          //   SizedBox(width: 24),
          // ],
        ),
        body: buildRows(context, themeProvider),
      ),
    );
  }

  ListView buildRows(BuildContext context, ThemeProvider tp) {
    return ListView.builder(
      itemCount: setList.length,
      itemBuilder: (context, index) {
        SetItem item = setList[index];

        List<Widget> children = [];
        if (index == 0) {
          children.add(Divider(height: 1));
        }
        if (item.popMenus != null && item.popMenus!.isNotEmpty) {
          children.add(buildPopMenuRowContent(context, item, tp));
        } else {
          children.add(buildRowContent(context, item, tp));
        }

        children.add(Divider(height: 1));
        return Column(children: children);
      },
    );
  }

  Widget buildRowContent(BuildContext context, SetItem item, ThemeProvider tp) {
    List<Widget> children = [];
    if (item.leading != null) {
      children.add(Icon(item.leading));
    } else {
      children.add(Container());
    }
    children.add(SizedBox(width: 8));
    children.add(Text(item.title ?? "", style: TextStyle(fontSize: tp.labelMediumFontsize)));
    children.add(
      Expanded(
        child: Container(
          padding: EdgeInsets.only(left: 16, right: 8),
          child: Text(
            item.content ?? "",
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: tp.labelSmallFontsize,
              color: Colors.grey, //Theme.of(context).hintColor 系统主题变化 不会自动变化,
            ),
          ),
        ),
      ),
    );
    if (item.isShowSwitch) {
      children.add(
        Switch(
          value: item.switchUIValue,
          onChanged: (value) {
            item.onChanged(value);
            _handleSetRowCallback(context, item);
          },
        ),
      );
    }
    if (item.isShowArrow) {
      children.add(Icon(Icons.arrow_forward_ios, size: 16));
    } else {
      children.add(Container());
    }
    return GestureDetector(
      onTap: () {
        if (item.isShowSwitch) {
        } else {
          _handleSetRowCallback(context, item);
        }
      },
      child: Container(
        height: 50.0,
        margin: EdgeInsets.only(left: 16, right: 16),
        width: double.infinity,
        // decoration: BoxDecoration(
        //   border: Border(bottom: Divider.createBorderSide(context, width: 1)),
        // ),
        child: Row(children: children),
      ),
    );
  }

  Widget buildPopMenuRowContent(BuildContext context, SetItem item, ThemeProvider tp) {
    List<PopupMenuEntry<int>> list = [];
    if (item.popMenus != null) {
      for (int i = 0; i < item.popMenus!.length; i++) {
        list.add(PopupMenuItem<int>(value: i, child: Text(item.popMenus![i])));
      }
    }
    return ListTile(
      leading: item.leading != null ? Icon(item.leading) : Container(), //Checkbox(value: true, onChanged: (bool? value) {}),
      title: Text(item.title ?? "", style: TextStyle(fontSize: tp.labelMediumFontsize)),
      subtitle: Text(item.popMenus![item.selectedPopMenuIndex], style: TextStyle(fontSize: tp.labelSmallFontsize)),
      horizontalTitleGap: 8,
      trailing: PopupMenuButton<int>(
        onSelected: (int value) {
          setState(() {
            item.selectedPopMenuIndex = value;
          });
        },
        itemBuilder: (BuildContext context) => list,
      ),
    );
  }

  void _handleSetRowCallback(BuildContext context, SetItem item) {
    if (item.callback != null) {
      item.callback!(context, item);
    }
  }

  void _showCleanOptions() {
    List<OptionButtonItem> list = [];
    for (ZjCleanCache obj in Settings.cleanCacheDesList()) {
      list.add((
        label: obj.desc ?? "",
        onPressed: () {
          _delayCleanCacheAlert(obj);
        },
      ));
    }
    Uiutils.simpleSelectOptionsDialog(context, list);
  }

  void _delayCleanCacheAlert(ZjCleanCache obj) {
    Future.delayed(Duration(milliseconds: 100), () {
      Uiutils.showAlertDialog(
        context.mounted ? context : null,
        barrierDismissible: true,
        content: "开始清除缓存，请确认！",
        callBackFun: (isOk) {
          if (isOk) {
            _cleanCacheHandle(obj);
          }
        },
      );
    });
  }

  Future<void> _cleanCacheHandle(ZjCleanCache val) async {
    cleanDoing = true;
    await Settings.cleanCache(val);
    cleanDoing = false;
    if (mounted) {
      Uiutils.showSnackBar(context, "清除缓存完成。");
    }
  }

  void imageManager() {
    List<({String label, void Function() onPressed})> rows = [];
    if (Utils.isDesktopSystem) {
      rows.add((
        label: '浏览下载图片',
        onPressed: () async {
          FileSaveHelper.openImageFolder();
        },
      ));
    }
    rows.add((
      label: '浏览压缩图片',
      onPressed: () async {
        ///
        FileSaveHelper.openUserThumbsFolder();
      },
    ));
    rows.add((
      label: '导入压缩图片',
      onPressed: () async {
        var v = await FileSaveHelper.importCompressImages((status, total, index, pressResult, finish) {});
        var copyNum = v[0];
        var pressNum = v[1];
        if ((copyNum + pressNum) > 0) {
          if (mounted) {
            Uiutils.showSnackBar(context, "导入图片${copyNum + pressNum}张，压缩$pressNum张。");
          }
        }
      },
    ));
    rows.add((
      label: '清空压缩图片',
      onPressed: () async {
        if (cleanDoing) {
          return;
        }
        cleanDoing = true;
        await Settings.cleanCompressImages();
        cleanDoing = false;
        if (mounted) {
          Uiutils.showSnackBar(context, "清空压缩图片完成。");
        }
      },
    ));
    Uiutils.bottomSimpleSelectOptionsDialog(context, rows);
  }
}
