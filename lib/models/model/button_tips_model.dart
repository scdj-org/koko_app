import 'package:koko/states/global_profile_change_notifier.dart';

class ButtonTipsModel extends GlobalProfileChangeNotifier {
  bool get buttonTips => globalProfile.buttonTips;

  set buttonTips(bool value) {
    if (globalProfile.buttonTips != value) {
      globalProfile.buttonTips = value;
      notifyListeners();
    }
  }
}
