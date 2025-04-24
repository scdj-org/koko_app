import 'package:flutter/material.dart';
import 'package:koko/interface/menu_label_interface.dart';
import 'package:koko/l10n/l10n.dart';

class DefaultMenuItemHelper implements MenuLabelInterface {
  DefaultMenuItemHelper({this.style, this.label, this.icon, this.value});

  TextStyle? style;
  String? label;
  Icon? icon;
  Object? value;

  @override
  Icon? getIcon(BuildContext context) => icon;

  @override
  String getLabel(BuildContext context) =>
      label ?? AppLocalizations.of(context).defaultDesc;

  @override
  TextStyle? getStyle(BuildContext context) =>
      style ?? const TextStyle(color: Colors.black);
}
