import 'package:flutter/material.dart';
import 'package:koko/l10n/l10n.dart';

class ButtomSettingOverlay {
  static OverlayEntry? _overlayEntry;

  /// child不为null的时候将忽略tiles、sperated参数
  static void show({
    required BuildContext context,
    required List<Widget> tiles,
    Widget? child,
    Widget? title,
    Widget? sperated,
    double? panelHeight,
  }) {
    final overlay = Overlay.of(context);
    final mediaQuery = MediaQueryData.fromView(View.of(context));

    _overlayEntry = OverlayEntry(
      builder:
          (context) => _BottomPanel(
            title: title,
            tiles: tiles,
            sperated: sperated,
            panelHeight: panelHeight ?? mediaQuery.size.height / 2,
            onDismiss: () => _dismiss(),
            screenHeight: mediaQuery.size.height,
            child: child,
          ),
    );

    overlay.insert(_overlayEntry!);
  }

  static void _dismiss() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class _BottomPanel extends StatefulWidget {
  final Widget? title;
  final List<Widget> tiles;
  final double panelHeight;
  final VoidCallback onDismiss;
  final double screenHeight;
  final Widget? sperated;
  final Widget? child;

  const _BottomPanel({
    this.title,
    required this.tiles,
    this.sperated,
    this.child,
    required this.panelHeight,
    required this.onDismiss,
    required this.screenHeight,
  });

  @override
  State<_BottomPanel> createState() => _BottomPanelState();
}

class _BottomPanelState extends State<_BottomPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _slideAnimation;

  late ValueNotifier<double> _dragDistanceNotifier;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0, // 初始透明度为 0
      end: 1.0, // 结束透明度为 1
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _slideAnimation = Tween<double>(
      begin: widget.panelHeight,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        widget.onDismiss();
      }
    });

    _dragDistanceNotifier = ValueNotifier<double>(0.0);

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _controller.reverse,
      child: AnimatedBuilder(
        animation: _opacityAnimation,
        child: AnimatedBuilder(
          animation: _slideAnimation,
          child: GestureDetector(
            // 防误触
            onTap: () {},
            child: ValueListenableBuilder(
              valueListenable: _dragDistanceNotifier,
              child: _buildContainer(),
              builder: (context, dragDistance, child) {
                return Padding(
                  padding: EdgeInsets.only(
                    top:
                        widget.screenHeight - widget.panelHeight + dragDistance,
                  ),
                  child: child,
                );
              },
            ),
          ),
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: child,
            );
          },
        ),
        builder: (context, child) {
          return Material(
            color: Colors.black54.withOpacity(0.4 * _opacityAnimation.value),
            child: child,
          );
        },
      ),
    );
  }

  Widget _buildContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 顶部拖拽指示条
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanUpdate: (details) {
              var offset =
                  widget.screenHeight -
                  widget.panelHeight +
                  _dragDistanceNotifier.value +
                  details.delta.dy;
              // 最长到屏幕1/8
              if (offset > widget.screenHeight / 8) {
                _dragDistanceNotifier.value += details.delta.dy;
              }
            },
            onPanEnd: (details) {
              var offset =
                  widget.screenHeight -
                  widget.panelHeight +
                  _dragDistanceNotifier.value;
              // 小于2/5退出
              if (offset > 3 * widget.screenHeight / 5) {
                _controller.reverse();
              }
            },
            child: SizedBox(
              height: 28,
              child: Container(
                width: 60,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // 标题
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
            child: Row(
              children: [
                widget.title ??
                    Text(
                      AppLocalizations.of(context).settingDesc,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _controller.reverse,
                ),
              ],
            ),
          ),

          // 内容区域
          Expanded(
            child:
                widget.child ??
                (widget.sperated != null
                    ? ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) => widget.tiles[index],
                      separatorBuilder: (context, index) => widget.sperated!,
                      itemCount: widget.tiles.length,
                    )
                    : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: widget.tiles,
                    )),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _dragDistanceNotifier.dispose();
    super.dispose();
  }
}
