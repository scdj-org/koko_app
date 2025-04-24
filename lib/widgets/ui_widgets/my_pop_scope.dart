import 'dart:io';

import 'package:flutter/material.dart';
import 'package:koko/models/entity/call_back_result.dart';

/// 可用于ios增强返回手势范围
class MyPopScope extends StatelessWidget {
  const MyPopScope({
    required this.child,
    super.key,
    this.onPopInvokedWithResult,
    this.canPop = true,
  });

  final Widget child;
  final PopInvokedWithResultCallback<CallBackResult>? onPopInvokedWithResult;
  final bool canPop;

  /// 监控手势滑动距离, 防误触
  final double _popDetectionDelta = 8;

  @override
  Widget build(BuildContext context) {
    // 手势只能pop一次
    bool gesturePop = false;

    return Platform.isIOS
        ? GestureDetector(
          onHorizontalDragUpdate: (details) {
            if (!gesturePop &&
                details.delta.dx > _popDetectionDelta &&
                onPopInvokedWithResult != null) {
              CallBackResult callBackResult = CallBackResult.backGesture();

              // 不允许手势返回了
              gesturePop = true;

              // 只要不管callBackResult，即忽略MyPopScope恢复为PopScope
              onPopInvokedWithResult!.call(true, callBackResult);
            }
          },
          child: PopScope(
            canPop: canPop,
            onPopInvokedWithResult: onPopInvokedWithResult,
            child: child,
          ),
        )
        : PopScope(
          canPop: canPop,
          onPopInvokedWithResult: onPopInvokedWithResult,
          child: child,
        );
  }
}
