import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 输入窗图层模式
///
/// 系统的showDialog会全局刷新，导致某些动画丢失
///
/// 这个性能更好
class MultiLineInputDialogOverlay {
  static final TextEditingController controller = TextEditingController();
  // static late final FocusNode _focusNode;

  static Future<void> globalInit() async {
    // controller = TextEditingController();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   FocusScope.of(context).requestFocus(_focusNode);
    // });
  }

  static OverlayEntry? _overlayEntry;

  /// 显示输入对话框（Overlay实现）
  static Future<String?> show({
    required BuildContext context,
    String title = "输入内容",
    String confirmText = "确认",
    String cancelText = "取消",
    String hintText = "请输入...",
    int maxLines = 3,
  }) async {
    final completer = Completer<String?>();

    _overlayEntry = OverlayEntry(
      builder:
          (context) => _DialogLayer(
            title: title,
            confirmText: confirmText,
            cancelText: cancelText,
            hintText: hintText,
            maxLines: maxLines,
            onResult: (result) {
              _dismiss();
              completer.complete(result);
            },
          ),
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
    return completer.future;
  }

  /// 关闭对话框
  static void _dismiss() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

/// 输入对话框内容层
class _DialogLayer extends StatefulWidget {
  final String title;
  final String confirmText;
  final String cancelText;
  final String hintText;
  final int maxLines;
  final ValueChanged<String?> onResult;

  const _DialogLayer({
    required this.title,
    required this.confirmText,
    required this.cancelText,
    required this.hintText,
    required this.maxLines,
    required this.onResult,
  });

  @override
  State<_DialogLayer> createState() => _DialogLayerState();
}

class _DialogLayerState extends State<_DialogLayer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // _controller.dispose();
    // _focusNode.dispose();
    MultiLineInputDialogOverlay.controller.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // 半透明遮罩
          GestureDetector(
            onVerticalDragUpdate: (details) {
              if (details.delta.dy > 10) widget.onResult(null);
            },
            onTap: () => widget.onResult(null),
            child: Container(color: Colors.black38),
          ),

          // 对话框内容
          Center(
            child: Container(
              constraints: const BoxConstraints(minWidth: 200, maxWidth: 300),
              margin: const EdgeInsets.symmetric(horizontal: 60),
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
                  // 标题
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 5),
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  // 输入区域
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      child: TextField(
                        controller: MultiLineInputDialogOverlay.controller,
                        // focusNode: _focusNode,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 10,
                          ),
                          hintText: widget.hintText,
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(width: 0.1),
                            borderRadius: BorderRadius.all(Radius.circular(14)),
                          ),
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),

                  // 按钮区域
                  _buildButtonRow(context),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fade();
  }

  Widget _buildButtonRow(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFD1D1D6), width: 0.5)),
      ),
      child: Row(
        children: [
          // 取消按钮
          Expanded(
            child: TextButton(
              style: _buttonStyle(isCancel: true),
              onPressed: () => widget.onResult(null),
              child: Text(
                widget.cancelText,
                style: const TextStyle(fontSize: 17, color: Color(0xFF007AFF)),
              ),
            ),
          ),

          // 分隔线
          Container(width: 0.5, height: 36, color: const Color(0xFFD1D1D6)),

          // 确认按钮
          Expanded(
            child: TextButton(
              style: _buttonStyle(),
              onPressed:
                  () => widget.onResult(
                    MultiLineInputDialogOverlay.controller.text,
                  ),
              child: Text(
                widget.confirmText,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF007AFF),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ButtonStyle _buttonStyle({bool isCancel = false}) {
    return TextButton.styleFrom(
      padding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius:
            isCancel
                ? const BorderRadius.only(bottomLeft: Radius.circular(14))
                : const BorderRadius.only(bottomRight: Radius.circular(14)),
      ),
    );
  }
}
