import 'package:flutter/material.dart';

typedef RadioCallbackItem = ({
  String desc,
  void Function(int? changedValue)? onCall,
});

class RadioOptionsAlertDialog extends StatefulWidget {
  const RadioOptionsAlertDialog({
    super.key,
    required this.title,
    required this.rows,
    required this.selecedIndex,
    required this.call,
  });
  final String title;
  final List<String> rows;
  final int selecedIndex;
  final RadioCallbackItem call;

  @override
  State<RadioOptionsAlertDialog> createState() =>
      _RadioOptionsAlertDialogState();
}

class _RadioOptionsAlertDialogState extends State<RadioOptionsAlertDialog>
    with AutomaticKeepAliveClientMixin {
  int groupSelected = 0;

  //切换页面，如何保持当前页的状态 with AutomaticKeepAliveClientMixin
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    groupSelected = widget.selecedIndex;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    List<Widget> chs = [];
    chs.add(Divider());

    for (var i = 0; i < widget.rows.length; i++) {
      String content = widget.rows[i];
      chs.add(
        RadioGroup(
          groupValue: groupSelected,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                groupSelected = value;
              });
            }
          },
          // child: SizedBox(
          //   height: 50,
          child: RadioListTile(
            titleAlignment: ListTileTitleAlignment.center,
            value: i,
            title: Text(content),
            selected: i == groupSelected,
          ),
        ),
        //),
      );
      chs.add(Divider());
    }
    chs.add(
      SimpleDialogOption(
        // padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
        child: Text('确认', textAlign: TextAlign.center),
        onPressed: () {
          Navigator.of(context).pop();
          int? nvalue;
          if (groupSelected != widget.selecedIndex) {
            nvalue = groupSelected;
            if (widget.call.onCall != null) {
              widget.call.onCall!(nvalue);
            }
          }

          // Future.delayed(Duration(milliseconds: 500), () {
          //   // 延迟执行的代码
          // });
        },
      ),
    );
    return SimpleDialog(
      title: Text(widget.title, textAlign: TextAlign.center),

      children: chs,
    );
  }
}
