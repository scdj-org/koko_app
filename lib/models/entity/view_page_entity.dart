import 'dart:typed_data';

/// 构成页面的组件
class ViewPageEntity {
  ViewPageEntity({
    required this.isRoot,
    required this.isDir,
    required this.absPath,
    this.basename = "",
    this.extension,
    this.sizeDesc,
    this.size,
    this.dateTime,
    this.imageUint8,
  });

  /// 是否为根目录
  bool isRoot;

  /// 是否为文件夹
  bool isDir;

  /// 真实路径, 该值不能为null
  String absPath;

  /// 名字(无后缀)
  String basename;

  /// 后缀，如果为文件夹则为null
  String? extension;

  /// 大小(描述，类似 1.21MB)，如果为文件夹则为null
  String? sizeDesc;

  /// 大小
  int? size;

  /// 日期
  DateTime? dateTime;

  /// 缩略图(可能并非缩略)
  Future<Uint8List?>? imageUint8;

  /// 外界展示名字，showExtension为true时带后缀
  String showName({bool showExtension = false}) {
    // 名字为.xxx
    if (basename == "") {
      return ".$extension";
    }
    if (showExtension == true) {
      return "$basename$extension";
    }
    return basename;
  }

  /// 序列化为 JSON
  Map<String, dynamic> toJson() {
    return {
      'isRoot': isRoot,
      'isDir': isDir,
      'absPath': absPath,
      'basename': basename,
      'extension': extension,
      'sizeDesc': sizeDesc,
      'size': size,
      'dateTime': dateTime?.toIso8601String(),
      'imageUint8': null, // 无法直接序列化 Future<Uint8List?>
    };
  }

  /// 反序列化 JSON
  factory ViewPageEntity.fromJson(Map<String, dynamic> json) {
    return ViewPageEntity(
      isRoot: json['isRoot'] as bool,
      isDir: json['isDir'] as bool,
      absPath: json['absPath'] as String,
      basename: json['basename'] as String? ?? "",
      extension: json['extension'] as String?,
      sizeDesc: json['sizeDesc'] as String?,
      size: json['size'] as int?,
      dateTime: json['dateTime'] != null ? DateTime.parse(json['dateTime']) : null,
      imageUint8: null, // Future<Uint8List?> 需要手动加载
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ViewPageEntity) return false;
    return absPath == other.absPath && isDir == other.isDir;
  }

  @override
  int get hashCode => Object.hash(absPath, isDir);
}
