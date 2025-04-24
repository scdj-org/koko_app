import 'package:flutter/material.dart';
import 'package:koko/interface/menu_label_interface.dart';
import 'package:koko/models/model/locale_model.dart';
import 'package:provider/provider.dart';

/// 国际化菜单项构建协助类
class LocaleMenuItemHelper implements MenuLabelInterface {
  LocaleMenuItemHelper(this.lable, this.locale);

  final String lable;

  String? locale;

  @override
  Icon? getIcon(BuildContext context) => null;

  @override
  String getLabel(BuildContext context) => lable;

  @override
  TextStyle? getStyle(BuildContext context) {
    return Provider.of<LocaleModel>(context, listen: false).locale == locale
        ? TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        )
        : TextStyle(fontSize: 14, color: Colors.black);
  }
}
