import 'package:koko/states/global_profile_change_notifier.dart';

/// App Cache最大size
class MaxCacheFileSizeModel extends GlobalProfileChangeNotifier {
  /// 获取最大size
  int get maxCacheFileSize => globalProfile.maxCacheFileSize;

  /// 设置最大size，传入byte流
  set maxCacheFileSize(int size) {
    if(globalProfile.maxCacheFileSize != size) {
      globalProfile.maxCacheFileSize = size;
      notifyListeners();
    }
  } 
}
