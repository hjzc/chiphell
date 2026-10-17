import 'dart:async';

import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../modals/AppState.dart';
import '../modals/url_search_resoult.dart';
import '../theme/theme_provider.dart';
import '../utils/ui_utils.dart';
import '../utils/utils.dart';

const double textfiledDropDownDefaultRowHeight = 40;
const double textfiledDropDownDefaultSectionHeight = 24;

//选中一个行
class TextfiledDropDownController<T> extends ChangeNotifier {
  T? _value;

  void Function(String searchText, USRSourceType source, List<T> results, List<T> Function(List<T> items, List<T> newItems) mergFn)?
  _searchResult;

  TextfiledDropDownController({T? value}) : _value = value;
  T? get value => _value;
  set value(T? newValue) {
    if (_value == newValue) {
      return;
    }
    _value = newValue;
    notifyListeners();
  }

  void updateResoult(String searchText, USRSourceType source, List<T> results, List<T> Function(List<T> items, List<T> newItems) mergFn) {
    if (_searchResult != null) {
      _searchResult?.call(searchText, source, results, mergFn);
    }
  }

  @override
  String toString() => '${describeIdentity(this)}($value)';
}

class TextfiledDropDown<T> extends StatefulWidget {
  final String title; //site title
  final String? hint;
  final String textValue; //url
  final bool? isSecure;
  final double? rowHeight;
  final double? sectionHeight;
  final double? dropdownMaxHeight;
  final TextInputType keyboardType; // TextInputType.url,
  final bool? isNoShowSearchUrl;

  final TextfiledDropDownController<T> controller;
  final String Function(T item)? onChanged;

  final Future<void> Function() onUrlInfoFn;
  final Future<void> Function() onReloadFn;

  final bool Function(T item, String str)? filterFn;
  final USRType Function(T item)? drawTypeFn;
  final double? Function(T item)? drawHeightFn;
  final bool Function(T? item1, T? item2)? selectedFn;
  //输入值变了，需要去查找
  final Future<List<T>> Function(String str) findFn;
  //提交最后值
  final Future<void> Function(dynamic item, String text, bool isSuggest) submit;

  final Widget Function(T item, double height, int position, bool focused, bool selected, Function() onTap) dropdownItemFn;

  const TextfiledDropDown({
    super.key,
    required this.title,
    required this.hint,
    required this.textValue,
    required this.isSecure,
    required this.rowHeight,
    required this.sectionHeight,
    required this.dropdownMaxHeight,
    required this.keyboardType,
    required this.controller,
    required this.onChanged,
    required this.onUrlInfoFn,
    required this.onReloadFn,
    required this.filterFn,
    required this.drawTypeFn,
    required this.drawHeightFn,
    required this.selectedFn,
    required this.findFn,
    required this.submit,
    required this.dropdownItemFn,
    this.isNoShowSearchUrl,
  });

  @override
  State<StatefulWidget> createState() {
    return TextfiledDropDownState<T>();
  }
}

