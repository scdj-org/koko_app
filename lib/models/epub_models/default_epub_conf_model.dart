import 'package:flutter/rendering.dart';
import 'package:koko/enums/epub_font_size_enmu.dart';
import 'package:koko/states/global_profile_change_notifier.dart';

/// 默认Epub阅读设置
class DefaultEpubConfModel extends GlobalProfileChangeNotifier {
  EpubFontSizeEnmu get fontSize => globalProfile.defaultEpubConf.fontSize!;

  set fontSize(EpubFontSizeEnmu size) {
    if (globalProfile.defaultEpubConf.fontSize != size) {
      globalProfile.defaultEpubConf.fontSize = size;
      notifyListeners();
    }
  }

  int get preloadNum => globalProfile.defaultEpubConf.preloadNum!;

  set preloadNum(int num) {
    if (globalProfile.defaultEpubConf.preloadNum != num) {
      globalProfile.defaultEpubConf.preloadNum = num;
      notifyListeners();
    }
  }

  Axis get direction => globalProfile.defaultEpubConf.direction ?? Axis.horizontal;

  set direction(Axis axis) {
    if (globalProfile.defaultEpubConf.direction != axis) {
      globalProfile.defaultEpubConf.direction = axis;
      notifyListeners();
    }
  }

  bool get withTheme => globalProfile.defaultEpubConf.withTheme ?? true;

  set withTheme(bool setWithTheme) {
    if (globalProfile.defaultEpubConf.withTheme != setWithTheme) {
      globalProfile.defaultEpubConf.withTheme = setWithTheme;
      notifyListeners();
    }
  }
}
