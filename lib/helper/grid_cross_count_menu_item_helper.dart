import 'package:flutter/material.dart';
import 'package:koko/interface/menu_label_interface.dart';

class GridCrossCountMenuItemHelper implements MenuLabelInterface {
  GridCrossCountMenuItemHelper(this.crossCount);

  static Map<int, GridCrossCountMenuItemHelper> gridCrossCountItemMap = {
    2: GridCrossCountMenuItemHelper(2),
    3: GridCrossCountMenuItemHelper(3),
    4: GridCrossCountMenuItemHelper(4),
    5: GridCrossCountMenuItemHelper(5),
    6: GridCrossCountMenuItemHelper(6),
  };

  final int crossCount;

  @override
  Icon? getIcon(BuildContext context) => null;

  @override
  String getLabel(BuildContext context) => crossCount.toString();

  @override
  TextStyle? getStyle(BuildContext context) =>
      TextStyle(fontSize: 14, color: Colors.black);
}
