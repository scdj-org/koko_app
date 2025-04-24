import 'package:flutter/material.dart';
import 'package:koko/common/global.dart';
import 'package:koko/models/entity/global_profile.dart';

/// 全局配置文件notifier
class GlobalProfileChangeNotifier extends ChangeNotifier {
  GlobalProfile get globalProfile => Global.instance.globalProfile;

  @override
  void notifyListeners() {
    Global.instance.saveProfile();
    super.notifyListeners();
  }
}
