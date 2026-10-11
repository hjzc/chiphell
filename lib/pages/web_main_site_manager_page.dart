import 'package:chiphell/sites/main_site.dart';
import 'package:chiphell/theme/theme_provider.dart';
import 'package:chiphell/utils/Toast.dart';
import 'package:chiphell/utils/ui_utils.dart';
import 'package:chiphell/utils/util_map.dart';
import 'package:chiphell/utils/zs_log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../common/constants.dart';
import '../data/main_site_manager.dart';
import '../modals/AppState.dart';
import '../web/automation/web_automation_framework.dart';
import '../web/web_image_view.dart';

class WebMainSiteManagerPage extends StatefulWidget {
  const WebMainSiteManagerPage({super.key, this.title});
  final String? title;

  @override
  WebMainSiteManagePageState createState() => WebMainSiteManagePageState();
}

class WebMainSiteManagePageState extends State<WebMainSiteManagerPage> {
  final TextEditingController _editController = TextEditingController();

  List<MainSite> dataSources = [];
  Future<void>? _loadDataFuture;
  //bool _dataLoading = false;
  int _selectedIndex = 0;
  int _userSelectedIndex = 0;

  Browser? browser;

  Future<void> _loadSitesList() async {
    // _dataLoading = true;
    await Future.delayed(Duration(milliseconds: 200));
    dataSources = await MainSiteManager.getAll(
      selectedFn: (s, index) {
        _selectedIndex = index;
        _userSelectedIndex = index;
      },
    );
    // _dataLoading = false;
  }

  MainSite? _existHost(String host) {
    MainSite? r;
    for (int i = 0; i < dataSources.length; i++) {
      var v = dataSources[i];
      if (v.host == host) {
        //已经存在了
        r = v;
        break;
      }
    }
    return r;
  }

  bool _isExistHost(String host) {
    return _existHost(host) != null;
  }

  /// 0,正常退出，1，修改站点保存退出，2，内部打开退出，3，外部打开退出，
  void _popPage(int val, {String? value}) {
    context.pop({'event': val, 'param': value ?? ''});
  }

