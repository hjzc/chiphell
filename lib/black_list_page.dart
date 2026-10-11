import 'package:chiphell/theme/theme_provider.dart';
import 'package:chiphell/utils/Toast.dart';
import 'package:chiphell/utils/ui_utils.dart';
import 'package:chiphell/utils/util_csv.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'common/constants.dart';
import 'data/black_list.dart';
import 'modals/AppState.dart';
import '../utils/zs_log.dart';

class BlackListPage extends StatefulWidget {
  const BlackListPage({super.key, this.title});
  final String? title;

  @override
  BlackListPageState createState() => BlackListPageState();
}

class BlackListPageState extends State<BlackListPage> {
  final TextEditingController _editController = TextEditingController();
  String? clipContents;
  @override
  void initState() {
    //1
    super.initState();
  }

  @override
  void didChangeDependencies() {
    //2
    super.didChangeDependencies();
  }

  @override
  void activate() {
    super.activate();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void reassemble() {
    super.reassemble();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppState>(context);
    var tp = Provider.of<ThemeProvider>(context, listen: false);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        //context.pop(appState.userBlackListChanged);
        if (!didPop) {
          //Duration.zero, Duration(seconds: 1)
          Future.delayed(Duration.zero, () {
            if (context.mounted) {
              context.pop(BlackList.userBlackListChanged);
            }
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 60,
          //automaticallyImplyLeading: true, //自动添加返回按钮
          centerTitle: true, // 标题是否居中（ios默认居中，Android默认居左）
          leading: BackButton(
            onPressed: () {
              context.pop(BlackList.userBlackListChanged);
              //context.go('/');
            },
          ),

          // flexibleSpace: BlurWidget(child: SizedBox.expand()),
          title: Text(widget.title ?? Constants.kPageTitleFilterList),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                topRightButtonAction(tp.themeBrightness());
              },
              icon: Icon(Icons.menu), //add_circle_outline),
            ),
            SizedBox(width: 24),
          ],
        ),
        body: buildRows(appState),
      ),
    );
  }

  void updateTable() {
    setState(() {});
  }

  ListView buildRows(AppState appState) {
    return ListView.builder(
      itemCount: BlackList.userBlackList.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Divider(height: 1);
        } else {
          return Column(
            children: [
              ListTile(
                leading: Icon(Icons.person),
                trailing: IconButton(
                  onPressed: () async {
                    if (await BlackList.apiRemoveBlacknameFromDb(index - 1)) {
                      updateTable();
                    }
                  },
                  icon: Icon(Icons.delete),
                ),
                title: Text(BlackList.userBlackList[index - 1]),
                onTap: () {
                  ZsLog.d('tap :${BlackList.userBlackList[index - 1]}');
                },
              ),
              Divider(height: 1),
            ],
          );
        }
      },
    );
  }

  void topRightButtonAction(Brightness? keyboardAppearance) {
    //从剪贴板导入
    //导出
    //增加
    Uiutils.showSimpleDialog(
      context,
      op1: Constants.kAlertButtonCSVFile,
      op2: Constants.kAlertButtonPastboard,
      op3: Constants.kAlertButtonAdd,
      op4: BlackList.count() > 0 ? Constants.kAlertButtonClean : null,
      callBackFun: (index) async {
        if (index == 0) {
          exportImportCSVFileOptions(keyboardAppearance);
        } else if (index == 1) {
          exportImportClipboardOptions(keyboardAppearance);
        } else if (index == 2) {
          addBlacklistNameDialog(keyboardAppearance);
        } else if (index == 3) {
          if (BlackList.count() > 0) {
            Uiutils.showAlertDialog(
              context,
              content: Constants.kPopMesgContentListClear,
              barrierDismissible: true,
              callBackFun: (isOk) async {
                if (isOk) {
                  if (await BlackList.apiRemoveAllBlacknameFromDb()) {
                    updateTable();
                  }
                }
              },
            );
          } else {
            ZsLog.d('add black item cancel!');
          }
        } else {
          //cancel
          ZsLog.d('add black item cancel!');
        }
      },
    );
  }

  void exportImportCSVFileOptions(Brightness? keyboardAppearance) {
    Uiutils.bottomSimpleSelectOptionsDialog(context, [
      (
        label: Constants.kAlertButtonImportFile,
        onPressed: () async {
          final r = await UtilCsv.importCsvFile();
          if (r.isNotEmpty) {
            int count = await BlackList.importBlackListFromCSVArray(r);
            if (count > 0) {
              updateTable();
            }
            _popMessage(count, false);
          } else {
            Toast.toastAtBottom(mounted ? context : null, '无效文件');
          }
        },
      ),
      (
        label: Constants.kAlertButtonExportFile,
        onPressed: () async {
          int count = BlackList.count();
          final r = await UtilCsv.exportCsvFile(BlackList.exportBlackList());
          if (r != null) {
            _popMessage(count, true);
          }
        },
      ),
    ]);
  }

  void exportImportClipboardOptions(Brightness? keyboardAppearance) {
    Uiutils.bottomSimpleSelectOptionsDialog(context, [
      (
        label: Constants.kAlertButtonImportPB,
        onPressed: () async {
          int count = 0;
          String text = await Uiutils.importFromClipboard(context);
          if (text.isNotEmpty) {
            final ct = await UtilCsv.parserCsvText(text);
            if (ct.isNotEmpty) {
              count = await BlackList.importBlackListFromCSVArray(await UtilCsv.parserCsvText(text));
              if (count > 0) {
                updateTable();
              }
              _popMessage(count, false);
            } else {
              Toast.toastAtBottom(mounted ? context : null, '无效数据');
            }
          } else {
            Toast.toastAtBottom(mounted ? context : null, '无可用数据');
          }
        },
      ),
      (
        label: Constants.kAlertButtonExportPB,
        onPressed: () {
          Uiutils.copyContentToClipboard(context, BlackList.exportBlackList());
        },
      ),
    ]);
  }

  void _popMessage(int count, bool exportOrImport) {
    var msg = '${exportOrImport ? '导出' : '导入'} $count 项';
    Uiutils.showSnackBar(context.mounted ? context : null, msg);
    ZsLog.i(msg);
  }

  void addBlacklistNameDialog(Brightness? keyboardAppearance) {
    Uiutils.addTextEditDialog(
      context,
      (String? inputContent, bool isOk) async {
        if (isOk) {
          if (inputContent != null && inputContent.isNotEmpty) {
            String name = BlackList.correctName(inputContent);
            if (BlackList.userBlackList.contains(name)) {
              Uiutils.showSnackBar(context, Constants.kPopMesgReadyExist);
            } else {
              if (await BlackList.apiInsertToBlacklist(name)) {
                _editController.text = '';
                updateTable();
              } else {
                Uiutils.showSnackBar(context.mounted ? context : null, Constants.kPopMesgAddFailted);
              }
            }
          }
        }
      },
      title: Constants.kAlertTitleAddFilterUserName,
      inputDecoration: Constants.kInputPromptUserName,
      controller: _editController,
      keyboardAppearance: keyboardAppearance,
    );
  }
}

/// 模糊组件
// class BlurWidget extends StatelessWidget {
//   const BlurWidget({
//     super.key,
//     this.child,
//     this.sigmaX = 20,
//     this.sigmaY = 20,
//     this.radius = BorderRadius.zero,
//   });

//   final double sigmaX;

//   final double sigmaY;

//   final Widget? child;

//   final BorderRadius radius;

//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);
//     return ClipRRect(
//       borderRadius: radius,
//       child: BackdropFilter.grouped(
//         filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
//         child: DecoratedBox(
//           decoration: BoxDecoration(color: theme.shadowColor),
//           child: child,
//         ),
//       ),
//     );
//   }
// }
