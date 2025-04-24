import 'package:flutter/material.dart';
import 'package:koko/interface/menu_label_interface.dart';

/// epub预缓存页数
class EpubPreloadNumMenuItemHelper implements MenuLabelInterface {
  EpubPreloadNumMenuItemHelper(this.preloadNum);

  /// HACK: 新的缓存策略需要维护该表
  static List<EpubPreloadNumMenuItemHelper> epubPreloadNumItems = [
    for (int i = 0; i < 4; i++) EpubPreloadNumMenuItemHelper(i),
  ];

  final int preloadNum;

  @override
  Icon? getIcon(BuildContext context) => null;

  @override
  String getLabel(BuildContext context) => preloadNum.toString();

  @override
  TextStyle? getStyle(BuildContext context) =>
      TextStyle(fontSize: 14, color: Colors.black);
}
