import 'package:flutter/widgets.dart';

/// 菜单接口，用于菜单的组件必须实现
/// 可以添加私有类实现接口
///
/// ie
/// ```dart
/// class _exampleMenuItemHelper implements MenuLabelInterface {
///
///   @override
///   Icon? getIcon(BuildContext context) => null;
///
///   @override
///   String getLabel(BuildContext context) => "";
///
///   @override
///   TextStyle? getStyle(BuildContext context) => null;
/// }
/// ```
abstract interface class MenuLabelInterface {
  /// 名字
  String getLabel(BuildContext context);

  /// 图标
  Icon? getIcon(BuildContext context);

  /// 文字样式
  TextStyle? getStyle(BuildContext context);
}
