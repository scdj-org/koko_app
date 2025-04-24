import 'package:flutter/material.dart';
import 'package:koko/interface/menu_label_interface.dart';
import 'package:koko/l10n/l10n.dart';

/// epub阅读方向
class EpubReadingDirectionMenuItemHelper implements MenuLabelInterface {
  EpubReadingDirectionMenuItemHelper(this.direction);

  final Axis direction;

  static Map<Axis, EpubReadingDirectionMenuItemHelper> epubPreloadNumItems = {
    Axis.horizontal: EpubReadingDirectionMenuItemHelper(Axis.horizontal),
    Axis.vertical: EpubReadingDirectionMenuItemHelper(Axis.vertical),
  };

  @override
  Icon? getIcon(BuildContext context) =>
      direction == Axis.horizontal
          ? Icon(Icons.view_column)
          : Icon(Icons.view_stream);

  @override
  String getLabel(BuildContext context) =>
      direction == Axis.horizontal
          ? AppLocalizations.of(context).horizontal
          : AppLocalizations.of(context).vertical;

  @override
  TextStyle? getStyle(BuildContext context) =>
      TextStyle(fontSize: 14, color: Colors.black);
}
