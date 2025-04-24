import 'package:koko/models/entity/index.dart';
import 'package:koko/states/global_profile_change_notifier.dart';

class NetDevicesModel extends GlobalProfileChangeNotifier {
  /// 获取服务器列表
  List<NetDevice> get netDevices => globalProfile.netDevices;

  /// 添加服务器
  ///
  /// id必须唯一
  set appendNetDevice(NetDevice appendedNetDevice) {
    assert(!netDevices.contains(appendedNetDevice), "不能传入id一样的netDevice");
    netDevices.add(appendedNetDevice);
    notifyListeners();
  }

  /// 删除服务器列表
  set removeNetDevice(NetDevice removedNetDevice) {
    assert(netDevices.contains(removedNetDevice), "不能传入没有的netDevice");
    netDevices.remove(removedNetDevice);
    notifyListeners();
  }
}
