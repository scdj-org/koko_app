import 'package:flutter/gestures.dart';

/// 永远赢的tap手势
class WinTapGestureRecognizer extends TapGestureRecognizer {
  @override
  void rejectGesture(int pointer) {
    //宣布成功
    super.acceptGesture(pointer);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerCancelEvent) {
      // 确保 PointerCancelEvent 能正确重置 Tap 状态
      resolve(GestureDisposition.rejected);
    }
    super.handleEvent(event);
  }
}
