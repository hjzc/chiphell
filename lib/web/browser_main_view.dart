import 'dart:math';
import 'package:chiphell/common/constants.dart';
import 'package:chiphell/data/Favorites.dart';
import 'package:chiphell/data/site_url_manager.dart';
import 'package:chiphell/modals/AppState.dart';
import 'package:chiphell/modals/web_mode.dart';
import 'package:chiphell/net/download_file.dart';
import 'package:chiphell/view/textfiled_drop_down.dart';
import 'package:chiphell/utils/ui_utils.dart';
import 'package:chiphell/utils/zs_log.dart';
import 'package:chiphell/web/web_image_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../modals/url_search_resoult.dart';
import '../theme/theme_provider.dart';
import '../utils/utils.dart';
import 'browser_web_tab_page.dart';
import '../multi_windows/window_util.dart';
import 'certificate/custom_popup_dialog.dart';
import 'certificate/url_info_popup.dart';
import 'web_constants.dart';

class BrowserMainView extends StatefulWidget {
  final String? urlParam;
  final int? windowId;
  const BrowserMainView({required GlobalKey key, required this.urlParam, this.windowId}) : super(key: key);

  @override
  State<BrowserMainView> createState() => BrowserMainViewState();

  BrowserMainViewState? getState() {
    return (key as GlobalKey).currentState as BrowserMainViewState?;
  }

  Future<void> windowClose(bool userClose) async {
    return await getState()?.windowClose(userClose);
  }

  Future<void> windowFocus() async {
    return await getState()?.windowFocus();
  }

  Future<void> windowBlur() async {
    return await getState()?.windowBlur();
  }

  Future<void> windowMinimize() async {
    return await getState()?.windowMinimize();
  }

  Future<void> addNewWebTab(String url) async {
    return getState()?.addNewWebTab(url);
  }
}

class BrowserMainViewState extends State<BrowserMainView> with AutomaticKeepAliveClientMixin {
  bool _shouldExit = false;

  bool showWebViewTabsViewer = false;

  List<BrowserWebTabPage> webViewTabs = [];
  int tabCountMax = 5;
  int currentTabIndex = 0;

  //String kHomeUrl = WebConstants.kWebSearchSiteBaidu; // kWebSearchSiteBing;
  // late TextEditingController _textEditingController;
  // String lastTextEditingValue = '';
  // final FocusNode _focusNode = FocusNode();
  // GlobalKey txKey = GlobalKey();
  // GlobalKey txEditKey = GlobalKey();

  Duration customPopupDialogTransitionDuration = const Duration(milliseconds: 300);
  CustomPopupDialogPageRoute? route;
  final TextfiledDropDownController<UrlSearchResult> _dropDownController = TextfiledDropDownController<UrlSearchResult>();

  @override
  bool get wantKeepAlive => !_shouldExit;

  void tabIndexChanged(int old, int value) {
    BrowserWebTabPage? pg = webViewTabAtIndex(old);
    pg?.pause();
    _currentWebViewTabState(true);
    updateWindowTitle();
  }

  void _currentWebViewTabState(bool show) {
    BrowserWebTabPage? tp = currentWebViewTab();
    show ? tp?.resume() : tp?.pause();
  }

  //window/macos root 调用
  Future<void> windowClose(bool userClose) async {
    if (Utils.isDesktopSystem) {
      await _willCloseBrowser();
    }
  }

  //window/macos root 调用
  Future<void> windowFocus() async {
    if (Utils.isWindows()) {
      //新版本webview已经修改，这里不需要激活
      if (showWebViewTabsViewer == false) {
        _currentWebViewTabState(true);
      }
    } else {
      setState(() {});
    }
  }

  Future<void> windowBlur() async {
    //if (Utils.isWindows()) {
    //新版本webview已经修改，这里不需要激活
    // if (showWebViewTabsViewer == false) {
    //   BrowserWebTabPage tp = currentWebViewTab();
    //   tp.pause();
    // }
    // } else {
    // setState(() {});
    // }
  }

  Future<void> windowMinimize() async {
    if (Utils.isWindows()) {
      if (showWebViewTabsViewer == false) {
        _currentWebViewTabState(false);
      }
    } else {}
  }

