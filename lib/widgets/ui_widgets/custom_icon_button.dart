import 'package:flutter/material.dart';

/// 自定义的icon按钮
class CustomIconButton extends StatelessWidget {
  final Widget? icon;
  final Widget? label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final double elevation;
  final double? width;
  final double? height;
  final bool expand;

  const CustomIconButton({
    super.key,
    this.icon,
    this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    this.borderRadius = const BorderRadius.all(Radius.zero),
    this.elevation = 0,
    this.width,
    this.height,
    this.expand = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBgColor =
        backgroundColor ?? Theme.of(context).colorScheme.primary;
    final effectiveFgColor = _calculateForegroundColor(
      context,
      effectiveBgColor,
    );

    final buttonChild = _buildContent(context);

    final button = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: effectiveBgColor,
        foregroundColor: effectiveFgColor,
        padding: padding,
        elevation: elevation,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        minimumSize: Size(width ?? 0, height ?? 48),
      ),
      child: buttonChild,
    );

    return expand ? Expanded(child: button) : button;
  }

  Color _calculateForegroundColor(BuildContext context, Color bgColor) {
    if (foregroundColor != null) return foregroundColor!;
    final brightness = ThemeData.estimateBrightnessForColor(bgColor);
    return brightness == Brightness.light ? Colors.black87 : Colors.white;
  }

  Widget _buildContent(BuildContext context) {
    if (icon == null && label == null) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          IconTheme(
            data: IconThemeData(color: foregroundColor, size: 24),
            child: icon!,
          ),
          if (label != null) const SizedBox(width: 8),
        ],
        if (label != null)
          Flexible(
            child: DefaultTextStyle(
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w600,
              ),
              child: label!,
            ),
          ),
      ],
    );
  }
}
