import 'package:flutter/material.dart';
import 'package:koko/enums/toast_enum.dart';

class StatusToast extends StatefulWidget {
  final String message;
  final bool isSuccess;
  final int durationSeconds;
  final ToastPosition position;

  const StatusToast({
    super.key,
    required this.message,
    required this.isSuccess,
    this.durationSeconds = 2,
    this.position = ToastPosition.center,
  });

  /// 显示 Toast
  static void show({
    required BuildContext context,
    required String message,
    required bool isSuccess,
    int durationSeconds = 2,
    ToastPosition position = ToastPosition.bottom,
  }) {
    final overlay = Overlay.of(context);
    var mediaQueryData = MediaQueryData.fromView(View.of(context));

    final GlobalKey<_StatusToastState> toastKey =
        GlobalKey<_StatusToastState>();

    final overlayEntry = OverlayEntry(
      builder:
          (context) => _buildPositionedToast(
            context,
            position: position,
            mediaQueryData: mediaQueryData,
            child: StatusToast(
              key: toastKey,
              message: message,
              isSuccess: isSuccess,
              durationSeconds: durationSeconds,
              position: position,
            ),
          ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(Duration(seconds: durationSeconds), () async {
      // 获取state对象并触发渐出动画
      final state = toastKey.currentState;
      if (state != null) {
        await state._fadeOut();
      }
      overlayEntry.remove();
    });
  }

  /// 根据位置构建定位组件
  static Widget _buildPositionedToast(
    BuildContext context, {
    required ToastPosition position,
    required MediaQueryData mediaQueryData,
    required Widget child,
  }) {
    switch (position) {
      case ToastPosition.top:
        return Positioned(
          top: mediaQueryData.viewPadding.top + 80,
          left: 0,
          right: 0,
          child: child,
        );
      case ToastPosition.center:
        return Center(child: child);
      case ToastPosition.bottom:
        return Positioned(
          bottom: mediaQueryData.viewInsets.bottom + 120,
          left: 0,
          right: 0,
          child: child,
        );
    }
  }

  @override
  State<StatusToast> createState() => _StatusToastState();
}

class _StatusToastState extends State<StatusToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );

    final offset = _getPositionOffset();
    _offsetAnimation = Tween<Offset>(
      begin: offset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  Offset _getPositionOffset() {
    switch (widget.position) {
      case ToastPosition.top:
        return const Offset(0, -1);
      case ToastPosition.center:
        return Offset.zero;
      case ToastPosition.bottom:
        return const Offset(0, 1);
    }
  }

  Future<void> _fadeOut() async {
    await _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: _getBackgroundColor(context),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.isSuccess ? Icons.check_circle : Icons.error,
                  color: _getIconColor(context),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    widget.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _getTextColor(context),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    return widget.isSuccess
        ? Colors.green.shade100
        : Theme.of(context).colorScheme.errorContainer;
  }

  Color _getIconColor(BuildContext context) {
    return widget.isSuccess
        ? Colors.green.shade800
        : Theme.of(context).colorScheme.error;
  }

  Color _getTextColor(BuildContext context) {
    return widget.isSuccess
        ? Colors.green.shade900
        : Theme.of(context).colorScheme.onErrorContainer;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