  @override
  void initState() {
    super.initState();
    // if (Utils.isDesktopSystem ) {
    //   kHomeUrl = WebConstants.kWebSearchSiteBaidu;
    // }
    //_textEditingController = TextEditingController();

    if (Utils.isDesktopSystem) {
      tabCountMax = 999;
    }
    String? requestUrl;
    if (widget.urlParam != null && widget.urlParam!.isNotEmpty) {
      requestUrl = widget.urlParam;
    }
    int? wid;
    if (widget.windowId != null && (widget.windowId != -1)) {
      wid = widget.windowId;
    }
    webViewTabs.add(createWebViewTab(url: requestUrl, windowId: wid));
  }

  @override
  void dispose() {
    _shouldExit = true;
    //_textEditingController.dispose();
    //_focusNode.dispose();
    webViewTabs.clear();
    _dropDownController.dispose();
    ZsLog.d("browser main view dispose");
    super.dispose();
  }

  @override
  void deactivate() {
    //Widget从树中移除时触发
    super.deactivate();
    ZsLog.d('did changd app lifecycle :  deactivate');
  }

  Future<void> currentTabOpenUrl(String url) async {
    if (webViewTabs.isEmpty) {
      _addWebViewTab(url: url);
    } else {
      currentWebViewTab()?.openUrl(url);
    }
  }

  String currentTabTitle() {
    return webViewTabs.isEmpty ? '' : (webViewTabs[currentTabIndex].title ?? '');
  }

  String currentTabUrl() {
    return webViewTabs.isEmpty ? '' : (webViewTabs[currentTabIndex].currentUrl ?? '');
  }

  // Icon currentSecureIcon() {
  //   return Icon(
  //     size: 12,
  //     (webViewTabs.isEmpty ? false : (webViewTabs[currentTabIndex].isSecure == true)) ? Icons.lock : Icons.lock_open,
  //     color: (webViewTabs.isEmpty ? false : (webViewTabs[currentTabIndex].isSecure == true)) ? Colors.green : Colors.red,
  //   );
  // }

