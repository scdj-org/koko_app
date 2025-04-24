import 'package:flutter/material.dart';
import 'package:koko/interface/menu_label_interface.dart';
import 'package:koko/l10n/l10n.dart';

// HACK: 添加新主题色需要同时维护包扩展类的switch代码块；枚举类的成员不能为非const，因此不能加入function作为成员，采用包扩展解决
/// 主题色枚举
enum ThemeColorEnum implements MenuLabelInterface {
  // 枚举值
  pink("pink", Colors.pink),
  purple("purple", Colors.purple),
  // white("white", Colors.white),
  cyan("cyan", Colors.cyan),
  green("green", Colors.green),
  white("white", Colors.white);

  /// 反序列化寻址map, 通过key反序列化到ThemeColorEnum
  static final Map<String, ThemeColorEnum> _serializationMap = {
    for (final v in values) v.key: v,
  };

  // // 也可用包扩展实现，map比较统一，因此选用map
  // // 国际化寻址map, 通过key寻找对应的国际化函数
  // static final Map<String, String Function(BuildContext)> _intlMap = {
  //   "pink": (BuildContext context) => S.of(context).colorPink,
  //   "purple": (BuildContext context) => S.of(context).colorPurple,
  //   "white": (BuildContext context) => S.of(context).colorWhite,
  //   "cyan": (BuildContext context) => S.of(context).colorCyan,
  //   "green": (BuildContext context) => S.of(context).colorGreen,
  // };

  /// 通过key获取颜色
  static ThemeColorEnum fromColorKey(String key) {
    return _serializationMap[key] ?? ThemeColorEnum.pink;
  }

  // // 通过key获取对应语言的色彩描述(国际化)
  // static String getColorIntlDesc() {
  //   return "";
  // }

  /// 对应颜色
  final Color color;

  /// 对应key
  final String key;

  // 构造函数
  const ThemeColorEnum(this.key, this.color);

  @override
  Icon? getIcon(BuildContext context) => Icon(
    Icons.color_lens_outlined,
    color: this == ThemeColorEnum.white ? Colors.grey : color,
  );

  @override
  String getLabel(BuildContext context) => _getColorIntlDesc(context);

  @override
  TextStyle? getStyle(BuildContext context) {
    return TextStyle(
      color: this == ThemeColorEnum.white ? Colors.grey : color,
      fontSize: 15,
      fontWeight: FontWeight.bold,
    );
  }
}

/// 获取颜色描述(国际化适配)
extension IntlColorDesc on ThemeColorEnum {
  String _getColorIntlDesc(BuildContext context) {
    switch (this) {
      case ThemeColorEnum.pink:
        return AppLocalizations.of(context).colorPink;
      case ThemeColorEnum.purple:
        return AppLocalizations.of(context).colorPurple;
      case ThemeColorEnum.cyan:
        return AppLocalizations.of(context).colorCyan;
      case ThemeColorEnum.green:
        return AppLocalizations.of(context).colorGreen;
      case ThemeColorEnum.white:
        return AppLocalizations.of(context).colorWhite;
    }
  }
}
