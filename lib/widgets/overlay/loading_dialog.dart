import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:koko/l10n/l10n.dart';
import 'package:koko/models/entity/call_back_result.dart';

enum ProgressBarStyle { linear, circular }

/// 加载dialog
class LoadingDialog {
  static OverlayEntry? _currentEntry;

  /// 显示加载对话框
  ///
  /// [task] 接收一个带进度回调的函数，返回是否成功
  ///
  ///
  /// [timeout] 超时时间（默认30秒）
  ///
  ///
  /// [progressBarStyle] 进度条样式（默认线性）
  static Future<CallBackResult> show({
    required BuildContext context,
    required Future<CallBackResult> Function(
      void Function(double)? updateProgress,
    )
    task,
    String message = '处理中...',
    ProgressBarStyle progressBarStyle = ProgressBarStyle.linear,
    Color barrierColor = Colors.black38,
    Color progressBarColor = Colors.blue,
    double progressBarHeight = 4.0,
    Duration timeout = const Duration(seconds: 30),
    VoidCallback? onTimeout,
    VoidCallback? onCancel,
    Widget? headerWidget,
  }) async {
    final overlay = Overlay.of(context);
    final completer = Completer<bool>();

    // 关闭已有对话框
    _currentEntry?.remove();

    double? currentProgress;
    bool isCompleted = false;

    final GlobalKey<_LoadingLayerState> globalKey =
        GlobalKey<_LoadingLayerState>();

    void updateProgress(double progress) {
      if (_currentEntry?.mounted ?? false) {
        currentProgress = progress.clamp(0.0, 100.0);
        var state = globalKey.currentState;
        if (state != null) {
          state._updateProgress(currentProgress!);
        }
      }
    }

    _currentEntry = OverlayEntry(
      builder:
          (context) => _LoadingLayer(
            key: globalKey,
            message: message,
            barrierColor: barrierColor,
            progressBarStyle: progressBarStyle,
            progressBarColor: progressBarColor,
            progressBarHeight: progressBarHeight,
            initialProgress: currentProgress,
            onCancel:
                onCancel != null
                    ? () {
                      onCancel.call();
                      _currentEntry?.remove();
                      _currentEntry = null;
                    }
                    : null,
            headerWidget: headerWidget,
          ),
    );

    overlay.insert(_currentEntry!);

    try {
      var result = await task(updateProgress).timeout(timeout);
      isCompleted = true;
      return result;
    } on TimeoutException {
      onTimeout?.call();
      return CallBackResult.failure(result: "TimeOut");
    } catch (e) {
      return CallBackResult.failure(result: e);
    } finally {
      if (!isCompleted) completer.complete(false);
      _currentEntry?.remove();
      _currentEntry = null;
    }
  }
}

class _LoadingLayer extends StatefulWidget {
  final String message;
  final Color barrierColor;
  final ProgressBarStyle progressBarStyle;
  final Color progressBarColor;
  final double progressBarHeight;
  final double? initialProgress;
  final VoidCallback? onCancel;
  final Widget? headerWidget;

  const _LoadingLayer({
    super.key,
    required this.message,
    required this.barrierColor,
    required this.progressBarStyle,
    required this.progressBarColor,
    required this.progressBarHeight,
    this.initialProgress,
    this.onCancel,
    this.headerWidget,
  });

  @override
  State<_LoadingLayer> createState() => _LoadingLayerState();
}

class _LoadingLayerState extends State<_LoadingLayer> {
  late final ValueNotifier<double?> _currentProgress;

  void _updateProgress(double progress) {
    _currentProgress.value = progress;
  }

  @override
  void initState() {
    super.initState();
    _currentProgress = ValueNotifier(widget.initialProgress);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child:
          Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                // 阻断交互的遮罩
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    color: widget.barrierColor,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),

                // 加载内容
                Center(
                  child: Container(
                    width: 270,
                    padding: EdgeInsets.only(top: 24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(90, 0, 0, 0),
                          blurRadius: 14,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.headerWidget != null) ...[
                          widget.headerWidget!,
                          const SizedBox(height: 20),
                        ],
                        ValueListenableBuilder(
                          valueListenable: _currentProgress,
                          builder: (context, currentProgressValue, _) {
                            return _buildProgressIndicator(
                              currentProgressValue,
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        Text(
                          widget.message,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (widget.onCancel != null)
                          // 按钮区域
                          const Divider(height: 1, color: Color(0xFFD1D1D6)),
                        if (widget.onCancel != null)
                          TextButton(
                            style: TextButton.styleFrom(
                              minimumSize: const Size(double.infinity, 44),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(14),
                                  bottomRight: Radius.circular(14),
                                ),
                              ),
                            ),
                            onPressed: widget.onCancel,
                            child: Text(
                              AppLocalizations.of(context).cancel,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fade(),
    );
  }

  Widget _buildProgressIndicator(double? currentProgressValue) {
    if (currentProgressValue == null) {
      return widget.progressBarStyle == ProgressBarStyle.circular
          ? CircularProgressIndicator(
            color: widget.progressBarColor,
            strokeWidth: widget.progressBarHeight,
          )
          : LinearProgressIndicator(
            minHeight: widget.progressBarHeight,
            color: widget.progressBarColor,
          );
    }

    return widget.progressBarStyle == ProgressBarStyle.circular
        ? SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            value: currentProgressValue / 100,
            color: widget.progressBarColor,
            strokeWidth: widget.progressBarHeight,
          ),
        )
        : LinearProgressIndicator(
          value: currentProgressValue / 100,
          minHeight: widget.progressBarHeight,
          color: widget.progressBarColor,
        );
  }
}
