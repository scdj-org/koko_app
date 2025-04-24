import 'package:flutter/material.dart';

/// 渐变方向
enum GradientDirection { centerOut, leftToRight, rightToLeft }

class GradientDivider extends StatelessWidget {
  final double height;
  final Color color;
  final GradientDirection direction;

  const GradientDivider({
    super.key,
    this.height = 4.0,
    this.color = Colors.grey,
    this.direction = GradientDirection.centerOut, // 默认：中间厚两边细
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GradientDividerPainter(color, direction),
      child: SizedBox(height: height),
    );
  }
}

class _GradientDividerPainter extends CustomPainter {
  final Color color;
  final GradientDirection direction;

  _GradientDividerPainter(this.color, this.direction);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..shader = _createGradientShader(size)
          ..style = PaintingStyle.fill;

    final Path path = Path();

    if (direction == GradientDirection.centerOut) {
      // 中间厚，两边渐变变细
      path
        ..quadraticBezierTo(size.width / 2, -size.height * 2, size.width, 0)
        ..close();
    } else if (direction == GradientDirection.leftToRight) {
      // 左边厚，右边细
      path
        ..lineTo(0, -size.height) // 左边厚
        ..lineTo(size.width, 0) // 右边细
        ..close();
    } else {
      // 右边厚，左边细
      path
        ..lineTo(size.width, 0)
        ..lineTo(size.width, -size.height)
        ..close();
    }

    canvas.drawPath(path, paint);
  }

  /// 生成不同方向的渐变 Shader
  Shader _createGradientShader(Size size) {
    switch (direction) {
      case GradientDirection.centerOut:
        return LinearGradient(
          colors: [Colors.transparent, color, color, Colors.transparent],
          stops: [0.0, 0.3, 0.7, 1.0],
        ).createShader(Rect.fromLTRB(0, 0, size.width, -size.height));

      case GradientDirection.leftToRight:
        return LinearGradient(
          colors: [color, Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromLTRB(0, 0, size.width, -size.height));

      case GradientDirection.rightToLeft:
        return LinearGradient(
          colors: [Colors.transparent, color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromLTRB(0, 0, size.width, -size.height));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
