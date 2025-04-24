import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

/// 自定义的悬浮按钮
class FloatingButton extends StatelessWidget {
  const FloatingButton({super.key, required this.children});

  final List<SpeedDialChild> children;

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      // 背景颜色相关
      overlayColor: Theme.of(context).scaffoldBackgroundColor,
      // 透明度
      overlayOpacity: 0.5,
      // 图标样式
      // icon: Icons.more_horiz,
      // activeIcon: Icons.more_vert,
      animatedIcon: AnimatedIcons.list_view,

      // 方向
      direction: SpeedDialDirection.up,
      // 展开菜单
      children: children,
      // 转向动画
      // animationAngle: pi / 2,
      useRotationAnimation: true,
    );
  }
}
