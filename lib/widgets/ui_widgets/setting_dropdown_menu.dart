import 'package:flutter/material.dart';
import 'package:koko/interface/menu_label_interface.dart';
import 'package:koko/widgets/overlay/dropdown_button_overlay.dart';

/// 自定义的通用设置菜单
class SettingDropdownMenu<T extends MenuLabelInterface>
    extends StatelessWidget {
  const SettingDropdownMenu({
    super.key,
    required this.dropDownItems,
    required this.onSelected,
    required this.initSelection,
    this.style,
    this.width = 75,
    this.needIcon = true,
    this.needLabel = true,
  });

  /// 菜单项列表
  final List<T> dropDownItems;

  /// 选中后的回调函数
  final void Function(T?) onSelected;

  /// 输入框修饰
  final TextStyle? style;

  /// 最初选择对象
  final T initSelection;

  /// 菜单宽度
  final double width;

  /// 是否启用icon
  final bool needIcon;

  /// 是否启用label
  final bool needLabel;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonOverlay(
      style: style,
      width: width,
      underline: Container(
        height: 2,
        color: Theme.of(context).colorScheme.primary,
      ),
      onChanged: onSelected,
      items: _buildDropdownMenuEntries(context),
      value: initSelection,
      borderRadius: BorderRadius.circular(14.0),
    );
  }

  List<DropdownMenuItem<T>> _buildDropdownMenuEntries(BuildContext context) {
    return dropDownItems.map((item) {
      return DropdownMenuItem(
        value: item,
        // 有图标则左侧加图标
        child: SizedBox(
          width: width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 左侧图标或占位
              if (needIcon && item.getIcon(context) != null)
                item.getIcon(context)!
              else
                const SizedBox.shrink(),
              // 右侧文字
              if (needLabel)
                Flexible(
                  child: Text(
                    item.getLabel(context),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: item.getStyle(context),
                  ),
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        ),
      );
    }).toList();
  }
}
