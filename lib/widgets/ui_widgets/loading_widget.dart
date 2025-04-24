import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final Color? color;
  final Color? backgroundColor;

  const LoadingWidget({
    super.key,
    this.message,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      color: backgroundColor ?? theme.scaffoldBackgroundColor,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: color ?? theme.primaryColor),
            const SizedBox(height: 16),
            Text(
              message ?? '加载中...',
              style: TextStyle(color: color ?? theme.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