  @override
  void initState() {
    //1
    super.initState();
    _loadDataFuture = _loadSitesList();
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

  void updateTable() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppState>(context, listen: false);
    var tp = Provider.of<ThemeProvider>(context, listen: false);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          if (browser != null) {
            await browser?.close();
            browser = null;
            return;
          }
          Future.delayed(Duration.zero, () {
            if (context.mounted) {
              _popPage(0);
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
            onPressed: () async {
              if (browser != null) {
                await browser?.close();
                browser = null;
                return;
              }
              _popPage(0);
            },
          ),

          // flexibleSpace: BlurWidget(child: SizedBox.expand()),
          title: Text(widget.title ?? Constants.kPageTitleMainsiteList),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                _topRightSaveButtonAction(context, appState, tp);
              },
              icon: Icon(Icons.save_alt, color: (_userSelectedIndex != _selectedIndex) ? Colors.blueAccent : null), //add_circle_outline),
            ),
            SizedBox(width: 8),
            IconButton(
              onPressed: () {
                _topRightButtonAction(context, tp.themeBrightness());
              },
              icon: Icon(Icons.add_circle_outline), //Icons.menu),
            ),
            SizedBox(width: 24),
          ],
        ),
        body: _loadDataFutureBuilder(context, tp),
      ),
    );
  }

  ListView buildRows(BuildContext context, ThemeProvider tp) {
    return ListView.builder(
      itemCount: dataSources.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Divider(height: 1);
        } else {
          int idx = index - 1;
          MainSite site = dataSources[idx];
          return Column(
            children: [
              ListTile(
                leading: WebImageView(
                  url: site.faviconUri,
                  maxWidth: 30.0,
                  height: 30.0,
                  defaultIconFn: () {
                    return Icon(Icons.web, size: 30);
                  },
                ),
                trailing: Checkbox(
                  value: idx == _userSelectedIndex,
                  onChanged: (bool? value) {
                    setState(() {
                      _userSelectedIndex = value == true ? idx : _selectedIndex;
                    });
                  },
                ),
                title: Text(
                  site.title,
                  style: idx == _selectedIndex
                      ? TextStyle(color: Colors.red)
                      : (site.sourceType == MainSiteSourceType.recommend
                            ? TextStyle(color: const Color.fromARGB(248, 244, 54, 206))
                            : null),
                ),
                subtitle: Text(site.url),
                onLongPress: site.sourceType == MainSiteSourceType.recommend
                    ? null
                    : () {
                        //删除
                        _longTapRowAction(context, tp, site, idx);
                      },
                onTap: () {
                  _tapRowAction(context, tp, site, idx);
                },
              ),
              Divider(height: 1),
            ],
          );
        }
      },
    );
  }

  FutureBuilder _loadDataFutureBuilder(BuildContext context, ThemeProvider tp) {
    return FutureBuilder(
      future: _loadDataFuture, // 异步操作, 比如通过 api 拉取数据
      builder: (context, snapshot) {
        // 根据异步操作的状态更新UI
        bool st = (snapshot.connectionState == ConnectionState.waiting);
        if (!st) {
          //_dataLoading = false;
          _loadDataFuture = null;
        }
        List<Widget> views = [buildRows(context, tp)];
        if (st) {
          views.add(_loadingPage(context));
        }
        return Stack(alignment: AlignmentDirectional.center, children: views);
      },
    );
  }

  Widget _loadingPage(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      alignment: AlignmentGeometry.center,
      color: Color.fromARGB(0, 1, 1, 1),
      child: const SizedBox(width: 55, height: 55, child: CircularProgressIndicator()),
    );
    //
  }

  void _deleteRow(MainSite site, int idx) async {
    Uiutils.showAlertDialog(
      context,
      title: '警告',
      content: '请确认删除站点 - ${site.title}?',
      callBackFun: (isOk) async {
        if (isOk) {
          if (await MainSiteManager.deleteSite(id: site.id)) {
            dataSources.removeAt(idx);
            setState(() {});
            Toast.toastAtCenter(mounted ? context : null, '删除站点成功。');
          } else {
            Toast.toastAtCenter(mounted ? context : null, '删除站点失败。');
          }
        }
      },
    );
  }

  /// 编辑名称
  void _editRow(BuildContext context, Brightness? keyboardAppearance, MainSite site, int idx) async {
    _editController.text = site.title;
    Uiutils.addTextEditDialog(
      context,
      title: Constants.kAlertButtonEdit,
      inputDecoration: Constants.kInputPromptEditDiscuzSite,
      controller: _editController,
      keyboardAppearance: keyboardAppearance,
      keyboardType: TextInputType.text,
      (String? inputContent, bool isOk) async {
        if (isOk) {
          if (inputContent != null && inputContent.isNotEmpty) {
            String name = inputContent.trim();
            var oldtt = site.title;
            if (name.isNotEmpty && (name.length > 2) && oldtt != name) {
              var vals = site.updateTitle(name);
              if (vals.isNotEmpty) {
                if (await site.saveToDb() == true) {
                  setState(() {});
                  Toast.toastAtBottom(mounted ? context : null, '修改名称成功。');
                } else {
                  site.updateTitle(oldtt);
                  Toast.toastAtBottom(mounted ? context : null, '修改名称失败。');
                }
              } else {
                site.updateTitle(oldtt);
                Toast.toastAtBottom(context, '请输入不同名称。');
              }
            } else {
              Toast.toastAtBottom(context, '无效名称。');
            }
          }
        }
      },
    );
  }

  void _tapRowAction(BuildContext context, ThemeProvider tp, MainSite site, int idx) {
    _popPage(2, value: site.url);
  }

  /// 弹窗，删除 行, 或者打开
  void _longTapRowAction(BuildContext context, ThemeProvider tp, MainSite site, int idx) {
    if (site.sourceType == MainSiteSourceType.recommend) {
      return;
    }

    Uiutils.showSimpleDialog(
      context,
      op1: Constants.kUrlInPageOpen,
      op2: Constants.kOutBrowserOpen,
      op3: site.isSelected ? Constants.kAlertButtonEdit : Constants.kAlertButtonDelete,
      op4: site.isSelected ? null : Constants.kAlertButtonEdit,
      callBackFun: (index) async {
        if (index == 0) {
          _popPage(2, value: site.url);
        } else if (index == 1) {
          _popPage(3, value: site.url);
        } else if (index == 2) {
          if (site.isSelected) {
            _editRow(context, tp.themeBrightness(), site, index);
          } else {
            _deleteRow(site, index);
          }
        } else if (index == 3) {
          if (!site.isSelected) {
            _editRow(context, tp.themeBrightness(), site, index);
          }
        } else {
          //cancel
          ZsLog.d('add black item cancel!');
        }
      },
    );
  }

  /// 保存用户选择的站点
  void _topRightSaveButtonAction(BuildContext context, AppState appState, ThemeProvider tp) async {
    if (_userSelectedIndex != _selectedIndex) {
      MainSite osite = dataSources[_selectedIndex];
      MainSite site = dataSources[_userSelectedIndex];
      bool r = await appState.selecteMainSite(osite, site);
      if (r) {
        _selectedIndex = _userSelectedIndex;
        osite.unSelecte();
        site.setSelected();
        setState(() {});
        Toast.toastAtCenter(mounted ? context : null, '设置主站点 - ${site.title} 成功！');
        if (context.mounted) {
          _popPage(1);
        }
      } else {
        Toast.toastAtCenter(mounted ? context : null, '设置主站点 - ${site.title} 失败！');
      }
    }
  }

  void _topRightButtonAction(BuildContext context, Brightness? keyboardAppearance) {
    Uiutils.addTextEditDialog(
      context,
      title: Constants.kAlertTitleAddDiscuzSite,
      inputDecoration: Constants.kInputPromptDiscuzSite,
      controller: _editController,
      keyboardAppearance: keyboardAppearance,
      keyboardType: TextInputType.url,
      (String? inputContent, bool isOk) async {
        if (isOk) {
          if (inputContent != null && inputContent.isNotEmpty) {
            String name = inputContent.trim();
            Uri? u;
            if (name.isNotEmpty && name.length > 2) {
              if (name.startsWith('https://') == false && !name.startsWith('http://')) {
                name = 'https://$name';
              }
              u = Uri.parse(name);
              if (!u.hasAuthority) {
                u = null;
              } else if (_isExistHost(u.authority)) {
                Toast.toastAtBottom(context, '已经存在');
                return;
              }
            }
            if (u == null) {
              //无效url
              Toast.toastAtBottom(context, '无效链接');
            } else {
              _loadDataFuture = startRunBrowser(u);
            }
            // if (dataSources.contains(name)) {
            //   Uiutils.showSnackBar(context, Constants.kPopMesgReadyExist);
            // } else {}
          }
        }
      },
    );
  }

  Future<void> startRunBrowser(Uri u) async {
    if (browser == null || browser!.isClosed()) {
      browser = await WebAutomationFramework.launch();
    }
    final page = await browser!.newPage();
    page.onConsole = (consoleMessage) async {
      if (kDebugMode) {
        ZsLog.d(consoleMessage);
      }
    };
    bool domReady = false;
    page.onDOMContentLoaded = (String? urlStr) async {
      domReady = true;
    };
    final response = await page.goto(url: u.toString());
    if (mounted && ((response != null && response.statusCode == 200) || domReady)) {
      /// https://cliff.imwork.net:19999/xfbbs/
      String js = await rootBundle.loadString('assets/js/get_discuz.js');
      final val = await page.evaluate(source: js);
      if (val != null && (val is Map && val.isNotEmpty)) {
        //{curl: https://cliff.imwork.net:19999/xfbbs/, cpath: /xfbbs/, uid: 0, domain: , chost: cliff.imwork.net:19999, cookiepre: t453_2132_, title: 消费秀, host: cliff.imwork.net:19999/xfbbs, source: 2.0, scheme: 0.0, type: 1.0, corigin: https://cliff.imwork.net:19999}
        // print(val);
        Map<String, dynamic> vmap = UtilMap.safeConvertSDMap(val);
        MainSite? ms = MainSite.fromMap(vmap);
        if (ms != null && ms.valid && ms.isDiscuz) {
          ms.updateSource(MainSiteSourceType.user);
          ms.updateSiteType(SiteType.discuz);
          if (_isExistHost(ms.host)) {
            Toast.toastAtBottom((mounted ? context : null), '发现存在的站点-${ms.title}[${ms.url}]');
          } else {
            if (await MainSiteManager.insert(ms)) {
              Toast.toastAtBottom((mounted ? context : null), '发现新站点-${ms.title}[${ms.url}],保存成功');
              dataSources.add(ms);
              setState(() {});
            } else {
              Toast.toastAtBottom((mounted ? context : null), '发现新站点-${ms.title}[${ms.url}],保存失败');
            }
          }
        } else {
          //无效
          Toast.toastAtCenter((mounted ? context : null), '无法解析网址内容。');
        }
      } else {
        //失败
        Toast.toastAtCenter((mounted ? context : null), '加载页面失败。');
      }
    }
    await browser?.close();
    browser = null;
  }
}
