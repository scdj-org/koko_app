import 'package:flutter/material.dart';

/// 对话框选项配置类
class ChoiceOption<T> {
  /// 标签
  final String label;
  /// 图标
  final IconData icon;
  /// 图标颜色
  final Color? iconColor;
  /// 返回值
  final T value;

  const ChoiceOption({
    required this.label,
    required this.icon,
    required this.value,
    this.iconColor,
  });
}