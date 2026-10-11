import 'package:chiphell/theme/theme_provider.dart';
import 'package:chiphell/web/web_view_helper.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';

class WebViewFindBar extends StatefulWidget implements PreferredSizeWidget {
  final double height;
  final WebViewHelper webViewHelper;
  final void Function(String? searchText, int numberOfMatches, bool hide)?
  callFunc;
  const WebViewFindBar({
    super.key,
    required this.height,
    required this.webViewHelper,
    required this.callFunc,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  WebViewFindBarState createState() => WebViewFindBarState();
}

class WebViewFindBarState extends State<WebViewFindBar> {
  // "1/4"
  var textFound = "";
  var lastFindText = "";
  final searchController = TextEditingController();
  //FocusNode _focusNode = FocusNode();
  GlobalKey txKey = GlobalKey();
  GlobalKey txEditKey = GlobalKey();

  OutlineInputBorder outlineBorder = const OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent, width: 0.0),
    borderRadius: BorderRadius.all(Radius.circular(50.0)),
  );

  //使用防抖函数，防止查询过于频繁
  Debouncer? debouncer;

  void _debouncerUpdateRectString(String input) {
    if (debouncer == null) {
      debouncer = Debouncer<String>(
        Duration(milliseconds: 500),
        initialValue: input,
        onChanged: (value) {
          //去搜索
          lastFindText = value;
          findInteractionController?.findAll(find: value);
        },
      );
    } else {
      debouncer?.value = input;
    }
  }

  @override
  void initState() {
    super.initState();
    widget.webViewHelper.findResoultCall =
        (activeMatchOrdinal, numberOfMatches, isDoneCounting) {
          _updateFindResoult(
            activeMatchOrdinal,
            numberOfMatches,
            isDoneCounting,
          );
        };
  }

  FindInteractionController? get findInteractionController =>
      widget.webViewHelper.findController;

  void _updateFindResoult(
    int activeMatchOrdinal,
    int numberOfMatches,
    bool isDoneCounting,
  ) async {
    if (isDoneCounting) {
      if (mounted) {
        setState(() {
          textFound = numberOfMatches > 0
              ? '${activeMatchOrdinal + 1} of $numberOfMatches'
              : (lastFindText.isNotEmpty ? '0' : '');
        });
      }
      if (widget.callFunc != null) {
        widget.callFunc!(lastFindText, numberOfMatches, false);
      }
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(
      //       'No matches found for "${await findInteractionController.getSearchText()}"',
      //     ),
      //   ),
      // );
    }
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    if (widget.callFunc != null) {
      widget.callFunc!(null, 0, true);
    }
    // _focusNode.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, //x轴方向居中
      mainAxisAlignment: MainAxisAlignment.spaceBetween, //y轴方向排列 第一个顶上面，最后一个顶下面
      children: [bottomFindBar(context, themeProvider)],
    );
  }

