import 'package:chiphell/common/constants.dart';
import 'package:chiphell/utils/utils.dart';
import 'package:chiphell/utils/zs_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../common/type_utils.dart';

class Uiutils {
  // MediaQuery.devicePixelRatio 每一个逻辑像素点对应的物理像素点个数
  // MediaQuery.size.width 用逻辑像素表示的屏幕宽度
  // MediaQuery.size.height 用逻辑像素表示的屏幕高度
  // MediaQuery.padding.top 屏幕上部被系统UI遮挡的部分的逻辑高度（即：状态栏高度）
  // MediaQuery.textScaleFactor 显示文字时，每一个逻辑像素对应的字体像素
  static double devWidth(BuildContext ctx) => MediaQuery.of(ctx).size.width;
  static double devHeight(BuildContext ctx) => MediaQuery.of(ctx).size.height;
  static EdgeInsets padding(BuildContext ctx) => MediaQuery.of(ctx).padding;
  static double paddingTop(BuildContext ctx) => MediaQuery.of(ctx).padding.top;

  //自动显示在scaffold树上，在overlay上没有scaffold的话 将被overlay 遮住。可以使用Toast
  static void showSnackBar(BuildContext? ctx, String message, {int milliseconds = 3000}) {
    if (ctx != null && ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(message), //style: TextStyle(color: Colors.red) ),
          duration: Duration(milliseconds: milliseconds),
          // onVisible: () {
          //   ZsLog.d('snack bar visible ');
          // },
        ),
      );
    }
  }

  static void showSnackBarIconMessage(BuildContext? ctx, IconData data, String message, CtxCallback callback, {int milliseconds = 3000}) {
    if (ctx != null && ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(data),
              SizedBox(width: 20),
              Expanded(child: Text(message)),
            ],
          ),
          duration: Duration(milliseconds: milliseconds),
        ),
      );
    }
  }

  static void showSnackActionBar(
    BuildContext? ctx,
    String message,
    String actionLabel,
    CtxCallback callback, {
    int milliseconds = 0,
    String? clostBtnTitle = Constants.kTipClose,
  }) {
    if (ctx != null && ctx.mounted) {
      if (milliseconds <= 0) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(message),
                clostBtnTitle != null
                    ? ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(Colors.redAccent), // 背景颜色
                          // textStyle: WidgetStateProperty.all<TextStyle>(TextStyle(fontSize: 20)), // 字体样式
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
                        },
                        child: Text(clostBtnTitle, style: TextStyle(color: Colors.white)),
                      )
                    : Container(),
              ],
            ),
            action: SnackBarAction(
              label: actionLabel,
              onPressed: () {
                callback(ctx);
              },
            ),
            duration: Duration(milliseconds: milliseconds),
          ),
        );
      } else {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(message),
                clostBtnTitle != null
                    ? ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(Colors.redAccent), // 背景颜色
                          // textStyle: WidgetStateProperty.all<TextStyle>(TextStyle(fontSize: 20)), // 字体样式
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
                        },
                        child: Text(clostBtnTitle),
                      )
                    : Container(),
              ],
            ),
            action: SnackBarAction(
              backgroundColor: Colors.blueAccent,
              label: actionLabel,
              onPressed: () {
                callback(ctx);
              },
            ),
            duration: Duration(milliseconds: milliseconds),
          ),
        );
      }
    }
  }

  static void showContentSnackActionBar(
    BuildContext? ctx,
    Widget content,
    String actionLabel,
    CtxCallback callback, {
    int milliseconds = 3000,
  }) {
    if (ctx != null && ctx.mounted) {
      if (milliseconds <= 0) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: content,
            closeIconColor: Colors.red,
            showCloseIcon: true,
            action: SnackBarAction(
              label: actionLabel,
              onPressed: () {
                callback(ctx);
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: content,
            closeIconColor: Colors.red,
            showCloseIcon: true,
            action: SnackBarAction(
              label: actionLabel,
              onPressed: () {
                callback(ctx);
              },
            ),
            duration: Duration(milliseconds: milliseconds),
          ),
        );
      }
    }
  }

  static Future<void> copyContentToClipboard(BuildContext? context, String message) async {
    await Clipboard.setData(ClipboardData(text: message));
    //debugPrint('复制成功:$message');
    if (context != null && context.mounted) {
      Uiutils.showSnackBar(context, '复制成功：$message');
    }
  }

  static Future<String> importFromClipboard(BuildContext context, {String format = 'text/plain'}) async {
    String r = '';
    ClipboardData? clipboardData;
    try {
      clipboardData = await Clipboard.getData(format);
      if (clipboardData != null) {
        String? text = clipboardData.text;
        if (text != null) {
          r = text;
          ZsLog.i('剪贴板内容：$text');
        } else {
          ZsLog.i('剪贴板内容空');
        }
      } else {
        ZsLog.i('剪贴板为空');
      }
    } catch (e) {
      ZsLog.e('读取剪贴板时发生错误: $e');
    }
    return r;
  }

  static Future<void> showAlertDialog(
    BuildContext? context, {
    String title = Constants.kTip,
    String content = Constants.kStrNull,
    bool barrierDismissible = false,
    String cancelTitle = Constants.kTipCancel,
    String okTitle = Constants.kTipOk,
    required void Function(bool isOk) callBackFun,
    bool delayPop = true,
  }) async {
    if (context != null && context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(content),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: <Widget>[
              //ElevatedButton OutlinedButton
              FilledButton(
                // style: ElevatedButton.styleFrom(
                //   // backgroundColor: Colors.grey,
                //   // textStyle: TextStyle(fontSize: 16),
                // ),
                onPressed: () {
                  Navigator.of(context).pop();
                  if (delayPop) {
                    Future.delayed(Duration(milliseconds: 500), () {
                      callBackFun(false);
                    });
                  } else {
                    callBackFun(false);
                  }
                },
                child: Text(cancelTitle),
              ),
              ElevatedButton(
                // style: ElevatedButton.styleFrom(
                //   backgroundColor: Colors.red,
                //   //textStyle: TextStyle(fontSize: 16),
                // ),
                onPressed: () {
                  Navigator.of(context).pop();
                  if (delayPop) {
                    Future.delayed(Duration(milliseconds: 500), () {
                      callBackFun(true);
                    });
                  } else {
                    callBackFun(true);
                  }
                },
                child: Text(okTitle),
              ),
            ],
          );
        },
      );
    }
  }

  // 显示菜单的方法
  static void showSimpleDialog(
    BuildContext? context, {
    String title = Constants.kSelectOptions,
    String? op1,
    String? op2,
    String? op3,
    String? op4,
    String? op5,
    String? op6,
    String cancel = Constants.kTipCancel,
    required void Function(int index) callBackFun,
  }) {
    if (context != null && context.mounted) {
      List<Widget> ops = [];
      int idx = 0;
      if (op1 != null) {
        int t = idx;
        ops.add(Divider());
        ops.add(
          SimpleDialogOption(
            onPressed: () {
              Future.delayed(Duration(milliseconds: 500), () {
                callBackFun(t);
              });
              Navigator.pop(context);
            },
            child: Text(op1, textAlign: TextAlign.center),
          ),
        );
        idx++;
      }
      if (op2 != null) {
        int t = idx;
        ops.add(Divider());
        ops.add(
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              Future.delayed(Duration(milliseconds: 500), () {
                callBackFun(t);
              });
            },
            child: Text(op2, textAlign: TextAlign.center),
          ),
        );
        idx++;
      }
      if (op3 != null) {
        int t = idx;
        ops.add(Divider());
        ops.add(
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              Future.delayed(Duration(milliseconds: 500), () {
                callBackFun(t);
              });
            },
            child: Text(op3, textAlign: TextAlign.center), // 菜单选项
          ),
        );
        idx++;
      }

      if (op4 != null) {
        int t = idx;
        ops.add(Divider());
        ops.add(
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              Future.delayed(Duration(milliseconds: 500), () {
                callBackFun(t);
              });
            },
            child: Text(op4, textAlign: TextAlign.center), // 菜单选项
          ),
        );
        idx++;
      }
      if (op5 != null) {
        int t = idx;
        ops.add(Divider());
        ops.add(
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              Future.delayed(Duration(milliseconds: 500), () {
                callBackFun(t);
              });
            },
            child: Text(op5, textAlign: TextAlign.center), // 菜单选项
          ),
        );
        idx++;
      }
      if (op6 != null) {
        int t = idx;
        ops.add(Divider());
        ops.add(
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              Future.delayed(Duration(milliseconds: 500), () {
                callBackFun(t);
              });
            },
            child: Text(op6, textAlign: TextAlign.center), // 菜单选项
          ),
        );
        idx++;
      }

      ops.add(Divider());
      ops.add(
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context);
            Future.delayed(Duration(milliseconds: 500), () {
              callBackFun(idx);
            });
          },
          child: Text(cancel, textAlign: TextAlign.center), // 菜单选项
        ),
      );

      showDialog(
        context: context,
        // barrierDismissible: false, // 点击空白处是否可以关闭
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text(title, textAlign: TextAlign.center), // 菜单标题
            children: ops,
          );
        },
      );
    }
  }

  static Future<void> simpleSelectOptionsDialog(
    BuildContext? context,
    List<OptionButtonItem> rows, {
    String title = Constants.kSelectOptions,
  }) async {
    if (context != null && context.mounted) {
      List<Widget> chs = [];
      for (var i = 0; i < rows.length; i++) {
        OptionButtonItem row = rows[i];
        chs.add(Divider());
        chs.add(
          SimpleDialogOption(
            // padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
            child: Text(row.label, textAlign: TextAlign.center),
            onPressed: () {
              Navigator.of(context).pop();
              Future.delayed(Duration(milliseconds: 1000), () {
                // 延迟执行的代码
                row.onPressed();
              });
            },
          ),
        );
      }
      await showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            //alignment: AlignmentGeometry.center,
            title: Text(title, textAlign: TextAlign.center),
            children: chs,
          );
        },
      );
    }
  }

  // 显示弹窗
  static void showWeChatPopup(BuildContext? context, String message, {int milliseconds = 3000}) {
    if (context != null && context.mounted) {
      OverlayEntry overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 10,
          right: 10,
          child: Material(
            color: Theme.of(context).colorScheme.primary, //Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.inversePrimary, // Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: Row(
                children: [
                  // CircleAvatar(
                  //   backgroundImage: AssetImage('assets/wechat_icon.png'),
                  // ),
                  //SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Chiphell', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(message, maxLines: 2),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // 插入到Overlay
      Overlay.of(context).insert(overlayEntry);

      // 3秒后自动隐藏
      Future.delayed(Duration(milliseconds: milliseconds), () {
        if (overlayEntry.mounted) overlayEntry.remove();
        // overlayEntry.remove();
      });
    }
  }

  // 带动画的弹窗
  static void showAnimatedPopup(BuildContext? context, String message, void Function() onPressed, {int milliseconds = 4000}) {
    if (context != null && context.mounted) {
      OverlayEntry overlayEntry;
      overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 10,
          right: 10,
          child: GestureDetector(
            onTap: () {
              //overlayEntry.remove();
              // // 跳转到对应页面
              // Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPage()));
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: Row(/* 内容同上 */),
            ),
          ),
        ),
      );

      Overlay.of(context).insert(overlayEntry);

      // 自动隐藏
      Future.delayed(Duration(milliseconds: milliseconds), () {
        if (overlayEntry.mounted) overlayEntry.remove();
      });
    }
  }

  static Future<void> addTextEditDialog(
    BuildContext? ctx,
    void Function(String? inputContent, bool isOk)? callback, {
    String title = Constants.kStrNull,
    String inputDecoration = Constants.kTipInputContentDecoration,
    String leftButtonTitle = Constants.kTipCancel,
    String rightButtonTitle = Constants.kTipOk,
    TextEditingController? controller,
    Brightness? keyboardAppearance,
    TextInputType? keyboardType,
  }) async {
    if (ctx != null && ctx.mounted) {
      TextField textField = TextField(
        decoration: InputDecoration(labelText: inputDecoration),
        keyboardAppearance: keyboardAppearance,
        controller: controller,
        keyboardType: keyboardType,
      );
      await showDialog(
        context: ctx,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: <Widget>[textField]),
            actions: <Widget>[
              ElevatedButton(
                child: Text(leftButtonTitle),
                onPressed: () {
                  if (callback != null) {
                    callback(textField.controller?.text.trim(), false);
                  }
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: Text(rightButtonTitle),
                onPressed: () {
                  if (callback != null) {
                    callback(textField.controller?.text.trim(), true);
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  // 显示菜单的方法
  static Future<MenuButtonItem?> showMenuListDialog(
    BuildContext? context,
    List<MenuButtonItem> rows, {
    RelativeRect? position,
    void Function(MenuButtonItem item)? selectedFn,
    void Function()? dismissFn,
  }) async {
    //?? RelativeRect.fromLTRB(position.dx, position.dy - 116, 16, 80),
    MenuButtonItem? ret;
    if (context != null && context.mounted) {
      RelativeRect? newPosition;
      if (position != null) {
        //重新计算
        double menuHeight = rows.length * kMinInteractiveDimension;
        double viewHeight = MediaQuery.of(context).size.height;
        double bottom = viewHeight - position.top;
        newPosition = RelativeRect.fromLTRB(position.left, position.top - menuHeight, Utils.isDesktopSystem ? 16 : 0, bottom);
      }
      ret =
          await showMenu<MenuButtonItem>(
                requestFocus: true,
                useRootNavigator: true,
                context: context,
                position: newPosition,
                elevation: 5, //阴影
                items: rows.map((MenuButtonItem item) {
                  return PopupMenuItem<MenuButtonItem>(
                    value: item,
                    height: kMinInteractiveDimension,
                    child: Row(
                      children: [
                        item.icon,
                        Container(padding: const EdgeInsets.only(left: 16.0), child: Text(item.label)),
                      ],
                    ),
                    onTap: () {
                      if (item.onPressed != null) {
                        if (item.onPressed != null) {
                          item.onPressed!();
                        }
                      }
                    },
                  );
                }).toList(),
              )
              .then((value) {
                // ZsLog.d("选中的菜单: then${value ?? 'null'}, ret:${ret ?? 'null'}");
                if (value != null && selectedFn != null) {
                  selectedFn(value);
                }
              })
              .whenComplete(() {
                //ZsLog.d("选中的菜单: whenComplete, ret:${ret ?? 'null'}");
                if (dismissFn != null) {
                  dismissFn();
                }
              });
    } else {
      if (dismissFn != null) {
        dismissFn();
      }
    }
    // ZsLog.d("选中的菜单:${ret ?? 'null'}");
    // Future.delayed(Duration(milliseconds: 600), () {
    //   // 延迟执行的代码
    //   if (ret != null && selectedFn != null) {
    //     selectedFn(ret);
    //   }
    //   if (dismissFn != null) {
    //     dismissFn();
    //   }
    // });
    // if (dismissFn != null) {
    //   dismissFn();
    // }
    return ret;
  }

  //从下往上推出一个sheet页面 var result = await Uiutils.pushModalBottomSheet(context, child: SettingPage());
  static Future<T?> pushModalBottomSheet<T>(BuildContext context, {BorderRadius? radius, Widget? child, double? height}) async {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: height ?? MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: radius ?? BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        ),
        child: child, // 你的自定义组件
      ),
    );
  }

  static Future<void> bottomSimpleSelectOptionsDialog(
    BuildContext? context,
    List<OptionButtonItem> rows, {
    String title = Constants.kSelectOptions,
    String cancel = Constants.kTipCancel,
    Future<void> Function()? cancelFn,
  }) async {
    if (context != null && context.mounted) {
      List<Widget> chs = [];
      for (var i = 0; i < rows.length; i++) {
        OptionButtonItem row = rows[i];
        chs.add(Divider());
        chs.add(
          SimpleDialogOption(
            child: Text(row.label, textAlign: TextAlign.center),
            onPressed: () {
              Navigator.of(context).pop();
              Future.delayed(Duration(milliseconds: 1000), () {
                // 延迟执行的代码
                row.onPressed();
              });
            },
          ),
        );
      }

      chs.add(Divider());
      chs.add(
        SimpleDialogOption(
          child: Text(cancel, textAlign: TextAlign.center),
          onPressed: () async {
            if (cancelFn != null) {
              cancelFn.call();
            }
            Navigator.of(context).pop();
          },
        ),
      );

      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext ctx) {
          return SimpleDialog(
            alignment: AlignmentGeometry.center,
            title: Text(title, textAlign: TextAlign.center),
            children: chs,
          );
        },
      );
    }
  }
}
