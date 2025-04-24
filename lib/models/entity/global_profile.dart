import 'package:json_annotation/json_annotation.dart';
import 'package:koko/enums/protocol_enum.dart';
import 'package:koko/enums/theme_color_enum.dart';
import 'package:koko/models/epub_models/epub_conf.dart';
import 'package:koko/models/entity/index.dart';
part 'global_profile.g.dart';

@JsonSerializable()
class GlobalProfile {
  GlobalProfile();

  late ThemeColorEnum themeColor;
  String? locale;
  late bool buttonTips;
  late PageProfile defaultPageMode;
  late List<NetDevice> netDevices;
  late int maxCacheFileSize;
  late EpubConf defaultEpubConf;

  factory GlobalProfile.fromJson(Map<String, dynamic> json) =>
      _$GlobalProfileFromJson(json);
  Map<String, dynamic> toJson() => _$GlobalProfileToJson(this);
}
