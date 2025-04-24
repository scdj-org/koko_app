import 'package:flutter/material.dart';

class PageErrorWidget extends StatelessWidget {
  final String message;
  final Color? color;
  final Color? backgroundColor;
  final VoidCallback? onRetry;

  const PageErrorWidget({
    super.key,
    required this.message,
    this.color,
    this.backgroundColor,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: backgroundColor ?? theme.scaffoldBackgroundColor,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: color ?? theme.colorScheme.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: color ?? theme.colorScheme.error,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(onPressed: onRetry, child: const Text('重试')),
            ],
          ],
        ),
      ),
    );
  }
}
