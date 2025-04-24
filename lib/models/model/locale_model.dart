import 'package:flutter/widgets.dart';
import 'package:koko/states/global_profile_change_notifier.dart';

/// 国际化
class LocaleModel extends GlobalProfileChangeNotifier {
  /// 获取当前用户的APP语言配置Locale类，如果为null，则语言跟随系统语言
  Locale? getLocale() {
    if (globalProfile.locale == null) return null;
    var t = globalProfile.locale!.split("_");
    return Locale(t[0], t[1]);
  }

  /// 获取语言的字符串表示, 比如zh_CN
  String? get locale => globalProfile.locale;

  /// 用户改变APP语言后，通知依赖项更新，新语言会立即生效
  set locale(String? locale) {
    if (locale != globalProfile.locale) {
      globalProfile.locale = locale;
      notifyListeners();
    }
  }
}