class TextfiledDropDownState<T> extends State<TextfiledDropDown> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  GlobalKey txKey = GlobalKey();
  GlobalKey txEditKey = GlobalKey();
  final TextEditingController _textEditingController = TextEditingController();
  String _lastTextEditingValue = '';

  final FocusNode _widgetFocusNode = FocusNode();
  //bool _isFocused = false;

  final FocusNode _focusNode = FocusNode();

  GlobalKey _overlayEntryKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  double _overlayEntryWidth = 0;
  OverlayEntry? _overlayBackdropEntry;
  Size _overlayBackdropEntrySize = Size.zero;

  List<T>? _options;
  int _listItemFocusedPosition = 0;
  T? _selectedItem;
  //bool get _isEmpty => _selectedItem == null;

  //设置 widget.dropdownMaxHeight，否则desktop 480/mobile 320
  double _dropdownMaxHeight = 0;

  double _rowHeight = textfiledDropDownDefaultRowHeight;
  double _sectionHeight = textfiledDropDownDefaultSectionHeight;

  //计算实际高度
  // double _dropdownTotalHeight = 0;

  //等于_dropdownTotalHeight 不能大于 dropdownMaxHeight
  double _dropdownHeight = 0;
  set dropdownHeight(double v) {
    if (v != _dropdownHeight) {
      setState(() {
        _dropdownHeight = v;
      });
      if (_overlayEntry != null && _overlayEntry!.mounted) {
        _overlayEntry?.markNeedsBuild();
      }
      if (_overlayBackdropEntry != null && _overlayBackdropEntry!.mounted) {
        _overlayBackdropEntry?.markNeedsBuild();
      }
    }
  }

  TextfiledDropDownController<dynamic>? get _effectiveController => widget.controller;

  final LayerLink _layerLink = LayerLink();
  final ValueNotifier<List<T>> _listItemsValueNotifier = ValueNotifier<List<T>>([]);
  //final Function(T?, T?) _selectedFn = (dynamic item1, dynamic item2) => item1 == item2;
  bool _selectedFn(dynamic item1, dynamic item2) => item1 == item2;

  //Timer? _debouncer;
  //Timer? _overlayEntryDebounce;
  int _inputTextLength = 0;
  Debouncer<int>? _overlayEntryDebounce;

  Debouncer<String>? _debouncer;
  String? _lastSearchString;

  late String hintStr;

  double sugOffsetY = 0;
  late EdgeInsets padding;
  @override
  void initState() {
    super.initState();
    hintStr = widget.hint ?? ''; //WebConstants.kWebUrlAddressInputHint;
    padding = const EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0);
    sugOffsetY = padding.top;

    // keyboardType = widget.keyboardType ?? TextInputType.text; // TextInputType.url,
    WidgetsBinding.instance.addObserver(this);
    if (widget.dropdownMaxHeight != null && widget.dropdownMaxHeight! > 0) {
      _dropdownHeight = widget.dropdownMaxHeight!;
    }
    if (widget.rowHeight != null) {
      _rowHeight = widget.rowHeight!;
    }
    if (widget.sectionHeight != null) {
      _sectionHeight = widget.sectionHeight!;
    }
    if (widget.dropdownMaxHeight != null) {
      _dropdownMaxHeight = widget.dropdownMaxHeight!;
    } else {
      _dropdownMaxHeight = Utils.isDesktopSystem ? 480 : 320;
    }

    _effectiveController?._searchResult = (searchText, source, dynamic results, dynamic mergFn) {
      if (results.isNotEmpty && _overlayEntry != null && _overlayEntry!.mounted && searchText == _lastSearchString) {
        List<T> ops = [];
        if (_options == null) {
          ops = results as List<T>;
        } else {
          ops.addAll(_options as List<T>);
          ops = mergFn(ops, results) as List<T>;
        }
        _updateDropDownTableLayout(ops, searchText);
      }
    };
    _onTextChanged('');
    // ZsLog.i('TDD——init end');
  }

  @override
  void dispose() {
    _effectiveController?._searchResult = null;
    _debouncer?.cancel();
    _debouncer = null;
    _overlayEntryDebounce?.canceled;
    _overlayEntryDebounce = null;
    _focusNode.dispose();
    _widgetFocusNode.dispose();
    _textEditingController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  set lastTextEditingValue(String v) {
    if (v != _lastTextEditingValue) {
      bool f = v.isEmpty || _lastTextEditingValue.isEmpty;
      _lastTextEditingValue = v;
      if (f) {
        setState(() {});
      }
    }
  }

  @override
  void didChangeDependencies() {
    //--zorro add 2026-06-23
    // _updateBackdropOverlaySize();
    // _updateOverlayEntryWidth();
    super.didChangeDependencies();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    //窗口大小变化,在这里执行你的逻辑，比如更新UI等。
    // ZsLog.d('TDD——didChangeMetrics: 窗口大小变化');
    _updateBackdropOverlaySize();
    _updateOverlayEntryWidth();
  }

  @override
  Widget build(BuildContext context) {
    AppState appState = Provider.of<AppState>(context, listen: true);
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: () {
          _widgetFocusNode.requestFocus();
        },
        child: Focus(
          autofocus: true,
          focusNode: _widgetFocusNode,
          onFocusChange: (focused) {
            setState(() {
              //_isFocused = focused;
              // ZsLog.d('TDD——_widgetFocusNode _isFocused=$_isFocused');
            });
          },
          onKeyEvent: (node, event) {
            return _onKeyPressed(event, appState, themeProvider) ? KeyEventResult.handled : KeyEventResult.ignored;
          },
          child: centerInputTitleWidget(context, appState, themeProvider),
        ),
      ),
    );
  }

  Widget centerInputTitleWidget(BuildContext context, AppState appState, ThemeProvider themeProvider) {
    String tt = widget.title;
    String ttValue = widget.textValue;
    // final hint = WebConstants.kWebUrlAddressInputHint;
    // '搜索或输入网站名称';
    bool isDark = themeProvider.isDarkTheme();
    EdgeInsets contentEI = EdgeInsets.fromLTRB((widget.isSecure != null) ? 0 : 38, 4, 0, 4); //调整这个值来垂直居中,

    return Padding(
      padding: padding,
      // padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: AutoSizeTextField(
        key: txKey,
        textFieldKey: txEditKey,
        controller: _textEditingController,
        focusNode: _focusNode,
        minLines: 1,
        maxLines: 1,
        minFontSize: Utils.isDesktopSystem ? 10 : 7,
        maxFontSize: Utils.isDesktopSystem ? 16 : 14,
        scrollPadding: EdgeInsets.fromLTRB(16, 4, 16, 4),
        wrapWords: false,
        autocorrect: false,
        autofocus: true,
        enableSuggestions: true, //避免触发安全键盘
        //stepGranularity:2, 每次字体缩小步进
        obscureText: false, //安全键盘不能切换输入法
        minWidth: Utils.isDesktopSystem ? 600 : (Uiutils.devWidth(context) - 32),
        fullwidth: false,
        // style: TextStyle(
        //   fontSize: 16,
        //   height: -1, // 行高，调整这个值可以影响垂直位置
        //   color: Colors.black,
        // ),
        style: Theme.of(context).textTheme.titleSmall,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        // enableIMEPersonalizedLearning:true,
        keyboardType: widget.keyboardType,
        keyboardAppearance: themeProvider.themeBrightness(),
        // textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          hintMaxLines: 1,
          hintText: (_focusNode.hasFocus && _lastTextEditingValue.isEmpty)
              ? hintStr
              : (tt.length > 1 ? tt : (ttValue.isNotEmpty ? ttValue : hintStr)),
          hintStyle: TextStyle(
            color: Colors.grey,
            textBaseline: TextBaseline.alphabetic, //用于对齐字母字符字形底部的水平线
          ),
          prefixIcon: widget.isSecure != null
              ? IconButton(
                  onPressed: () async {
                    widget.onUrlInfoFn.call();
                    //showUrlInfo(themeProvider);
                  },
                  icon: Icon(
                    widget.isSecure == true ? Icons.lock : Icons.lock_open,
                    size: 12,
                    color: widget.isSecure == true ? Colors.green : Colors.red,
                  ),
                )
              : null,
          suffixIcon: IconButton(
            onPressed: () async {
              widget.onReloadFn.call();
            },
            icon: Icon(Icons.refresh, color: isDark ? Colors.white70 : Colors.grey),
          ),

          border: OutlineInputBorder(
            borderSide: BorderSide(width: 1.0, color: isDark ? Colors.white70 : Colors.grey, style: BorderStyle.solid),
            borderRadius: BorderRadius.all(Radius.circular(Utils.isDesktopSystem ? 24 : 16)),
          ),
          isDense: true, // 减少默认内边距
          contentPadding: contentEI, //调整这个值来垂直居中,
        ),
        buildCounter: (context, {required currentLength, required isFocused, required maxLength}) {
          if (isFocused) {
            //长度变化-输入内容的区域的宽度有可能变化，需要更新
            _onTextLengthChanged(currentLength);
          }
          // ZsLog.d(
          //   'TDD——autotextfiled: buildCounter:$currentLength,$isFocused,$maxLength',
          // );
          if (_overlayEntry == null && !isFocused && _focusNode.hasFocus == false && (_textEditingController.text != '')) {
            Future.delayed(Duration(milliseconds: 400), () {
              if (_focusNode.hasFocus == false && _textEditingController.text != '') {
                //清空值，显示title
                _textEditingController.text = '';
              }
            });
          }
          return null;
        },
        onChanged: (value) {
          // ZsLog.d('TDD——autotextfiled: onChanged:$value');
          if (_textEditingController.value.isComposingRangeValid) {
            return;
          }
          if (_overlayEntry == null) {
            _addOverlay(appState, themeProvider);
          }
          lastTextEditingValue = value.trim();
          _onTextChanged(_lastTextEditingValue);
        },
        onEditingComplete: () {
          if (_textEditingController.text != '') {
            if (_lastTextEditingValue.isNotEmpty) {
              _textEditingController.text = '';
            }
            // else { 避免没有输入，没有修改原来的值}
          }
          // ZsLog.d('TDD——autotextfiled: onEditingComplete');
        },
        onSubmitted: (String value) {
          //回车时候
          var text = _lastTextEditingValue;
          if (text.isEmpty) {
            text = value.trim();
            text = text.isNotEmpty ? text : _textEditingController.text.trim();
          }
          if (text.isNotEmpty) {
            String newUrl = Utils.textToUrlOrSearch(text, search: appState.webSearchEngin);
            if (newUrl != _textEditingController.text) {
              if (widget.isNoShowSearchUrl != null && widget.isNoShowSearchUrl == true) {
                //不显示url
              } else {
                _textEditingController.text = newUrl;
              }
            }
            _focusNode.nextFocus();
            if (newUrl != ttValue) {
              //url 改变了，需要打开
              //currentTabOpenUrl(newUrl);
              widget.submit(null, newUrl, false);
            }
          }
          _removeOverlay();
          //ZsLog.d('TDD——autotextfiled: onSubmitted');
        },
        // 禁用菜单和文本选择（默认值为true）
        //enableInteractiveSelection: false,
        contextMenuBuilder: (context, editableTextState) {
          // final List<ContextMenuButtonItem> items = editableTextState.contextMenuButtonItems.toList();
          // items.add(ContextMenuButtonItem(
          //   label: '翻译',
          //   onPressed: () => _translateText(editableTextState.textEditingValue.selection.textInside(editableTextState.textEditingValue.text)),
          // ));
          // return AdaptiveTextSelectionToolbar.buttonItems(
          //   anchors: editableTextState.contextMenuAnchors,
          //   buttonItems: items,
          // );
          return AdaptiveTextSelectionToolbar.editableText(editableTextState: editableTextState);
        },

        onTap: () {
          //ZsLog.d('TDD——autotextfiled: onTap-start${_focusNode.hasFocus}');
          //一些系统，会触发安全输入法，导致不能切换输入法，触发输入法重新加载，enableSuggestions: true解决
          // SystemChannels.textInput.invokeMethod('TextInput.show');
          //如果之前在编辑状态，在点击不应该修改值
          int textLen = _textEditingController.text.length;
          if (_focusNode.hasFocus) {
            if (textLen > 0) {
              int selectedLens = _textEditingController.selection.extentOffset - _textEditingController.selection.baseOffset;
              if (selectedLens > 0) {
                //用户编辑中
                if (selectedLens == textLen) {
                  //已经全选,取消选中
                  _textEditingController.selection = TextSelection(baseOffset: 0, extentOffset: 0);
                }
                return;
              } else {
                //用户编辑中
                return;
              }
            }
          } else {
            _textEditingController.text = widget.textValue;
            setState(() {
              FocusScope.of(context).requestFocus(_focusNode);
            });
            _textEditingController.selection = TextSelection(baseOffset: 0, extentOffset: _textEditingController.text.length);
          }

          //内容有效弹出下拉菜单
          if (_textEditingController.text.trim().isNotEmpty) {
            if (_overlayEntry == null) {
              //textfiled 输入内容宽度变化， delay显示能获取真实宽度
              Future.delayed(Duration(milliseconds: 100), () {
                _addOverlay(appState, themeProvider);
              });
            } else {
              //check 大小
              _onTextChanged(_textEditingController.text);
            }
          }
          //ZsLog.d('TDD——autotextfiled: onTap--end');
        },
        onTapOutside: (PointerDownEvent ev) {
          final text = context.findRenderObject() as RenderBox;

          ///判断是否点在自己身上，如果是的话，要判断是否用户想选中文字
          Rect textRect = text.paintBounds;
          Offset gos = ev.position;
          Offset intextPos = text.globalToLocal(gos);
          if (intextPos.dx >= textRect.left &&
              intextPos.dx < textRect.right &&
              intextPos.dy >= textRect.top &&
              intextPos.dy < textRect.bottom) {
            //点击在自己上
            if (_textEditingController.text.trim().isNotEmpty) {
              if (_textEditingController.selection.extentOffset - _textEditingController.selection.baseOffset > 0) {
                //_textEditingController.selection = TextSelection(baseOffset: 0, extentOffset: 0);
              } else {
                _textEditingController.selection = TextSelection(baseOffset: 0, extentOffset: _textEditingController.text.length);
              }
              if (_focusNode.hasFocus) {
                //进入编辑状态，移除建议，否则不能弹出编辑菜单（copy，cut...）
                _removeOverlay();
              }
            }
            return;
          }
          if (_overlayEntry != null && _overlayEntryKey.currentContext != null) {
            final box = _overlayEntryKey.currentContext?.findRenderObject() as RenderBox;
            Rect rect = box.paintBounds;

            Offset pos = Offset(intextPos.dx, intextPos.dy - textRect.size.height + 4);
            if (_overlayEntry != null &&
                (((pos.dx >= rect.left) && (pos.dx <= rect.right) && (pos.dy >= rect.top) && (pos.dy <= rect.bottom)))) {
              // ZsLog.d(
              //   'TDD——autotextfiled: onTapOutside false,按下位置: ${ev.position},本地位置: ${ev.localPosition},pointer($pos) in drop view($rect)',
              // );
              setState(() {
                FocusScope.of(context).requestFocus(_focusNode);
              });
              return;
              // _widgetFocusNode.requestFocus();
            }
          }
          // ZsLog.d(
          //   'TDD——autotextfiled: onTapOutside true,按下位置: ${ev.position},本地位置: ${ev.localPosition},pointer($ev.position)',
          // );
          _textEditingController.text = '';
          _removeOverlay();
          _focusNode.nextFocus();
          //刷新hint 内容
          setState(() {});
        },
      ),
    );
  }

  OverlayEntry _createOverlayEntry(AppState appState, ThemeProvider themeProvider) {
    final renderObject = context.findRenderObject() as RenderBox;
    final Size size = renderObject.size;
    _overlayEntryWidth = size.width;
    var overlay = OverlayEntry(
      builder: (context) {
        return Positioned(
          key: _overlayEntryKey,
          width: _overlayEntryWidth,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            //targetAnchor: Alignment.topCenter, // 目标组件的锚点
            //followerAnchor: Alignment.bottomCenter, // 跟随组件的锚点
            offset: Offset(0.0, size.height - sugOffsetY),
            child: Material(
              elevation: 4.0, //阴影
              borderRadius: BorderRadius.circular(16.0),
              child: SizedBox(
                height: _dropdownHeight,
                child: Container(
                  color: Colors.transparent, //下面是圆角。所以这里要透明色
                  child: ValueListenableBuilder(
                    valueListenable: _listItemsValueNotifier,
                    builder: (context, List<T> items, child) {
                      return _options != null && _options!.isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
                              itemCount: _options!.length,
                              itemBuilder: (context, position) {
                                T item = _options![position];
                                // Function() onTap = () {
                                //   _listItemFocusedPosition = position;
                                //   _tapRowAction();
                                //   _removeOverlay();
                                // };
                                double height = _calCellHeight(item);
                                Widget listTile = widget.dropdownItemFn(
                                  item,
                                  height,
                                  position,
                                  position == _listItemFocusedPosition,
                                  (widget.selectedFn ?? _selectedFn)(_selectedItem, item),
                                  () {
                                    //user tap
                                    _listItemFocusedPosition = position;
                                    _tapRowAction(appState);
                                  },
                                );
                                return listTile;
                              },
                            )
                          : Container(
                              padding: EdgeInsets.all(0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [SizedBox(height: 0, width: size.width)],
                              ),
                            );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    return overlay;
  }

  void _onTextLengthChanged(int len) {
    if (_overlayEntryDebounce == null) {
      _overlayEntryDebounce = Debouncer<int>(
        Duration(milliseconds: 500),
        initialValue: len,
        onChanged: (value) {
          if (_inputTextLength != value) {
            _inputTextLength = value;
            _updateOverlayEntryWidth();
          }
        },
      );
    } else {
      _overlayEntryDebounce?.value = len;
    }

    // if (_overlayEntryDebounce?.isActive ?? false)
    //   _overlayEntryDebounce!.cancel();
    // _overlayEntryDebounce = Timer(const Duration(milliseconds: 300), () {
    //   if (inputTextLength != len) {
    //     inputTextLength = len;
    //     _updateOverlayEntryWidth();
    //   }
    // });
  }

  bool _updateBackdropOverlaySize() {
    var r = false;
    if (_overlayBackdropEntry != null) {
      Size bgSize = MediaQuery.of(context).size;
      // ZsLog.d('TDD——_createBackdropOverlay size:$bgSize');
      if (bgSize != _overlayBackdropEntrySize) {
        _overlayBackdropEntrySize = bgSize;
        _overlayBackdropEntry?.markNeedsBuild();
        r = true;
      }
    }
    return r;
  }

  bool _updateOverlayEntryWidth() {
    var r = false;
    if (_overlayEntry != null) {
      final renderObject = context.findRenderObject() as RenderBox;
      final Size size = renderObject.size;
      if (_overlayEntryWidth != size.width) {
        _overlayEntryWidth = size.width;
        _overlayEntry?.markNeedsBuild();
        r = true;
      }
    }

    return r;
  }

  OverlayEntry _createBackdropOverlay(AppState appState, ThemeProvider themeProvider) {
    final text = context.findRenderObject() as RenderBox;
    Rect bd = text.paintBounds;
    var top = bd.bottom - 10;
    if (_overlayBackdropEntrySize == Size.zero) {
      _overlayBackdropEntrySize = MediaQuery.of(context).size;
    }
    return OverlayEntry(
      canSizeOverlay: true,
      builder: (context) => Positioned(
        left: 0,
        top: top,
        height: _overlayBackdropEntrySize.height,
        width: _overlayBackdropEntrySize.width,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: Container(color: const Color.fromARGB(1, 44, 44, 44)),
          onTap: () {
            // ZsLog.d('TDD——_createBackdropOverlay onTap');
            // if(_textEditingController.)
            // _removeOverlay();
          },
        ),
      ),
    );
  }

  void _addOverlay(AppState appState, ThemeProvider themeProvider) {
    if (_overlayEntry == null) {
      _onTextChanged(_textEditingController.text);
      // _lastSearchString = _textEditingController.text;
      // //必须与_lastSearchString相同值，否则可能下一次不执行
      // _debouncer?.value = _lastSearchString ?? '';
      // _search(_lastSearchString ?? "");
      // ZsLog.d('TDD——_addOverlay...');
      _overlayBackdropEntry = _createBackdropOverlay(appState, themeProvider);
      _overlayEntry = _createOverlayEntry(appState, themeProvider);
      if (_overlayEntry != null) {
        //Overlay.of(context).insert(_overlayEntry!);
        Overlay.of(context).insertAll([_overlayBackdropEntry!, _overlayEntry!]);
        setState(() {
          _focusNode.requestFocus();
        });
      }
    }
  }

  /// Dettach overlay from the dropdown widget
  void _removeOverlay() {
    bool update = false;
    _lastSearchString = '';
    //必须与_lastSearchString相同值，否则可能下一次不执行
    _debouncer?.value = _lastSearchString ?? '';
    _listItemFocusedPosition = 0;
    _selectedItem = null;
    _options?.clear();
    if (_overlayBackdropEntry != null) {
      _overlayBackdropEntry!.remove();
      _overlayBackdropEntry = null;
      update = true;
    }
    if (_overlayEntry != null) {
      // ZsLog.d('TDD——_removeOverlay...');
      _overlayEntry!.remove();
      _overlayEntry = null;
      _overlayEntryKey = GlobalKey();
      // _searchTextController.value = TextEditingValue.empty;
      update = true;
    }
    if (_listItemsValueNotifier.value.isNotEmpty) {
      _listItemsValueNotifier.value = List<T>.from(_options ?? []);
    }
    if (update) {
      setState(() {});
    }
  }

  // _toggleOverlay(AppState appState, ThemeProvider themeProvider) {
  //   if (_overlayEntry == null)
  //     _addOverlay(appState, themeProvider);
  //   else
  //     _removeOverlay();
  // }

  void _onTextChanged(String? str) {
    if (_debouncer == null) {
      // ZsLog.d("TDD——_onTextChanged,init $str");
      _debouncer = Debouncer<String>(
        Duration(milliseconds: 300),
        initialValue: str ?? '',
        onChanged: (value) {
          //  ZsLog.d("TDD——_onTextChanged: $_lastSearchString to  $value");
          if (_lastSearchString != value) {
            _lastSearchString = value;
            _search(_lastSearchString ?? "");
          }
        },
      );
    } else {
      _debouncer?.value = str ?? '';
    }

    // if (_debounce?.isActive ?? false) _debounce!.cancel();
    // _debounce = Timer(const Duration(milliseconds: 300), () {
    //   ZsLog.d("TDD——_onTextChanged: $_lastSearchString to  $str");
    //   if (_lastSearchString != str) {
    //     _lastSearchString = str;
    //     _search(str ?? "");
    //   }
    // });
  }

  Future<void> _search(String str) async {
    List<T> items = await widget.findFn(str) as List<T>;
    if (str != _lastSearchString) {
      return;
    }
    _updateDropDownTableLayout(items, str);
  }

  double _calCellHeight(T item) {
    double dvHeight = 0;
    USRType ty = USRType.row;
    if (widget.drawTypeFn != null) {
      ty = widget.drawTypeFn!(item);
    }
    double? uh;
    if (widget.drawHeightFn != null) {
      uh = widget.drawHeightFn!(item);
    }
    if (uh != null && uh >= 0) {
      //使用用户定义的高度
      dvHeight += uh;
    } else if (ty == USRType.section) {
      dvHeight += _sectionHeight;
    } else {
      dvHeight += _rowHeight;
    }
    return dvHeight;
  }

  void _updateDropDownTableLayout(List<T> items, String str) {
    double dvHeight = 0;
    const double baseH = 56; //32+16 + 8
    if (str.isNotEmpty) {
      items = items.where((item) {
        bool r = true;
        if (widget.filterFn != null) {
          r = widget.filterFn!(item, str);
        }
        if (r) {
          dvHeight += _calCellHeight(item);
        }
        return r;
      }).toList();
    }
    //_dropdownTotalHeight = dvHeight;
    if (dvHeight + baseH >= _dropdownMaxHeight) {
      dvHeight = _dropdownMaxHeight;
    } else if (dvHeight > 0) {
      dvHeight = dvHeight + baseH;
    }
    if (str != _lastSearchString) {
      return;
    }
    _options = items;
    //计算高度
    _listItemsValueNotifier.value = items;
    dropdownHeight = dvHeight;
    // ZsLog.d(
    //   "TDD——_search: $str,resoult count:${_options!.length}, height:$_dropdownHeight",
    // );
  }

  bool _onKeyPressed(KeyEvent event, AppState appState, ThemeProvider themeProvider) {
    bool r = false;
    // ZsLog.d('TDD——_onKeyPressed : ${event.toString()}');
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (_focusNode.hasFocus) {
        //  ZsLog.d('TDD——_onKeyPressed --_focusNode.hasFocus  }');
        if (_overlayEntry == null) {
          _addOverlay(appState, themeProvider);
          r = true;
        }
      } else {
        //_removeOverlay();
      }
      //_toggleOverlay();
    } else if (_overlayEntry != null) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        _removeOverlay();
        r = true;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        int v = _listItemFocusedPosition;
        v++;
        if (v >= _options!.length) v = 0;
        _listItemFocusedPosition = v;
        _listItemsValueNotifier.value = List<T>.from(_options ?? []);
        r = true;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        int v = _listItemFocusedPosition;
        v--;
        if (v < 0) v = _options!.length - 1;
        _listItemFocusedPosition = v;
        _listItemsValueNotifier.value = List<T>.from(_options ?? []);
        r = true;
      }
    }
    return r;
  }

  void _tapRowAction(AppState appState) {
    var item = _options![_listItemFocusedPosition];
    _selectedItem = item;
    _effectiveController!.value = _selectedItem;
    if (widget.onChanged != null) {
      String newUrl = widget.onChanged!(_selectedItem);
      if (newUrl.isNotEmpty) {
        //url 改变了，需要打开 currentTabOpenUrl(newUrl);
        if (newUrl != widget.textValue) {
          if (newUrl != _textEditingController.text) {
            _textEditingController.text = newUrl;
          }
        }
        widget.submit(_selectedItem, newUrl, true);
      }
    }
    _focusNode.nextFocus();
    _removeOverlay();
    setState(() {});
  }

  // _clearValue() {
  //   var item;
  //   _effectiveController!.value = item;
  //   if (widget.onChanged != null) {
  //     widget.onChanged!(_selectedItem);
  //   }
  //   _textEditingController.value = TextEditingValue(text: "");
  // }
}
