import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:koko/l10n/l10n.dart';

/// 两次确认弹窗图层模式
///
/// 系统的showDialog会全局刷新，导致某些动画丢失
///
/// 这个性能更好
class DoubleConfirmDialogOverlay {
  static OverlayEntry? _overlayEntry;

  /// 显示弹窗（基于Overlay实现）
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    Color? confirmColor,
    Color? cancelColor,
  }) async {
    final completer = Completer<bool?>();

    // 创建弹窗内容
    _overlayEntry = OverlayEntry(
      builder:
          (context) => _DialogLayer(
            title: title,
            message: message,
            confirmText:
                confirmText ?? AppLocalizations.of(context).confirmText,
            cancelText: AppLocalizations.of(context).cancleText,
            confirmColor: confirmColor,
            cancelColor: cancelColor,
            onResult: (result) {
              _dismiss();
              completer.complete(result);
            },
          ),
    );

    // 插入到全局Overlay
    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
    return completer.future;
  }

  /// 关闭弹窗
  static void _dismiss() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

/// 弹窗内容层（独立于路由层级）
class _DialogLayer extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Color? confirmColor;
  final Color? cancelColor;
  final ValueChanged<bool?> onResult;

  const _DialogLayer({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    required this.onResult,
    this.confirmColor,
    this.cancelColor,
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
            onTap: () => onResult(null), // 点击外部关闭
            child: Container(
              color: Colors.black38,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // 弹窗内容（居中显示）
          Center(child: _buildDialogContent(context)),
        ],
      ),
    ).animate().fade();
  }

  Widget _buildDialogContent(BuildContext context) {
    return Container(
      width: 270,
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
          // 标题与内容区
          Padding(
            padding: const EdgeInsets.only(
              top: 20,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            child: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),

          // 按钮区
          Divider(height: 1, color: Colors.grey[300]),
          IntrinsicHeight(
            child: Row(
              children: [
                // 取消按钮
                Expanded(
                  child: TextButton(
                    style: _buttonStyle(isCancel: true),
                    onPressed: () => onResult(false),
                    child: Text(
                      cancelText,
                      style: TextStyle(
                        color: cancelColor ?? Colors.blue,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),

                // 分隔线
                Container(width: 0.5, color: Colors.grey[300]),

                // 确认按钮
                Expanded(
                  child: TextButton(
                    style: _buttonStyle(),
                    onPressed: () => onResult(true),
                    child: Text(
                      confirmText,
                      style: TextStyle(
                        color: confirmColor ?? Colors.blue,
                        fontSize: 17,
                        fontWeight:
                            confirmColor == Colors.red ? null : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ButtonStyle _buttonStyle({bool isCancel = false}) {
    return TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius:
            isCancel
                ? const BorderRadius.only(bottomLeft: Radius.circular(14))
                : const BorderRadius.only(bottomRight: Radius.circular(14)),
      ),
    );
  }
}
