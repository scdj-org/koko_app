import 'package:koko/enums/page_style_mode_enum.dart';
import 'package:koko/enums/page_sorted_mode_enum.dart';
import 'package:koko/states/global_profile_change_notifier.dart';

/// 默认页面配置model
class DefaultPageModeModel extends GlobalProfileChangeNotifier {
  /// 获取页面排序方式
  PageSortedModeEnum get pageSortedMode =>
      globalProfile.defaultPageMode.pageSortedMode!;

  /// 设置页面排序方式，通知监听者更新
  set pageSortedMode(PageSortedModeEnum mode) {
    if (mode != pageSortedMode) {
      globalProfile.defaultPageMode.pageSortedMode = mode;
      notifyListeners();
    }
  }

  /// 获取页面样式
  PageStyleModeEnum get pageStyleMode =>
      globalProfile.defaultPageMode.pageStyleMode!;

  /// 设置页面样式，通知监听者更新
  set pageStyleMode(PageStyleModeEnum mode) {
    if (mode != pageStyleMode) {
      globalProfile.defaultPageMode.pageStyleMode = mode;
      notifyListeners();
    }
  }

  /// 获取网格模式每行图片数
  int get gridCrossCount => globalProfile.defaultPageMode.gridCrossCount!;

  /// 设置网格模式每行图片数
  set gridCrossCount(int count) {
    if (count != gridCrossCount) {
      globalProfile.defaultPageMode.gridCrossCount = count;
      notifyListeners();
    }
  }
}
