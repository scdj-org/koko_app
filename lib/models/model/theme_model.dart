import 'package:koko/states/global_profile_change_notifier.dart';
import 'package:koko/enums/theme_color_enum.dart';

/// 主题
class ThemeModel extends GlobalProfileChangeNotifier {
  /// 获取主题色
  ThemeColorEnum get themeColor => globalProfile.themeColor;

  /// 切换主题色, 切换后立即生效刷新页面
  set themeColor(ThemeColorEnum color) {
    if (themeColor != color) {
      globalProfile.themeColor = color;
      notifyListeners();
    }
  }
}
