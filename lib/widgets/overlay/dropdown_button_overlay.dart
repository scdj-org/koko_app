import 'package:flutter/material.dart';
import 'package:koko/interface/menu_label_interface.dart';

/// overlay形式的dropdown button
///
/// 这里外界需要注意优化性能，主要是多次rebuild的问题，但是影响不是特别大
class DropdownButtonOverlay<T extends MenuLabelInterface>
    extends StatefulWidget {
  const DropdownButtonOverlay({
    super.key,
    required this.items,
    required this.width,
    required this.onChanged,
    this.underline,
    required this.value,
    this.hint,
    this.disabledHint,
    this.icon,
    this.style,
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
    this.height = kMinInteractiveDimension,
  });

  final List<DropdownMenuItem<T>> items;
  final double width;
  final ValueChanged<T?>? onChanged;
  final Widget? underline;
  final T value;
  final Widget? hint;
  final Widget? disabledHint;
  final Widget? icon;
  final TextStyle? style;
  final BorderRadius borderRadius;

  /// 每一项的高度，小于[kMinInteractiveDimension]按[kMinInteractiveDimension]计算
  final double height;

  @override
  State<DropdownButtonOverlay<T>> createState() =>
      _DropdownButtonOverlayState<T>();
}

class _DropdownButtonOverlayState<T extends MenuLabelInterface>
    extends State<DropdownButtonOverlay<T>>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final GlobalKey _triggerKey = GlobalKey();
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  late Animation<double> _opacityAnimation;
  late ValueNotifier<T> _valueNotifier;

  @override
  void initState() {
    super.initState();
    _valueNotifier = ValueNotifier(widget.value);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _heightAnimation = Tween<double>(
      begin: 0,
      end: widget.items.length * widget.height,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      }
    });
  }

  void _showMenu() {
    if (widget.onChanged == null) return;

    final renderBox =
        _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    final overlay = Navigator.of(context).overlay;

    if (renderBox == null || overlay == null) return;

    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);
    var mediaQueryData = MediaQueryData.fromView(View.of(context));
    final screenHeight = mediaQueryData.size.height;
    final availableSpaceBelow = screenHeight - position.dy - size.height - 8;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _hideMenu,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Stack(
              children: [
                AnimatedBuilder(
                  animation: _heightAnimation,
                  builder: (context, child) {
                    return CompositedTransformFollower(
                      link: _layerLink,
                      showWhenUnlinked: false,
                      offset: Offset(
                        0,
                        size.height +
                            4 -
                            _compensationHeight(
                              availableSpaceBelow,
                              _heightAnimation.value,
                            ),
                      ),
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: size.width,
                          maxHeight: _heightAnimation.value,
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor.withOpacity(0.9),
                      borderRadius: widget.borderRadius,
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(40, 0, 0, 0),
                          blurRadius: 4,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Material(
                      type: MaterialType.transparency, // 保持点击涟漪效果
                      child: ListView(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        children:
                            widget.items.map((item) {
                              return InkWell(
                                onTap: () {
                                  if (item.value == null) return;
                                  _valueNotifier.value = item.value!;
                                  widget.onChanged?.call(item.value);
                                  _hideMenu();
                                },
                                child: item,
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    overlay.insert(_overlayEntry!);
    _animationController.forward();
  }

  double _compensationHeight(double availableSpaceBelow, double menuHeight) {
    return availableSpaceBelow > menuHeight
        ? 0
        : menuHeight - availableSpaceBelow;
  }

  Future<void> _hideMenu() async {
    await _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        key: _triggerKey,
        onTap: widget.onChanged != null ? _showMenu : null,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: widget.width,
                    child: ValueListenableBuilder(
                      valueListenable: _valueNotifier,
                      builder: (context, value, child) {
                        return DefaultTextStyle(
                          style:
                              widget.style ??
                              value.getStyle(context) ??
                              TextStyle(color: Colors.black),
                          child:
                              widget.items
                                  .firstWhere(
                                    (item) => item.value == value,
                                    orElse: () => widget.items.first,
                                  )
                                  .child,
                        );
                      },
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color:
                        widget.onChanged != null
                            ? Colors.grey
                            : Colors.grey[400],
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0.0,
              right: 0.0,
              bottom: 0.0,
              child:
                  widget.underline ??
                  Container(
                    height: 1.0,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFFBDBDBD),
                          width: 0.0,
                        ),
                      ),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _animationController.dispose();
    _valueNotifier.dispose();
    super.dispose();
  }
}
