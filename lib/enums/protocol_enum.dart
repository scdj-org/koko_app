import 'package:flutter/material.dart';
import 'package:koko/interface/menu_label_interface.dart';

/// 网络协议的枚举类
enum ProtocolEnum implements MenuLabelInterface {
  /// 本地
  local(0, Icon(Icons.folder_open_rounded)),

  /// webdav
  webdav(1, Icon(Icons.cloud)),

  /// smb
  smb(2, Icon(Icons.window_rounded));

  final int protocolId;
  final Icon icon;
  const ProtocolEnum(this.protocolId, this.icon);

  static final Map<int, ProtocolEnum> _serializationMap = {
    for (final v in values) v.protocolId: v,
  };

  static ProtocolEnum? fromProtocolId(int id) => _serializationMap[id];

  @override
  Icon? getIcon(BuildContext context) => icon;

  @override
  String getLabel(BuildContext context) => name;

  @override
  TextStyle? getStyle(BuildContext context) =>
      TextStyle(fontSize: 14, color: Colors.black);
}
