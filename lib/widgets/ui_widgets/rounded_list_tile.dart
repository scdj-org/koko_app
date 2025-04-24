import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:koko/common/global.dart';

/// 卡片形的ListTile，用于构造列表项
///
/// 仅竖向排布的listTile可以有抽屉菜单
class RoundedListTile extends StatelessWidget {
  /// 左侧图标/图片
  final Widget? leading;

  /// 主标题
  final Widget title;

  /// 副标题
  final Widget? subtitle;

  /// 右侧控件
  final Widget? trailing;

  /// 背景色
  final Color? backgroundColor;

  /// 圆角半径
  final double borderRadius;

  /// 阴影配置
  final List<BoxShadow> shadow;

  /// 内边距
  final EdgeInsetsGeometry padding;

  /// 点击回调
  final VoidCallback? onTap;

  /// 长按回调
  final VoidCallback? onLongPress;

  /// 布局模式参数
  final Axis layoutMode;

  /// 后ActionPane
  final ActionPane? endActionPane;

  /// 前ActionPane
  final ActionPane? startActionPane;

  /// 是否需要防抖
  final bool needDebounce;

  /// 防抖时间
  final Duration debounceDuration;

  const RoundedListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.backgroundColor,
    this.borderRadius = 14.0,
    this.needDebounce = false,
    this.debounceDuration = const Duration(milliseconds: 200),
    this.shadow = const [
      BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 4)),
    ],
    this.padding = const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    this.onTap,
    this.onLongPress,
    this.layoutMode = Axis.vertical,
    this.endActionPane,
    this.startActionPane,
  });

  @override
  Widget build(BuildContext context) {
    // 背景色加深
    Color? color;
    color = backgroundColor;
    if (color == null) {
      HSLColor hsl = HSLColor.fromColor(
        Theme.of(context).scaffoldBackgroundColor,
      );
      color =
          hsl.withLightness((hsl.lightness - 0.05).clamp(0.8, 0.9)).toColor();
    }

    return Padding(
      padding: padding,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: shadow,
          ),
          child: Material(
            type: MaterialType.transparency, // 保持点击涟漪效果
            child: InkWell(
              splashFactory: InkRipple.splashFactory,
              borderRadius: BorderRadius.circular(borderRadius),
              onTap:
                  onTap == null
                      ? null
                      : () {
                        if (needDebounce) {
                          Global.instance.debouncer.debounce(
                            duration: debounceDuration,
                            onDebounce: () {
                              onTap!();
                            },
                          );
                        } else {
                          onTap!();
                        }
                      },
              onLongPress: onLongPress,
              child: _buildContent(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return layoutMode == Axis.horizontal
        ? _buildHorizontalLayout(context)
        : _buildVerticalLayout(context);
  }

  Widget _buildVerticalLayout(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Slidable(
        key: UniqueKey(),
        startActionPane: startActionPane,
        endActionPane: endActionPane,
        child: ListTile(
          leading: leading,
          title: title,
          subtitle: subtitle,
          trailing: trailing,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 图标区域
          if (leading != null) Center(child: leading),

          // 文字内容区域
          DefaultTextStyle(
            style: Theme.of(context).textTheme.titleMedium!,
            child: title,
          ),

          if (subtitle != null) ...[
            const SizedBox(height: 4),
            DefaultTextStyle(
              style: Theme.of(context).textTheme.bodySmall!,
              child: subtitle!,
            ),
          ],

          // 右侧控件
          if (trailing != null)
            Padding(padding: const EdgeInsets.only(left: 8), child: trailing),
        ],
      ),
    );
  }
}
