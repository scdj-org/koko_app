import 'package:flutter/material.dart';
import 'package:koko/enums/epub_font_size_enmu.dart';

class EpubConf {
  /// 字体大小
  EpubFontSizeEnmu? fontSize;

  /// 预加载页数
  int? preloadNum;

  /// 方向
  Axis? direction;

  /// 背景颜色
  bool? withTheme;

  EpubConf({
    this.fontSize,
    this.preloadNum,
    this.direction,
    this.withTheme,
  });

  /// 序列化为 JSON
  Map<String, dynamic> toJson() {
    return {
      'fontSize': fontSize?.fontSize,
      'preloadNum': preloadNum,
      'direction': direction == Axis.vertical,
      'withTheme': withTheme,
    };
  }

  /// 从 JSON 反序列化
  factory EpubConf.fromJson(Map<String, dynamic> json, {bool global = false}) {
    var fontSize = EpubFontSizeEnmu.fromFontSize(json['fontSize'] as int?);
    var preloadNum = json['preloadNum'] as int?;
    var directionBool = json['direction'] as bool?;
    var withTheme = json['withTheme'] as bool?;
    Axis? dirction;
    if (directionBool == null) {
      dirction = null;
    } else {
      dirction = directionBool ? Axis.vertical : Axis.horizontal;
    }
    if (global) {
      return EpubConf(
        fontSize: fontSize ?? EpubFontSizeEnmu.medium,
        preloadNum: preloadNum ?? 2,
        direction: dirction ?? Axis.horizontal,
        withTheme: withTheme ?? true,
      );
    } else {
      return EpubConf(
        fontSize: fontSize,
        preloadNum: preloadNum,
        direction: dirction,
        withTheme: withTheme,
      );
    }
  }
}
