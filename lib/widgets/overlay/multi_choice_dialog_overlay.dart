import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:koko/l10n/l10n.dart';
import 'package:koko/models/entity/choice_option.dart';
import 'package:koko/widgets/ui_widgets/rounded_list_tile.dart';

/// 多选选弹窗图层模式
///
/// 系统的showDialog会全局刷新，导致某些动画丢失
///
/// 这个性能更好
class MultiChoiceDialogOverlay<T> {
  static OverlayEntry? _overlayEntry;

  /// 显示多选对话框（Overlay实现）
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required List<ChoiceOption<T>> options,
    Axis layoutMode = Axis.vertical,
  }) async {
    final completer = Completer<T?>();

    _overlayEntry = OverlayEntry(
      builder:
          (context) => _DialogLayer<T>(
            title: title,
            options: options,
            layoutMode: layoutMode,
            onResult: (result) {
              _dismiss();
              completer.complete(result);
            },
          ),
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
    return completer.future;
  }

  static void _dismiss() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

/// 弹窗内容层
class _DialogLayer<T> extends StatelessWidget {
  final String title;
  final List<ChoiceOption<T>> options;
  final Axis layoutMode;
  final ValueChanged<T?> onResult;

  const _DialogLayer({
    required this.title,
    required this.options,
    required this.layoutMode,
    required this.onResult,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // 半透明遮罩
          GestureDetector(
            onVerticalDragUpdate: (details) {
              if (details.delta.dy > 10) onResult(null);
            },
            onTap: () => onResult(null),
            child: Container(color: Colors.black38),
          ),

          // 对话框内容
          Center(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 500),
              margin: const EdgeInsets.symmetric(horizontal: 48),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(90, 0, 0, 0),
                    blurRadius: 14,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(context),
                  Divider(height: 1, color: Colors.grey[200]),
                  _buildOptionsList(context),
                  Divider(height: 1, color: Colors.grey[200]),
                  _buildCancelButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fade();
  }

  // 以下保留原有构建方法，仅修改事件处理逻辑
  Widget _buildHeader(BuildContext context) {
    return Flexible(
      flex: 100,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionsList(BuildContext context) {
    final flex = layoutMode == Axis.horizontal ? 46 : 100;

    return Flexible(
      flex: flex,
      child: ListView.separated(
        scrollDirection: layoutMode,
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemCount: options.length,
        separatorBuilder:
            (_, __) =>
                layoutMode == Axis.vertical
                    ? Divider(height: 1, color: Colors.grey[200])
                    : VerticalDivider(width: 1, color: Colors.grey[200]),
        itemBuilder: (context, index) => _buildChoiceItem(options[index]),
      ),
    );
  }

  Widget _buildChoiceItem(ChoiceOption<T> option) {
    return RoundedListTile(
      layoutMode: layoutMode,
      leading: Icon(
        option.icon,
        color: option.iconColor,
        size: layoutMode == Axis.horizontal ? 64 : null,
      ),
      title: Text(option.label),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      onTap: () => onResult(option.value), // 修改结果回调方式
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return Flexible(
      flex: 25,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: TextButton(
          child: Text(
            AppLocalizations.of(context).cancel,
            style: TextStyle(color: Colors.grey[600]),
          ),
          onPressed: () => onResult(null), // 统一使用结果回调
        ),
      ),
    );
  }
}