  // @override
  // Widget build(BuildContext context) {
  //   if (_shouldExit) {
  //     return Container();
  //   }
  //   var appState = Provider.of<AppState>(context, listen: false);
  //   var themeProvider = Provider.of<ThemeProvider>(context, listen: true);
  //   super.build(context);
  //   return PopScope(
  //     canPop: showWebViewTabsViewer ? false : true,
  //     onPopInvokedWithResult: (didPop, result) async {
  //       if (!didPop) {
  //         if (showWebViewTabsViewer) {
  //           setState(() {
  //             showWebViewTabsViewer = false;
  //             _currentWebViewTabState(true);
  //           });
  //         } else if (await webViewTabs[currentTabIndex].canGoBack()) {
  //           webViewTabs[currentTabIndex].goBack();
  //         }
  //       } else {
  //         await _clearAllTabs();
  //       }
  //     },
  //     child: Scaffold(
  //       appBar: showWebViewTabsViewer
  //           ? _buildWebViewTabViewerAppBar(context, appState, themeProvider)
  //           : _buildWebViewTabAppBar(context, appState, themeProvider),
  //       resizeToAvoidBottomInset: false, //避免bottombar 推上来
  //       body: IndexedStack(
  //         index: showWebViewTabsViewer ? 1 : 0,
  //         children: [_buildWebViewTabs(context, appState, themeProvider), _buildWebViewTabsViewer(context, appState, themeProvider)],
  //       ),
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    if (_shouldExit) {
      return Container();
    }
    var appState = Provider.of<AppState>(context, listen: false);
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    super.build(context);
    return _annotatedRegionWidget(context, appState, themeProvider);
  }

  Widget _annotatedRegionWidget(BuildContext context, AppState appState, ThemeProvider themeProvider) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // 该页面专属的状态栏样式
      value: Provider.of<ThemeProvider>(context).getWebPageUIOverlayStyle(),
      child: _buildPopScope(context, appState, themeProvider),
    );
  }

  Widget _buildPopScope(BuildContext context, AppState appState, ThemeProvider themeProvider) {
    return PopScope(
      canPop: showWebViewTabsViewer ? false : true,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          if (showWebViewTabsViewer) {
            setState(() {
              showWebViewTabsViewer = false;
              _currentWebViewTabState(true);
            });
          } else if (await webViewTabs[currentTabIndex].canGoBack()) {
            webViewTabs[currentTabIndex].goBack();
          }
        } else {
          await _clearAllTabs();
        }
      },
      child: Scaffold(
        appBar: showWebViewTabsViewer
            ? _buildWebViewTabViewerAppBar(context, appState, themeProvider)
            : _buildWebViewTabAppBar(context, appState, themeProvider),
        resizeToAvoidBottomInset: false, //避免bottombar 推上来
        body: IndexedStack(
          index: showWebViewTabsViewer ? 1 : 0,
          children: [_buildWebViewTabs(context, appState, themeProvider), _buildWebViewTabsViewer(context, appState, themeProvider)],
        ),
      ),
    );
  }

  void updateWindowTitle() {
    //window title update
    if (Utils.isDesktopSystem) {
      WindowUtil.updateWindowTitle(currentTabTitle());
      // SiteUrlManager.autoInsert(Uri.parse(currentTabUrl()), currentTabTitle());
    }
  }

  BrowserWebTabPage createWebViewTab({String? url, int? windowId}) {
    BrowserWebTabPage? webViewTab;
    ZsLog.d('--------------webview window id= $windowId----------------------------');
    webViewTab = BrowserWebTabPage(
      key: GlobalKey(),
      webMode: WebMode(
        initUrl: url ?? _currentSearchEnginHome(),
        initUa: AppState().webTabInitUA() ?? '',
        multipleWindows: Utils.multipleWindows,
        windowId: windowId,
        onStateUpdated: () {
          if (mounted) {
            setState(() {});
          }
          updateWindowTitle();
        },
        onCloseTabRequested: () {
          if (webViewTab != null) {
            _closeWebViewTab(webViewTab);
          }
        },
        onCreateTabRequested: (createWindowAction, orUrl) {
          if (webViewTabs.length >= tabCountMax) {
            return false;
          }
          _addWebViewTab(url: createWindowAction?.request.url.toString() ?? orUrl, windowId: createWindowAction?.windowId);
          return true;
        },
        onCloseBrowser: () async {
          if (kIsWeb) {
          } else if (Utils.isDesktopSystem) {
            //close window, 下面导航栏，退无可退，将关闭窗口
            await _willCloseBrowser();
            await WindowUtil.closeSubWindow();
          } else {
            bool r = await _willCloseBrowser();
            if (r && mounted) {
              context.pop();
            }
          }
        },
      ),
    );
    return webViewTab;
  }

  AppBar _buildWebViewTabAppBar(BuildContext context, AppState appState, ThemeProvider themeProvider) {
    return AppBar(
      toolbarHeight: kToolbarHeight,
      centerTitle: true,
      leading: IconButton(
        onPressed: () {
          _addWebViewTab();
        },
        icon: Icon(Icons.add, color: themeProvider.isDarkThreme() ? Colors.white : Colors.blue),
      ),
      titleSpacing: 0,
      title:
          // Utils.isDesktopSystem ? desktopCenterInputTitleWidget(context, appState, themeProvider) :
          Container(
            padding: EdgeInsets.all(0),
            child: Column(
              //spaceBetween两端对齐，也就是第一个子组件靠顶部，最后一个子组件靠底部，剩余组件在中间平均分散排列
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //子组件在Column中居中对齐(从Column的结构体可以看出这是默认的值)，所以图一里子控件会在垂直方向居中。
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, //高度铺满主轴方向(这个是
              children: [
                //Container(height: 2),
                _topBarCenterInputTitleWidget(context, appState, themeProvider),
                // Expanded(flex: 2, child: _topBarCenterInputTitleWidget(context, appState, themeProvider)),
                //Container(height: 2),
              ],
            ),
          ),
      actions: _buildWebViewTabActions(context, appState, themeProvider),
    );
  }

  // Widget desktopCenterInputTitleWidget(BuildContext context, AppState appState, ThemeProvider themeProvider) {
  //   return Row(
  //     mainAxisSize: MainAxisSize.max,
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [Flexible(child: _topBarCenterInputTitleWidget(context, appState, themeProvider))],
  //   );
  // }

  SearchEngin _currentSearchEngin() {
    SearchEngin r = SearchEngin.baidu;
    int i = _currentSearchEnginIndex();
    if (i == 1) {
      r = SearchEngin.bing;
    } else {}
    return r;
  }

  int _currentSearchEnginIndex() {
    return AppState().webSearchEngin;
  }

  String _currentSearchEnginHome() {
    return AppState().webSearchEnginHomeUrl;
  }

  //1 推荐db查询
  //2 search engin，异步查询
  //3 recored/history db， 长度在4个字符 查查询
  Future<List<UrlSearchResult>> _urlSuggestQuery(String searchText) async {
    // Favorites().queryUrlListFromKey(searchText, pageSize: 15);
    List<UrlSearchResult> res = Utils.validHttpUrl(searchText) ? [] : await SiteUrlManager.queryUrlListFromKey(searchText, pageSize: 1);

    if (searchText.length >= 4) {
      //书签和历史记录
      List<UrlSearchResult> records = await Favorites().queryUrlListFromKey(searchText, pageSize: 5);
      if (records.isNotEmpty) {
        UrlSearchResult sug = UrlSearchResult(
          name: "书签和历史记录",
          subName: null,
          value: null,
          type: USRType.section,
          source: USRSourceType.suggest,
          other: null,
        );
        res.add(sug);
        res.addAll(records);
      }
    }
    if (searchText.isNotEmpty && (!searchText.toLowerCase().startsWith('http'))) {
      DownloadFile.searchEnginSuggestion(
        searchText,
        engin: _currentSearchEngin(),
        result: (result, from) {
          List<UrlSearchResult> suggest = [];
          if (result.isNotEmpty) {
            ZsLog.i('TDD——搜索引擎key[$from]推荐:$result');
            UrlSearchResult sug = UrlSearchResult(
              name: from == SearchEngin.bing ? "必应建议" : "百度建议",
              subName: null,
              value: null,
              type: USRType.section,
              source: USRSourceType.suggest,
              other: null,
            );
            suggest.add(sug);

            for (int i = 0; i < result.length; i++) {
              var str = result[i];
              UrlSearchResult sug = UrlSearchResult(
                name: str,
                subName: null,
                value: str,
                type: USRType.row,
                source: USRSourceType.suggest,
                other: null,
              );
              suggest.add(sug);
            }

            _dropDownController.updateResoult(searchText, USRSourceType.suggest, suggest, (dynamic items, dynamic newItems) {
              //add to search engin end
              List<UrlSearchResult> rets = [];
              rets.addAll(items);
              if (rets.isEmpty) {
                rets.addAll(newItems);
              } else {
                int pos = 0;
                for (int i = 0; i < rets.length; i++) {
                  USRSourceType st = rets[i].source;
                  if (st == USRSourceType.db) {
                    pos++;
                  } else if (st == USRSourceType.suggest) {
                    rets.removeAt(i);
                    i--;
                  } else if (st == USRSourceType.history) {
                    break;
                  }
                }
                rets.insertAll(pos, newItems);
              }
              return rets;
            });
          } else {
            ZsLog.i('TDD——搜索引擎推荐为空');
          }
        },
      );
    }
    return res;
  }

  Widget _topBarCenterInputTitleWidget(BuildContext context, AppState appState, ThemeProvider themeProvider) {
    return TextfiledDropDown<UrlSearchResult>(
      title: currentTabTitle(),
      textValue: currentTabUrl(),
      keyboardType: TextInputType.url,
      isSecure: currentWebViewTab()?.isSecure == true,
      dropdownMaxHeight: null,
      rowHeight: null,
      sectionHeight: null,
      controller: _dropDownController,
      onChanged: (dynamic item) {
        String r = '';
        if (item is UrlSearchResult) {
          if (item.source == USRSourceType.suggest && item.type == USRType.row) {
            r = Utils.textToUrlOrSearch(item.value ?? item.name, search: appState.webSearchEngin);
          } else if (item.type == USRType.row) {
            r = item.value ?? '';
          }
        }
        return r;
      },
      onUrlInfoFn: () async {
        showUrlInfo(themeProvider);
      },
      onReloadFn: () async {
        currentWebViewTab()?.reload();
      },
      filterFn: (dynamic item, str) {
        return true;
      },
      drawTypeFn: (dynamic item) {
        if (item is UrlSearchResult) {
          return item.type;
        }
        return USRType.row;
      },
      drawHeightFn: (dynamic item) {
        if (item is UrlSearchResult) {
          if (item.type == USRType.row) {
            if (item.source == USRSourceType.suggest) {
              //只有1行
              return textfiledDropDownDefaultSectionHeight;
            }
          } else if (item.type == USRType.section) {}
        }
        //使用默认高度
        return null;
      },
      selectedFn: (dynamic item1, dynamic item2) {
        if (item1 != null && item2 != null) {
          return (item1 as UrlSearchResult).value == (item2 as UrlSearchResult).value;
        }
        return false;
      },
      findFn: (searchText) async {
        return await _urlSuggestQuery(searchText);
      },
      submit: (item, text, isSuggest) async {
        currentTabOpenUrl(text);
      },
      dropdownItemFn: (dynamic item, height, position, focused, selected, Function() onTap) {
        var result = item as UrlSearchResult;
        if (result.type == USRType.section) {
          return ListTile(
            title: Text(
              result.name,
              maxLines: 1,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            dense: true,
            minTileHeight: height,
            focusColor: Colors.transparent,
            tileColor: Colors.transparent,
            contentPadding: EdgeInsetsGeometry.all(0),
            // shape: RoundedRectangleBorder(
            //   borderRadius: BorderRadius.circular(12),
            // ),
            onTap: null,
          );
        }

        if (result.source == USRSourceType.suggest) {
          return ListTile(
            leading: Icon(Icons.search_rounded, size: 12),
            title: Text(result.name, maxLines: 1, style: TextStyle(fontSize: 12)),
            dense: true,
            minTileHeight: height,
            hoverColor: Colors.blue,
            tileColor: Colors.transparent,
            contentPadding: EdgeInsetsGeometry.fromLTRB(8, 2, 8, 2),
            horizontalTitleGap: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(height / 2.0)),
            onTap: () {
              ZsLog.d('tap');
              onTap();
            },
          );
        }
        Uri? favicon = result.faviconUri();
        return ListTile(
          leading: favicon != null
              ? WebImageView(
                  url: favicon,
                  maxWidth: 16.0,
                  width: 16.0,
                  height: 16.0,
                  defaultIconFn: () {
                    return Icon(CupertinoIcons.globe, size: 12);
                  },
                )
              : Icon(CupertinoIcons.globe, size: 12),
          title: Text(result.name, maxLines: 1, style: TextStyle(fontSize: 12)),
          subtitle: result.subName != null ? Text(result.subName!, maxLines: 1, style: TextStyle(fontSize: 10)) : null,
          dense: true,
          minTileHeight: height,
          //focusColor: const Color.fromARGB(255, 115, 4, 206),
          hoverColor: Colors.blue,
          tileColor: Colors.transparent,
          contentPadding: EdgeInsetsGeometry.fromLTRB(8, 2, 8, 2),
          horizontalTitleGap: 2,
          //minLeadingWidth: 12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(result.source == USRSourceType.suggest ? (height / 2.0) : (height / 4.0)),
          ),
          onTap: () {
            ZsLog.d('tap');
            onTap();
          },
        );
      },
      hint: WebConstants.kWebUrlAddressInputHint,
    );
  }

  Widget _buildWebViewTabs(BuildContext context, AppState appState, ThemeProvider themeProvider) {
    return IndexedStack(index: currentTabIndex, children: webViewTabs);
  }

  List<Widget> _buildWebViewTabActions(BuildContext context, AppState appState, ThemeProvider themeProvider) {
    return [
      IconButton(
        onPressed: () async {
          if (webViewTabs.isNotEmpty) {
            await webViewTabs[currentTabIndex].updateScreenshot();
            setState(() {
              showWebViewTabsViewer = true;
              _currentWebViewTabState(false);
            });
          }
        },
        icon: Container(
          margin: const EdgeInsets.only(top: 5, bottom: 5),
          decoration: BoxDecoration(
            border: Border.all(width: 2.0, color: themeProvider.isDarkThreme() ? Colors.white : Colors.blue),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(5.0),
          ),
          constraints: const BoxConstraints(minWidth: 25.0),
          child: Center(
            child: Text(
              webViewTabs.length.toString(),
              style: TextStyle(
                color: themeProvider.isDarkThreme() ? Colors.white : Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
            ),
          ),
        ),
      ),
    ];
  }

  AppBar _buildWebViewTabViewerAppBar(BuildContext context, AppState appState, ThemeProvider themeProvider) {
    return AppBar(
      leading: IconButton(
        onPressed: () {
          setState(() {
            showWebViewTabsViewer = false;
            _currentWebViewTabState(true);
          });
        },
        icon: const Icon(Icons.arrow_back),
      ),
      title: const Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Flexible(child: Text(Constants.kPageTitleWebTabList))],
      ),
      actions: _buildWebViewTabsViewerActions(),
    );
  }

  Widget _buildWebViewTabsViewer(BuildContext context, AppState appState, ThemeProvider themeProvider) {
    return GridView.count(
      crossAxisCount: 2,
      children: webViewTabs.map((webViewTab) {
        return _buildWebViewTabGrid(webViewTab, context, appState, themeProvider);
      }).toList(),
    );
  }

  Widget _buildWebViewTabGrid(BrowserWebTabPage webViewTab, BuildContext context, AppState appState, ThemeProvider themeProvider) {
    final webViewIndex = webViewTabs.indexOf(webViewTab);
    final screenshotData = webViewTab.screenshot;
    final favicon = webViewTab.favicon;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        side: currentTabIndex == webViewIndex
            ? const BorderSide(
                // border color
                color: Colors.blue,
                // border thickness
                width: 2,
              )
            : BorderSide.none,
        borderRadius: const BorderRadius.all(Radius.circular(5)),
      ),
      child: InkWell(
        onTap: () {
          _selectWebViewTab(webViewTab);
        },
        child: Column(
          children: [
            ListTile(
              tileColor: Colors.black12,
              selected: currentTabIndex == webViewIndex,
              selectedColor: Colors.white,
              selectedTileColor: Colors.blue,
              contentPadding: const EdgeInsets.only(left: 10),
              visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
              title: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    padding: const EdgeInsets.only(right: 10),
                    child: favicon != null ? WebImageView(url: favicon.url, maxWidth: 20.0, height: 20.0) : null,
                  ),
                  Expanded(
                    child: Text(webViewTab.title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              trailing: IconButton(
                onPressed: () {
                  _closeWebViewTab(webViewTab);
                },
                icon: const Icon(Icons.close, size: 16),
              ),
            ),
            Expanded(
              child: Ink(
                decoration: screenshotData != null
                    ? BoxDecoration(
                        image: DecorationImage(
                          image: MemoryImage(screenshotData),
                          fit: BoxFit.cover, // fill, //fitWidth,
                          alignment: Alignment.topCenter,
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildWebViewTabsViewerActions() {
    return [
      IconButton(
        onPressed: () async {
          Uiutils.showAlertDialog(
            context,
            content: Constants.kPopMesgContentListClear,
            callBackFun: (flag) async {
              if (flag) {
                await _closeAllWebViewTabsAction();
              }
            },
          );
        },
        icon: const Icon(Icons.clear_all),
      ),
    ];
  }

  void _addWebViewTab({String? url, int? windowId}) {
    webViewTabs.add(createWebViewTab(url: url, windowId: windowId));
    setState(() {
      int old = currentTabIndex;
      currentTabIndex = webViewTabs.length - 1;
      tabIndexChanged(old, currentTabIndex);
    });
  }

  void addNewWebTab(String url) {
    //先查看是否有相同的链接tab，有的话就不新建tab
    //ZsLog.d('打开:$url，当前：index-$currentTabIndex,tab url:${currentTabUrl()}');
    int index = -1;
    BrowserWebTabPage? tab;
    for (var i = 0; i < webViewTabs.length; i++) {
      BrowserWebTabPage w = webViewTabs[i];
      if (Utils.isEqualUrl(url, w.currentUrl)) {
        index = i;
        tab = w;
        break;
      }
    }
    if (tab != null) {
      if (currentTabIndex == index) {
        //不处理
        ZsLog.d('打开存在tab:$index,$url');
      } else {
        //选中
        _selectWebViewTab(tab);
      }
    } else {
      _addWebViewTab(url: url);
    }
  }

  void _selectWebViewTab(BrowserWebTabPage webViewTab) {
    if (webViewTabs.isEmpty) {
      return;
    }
    final webViewIndex = webViewTabs.indexOf(webViewTab);
    webViewTabs[currentTabIndex].pause();
    webViewTab.resume();
    setState(() {
      int old = currentTabIndex;
      currentTabIndex = webViewIndex;
      showWebViewTabsViewer = false;
      _currentWebViewTabState(true);
      tabIndexChanged(old, currentTabIndex);
    });
  }

  void _closeWebViewTab(BrowserWebTabPage webViewTab) {
    if (webViewTabs.isEmpty) {
      return;
    }
    final webViewIndex = webViewTabs.indexOf(webViewTab);
    webViewTab.willClose();
    webViewTabs.remove(webViewTab);
    if (currentTabIndex > webViewIndex) {
      currentTabIndex--;
    }
    if (webViewTabs.isEmpty) {
      webViewTabs.add(createWebViewTab());
      currentTabIndex = 0;
    }
    setState(() {
      int old = currentTabIndex;
      currentTabIndex = max(0, min(webViewTabs.length - 1, currentTabIndex));
      tabIndexChanged(old, currentTabIndex);
    });
  }

  BrowserWebTabPage? currentWebViewTab() {
    return webViewTabAtIndex(currentTabIndex);
  }

  BrowserWebTabPage? webViewTabAtIndex(int idx) {
    BrowserWebTabPage? r;
    if ((idx >= 0) && (idx < webViewTabs.length)) {
      r = webViewTabs[idx];
    }
    return r;
  }

  //手动关闭所有tab
  Future<void> _closeAllWebViewTabsAction() async {
    if (_shouldExit) {
      return;
    }
    await _clearAllTabs();
    webViewTabs.add(createWebViewTab());
    setState(() {
      currentTabIndex = 0;
      tabIndexChanged(-1, currentTabIndex);
    });
  }

  Future<void> _clearAllTabs() async {
    for (var i = 0; i < webViewTabs.length; i++) {
      BrowserWebTabPage w = webViewTabs[i];
      await w.willClose();
    }
    webViewTabs.clear();
    currentTabIndex = 0;
  }

  //窗口关闭了，应该先移除所有tab
  //userClose:true,用户在web页面 退出整个窗口，否则用户关掉窗口
  Future<bool> _willCloseBrowser() async {
    bool r = false;
    if (_shouldExit == false) {
      _shouldExit = true;
      await _clearAllTabs();
      //刷新一下把所有widget清空
      setState(() {});
      AppState().cleabWebSiteCache();
      r = true;
    }
    return r;
  }

  void showUrlInfo(ThemeProvider themeProvider) {
    BrowserWebTabPage? tp = currentWebViewTab();
    if (tp == null) {
      return;
    }
    var hp = tp.help();
    if (hp == null) {
      return;
    }
    var url = tp.currentUrl;
    if (url == null || url.isEmpty) {
      return;
    }

    route = CustomPopupDialog.show(
      context: context,
      transitionDuration: customPopupDialogTransitionDuration,
      //overlayColor: Colors.red,
      builder: (ctx) {
        return UrlInfoPopup(
          url: WebUri(url),
          isSecure: tp.isSecure == true,
          help: hp,
          route: route!,
          transitionDuration: customPopupDialogTransitionDuration,
          onWebViewTabSettingsClicked: () {
            // goToSettingsPage();
          },
        );
      },
    );
  }

  // Widget centerTitleWidget(
  //   BuildContext context,
  //   AppState appState,
  //   ThemeProvider themeProvider,
  // ) {
  //   String tt = currentTabTitle();
  //   return Column(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       Text(tt, overflow: TextOverflow.fade),
  //       Row(
  //         mainAxisSize: MainAxisSize.max,
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           (webViewTabs.isNotEmpty &&
  //                   webViewTabs[currentTabIndex].isSecure != null)
  //               ? currentSecureIcon()
  //               : Container(),
  //           const SizedBox(width: 5),
  //           Flexible(
  //             child: Text(
  //               webViewTabs.isEmpty
  //                   ? ''
  //                   : (webViewTabs[currentTabIndex].currentUrl ??
  //                         webViewTabs[currentTabIndex].webMode.initUrl ??
  //                         ''),
  //               style: const TextStyle(fontSize: 12, color: Colors.white70),
  //               overflow: TextOverflow.fade,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }
}
