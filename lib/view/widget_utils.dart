import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:chiphell/common/constants.dart';
import 'package:chiphell/utils/ui_utils.dart';
import 'package:chiphell/utils/utils.dart';
import 'package:flutter/material.dart';

import '../web/web_constants.dart';

class WidgetUtils {
  static FilledButton fbCancel({required void Function()? onPressed}) {
    return FilledButton(onPressed: onPressed, child: const Text(Constants.kTipCancel));
  }

  static ElevatedButton ebOk({required void Function()? onPressed}) {
    return ElevatedButton(onPressed: onPressed, child: const Text(Constants.kTipOk));
  }

  // late TextEditingController _textEditingController;
  // String lastTextEditingValue = '';
  // final FocusNode _focusNode = FocusNode();
  // GlobalKey txKey = GlobalKey();
  // GlobalKey txEditKey = GlobalKey();

  Widget centerInputTitleWidget(
    BuildContext context, {
    required TextEditingController controller,
    required GlobalKey txKey,
    required GlobalKey txEditKey,
    required FocusNode focusNode,
    String hint = WebConstants.kWebUrlAddressInputHint,
    required String Function() titleFn,
    required String Function() urlFn,
    required Icon currentSecureIcon,
    void Function()? secureActionFn,
    void Function()? suffixActionFn,
    required String Function() lastTextEditingValue,
    required void Function(String val) setLastTextEditingValue,
    bool isDark = false,
    int searchEngin = 0,
    required void Function(String newUrl) onSubmitted,
    void Function()? updateUIFn,
    // AppState appState,
    // ThemeProvider themeProvider,
  }) {
    //final hint = WebConstants.kWebUrlAddressInputHint;
    // '搜索或输入网站名称';
    String title = titleFn();
    String url = urlFn();
    return Padding(
      padding: const EdgeInsets.only(left: 0, top: 8, right: 0, bottom: 8),
      // padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: AutoSizeTextField(
        key: txKey,
        textFieldKey: txEditKey,
        controller: controller,
        focusNode: focusNode,
        minLines: 1,
        minFontSize: Utils.isDesktopSystem ? 12 : 6,
        maxFontSize: Utils.isDesktopSystem ? 14 : 10,
        wrapWords: false,
        autocorrect: false,
        autofocus: true,
        enableSuggestions: false,
        //stepGranularity:2, 每次字体缩小步进
        //obscureText: true,
        minWidth: Utils.isDesktopSystem ? 600 : (Uiutils.devWidth(context) - 32),
        fullwidth: false,
        style: Theme.of(context).textTheme.titleSmall,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        keyboardType: TextInputType.url,
        keyboardAppearance: isDark ? Brightness.dark : Brightness.light,
        decoration: InputDecoration(
          hintMaxLines: 1,
          hintText: (focusNode.hasFocus && lastTextEditingValue().isEmpty)
              ? hint
              : (title.length > 1 ? title : (url.isNotEmpty ? url : hint)),
          hintStyle: TextStyle(
            color: Colors.grey,
            textBaseline: TextBaseline.alphabetic, //用于对齐字母字符字形底部的水平线
          ),
          prefixIcon: IconButton(
            onPressed: () {
              if (secureActionFn != null) {
                secureActionFn();
              }
              //showUrlInfo(themeProvider);
            },
            icon: currentSecureIcon,
          ),
          suffixIcon: IconButton(
            //iconSize: 12,
            onPressed: () {
              if (suffixActionFn != null) {
                suffixActionFn();
              }
              //webViewTabs[currentTabIndex].reload();
            },
            icon: Icon(Icons.refresh, color: isDark ? Colors.white70 : Colors.grey),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(width: 1.0, color: Colors.white70, style: BorderStyle.solid),
            borderRadius: BorderRadius.all(Radius.circular(Utils.isDesktopSystem ? 24 : 16)),
          ),
        ),
        buildCounter: (context, {required currentLength, required isFocused, required maxLength}) {
          // ZsLog.i(
          //   'tab title currentLength:$currentLength, maxLenght:$maxLength,isFocused:$isFocused',
          // );
          if (!isFocused) {
            Future.delayed(Duration(milliseconds: 400), () {
              if (focusNode.hasFocus == false && controller.text != '') {
                controller.text = '';
              }
            });
          }
          return null;
        },
        onChanged: (value) {
          setLastTextEditingValue(value.trim());
        },
        onEditingComplete: () {
          if (controller.text != '') {
            if (lastTextEditingValue().isNotEmpty) {
              controller.text = '';
            }
            // else { 避免没有输入，没有修改原来的值}
          }
        },
        onSubmitted: (String value) {
          //回车时候
          var text = lastTextEditingValue();
          if (text.isEmpty) {
            text = value.trim();
            text = text.isNotEmpty ? text : controller.text.trim();
          }
          if (text.isNotEmpty) {
            String newUrl = Utils.textToUrlOrSearch(text, search: searchEngin);
            if (newUrl != controller.text) {
              controller.text = newUrl;
            }
            focusNode.nextFocus();
            if (newUrl != url) {
              //url 改变了，需要打开
              onSubmitted(newUrl);
              //currentTabOpenUrl(newUrl);
            }
          }
        },
        onTap: () {
          controller.text = urlFn();
          // setState(() {
          FocusScope.of(context).requestFocus(focusNode);
          // });
          controller.selection = TextSelection(baseOffset: 0, extentOffset: controller.text.length);
          if (updateUIFn != null) {
            updateUIFn();
          }
        },
        onTapOutside: (PointerDownEvent ev) {
          controller.text = '';
          focusNode.nextFocus();
          //刷新hint 内容
          if (updateUIFn != null) {
            updateUIFn();
          }
          //setState(() {});
        },
      ),
    );
  }
}
