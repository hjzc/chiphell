import 'package:flutter/material.dart';

typedef OVICallback = void Function(BuildContext ctx);

class OverlayWebImageGallery extends StatelessWidget {
  const OverlayWebImageGallery({super.key, required this.title, required this.callback});
  final String title;
  final OVICallback callback;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(height: 60, alignment: AlignmentGeometry.center, child: _menuBuild(context)),
          Container(
            height: 60,
            alignment: AlignmentGeometry.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [_textBuild(context)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _textBuild(BuildContext context) {
    return _circelContainerAutoSizeBuild(
      context,
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, decoration: TextDecoration.none, fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _menuBuild(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            SizedBox(width: 16),
            _circelContainerBuild(
              IconButton(
                icon: const Icon(Icons.save_alt),
                color: Colors.white,
                tooltip: '保存',
                onPressed: () {
                  callback(context);
                },
              ),
            ),
          ],
        ),
        Row(
          children: [
            _circelContainerBuild(
              IconButton(
                icon: const Icon(Icons.close),
                color: Colors.white,
                tooltip: '关闭',
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            SizedBox(width: 16),
          ],
        ),
      ],
    );
  }

  Widget _circelContainerBuild(Widget child, {double size = 40}) {
    return Container(
      width: size,
      height: size,
      alignment: AlignmentGeometry.center,
      decoration: BoxDecoration(
        color: const Color.fromARGB(90, 164, 164, 164), // 设置背景色
        borderRadius: BorderRadius.circular(size / 2), // 可选：设置圆角
        border: Border.all(
          color: const Color.fromARGB(120, 70, 70, 70), // 边框颜色
          width: 1.0, // 边框宽度
        ),
      ),
      child: child,
    );
  }

  Widget _circelContainerAutoSizeBuild(BuildContext context, {double radius = 10, Widget? child}) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
      decoration: BoxDecoration(
        color: const Color.fromARGB(90, 164, 164, 164),
        border: Border.all(
          color: const Color.fromARGB(120, 70, 70, 70), // 边框颜色
          width: 1.0, // 边框宽度
        ),
        borderRadius: BorderRadius.circular(radius), // 可选：设置圆角
      ),
      child: child,
    );
  }
}
