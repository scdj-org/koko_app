import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 阅读器设置页面overlay实现，可以扩展多个阅读器的通用组件
class ReaderSettingsOverlay {
  static OverlayEntry? _overlayEntry;
  // 防止多次打开
  static bool _isVisible = false;

  static GlobalKey<_SettingsLayerState>? _globalKey;

  static bool get isVisible => _isVisible;

  /// 显示阅读设置界面
  static void show({
    required BuildContext context,
    required VoidCallback onBack,
    String? title,
    Widget? rightButton,
    required int totalPages,
    required ValueNotifier<int> currentPageNotify,
    required ValueChanged<int> onPageChanged,
    Widget? bottomLeftButton,
    Widget? bottomRightButton,
  }) {
    if (_isVisible) return;
    final overlay = Overlay.of(context);
    // final mediaQuery = MediaQuery.of(context);
    _globalKey = GlobalKey();
    _overlayEntry = OverlayEntry(
      builder:
          (context) => _SettingsLayer(
            key: _globalKey,
            onBack: onBack,
            title: title,
            rightButton: rightButton,
            totalPages: totalPages,
            currentPageNotify: currentPageNotify,
            onPageChanged: onPageChanged,
            bottomLeftButton: bottomLeftButton,
            bottomRightButton: bottomRightButton,
            onDismiss: () => _dismiss(),
          ),
    );

    _isVisible = true;
    overlay.insert(_overlayEntry!);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  static void _dismiss() {
    if (_isVisible) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isVisible = false;
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  static bool doDismiss = false;

  /// 给外部调用的dismiss
  ///
  /// 在dispose中调用
  static void dismiss() {
    if (_isVisible) {
      doDismiss = true;
      if (_globalKey != null && _globalKey!.currentState != null) {
        _globalKey!.currentState!._controller.reverse().then((v) {
          _overlayEntry?.remove();
          _overlayEntry = null;
          _isVisible = false;
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
          doDismiss = false;
        });
      } else {
        _overlayEntry?.remove();
        _overlayEntry = null;
        _isVisible = false;
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        doDismiss = false;
      }
    } else {
      doDismiss = false;
    }
  }
}

class _SettingsLayer extends StatefulWidget {
  final VoidCallback onBack;
  final String? title;
  final Widget? rightButton;
  final int totalPages;
  final ValueNotifier<int> currentPageNotify;
  final ValueChanged<int> onPageChanged;
  final Widget? bottomLeftButton;
  final Widget? bottomRightButton;
  final VoidCallback onDismiss;

  const _SettingsLayer({
    super.key,
    required this.onBack,
    required this.title,
    required this.rightButton,
    required this.totalPages,
    required this.currentPageNotify,
    required this.onPageChanged,
    required this.bottomLeftButton,
    required this.bottomRightButton,
    required this.onDismiss,
  });

  @override
  State<_SettingsLayer> createState() => _SettingsLayerState();
}

class _SettingsLayerState extends State<_SettingsLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // late Animation<double> _topBarAnimation;
  // late Animation<double> _bottomBarAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        widget.onDismiss();
      }
    });
  }

  // 顶部bar和底部bar的高度
  double _topbarHeigth = 0;
  double _bottombarHeight = 0;
  double _screenWidth = 0;

  // 修正值，修正坐标的，让ui看上去更自然，而不会跳出的时候空一截
  double compensation = 10;

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQueryData.fromView(View.of(context));
    _topbarHeigth = mediaQueryData.padding.top + kToolbarHeight + compensation;
    // 适配安卓，不足24补偿到24
    var navigationBarHeight = mediaQueryData.viewPadding.bottom;
    if (navigationBarHeight < 24) navigationBarHeight = 24;
    _bottombarHeight = navigationBarHeight + 96 + compensation;
    _screenWidth = mediaQueryData.size.width;

    var topBarAnimation = Tween<double>(
      begin: -_topbarHeigth,
      end: -compensation,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    var bottomBarAnimation = Tween<double>(
      begin: -_bottombarHeight,
      end: -compensation,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (!ReaderSettingsOverlay.doDismiss) {
          _controller.reverse();
        }
      },
      child: Stack(
        children: [
          // 顶部设置栏
          AnimatedBuilder(
            animation: topBarAnimation,
            child: GestureDetector(
              //防误触
              onTap: () {},
              child: _buildTopBar(),
            ),
            builder: (context, child) {
              return Positioned(
                top: topBarAnimation.value,
                left: 0,
                right: 0,
                child: child!,
              );
            },
          ),

          // 底部控制栏
          AnimatedBuilder(
            animation: bottomBarAnimation,
            child: GestureDetector(
              // 防误触
              onTap: () {},
              child: _buildBottomBar(),
            ),
            builder: (context, child) {
              return Positioned(
                bottom: bottomBarAnimation.value,
                left: 0,
                right: 0,
                child: child!,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      alignment: Alignment.bottomCenter,
      height: _topbarHeigth,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(40, 0, 0, 0),
            blurRadius: 14,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 24),
            onPressed: () {
              if (!ReaderSettingsOverlay.doDismiss) {
                ReaderSettingsOverlay.doDismiss = true;
                widget.onBack();
              }
            },
          ),
          Expanded(child: SizedBox()),
          widget.title != null
              ? Container(
                height: 48,
                width: _screenWidth - 120,
                alignment: Alignment.bottomCenter,
                child: Center(
                  child: Text(
                    widget.title!,
                    overflow: TextOverflow.ellipsis,
                    // 防止上层污染Text渲染
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              )
              : const SizedBox(),
          Expanded(child: SizedBox()),
          widget.rightButton ?? const SizedBox(width: 48, height: 48),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      alignment: Alignment.topCenter,
      height: _bottombarHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(40, 0, 0, 0),
            blurRadius: 14,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: ValueListenableBuilder(
                valueListenable: widget.currentPageNotify,
                builder: (context, index, _) {
                  return Slider(
                    min: 0,
                    max: widget.totalPages.toDouble(),
                    value: index.toDouble(),
                    onChanged:
                        (value) =>
                            widget.currentPageNotify.value = value.toInt(),
                    onChangeEnd: (value) => widget.onPageChanged(value.toInt()),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // widget.bottomLeftButton ?? const SizedBox(),
                SizedBox(height: 48, width: 48, child: widget.bottomLeftButton),
                ValueListenableBuilder(
                  valueListenable: widget.currentPageNotify,
                  builder: (context, index, _) {
                    return Text(
                      '$index/${widget.totalPages}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    );
                  },
                ),
                SizedBox(
                  height: 48,
                  width: 48,
                  child: widget.bottomRightButton,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
