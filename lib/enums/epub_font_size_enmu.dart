import 'package:flutter/material.dart';
import 'package:flutter/src/painting/text_style.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/icon.dart';
import 'package:koko/interface/menu_label_interface.dart';
import 'package:koko/l10n/l10n.dart';

/// epub阅读字体大小枚举
enum EpubFontSizeEnmu implements MenuLabelInterface {
  small(4),
  medium(5),
  large(6),
  extraLarge(7);

  final int fontSize;

  const EpubFontSizeEnmu(this.fontSize);

  static final Map<int, EpubFontSizeEnmu> _serializationMap = {
    for (final v in values) v.fontSize: v,
  };

  static EpubFontSizeEnmu? fromFontSize(int? fontSize) =>
      _serializationMap[fontSize];

  @override
  Icon? getIcon(BuildContext context) => null;

  @override
  String getLabel(BuildContext context) => _getIntlEpubFontSizeDesc(context);

  @override
  TextStyle? getStyle(BuildContext context) =>
      TextStyle(fontSize: 14, color: Colors.black);
}

extension IntlEpubFontSizeDesc on EpubFontSizeEnmu {
  String _getIntlEpubFontSizeDesc(BuildContext context) {
    switch (this) {
      case EpubFontSizeEnmu.small:
        return AppLocalizations.of(context).fontSizeSmall;
      case EpubFontSizeEnmu.medium:
        return AppLocalizations.of(context).fontSizeMedium;
      case EpubFontSizeEnmu.large:
        return AppLocalizations.of(context).fontSizeLarge;
      case EpubFontSizeEnmu.extraLarge:
        return AppLocalizations.of(context).fontSizeSuperLarge;
    }
  }
}
