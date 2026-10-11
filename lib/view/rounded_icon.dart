import 'package:flutter/material.dart';

class RoundedIcon extends StatelessWidget {
  final IconData icon;
  final double borderRadius; // 圆角大小
  final Color color; // 图标背景色
  final double size;
  final double padding;
  const RoundedIcon({super.key, required this.icon, this.borderRadius = 10.0, this.color = Colors.blue, this.size = 32, this.padding = 10});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius), // 设置圆角大小
      child: Container(
        padding: EdgeInsets.all(padding), // 给图标留出一些空间，避免紧贴圆角边缘
        color: color, // 设置背景色
        child: Icon(icon, size: size, color: Colors.white), // 显示图标，并设置颜色和大小
      ),
    );
  }
}