  Widget bottomFindBar(BuildContext context, ThemeProvider themeProvider) {
    bool isDark = themeProvider.isDarkThreme();
    return AppBar(
      titleSpacing: 10.0,
      title: SizedBox(
        height: 40.0,
        child: TextField(
          autofocus: true,
          //  focusNode: _focusNode,
          onSubmitted: (value) {
            _debouncerUpdateRectString(value);
            // lastFindText = value;
            // findInteractionController.findAll(find: value);
          },
          controller: searchController,
          textInputAction: TextInputAction.go,
          keyboardAppearance: themeProvider.themeBrightness(),
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(10.0),
            filled: true,
            fillColor: isDark
                ? Color(0xFF303030)
                : Color.fromARGB(255, 224, 222, 222),
            border: outlineBorder,
            focusedBorder: outlineBorder,
            enabledBorder: outlineBorder,
            suffixText: textFound,
            hintText: "在页面上查找。。。。。。", //"Find on page ...",
            hintStyle: const TextStyle(color: Colors.grey),
          ),
          style: Theme.of(
            context,
          ).textTheme.titleSmall, //const TextStyle(color: Colors.black),
          onTap: () {
            // FocusScope.of(context).unfocus();
            //   _focusNode.requestFocus();
            // WidgetsBinding.instance.addPostFrameCallback((_) {
            //_focusNode.requestFocus();
            // });
          },
          // buildCounter:
          //     (
          //       context, {
          //       required currentLength,
          //       required isFocused,
          //       required maxLength,
          //     }) {
          //       // if (!isFocused) {
          //       //   Future.delayed(Duration(milliseconds: 400), () {
          //       //     if (_focusNode.hasFocus == false &&
          //       //         searchController.text != '') {
          //       //       searchController.text = '';
          //       //     }
          //       //   });
          //       // }
          //       return null;
          //     },
          onChanged: (value) {
            setState(() {
              if (textFound.isNotEmpty) {
                findInteractionController?.clearMatches();
              }
              textFound = "";
            });
            _debouncerUpdateRectString(value);
          },
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_up),
          onPressed: () {
            findInteractionController?.findNext(forward: false);
          },
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () {
            findInteractionController?.findNext(forward: true);
          },
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            findInteractionController?.clearMatches();
            searchController.text = "";
            lastFindText = '';
            //  _focusNode.nextFocus();
            if (widget.callFunc != null) {
              widget.callFunc!(null, 0, true);
            }
          },
        ),
      ],
    );

    // return
    // TextField(
    //   key: txKey,
    //   //focusNode: _focusNode,
    //   controller: searchController,
    //   textInputAction: TextInputAction.go,
    //   onTap: () {
    //     //FocusScope.of(context).unfocus();
    //     // _focusNode.requestFocus();
    //     // WidgetsBinding.instance.addPostFrameCallback((_) {
    //     //   _focusNode.requestFocus();
    //     // });
    //   },
    // );

    //   return AutoSizeTextField(
    //     key: txKey,
    //     textFieldKey: txEditKey,
    //     //autofocus: false,
    //     autocorrect: false,
    //     focusNode: _focusNode,
    //     minWidth: Utils.isDesktopSystem ? 600 : (Uiutils.devWidth(context) - 32),
    //     fullwidth: false,
    //     controller: searchController,
    //     keyboardType: TextInputType.text,
    //     keyboardAppearance: widget.keyboardAppearance,
    //     decoration: InputDecoration(
    //       prefixIcon: const Icon(Icons.search),
    //       suffixText: textFound,
    //       suffixIcon: Row(
    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //         mainAxisSize: MainAxisSize.min,
    //         children: <Widget>[
    //           const SizedBox(width: 10),
    //           IconButton(
    //             icon: const Icon(Icons.arrow_upward),
    //             onPressed: () {
    //               findInteractionController.findNext(forward: false);
    //             },
    //           ),
    //           IconButton(
    //             icon: const Icon(Icons.arrow_downward),
    //             onPressed: () {
    //               findInteractionController.findNext();
    //             },
    //           ),
    //         ],
    //       ),
    //       border: OutlineInputBorder(
    //         borderSide: BorderSide(
    //           width: 1.0,
    //           color: Colors.white70,
    //           style: BorderStyle.solid,
    //         ),
    //         borderRadius: BorderRadius.all(
    //           Radius.circular(Utils.isDesktopSystem ? 16 : 8),
    //         ),
    //       ),
    //     ),

    //     buildCounter:
    //         (
    //           context, {
    //           required currentLength,
    //           required isFocused,
    //           required maxLength,
    //         }) {
    //           if (!isFocused) {
    //             Future.delayed(Duration(milliseconds: 400), () {
    //               if (_focusNode.hasFocus == false &&
    //                   searchController.text != '') {
    //                 searchController.text = '';
    //               }
    //             });
    //           }
    //           return null;
    //         },
    //     onSubmitted: (value) {
    //       if (value == '') {
    //         findInteractionController.clearMatches();
    //         setState(() {
    //           textFound = '';
    //         });
    //       } else {
    //         findInteractionController.findAll(find: value);
    //       }
    //       _focusNode.nextFocus();
    //     },
    //     onTap: () {
    //       setState(() {
    //         _focusNode.requestFocus();
    //         //  FocusScope.of(context).requestFocus(_focusNode);
    //       });
    //     },
    //     onEditingComplete: () {},
    //     onChanged: (value) {},
    //     onTapOutside: (event) {
    //       _focusNode.nextFocus();
    //     },
    //   );
  }
}
