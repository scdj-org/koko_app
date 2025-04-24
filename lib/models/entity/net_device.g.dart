// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'net_device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NetDevice _$NetDeviceFromJson(Map<String, dynamic> json) =>
    NetDevice()
      ..id = json['id'] as int
      ..baseurl = json['baseurl'] as String
      ..protocol = ProtocolEnum.fromProtocolId(json['protocol'] as int)!
      ..name = json['name'] as String?
      ..port = json['port'] as int?
      ..rootPath = json['rootPath'] as String?
      ..account = json['account'] as String?
      ..password = json['password'] as String?;

Map<String, dynamic> _$NetDeviceToJson(NetDevice instance) => <String, dynamic>{
  'id': instance.id,
  'baseurl': instance.baseurl,
  'protocol': instance.protocol.protocolId,
  'rootPath': instance.rootPath,
  'name': instance.name,
  'port': instance.port,
  'account': instance.account,
  'password': instance.password,
};
