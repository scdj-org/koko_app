import 'package:collection/collection.dart';
import 'package:koko/models/entity/view_page_entity.dart';
import 'package:koko/routes/view_page_route.dart';

/// 扩展列表便于排序
extension ViewPageEntityListExtension on List<ViewPageEntity> {
  /// 名称排序
  Future<List<ViewPageEntity>> get sortByName async {
    final List<ViewPageEntity> dirs = [];
    final List<ViewPageEntity> files = [];

    for (final entity in this) {
      if (entity.isDir) {
        dirs.add(entity);
      } else {
        files.add(entity);
      }
    }

    dirs.sort(
      (a, b) => a.basename.toLowerCase().compareTo(b.basename.toLowerCase()),
    );
    files.sort((a, b) {
      var load = _checkLoadingTag(a, b);
      if (load != 0) {
        return load;
      }
      return a.basename.toLowerCase().compareTo(b.basename.toLowerCase());
    });

    return [...dirs, ...files];
  }

  /// 时间排序
  Future<List<ViewPageEntity>> get sortByDate async {
    final List<ViewPageEntity> list = [...this];

    list.sort((a, b) {
      var load = _checkLoadingTag(a, b);
      if (load != 0) {
        return load;
      }
      return b.dateTime!.compareTo(a.dateTime!);
    });

    return list;
  }

  /// 类型排序
  Future<List<ViewPageEntity>> get sortByType async {
    final List<ViewPageEntity> dirs = [];
    final List<ViewPageEntity> files = [];

    for (final entity in this) {
      if (entity.isDir) {
        dirs.add(entity);
      } else {
        files.add(entity);
      }
    }

    // 文件夹按名称排序
    dirs.sort(
      (a, b) => a.basename.toLowerCase().compareTo(b.basename.toLowerCase()),
    );
    // 文件按后缀名称排序
    files.sort((a, b) {
      var load = _checkLoadingTag(a, b);
      if (load != 0) {
        return load;
      }
      if (a.extension == null || a.extension!.isEmpty) {
        return 1;
      } else if (b.extension == null || b.extension!.isEmpty) {
        return -1;
      }

      return a.extension!.toLowerCase().compareTo(b.extension!.toLowerCase());
    });

    return [...dirs, ...files];
  }

  /// 大小排序
  Future<List<ViewPageEntity>> get sortBySize async {
    final List<ViewPageEntity> dirs = [];
    final List<ViewPageEntity> files = [];

    for (final entity in this) {
      if (entity.isDir) {
        dirs.add(entity);
      } else {
        files.add(entity);
      }
    }

    // 文件夹按名称排序
    dirs.sort(
      (a, b) => a.basename.toLowerCase().compareTo(b.basename.toLowerCase()),
    );
    // 文件按大小排序
    files.sort((a, b) {
      var load = _checkLoadingTag(a, b);
      if (load != 0) {
        return load;
      }
      return b.size!.compareTo(a.size!);
    });

    return [...dirs, ...files];
  }

  /// 查找 `entity` 应该插入的位置（保持顺序）
  Future<int> getInsertIndexByName(ViewPageEntity entity) async {
    return lowerBound(
      this,
      entity,
      compare: (a, b) {
        var load = _checkLoadingTag(a, b);
        if (load != 0) {
          return load;
        }
        // 文件夹在前
        if (a.isDir != b.isDir) {
          return a.isDir ? -1 : 1;
        }
        return a.basename.toLowerCase().compareTo(b.basename.toLowerCase());
      },
    );
  }

  Future<int> getInsertIndexByDate(ViewPageEntity entity) async {
    return lowerBound(
      this,
      entity,
      compare: (a, b) {
        var load = _checkLoadingTag(a, b);
        if (load != 0) {
          return load;
        }
        return b.dateTime!.compareTo(a.dateTime!);
      },
    );
  }

  Future<int> getInsertIndexByType(ViewPageEntity entity) async {
    return lowerBound(
      this,
      entity,
      compare: (a, b) {
        var load = _checkLoadingTag(a, b);
        if (load != 0) {
          return load;
        }
        // 文件夹在前
        if (a.isDir != b.isDir) {
          return a.isDir ? -1 : 1;
        }
        if (a.isDir && b.isDir) {
          return a.basename.toLowerCase().compareTo(b.basename);
        }
        return a.extension!.toLowerCase().compareTo(b.extension!.toLowerCase());
      },
    );
  }

  Future<int> getInsertIndexBySize(ViewPageEntity entity) async {
    return lowerBound(
      this,
      entity,
      compare: (a, b) {
        var load = _checkLoadingTag(a, b);
        if (load != 0) {
          return load;
        }
        // 文件夹在前
        if (a.isDir != b.isDir) {
          return a.isDir ? -1 : 1;
        }
        if (a.isDir && b.isDir) {
          return a.basename.toLowerCase().compareTo(b.basename);
        }
        if (a.size == null) {
          return 1;
        }
        if (b.size == null) {
          return -1;
        }
        return b.size!.compareTo(a.size!);
      },
    );
  }

  int _checkLoadingTag(ViewPageEntity a, ViewPageEntity b) {
    if (a.basename == ViewPageRoute.loadingTag) {
      return 1;
    }
    if (b.basename == ViewPageRoute.loadingTag) {
      return -1;
    }
    return 0;
  }
}
