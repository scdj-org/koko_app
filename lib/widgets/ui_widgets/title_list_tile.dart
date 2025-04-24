import 'package:flutter/material.dart';
import 'package:koko/widgets/ui_widgets/rounded_list_tile.dart';

/// ListView的标题项，基于RoundedListTile
class TitleListTile extends StatelessWidget {
  /// 图标数据
  final IconData iconData;

  /// 标题
  final String title;

  final EdgeInsetsGeometry? padding;

  const TitleListTile({
    super.key,
    required this.iconData,
    required this.title,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return RoundedListTile(
      backgroundColor: Colors.transparent, // 透明背景
      onTap: null, //禁用点击事件
      shadow: [], // 去除阴影
      padding:
          padding ??
          const EdgeInsets.only(left: 14, right: 16, top: 4), // 减少顶部间距
      title: Transform.translate(
        offset: const Offset(0, 10),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w300,
            color: Colors.black,
            letterSpacing: 0.8,
          ),
        ),
      ),
      leading: Transform.translate(
        offset: const Offset(0, 10),
        child: Icon(iconData, color: Colors.black),
      ),
    );
  }
}
