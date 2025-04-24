import 'dart:io';
import 'dart:typed_data';

import 'package:koko/common/global.dart';
import 'package:koko/interface/data_source_manager_interface.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Application Cache目录的管理器（单例模式）
///
/// **不要对文件夹操作**
class ApplicationCacheManager {
  /// 单例实例
  ///
  /// XXX约定项目的所有单例以instance的形式获取
  static ApplicationCacheManager? _instance;
  static ApplicationCacheManager get instance =>
      _instance ??= ApplicationCacheManager._internal();
  ApplicationCacheManager._internal();

  /// cache目录
  late final Directory _cacheDir;

  /// 最大缓存大小
  int _maxCacheSize = 0;

  /// 当前大小
  int _currentSize = -1;

  /// 获取缓存目录
  Directory get cacheDir => _cacheDir;

  /// 初始化缓存目录
  Future<void> init(int size) async {
    _cacheDir = Directory((await getApplicationCacheDirectory()).path);
    if (!_cacheDir.existsSync()) {
      _cacheDir.createSync(recursive: true);
    }
    _maxCacheSize = size;
    getCacheSize();
    final testFile = File('${cacheDir.path}/test.txt');
    await testFile.create();
    await testFile.writeAsString('test');
    // 应该输出 true
  }

  /// 获取缓存大小的描述
  Future<String> getCacheSizeDesc() async {
    return DataSourceManagerInterface.formatBytes(getCacheSize());
  }

  /// 获取缓存文件大小
  int getCacheSize() {
    if (_currentSize == -1 && _cacheDir.existsSync()) {
      _currentSize = 0;
      for (var file in _cacheDir.listSync(recursive: true)) {
        if (file is File) {
          _currentSize += file.lengthSync();
        }
      }
    }
    return _currentSize;
  }

  void addCacheSize(int size) {
    _currentSize += size;
  }

  /// 当前basePath是否已经被缓存 (文件)
  Future<bool> hasCachingFile(String basePath) async {
    return await File("$currentCachePath/$basePath").exists();
  }

  /// 写入缓存（自动删除 LRU）
  ///
  /// 会创建目录
  ///
  /// ** 标准basename: scuop/html/1.html, 不要有多余的'/' **
  Future<void> writeFile(String basePath, Uint8List data) async {
    // 创建目录
    var dirPath = path.dirname(basePath);

    // 创建文件夹
    var dir = Directory("$currentCachePath/$dirPath");
    try {
      await dir.create(recursive: true);
    } catch (e) {
      // 说明目录存在同名文件，需要逐级删除
      if (e is FileSystemException) {
        var checkPath = dirPath;
        while (checkPath != ".") {
          var entityType = FileSystemEntity.typeSync(
            "$currentCachePath/$checkPath",
          );
          if (entityType == FileSystemEntityType.file) {
            await deleteEntity(checkPath);
            break;
          }
          checkPath = path.dirname(checkPath);
        }
      } else {
        rethrow;
      }
    }

    final file = File("$currentCachePath/$basePath");
    // 如果缓存大小超限，则删除 LRU 文件
    while ((getCacheSize()) + data.length > _maxCacheSize) {
      await _removeLRUFile();
    }
    _currentSize += data.length;
    await Global.instance.loadBalancer.run((file) async {
      await file.writeAsBytes(data);
    }, file);
  }

  /// 读取缓存
  Future<Uint8List?> readFile(String basePath) async {
    final file = File('$currentCachePath/$basePath');
    return await Global.instance.loadBalancer.run((file) async {
      if (await file.exists()) {
        file.setLastAccessed(DateTime.now());
        var data = await file.readAsBytes();
        return data;
      }
      return null;
    }, file);
  }

  /// 删除缓存文件
  Future<void> deleteEntity(String relativePath) async {
    final target = FileSystemEntity.typeSync('$currentCachePath/$relativePath');
    final path = '$currentCachePath/$relativePath';

    if (target == FileSystemEntityType.file) {
      final file = File(path);
      if (file.existsSync()) {
        _currentSize -= file.lengthSync();
        await file.delete();
      }
    } else if (target == FileSystemEntityType.directory) {
      final dir = Directory(path);
      if (dir.existsSync()) {
        // 减去所有文件的大小
        await for (var entity in dir.list(
          recursive: true,
          followLinks: false,
        )) {
          if (entity is File) {
            _currentSize -= await entity.length();
          }
        }
        await dir.delete(recursive: true);
      }
    }
  }

  /// 清空缓存
  Future<void> clearCache() async {
    if (_cacheDir.existsSync()) {
      for (var entity in _cacheDir.listSync()) {
        try {
          entity.delete(recursive: entity is Directory);
          _currentSize = 0;
        } catch (e) {
          // TODO:写日志
        }
      }
    }
  }

  /// 删除最久未使用的文件（LRU 策略）
  Future<void> _removeLRUFile() async {
    final entities = _cacheDir.listSync().toList();
    if (entities.isEmpty) return;

    FileSystemEntity oldestEntity = entities[0];

    var oldestTime = oldestEntity.statSync().accessed;
    for (var entity in entities) {
      var nowTime = entity.statSync().accessed;
      if (oldestTime.compareTo(nowTime) > 0) {
        oldestTime = nowTime;
        oldestEntity = entity;
      }
    }

    try {
      // LRU删除的时候一般是自动删除，不会取当前size，设为-1之后查看的时候重新计算
      _currentSize = -1;
      await oldestEntity.delete(recursive: oldestEntity is Directory);
    } catch (e) {
      /// TODO: 异常处理
    }
  }

  /// 获取当前缓存目录
  String get currentCachePath =>
      "${_cacheDir.path}/${Global.instance.deviceId}";

  final String _androidContentPath = "top.scuop.fileprovider/cache";

  /// 兼容安卓
  String get requestCachePath {
    if (Platform.isAndroid) {
      return "content://$_androidContentPath/${Global.instance.deviceId}";
    } else {
      return "file://${_cacheDir.path}/${Global.instance.deviceId}";
    }
  }

  /// 将缓存路径转换为真实路径
  String converCachePathToRealPath(String cachePath) {
    return cachePath.replaceFirst("/cache", _cacheDir.path);
  }

  /// 获取 CachedNetworkImage 缓存的总大小
  Future<String> getCachedNetworkImageSize() async {
    var size = await DefaultCacheManager().store.getCacheSize();
    return DataSourceManagerInterface.formatBytes(size);
  }

  /// 清空图片缓存
  Future<void> clearNetworkImageCache() async {
    await DefaultCacheManager().emptyCache();
  }
}
