/// 自定义的回调返回值
class CallBackResult<T> {
  /// 构造函数，允许初始化所有属性
  CallBackResult({this.result, this.success, this.isBackGesture});

  /// 返回结果
  T? result;

  /// 是否成功
  bool? success;

  /// 是否是返回手势, 除手势检测外的其他地方情况忽略
  bool? isBackGesture;

  /// 快速创建一个成功的返回结果
  factory CallBackResult.success({T? result}) {
    return CallBackResult(result: result, success: true);
  }

  /// 快速创建一个失败的返回结果
  factory CallBackResult.failure({T? result}) {
    return CallBackResult(result: result, success: false);
  }

  /// 快速创建一个返回手势触发的结果
  factory CallBackResult.backGesture() {
    return CallBackResult(success: false, isBackGesture: true);
  }
}
