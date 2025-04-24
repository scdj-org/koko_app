import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:isolate/isolate_runner.dart';
import 'package:isolate/load_balancer.dart';
import 'package:koko/common/application_cache_manager.dart';
import 'package:koko/common/data_source_manager/local_data_source_manager.dart';
import 'package:koko/common/route_observer_instance.dart';
import 'package:koko/common/data_source_manager/webdav_data_source_manager.dart';
import 'package:koko/models/entity/index.dart';
import 'package:koko/models/entity/view_page_entity.dart';
import 'package:koko/widgets/overlay/multi_line_input_dialog_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webdav_client/webdav_client.dart';

/// 全局配置及初始化，单例
class Global {
  static final Global _instance = Global._();

  static Global get instance => _instance;

  Global._();

  /// deviceId，当前device的Id，方便后续预加载、提取服务器缓存等操作，0为本地资源
  int deviceId = 0;

  /// 线程池
  late final LoadBalancer _loadBalancer;
  LoadBalancer get loadBalancer => _loadBalancer;

  /// 防抖
  late final Debouncer _debouncer;
  Debouncer get debouncer => _debouncer;

  // 截流
  late final Throttler _throttler;
  Throttler get throttler => _throttler;

  /// 本地缓存文件
  late final SharedPreferencesWithCache _pref;
  SharedPreferencesWithCache get pref => _pref;

  /// 全局配置
  late GlobalProfile globalProfile;

  /// 需要刷新的viewpage路由页路径
  ViewPageEntity? backRouteRefreshPath;

  /// webdav客户端，每次进入新的webdav服务器之前需要set一次
  Client? webdavClient;

  // XXX初始化配置，添加在runApp前面
  Future init() async {
    // flutter框架启动
    WidgetsFlutterBinding.ensureInitialized();

    await MultiLineInputDialogOverlay.globalInit();

    int cores = Platform.numberOfProcessors;
    _loadBalancer = await LoadBalancer.create(cores, IsolateRunner.spawn);

    _debouncer = Debouncer();

    _throttler = Throttler();

    // 获取preference的实例化对象存取临时文件
    _pref = await SharedPreferencesWithCache.create(
      cacheOptions: SharedPreferencesWithCacheOptions(allowList: null),
    );

    // 清空缓存
    // _pref.remove("global_profile");

    // 从缓存中获取配置文件
    String? profile = _pref.getString("global_profile");
    try {
      globalProfile = GlobalProfile.fromJson(jsonDecode(profile ?? "{}"));
      if (profile == null) {
        saveProfile();
      }
    } catch (e) {
      // TODO:异常处理
      rethrow;
    }

    /// 加载单例, 部分单例不适合懒加载，为了统一单例模式统一写成懒加载模式
    ///
    /// 不需要懒加载的在这里加载即可
    LocalDataSourceManager.instance;
    await LocalDataSourceManager.instance.init();
    WebdavDataSourceManager.instance;
    await WebdavDataSourceManager.instance.init();
    ApplicationCacheManager.instance;
    await ApplicationCacheManager.instance.init(globalProfile.maxCacheFileSize);
    RouteObserverInstance.instance;
  }

  /// json格式保存方便扩展, 持久化配置文件
  void saveProfile() =>
      _pref.setString("global_profile", jsonEncode(globalProfile.toJson()));
}
