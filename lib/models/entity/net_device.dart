import 'package:json_annotation/json_annotation.dart';
import 'package:koko/enums/protocol_enum.dart';

part 'net_device.g.dart';

@JsonSerializable()
class NetDevice implements Comparable<NetDevice> {
  NetDevice();

  /// id自动生成，不开放给用户
  late int id;
  late String baseurl;
  late ProtocolEnum protocol;
  String? rootPath;
  String? name;
  int? port;
  String? account;
  String? password;

  factory NetDevice.fromJson(Map<String, dynamic> json) =>
      _$NetDeviceFromJson(json);
  Map<String, dynamic> toJson() => _$NetDeviceToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NetDevice) return false;
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  int compareTo(NetDevice other) => id.compareTo(other.id);
}
