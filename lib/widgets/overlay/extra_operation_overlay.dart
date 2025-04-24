import 'package:flutter/material.dart';
import 'package:koko/enums/toast_enum.dart';

class ExtraOperationOverlay extends StatefulWidget {
  final ToastPosition position;
  final Widget child;

  const ExtraOperationOverlay({
    super.key,
    this.position = ToastPosition.bottom,
    required this.child,
  });

  static GlobalKey<_StatusToastState>? _toastKey;
  static OverlayEntry? _overlayEntry;
  static bool _isVisible = false;
  static bool get isVisible => _isVisible;

  /// 显示 Toast
  static void show({
    required BuildContext context,
    required Widget child,
    ToastPosition position = ToastPosition.bottom,
  }) {
    if (_isVisible) return;
    final overlay = Overlay.of(context);
    var mediaQueryData = MediaQueryData.fromView(View.of(context));
    _toastKey = GlobalKey();
    _overlayEntry = OverlayEntry(
      builder:
          (context) => _buildPositionedToast(
            context,
            position: position,
            mediaQueryData: mediaQueryData,
            child: ExtraOperationOverlay(
              key: _toastKey,
              position: position,
              child: child,
            ),
          ),
    );

    _isVisible = true;
    overlay.insert(_overlayEntry!);
  }

  static Future<void> dismiss() async {
    if (!_isVisible) return;
    // 获取state对象并触发渐出动画
    final state = _toastKey?.currentState;
    if (state != null) {
      await state._fadeOut();
    }
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isVisible = false;
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
  State<ExtraOperationOverlay> createState() => _StatusToastState();
}

class _StatusToastState extends State<ExtraOperationOverlay>
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).scaffoldBackgroundColor.withOpacity(0.90),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                child: widget.child,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
