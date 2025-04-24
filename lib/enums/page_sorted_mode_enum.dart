import 'package:flutter/material.dart';
import 'package:koko/interface/menu_label_interface.dart';
import 'package:koko/l10n/l10n.dart';

/// 页面排序方式枚举
///
/// 0-名称，1-日期，2-类型，3-大小
enum PageSortedModeEnum implements MenuLabelInterface {
  /// 名字排序
  byName(0, Icon(Icons.sort_by_alpha, size: 15)),

  /// 日期排序
  byDate(1, Icon(Icons.access_time_filled, size: 15)),

  /// 类型排序
  byType(2, Icon(Icons.category, size: 15)),

  /// 大小排序
  bySize(3, Icon(Icons.storage, size: 15));

  final int modeNum;
  final Icon icon;
  const PageSortedModeEnum(this.modeNum, this.icon);

  static final Map<int, PageSortedModeEnum> _serializationMap = {
    for (final v in values) v.modeNum: v,
  };

  static PageSortedModeEnum? fromSortedModeId(int? id) => _serializationMap[id];

  @override
  Icon? getIcon(BuildContext context) => icon;

  @override
  String getLabel(BuildContext context) => _getPageSortedModeDesc(context);

  @override
  TextStyle? getStyle(BuildContext context) =>
      TextStyle(fontSize: 14, color: Colors.black);
}

extension PageSortedModeDesc on PageSortedModeEnum {
  String _getPageSortedModeDesc(BuildContext context) {
    switch (this) {
      case PageSortedModeEnum.byName:
        return AppLocalizations.of(context).pageSortedMode0;
      case PageSortedModeEnum.byDate:
        return AppLocalizations.of(context).pageSortedMode1;
      case PageSortedModeEnum.byType:
        return AppLocalizations.of(context).pageSortedMode2;
      case PageSortedModeEnum.bySize:
        return AppLocalizations.of(context).pageSortedMode3;
    }
  }
}
