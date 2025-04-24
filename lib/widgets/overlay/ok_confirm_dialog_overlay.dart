import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 信息提示框
class OkAlertDialogOverlay {
  static OverlayEntry? _overlayEntry;

  /// 显示提示框
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    String okText = '确定',
    Color? okColor,
  }) async {
    final completer = Completer<void>();

    _overlayEntry = OverlayEntry(
      builder:
          (context) => _DialogLayer(
            title: title,
            message: message,
            okText: okText,
            okColor: okColor,
            onDismiss: () {
              _dismiss();
              completer.complete();
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

class _DialogLayer extends StatelessWidget {
  final String title;
  final String message;
  final String okText;
  final Color? okColor;
  final VoidCallback onDismiss;

  const _DialogLayer({
    required this.title,
    required this.message,
    required this.okText,
    required this.onDismiss,
    this.okColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // 半透明遮罩
          GestureDetector(
            onTap: () {
              onDismiss();
            },
            child: Container(
              color: Colors.black38,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // 弹窗内容
          Center(
            child: Container(
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
                  // 标题与内容
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                    child: Column(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 按钮区域
                  const Divider(height: 1, color: Color(0xFFD1D1D6)),
                  TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(14),
                          bottomRight: Radius.circular(14),
                        ),
                      ),
                    ),
                    onPressed: onDismiss,
                    child: Text(
                      okText,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: okColor ?? const Color(0xFF007AFF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fade();
  }
}
