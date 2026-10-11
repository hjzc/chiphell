import 'package:chiphell/common/constants.dart';
import 'package:chiphell/data/Favorites.dart';
import 'package:chiphell/utils/ui_utils.dart';
import 'package:chiphell/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'common/type_utils.dart';
import 'view/keep_alive_wrapper.dart';
import '../utils/zs_log.dart';

class FavoritesManagerPage extends StatefulWidget {
  final String? title;
  const FavoritesManagerPage({super.key, this.title});
  @override
  FavoritesManagerPageState createState() => FavoritesManagerPageState();
}

class FavoritesManagerPageState extends State<FavoritesManagerPage> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  static const List<Tab> myTabs = <Tab>[Tab(text: '收藏夹'), Tab(text: '浏览记录')];
  final int _pageSize = 100;
  late TabController _tabController;
  int _tabIndex = 0;

  Favorites favorites = Favorites();
  List<Favor> favorList = [];
  late Future<void> _loadFavorFuture;
  List<Favor> recordList = [];
  Future<void>? _loadRecordFuture;
  bool _favorDataLoading = false;
  bool _recordDataLoading = false;

  bool _favorDataHasMore = false;
  bool _recordDatHasMore = false;

  int _favorTotal = 0;
  int _recordTotal = 0;

  ScrollController? _favorScrollController;
  ScrollController? _recordScrollController;

  double titleTextScaler = 0.8;
  double subTitleTextScaler = 0.6;

  //切换页面，如何保持当前页的状态 with AutomaticKeepAliveClientMixin
  @override
  bool get wantKeepAlive => true;

  void _autoLoadMore(bool isFavor) {
    if (isFavor) {
      if (!_favorDataLoading) {
        if (_favorTotal > favorList.length) {
          setState(() {
            _loadFavorFuture = loadFavorList(true);
          });
        }
      }
    } else {
      if (!_recordDataLoading) {
        if (_recordTotal > recordList.length) {
          setState(() {
            _loadRecordFuture = loadRecordList(true);
          });
        }
      }
    }
  }

  void _onFavorScroll() {
    if (_favorScrollController != null) {
      // double offset = _favorScrollController!.offset;
      //ZsLog.d("scroll: $offset");
      if (_favorScrollController!.position.pixels == _favorScrollController!.position.maxScrollExtent) {
        // 滑动到最底部时加载更多数据
        _autoLoadMore(true);
        // if (!_favorDataLoading) {
        //   if (_favorTotal > favorList.length) {
        //     setState(() {
        //       _loadFavorFuture = loadFavorList(true);
        //     });
        //   }
        // }
      }
    }
  }

  void _onRecordScroll() {
    if (_recordScrollController != null) {
      // double offset = _recordScrollController!.offset;
      // ZsLog.d("_onRecordScroll: $offset");
      if (_recordScrollController!.position.pixels == _recordScrollController!.position.maxScrollExtent) {
        // 滑动到最底部时加载更多数据
        _autoLoadMore(false);
        // if (!_recordDataLoading) {
        //   if (_recordTotal > recordList.length) {
        //     setState(() {
        //       _loadRecordFuture = loadRecordList(true);
        //     });
        //   }
        // }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _favorScrollController = ScrollController(keepScrollOffset: true);
    _recordScrollController = ScrollController(
      keepScrollOffset: true,
      // onAttach: (position) {
      //   ZsLog.d("onAttach: ${position.pixels}");
      // },
      // onDetach: (position) {
      //   ZsLog.d("onDetach: ${position.pixels}");
      // },
    );
    _favorScrollController?.addListener(_onFavorScroll);
    _recordScrollController?.addListener(_onRecordScroll);

    //可以加监听事件
    _tabController.addListener(() {
      ZsLog.d('${_tabController.index}');
      if (_tabIndex != _tabController.index) {
        setState(() {
          if (_tabController.index == 1 && _loadRecordFuture == null) {
            _recordDataLoading = true;
            _loadRecordFuture = loadRecordList(false);
          }
          _tabIndex = _tabController.index;
        });
      }
    });
    if (Utils.isDesktopSystem) {
      titleTextScaler = 1;
      subTitleTextScaler = 1;
    }
    _loadFavorFuture = loadFavorList(false);
    //_loadRecordFuture = loadRecordList(false);
  }

  @override
  void dispose() {
    _favorScrollController?.removeListener(_onFavorScroll);
    _recordScrollController?.removeListener(_onRecordScroll);
    _favorScrollController?.dispose();
    _recordScrollController?.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> loadFavorList(bool more) async {
    _favorDataLoading = true;
    await Future.delayed(Duration(milliseconds: 200));
    List<Favor> items = [];
    if (more) {
      int clen = favorList.length;
      int page = _favorTotal - clen;
      if (page > _pageSize) {
        page = _pageSize;
      }
      List<Favor> items = await favorites.queryAll(true, offset: favorList.length, pageSize: page);
      if (items.isNotEmpty) {
        if (items.length < page) {
          _favorTotal = favorList.length;
        }
      } else {
        _favorTotal = clen;
      }
    } else {
      _favorTotal = await favorites.count(true);
      items = await favorites.queryAll(true, pageSize: _pageSize, pageIndex: 0);
    }
    int nlen = items.length;
    bool hm = (_favorTotal > favorList.length + nlen);
    if (nlen > 0) {
      if (_favorDataHasMore != hm) {
        _favorDataHasMore = hm;
      }
      favorList.addAll(items);
    } else {
      if (_favorDataHasMore != hm) {
        setState(() {
          _favorDataHasMore = hm;
        });
      }
    }
  }

  Future<void> loadRecordList(bool more) async {
    _recordDataLoading = true;
    List<Favor> items = [];
    await Future.delayed(Duration(milliseconds: 200));
    if (more) {
      int clen = recordList.length;
      int page = _recordTotal - clen;
      if (page > _pageSize) {
        page = _pageSize;
      }
      items = await favorites.queryAll(false, offset: recordList.length, pageSize: page);
      if (items.isNotEmpty) {
        if (items.length < page) {
          _favorTotal = recordList.length;
        }
      } else {
        _recordTotal = clen;
      }
    } else {
      _recordTotal = await favorites.count(false);
      items = await favorites.queryAll(false, pageSize: _pageSize, pageIndex: 0);
    }

    int nlen = items.length;
    bool hm = (_recordTotal > recordList.length + nlen);
    if (nlen > 0) {
      if (_recordDatHasMore != hm) {
        _recordDatHasMore = hm;
      }
      recordList.addAll(items);
    } else {
      if (_recordDatHasMore != hm) {
        setState(() {
          _recordDatHasMore = hm;
        });
      }
    }
  }

  void _gotoVisiableFavor(Favor favor) {
    context.pop(favor);
  }

  void _gotoCopyFavor(Favor favor) {
    List<OptionButtonItem> list = [];
    if (favor.title != null && favor.title!.isNotEmpty) {
      list.add((
        label: Constants.kCopyTitle,
        onPressed: () {
          Uiutils.copyContentToClipboard(context, favor.title ?? '');
        },
      ));
    }
    list.add((
      label: Constants.kCopyLinker,
      onPressed: () {
        Uiutils.copyContentToClipboard(context, favor.url ?? '');
      },
    ));
    list.add((label: Constants.kTipCancel, onPressed: () {}));
    Uiutils.simpleSelectOptionsDialog(context, list);
  }

  // Widget _buildTopLine(BuildContext context) {
  //   var themeProvider = Provider.of<ThemeProvider>(context, listen: true);
  //   return Divider(
  //     color: themeProvider.isDarkThreme()
  //         ? Color.fromARGB(255, 42, 42, 42)
  //         : Color.fromARGB(
  //             240,
  //             214,
  //             214,
  //             217,
  //           ), // themeProvider.isDarkThreme() ? const Color.fromARGB(250, 12, 12, 12) : Colors.white, // 分割线颜色
  //     height: 1, // 分割线高度
  //     indent: 0, // 分割线缩进
  //     endIndent: 0, // 分割线末端缩进
  //     // thickness: 0,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 60,
        centerTitle: true, // 标题是否居中（ios默认居中，Android默认居左）
        //backgroundColor: Colors.amber,
        // bottom: PreferredSize(
        //   preferredSize: Size.fromHeight(1.0), // 分割线的高度
        //   child: Container(
        //     color: Colors.grey, // 分割线的颜色
        //     height: 1.0, // 分割线的高度
        //   ),
        // ),
        leading: BackButton(
          onPressed: () {
            context.pop(null);
            //context.go('/');
          },
        ),
        title: Text(widget.title ?? '浏览管理'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(kMinInteractiveDimension),
          child: Material(
            // color: const Color.fromARGB(255, 26, 26, 26), // 背景色设置
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // _buildTopLine(context),
                Divider(height: 1, thickness: 1),
                TabBar(
                  controller: _tabController,
                  tabs: myTabs,
                  // overlayColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                  //   if (states.contains(WidgetState.error)) {
                  //     return Colors.red;
                  //   } else if (states.contains(WidgetState.hovered) && states.contains(WidgetState.focused)) {
                  //     return Colors.blueAccent;
                  //   } else if (states.contains(WidgetState.hovered)) {
                  //     return Colors.blueAccent;
                  //   } else if (states.contains(WidgetState.focused)) {
                  //     return Colors.blue;
                  //   } else if (states.contains(WidgetState.selected)) {
                  //     return Colors.red;
                  //   } else if (states.contains(WidgetState.disabled)) {
                  //     return Colors.red;
                  //   } else if (states.contains(WidgetState.dragged)) {
                  //     return Colors.red;
                  //   } else if (states.contains(WidgetState.scrolledUnder)) {
                  //     return Colors.red;
                  //   } else if (!states.contains(WidgetState.disabled)) {
                  //     return Colors.red;
                  //   }
                  //   return null;
                  // }),
                  // labelColor: Colors.deepOrange,
                  // unselectedLabelColor: Colors.blue,
                  // indicator: BoxDecoration(
                  //   color: Colors.white, // 选中标签背景色
                  //   borderRadius: BorderRadius.circular(10),
                  // ),
                  // indicatorColor: Colors.black, // 指示器颜色
                  // labelColor: Colors.white,
                ),
              ],
            ),
          ),
        ),

        actions: <Widget>[
          _tabIndex == 1
              ? IconButton(
                  onPressed: () {
                    _topBarActionHandle();
                  },
                  icon: Icon(Icons.clear_all_outlined),
                )
              : Container(),
          SizedBox(width: 24),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          //保存滑动后 切换的scroll位置
          KeepAliveWrapper(child: buildTabFutureBuilder(context, 0)),
          KeepAliveWrapper(child: buildTabFutureBuilder(context, 1)),
        ],
      ),
    );
  }

  Future<void> _topBarActionHandle() async {
    if (!context.mounted) {
      return;
    }
    Uiutils.showAlertDialog(
      context,
      title: '警告',
      content: '请确认删除所有记录？',
      callBackFun: (isOk) async {
        if (isOk) {
          if (await favorites.removeAllNotFavorRecord()) {
            //favorList
            favorList.map((item) {
              item.setDel();
            });
            recordList.clear();
            _recordDatHasMore = false;
            _recordTotal = 0;
            setState(() {});
          }
        }
      },
    );
  }

  FutureBuilder buildTabFutureBuilder(BuildContext context, int index) {
    return FutureBuilder(
      future: index == 0 ? _loadFavorFuture : _loadRecordFuture, // 异步操作, 比如通过 api 拉取数据
      builder: (context, snapshot) {
        // 根据异步操作的状态更新UI
        bool st = (snapshot.connectionState == ConnectionState.waiting);
        if (!st) {
          if (index == 0) {
            _favorDataLoading = true;
          } else {
            _recordDataLoading = false;
          }
        }
        List<Widget> views = [index == 0 ? _buildFavoritesListView(context) : _buildRecordsRows(context)];
        if (st) {
          views.add(_loadingPage(context, index));
        }
        return Stack(alignment: AlignmentDirectional.center, children: views);

        // return IndexedStack(
        //   index: st ? 0 : 1,
        //   children: [
        //     _loadingPage(context),
        //     index == 0
        //         ? _buildFavoritesListView(context)
        //         : _buildRecordsRows(context),
        //   ],
        // );
      },
    );
  }

  Widget _loadingPage(BuildContext context, int index) {
    //hide? null //SizedBox(width: 0, height: 0):
    return Container(
      width: 70,
      height: 70,
      alignment: AlignmentGeometry.center,
      color: Color.fromARGB(0, 1, 1, 1),
      child: const SizedBox(width: 55, height: 55, child: CircularProgressIndicator()),
    );
    //
  }

  double _rowHeight() {
    double r = 80;
    if (Utils.isIOS()) {
      r = 66;
    }
    if (Utils.isAndroid()) {
      r = 70;
    }
    return r;
  }

  ListView _buildFavoritesListView(BuildContext context) {
    return ListView.builder(
      //shrinkWrap: true, // 使ListView适应内容大小，而不是填充整个屏幕。
      controller: _favorScrollController,
      itemCount: favorList.length + (_favorDataHasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if ((index != 0) && (index >= favorList.length)) {
          return buildMoreRow(context);
        }
        return Column(
          children: [
            SizedBox(
              height: _rowHeight(),
              child: ListTile(
                leading: IconButton(
                  onPressed: () async {
                    _favoritesRowLeadingButtonHandle(index);
                  },
                  icon: Icon(Icons.favorite, color: Colors.yellow),
                ),
                title: Text(favorList[index].title ?? '', maxLines: 1, textScaler: TextScaler.linear(titleTextScaler)),
                subtitle: Text(favorList[index].url ?? '', maxLines: 1, softWrap: false, textScaler: TextScaler.linear(subTitleTextScaler)),
                onLongPress: () {
                  _gotoCopyFavor(favorList[index]);
                },
                onTap: () {
                  _gotoVisiableFavor(favorList[index]);
                },
              ),
            ),
            Divider(height: 1),
          ],
        );
      },
    );
  }

  ListView _buildRecordsRows(BuildContext context) {
    return ListView.builder(
      controller: _recordScrollController,
      itemCount: recordList.length + (_recordDatHasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if ((index != 0) && (index >= recordList.length)) {
          //more
          return buildMoreRow(context);
        }
        return Column(
          children: [
            SizedBox(
              height: _rowHeight(),
              child: ListTile(
                leading: IconButton(
                  onPressed: () {
                    _recordRowLeadingButtonHandle(index);
                  },
                  icon: Icon(Icons.favorite, color: recordList[index].isFavor() ? Colors.yellow : null),
                ),
                trailing: IconButton(
                  onPressed: () {
                    _recordRowTrailingButtonHandle(index);
                  },
                  icon: Icon(Icons.delete),
                ),
                title: Text(recordList[index].title ?? '', maxLines: 1, textScaler: TextScaler.linear(titleTextScaler)),
                subtitle: Text(
                  recordList[index].url ?? "",
                  maxLines: 1,
                  softWrap: false,
                  textScaler: TextScaler.linear(subTitleTextScaler),
                  //textWidthBasis: TextWidthBasis.parent,
                ),
                onLongPress: () {
                  _gotoCopyFavor(recordList[index]);
                },
                onTap: () {
                  _gotoVisiableFavor(recordList[index]);
                },
              ),
            ),
            Divider(height: 1),
          ],
        );
      },
    );
  }

  Widget buildMoreRow(BuildContext context) {
    return SizedBox(
      height: _rowHeight(),
      child: ListTile(
        titleAlignment: ListTileTitleAlignment.center,
        title: TextButton(
          onPressed: () {
            //主要是macos/windows下
            _autoLoadMore(_tabIndex == 0);
          },
          child: Text('上拉更多......', maxLines: 1, textAlign: TextAlign.center, textScaler: TextScaler.linear(titleTextScaler)),
        ),
      ),
    );
  }

  Future<void> _favoritesRowLeadingButtonHandle(int index) async {
    Favor favor = favorList[index];
    if (favor.isFavor()) {
      //取消收藏
      Favor cp = Favor.copy(favor);
      cp.unFavor();
      if (await favorites.updateFavorVolumn(cp)) {
        favor.unFavor();
        favor.ftime = cp.ftime;
        for (int i = 0; i < recordList.length; i++) {
          Favor rr = recordList[i];
          if (rr.url == favor.url) {
            rr.unFavor();
            rr.ftime = cp.ftime;
            break;
          }
        }
        if (favor.del != 0) {
          //从数据库中删除
          if (!await favorites.remove(favor.url)) {
            //failed
          } else {}
        }
        favorList.removeAt(index);
        _favorTotal--;
        setState(() {});
      } else {
        //failed
      }
    } else {
      //不处理
    }
  }

  Future<void> _recordRowLeadingButtonHandle(int index) async {
    Favor favor = recordList[index];
    if (favor.isFavor()) {
      //取消收藏
      Favor cp = Favor.copy(favor);
      cp.unFavor();
      if (await favorites.updateFavorVolumn(cp)) {
        favor.unFavor();
        favor.ftime = cp.ftime;
        for (int i = 0; i < favorList.length; i++) {
          if (favorList[i].url == favor.url) {
            favorList.removeAt(i);
            _favorTotal--;
            break;
          }
        }
        setState(() {});
      } else {
        //failed
      }
    } else {
      //收藏
      Favor cp = Favor.copy(favor);
      cp.setFavor();
      if (await favorites.updateFavorVolumn(cp)) {
        favor.setFavor();
        favor.ftime = cp.ftime;
        favorList.insert(0, favor);
        _favorTotal++;
        setState(() {});
      } else {
        //failed
      }
    }
  }

  Future<void> _recordRowTrailingButtonHandle(int index) async {
    int idx = index;
    Favor favor = recordList[idx];
    if (favor.isFavor()) {
      //set del flag
      Favor cp = Favor.copy(favor);
      cp.del = 1;
      if (await favorites.updateDel(cp)) {
        favor.del = 1;
        _recordTotal--;
        for (int i = 0; i < favorList.length; i++) {
          if (favorList[i].url == favor.url) {
            favorList[i].del = 1;
            break;
          }
        }
        recordList.removeAt(idx);
        setState(() {});
      }
    } else {
      //del
      if (await favorites.remove(favor.url)) {
        favor.del = 1;
        recordList.removeAt(idx);
        _recordTotal--;
        setState(() {});
      }
    }
  }
}
