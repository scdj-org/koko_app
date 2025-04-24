import 'package:flutter/material.dart';
import 'package:koko/interface/menu_label_interface.dart';
import 'package:koko/l10n/l10n.dart';

/// 页面模式枚举
enum PageStyleModeEnum implements MenuLabelInterface {
  /// 简易列表
  simpleList(0, Icon(Icons.list_alt_rounded, size: 16)),

  /// 网格视图
  // TODO: 网格视图
  gridView(1, Icon(Icons.grid_on, size: 16)),

  /// 图片列表
  // TODO: 图片列表
  picList(2, Icon(Icons.image, size: 16));

  /// 模式序号 0-简易列表，1-网格视图，2-图片列表
  final int modeNum;

  /// 模式对应图标
  final Icon modeIcon;
  const PageStyleModeEnum(this.modeNum, this.modeIcon);

  static final Map<int, PageStyleModeEnum> _serializationMap = {
    for (final v in values) v.modeNum: v,
  };

  static PageStyleModeEnum? fromModeId(int? id) => _serializationMap[id];

  @override
  Icon? getIcon(BuildContext context) => modeIcon;

  @override
  String getLabel(BuildContext context) => _getPageModeDesc(context);

  @override
  TextStyle? getStyle(BuildContext context) =>
      TextStyle(fontSize: 14, color: Colors.black);
}

extension PageModeDesc on PageStyleModeEnum {
  String _getPageModeDesc(BuildContext context) {
    switch (this) {
      case PageStyleModeEnum.simpleList:
        return AppLocalizations.of(context).pageMode0;
      case PageStyleModeEnum.gridView:
        return AppLocalizations.of(context).pageMode1;
      case PageStyleModeEnum.picList:
        return AppLocalizations.of(context).pageMode2;
    }
  }
}
