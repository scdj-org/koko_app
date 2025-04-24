import 'dart:async';

import 'package:flutter/material.dart';

/// 双击确认按钮
class DoubleConfirmButton extends StatefulWidget {
  /// 图标
  final AnimatedIconData icon;

  /// 双击后调用函数
  final VoidCallback onCall;

  /// 动画持续时间
  final Duration animationDuration;

  /// 多久未持续恢复初始状态
  final Duration confirmTimeout;

  /// 正常情况下的颜色
  final Color normalColor;

  /// 展开状态下的颜色
  final Color confirmColor;

  /// 展开状态下展示文字
  final String confirmText;

  const DoubleConfirmButton({
    super.key,
    required this.icon,
    required this.onCall,
    required this.confirmText,
    this.animationDuration = const Duration(milliseconds: 300),
    this.confirmTimeout = const Duration(seconds: 1),
    this.normalColor = Colors.blue,
    this.confirmColor = Colors.red,
  });

  @override
  State<DoubleConfirmButton> createState() => _DoubleConfirmButtonState();
}

class _DoubleConfirmButtonState extends State<DoubleConfirmButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isConfirming = false;
  Timer? _resetTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedContainer(
        duration: widget.animationDuration,
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: _isConfirming ? widget.confirmColor : widget.normalColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedIcon(
              icon: widget.icon,
              progress: _controller,
              color: Colors.white,
              size: 24,
            ),
            AnimatedCrossFade(
              duration: widget.animationDuration,
              firstChild: Text(
                widget.confirmText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              secondChild: const SizedBox.shrink(),
              crossFadeState:
                  _isConfirming
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap() {
    if (_isConfirming) {
      _executeAction();
    } else {
      _startConfirmation();
    }
  }

  void _startConfirmation() {
    setState(() => _isConfirming = true);
    _controller.forward();
    _resetTimer?.cancel();
    _resetTimer = Timer(widget.confirmTimeout, _resetState);
  }

  void _executeAction() {
    _resetTimer?.cancel();
    _controller.reverse();
    widget.onCall();
    setState(() => _isConfirming = false);
  }

  void _resetState() {
    _controller.reverse();
    setState(() => _isConfirming = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    _resetTimer?.cancel();
    super.dispose();
  }
}
