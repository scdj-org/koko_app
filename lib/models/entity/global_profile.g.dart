// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GlobalProfile _$GlobalProfileFromJson(Map<String, dynamic> json) {
  var v =
      GlobalProfile()
        ..themeColor = ThemeColorEnum.fromColorKey(
          json['themeColor'] as String? ?? "pink",
        )
        ..locale = json['locale'] as String?
        ..buttonTips = json['buttonTips'] as bool? ?? false
        ..defaultPageMode = PageProfile.fromJson(
          json['defaultPageMode'] as Map<String, dynamic>? ?? {},
          global: true,
        )
        ..netDevices =
            (json['netDevices'] as List<dynamic>?)
                ?.map((e) => NetDevice.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [
              NetDevice()
                ..id = 0
                ..protocol = ProtocolEnum.local
                ..baseurl = "local",
            ]
        ..maxCacheFileSize = json['maxCacheFileSize'] as int? ?? 2147483648
        ..defaultEpubConf = EpubConf.fromJson(
          json['defaultEpubConf'] as Map<String, dynamic>? ?? {},
          global: true,
        );
  return v;
}

Map<String, dynamic> _$GlobalProfileToJson(GlobalProfile instance) =>
    <String, dynamic>{
      'themeColor': instance.themeColor.key,
      'locale': instance.locale,
      "buttonTips": instance.buttonTips,
      'defaultPageMode': instance.defaultPageMode.toJson(),
      'netDevices': instance.netDevices.map((e) => e.toJson()).toList(),
      'maxCacheFileSize': instance.maxCacheFileSize,
      "defaultEpubConf": instance.defaultEpubConf.toJson(),
    };
