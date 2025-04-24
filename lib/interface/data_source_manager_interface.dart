import 'dart:math';

import 'package:flutter/material.dart';
import 'package:koko/common/data_source_manager/local_data_source_manager.dart';
import 'package:koko/common/data_source_manager/webdav_data_source_manager.dart';
import 'package:koko/enums/protocol_enum.dart';
import 'package:koko/models/entity/call_back_result.dart';
import 'package:koko/models/entity/view_page_entity.dart';
import 'package:webdav_client/webdav_client.dart';

/// 数据源管理器接口，本地、webdav以及其他数据源管理器需要实现这个接口
///
/// page路由页面兼容该接口即可实现兼容不同的数据源
///
/// String? path传参实现的时候如果path为null，则采用当前目录path
///
/// 该接口的实现类简易建议采用单例模式
abstract interface class DataSourceManagerInterface {
  // 统计文件大小
  static const int base = 1024;
  static const List<String> suffix = ['B', 'KB', 'MB', 'GB', 'TB'];
  static const List<int> powBase = [
    1,
    1024,
    1048576,
    1073741824,
    1099511627776,
  ];

  /// 格式化文件大小
  static String formatBytes(int bytes, [int precision = 1]) {
    final base = (bytes == 0) ? 0 : (log(bytes) / log(1024)).floor();
    final size = bytes / powBase[base];
    final formattedSize = size.toStringAsFixed(precision);
    return '$formattedSize ${suffix[base]}';
  }

  /// 数据源和协议有一一对应关系
  static DataSourceManagerInterface getDataSourceManagerFromId(int id) {
    var protocol = ProtocolEnum.fromProtocolId(id);
    if (protocol == null) {
      throw "不支持的数据源";
    }
    switch (protocol) {
      case ProtocolEnum.local:
        return LocalDataSourceManager.instance;
      case ProtocolEnum.webdav:
      case ProtocolEnum.smb:
        return WebdavDataSourceManager.instance;
    }
  }

  /// 格式化uri
  static Uri formateUri(String rawPath) {
    var path = encodeSpecialChars(rawPath);
    return Uri.parse(path).replace(pathSegments: Uri.parse(path).pathSegments);
  }

  /// 格式化path，前减后加
  static String resolvePath(ViewPageEntity entity) {
    String path = "";
    if (!entity.absPath.endsWith("/") && entity.absPath.startsWith("/")) {
      path = "${entity.absPath}/".replaceFirst("/", "");
    } else if (entity.absPath.startsWith("/")) {
      path = entity.absPath.replaceFirst("/", "");
    } else if (!entity.absPath.endsWith("/")) {
      path = "${entity.absPath}/";
    } else {
      path = entity.absPath;
    }
    return path;
  }

  static String removeLastSlash(String path) {
    return path.endsWith('/') ? path.substring(0, path.length - 1) : path;
  }

  /// 解码url
  static String decodeComponent(String path) {
    if (!path.contains('%')) return path;

    final encodedPattern = RegExp(r'%[0-9A-Fa-f]{2}');
    if (!encodedPattern.hasMatch(path)) {
      return path;
    }

    try {
      return Uri.decodeComponent(path);
    } catch (_) {
      return path;
    }
  }

  /// 去除 URL 中的 scheme（如 https://、file://），保留剩余部分
  static String stripUrlScheme(String url) {
    final uri = Uri.tryParse(url);

    if (uri == null || uri.scheme.isEmpty) {
      // 无法解析或没有 scheme，直接返回原始内容
      return url;
    }

    final buffer = StringBuffer();

    // 如果有主机名（如 http/https）
    if (uri.hasAuthority) {
      buffer.write(uri.authority); // example.com:8080
    }

    // 拼接路径
    buffer.write(uri.path);

    // 拼接查询参数
    if (uri.hasQuery) {
      buffer.write('?${uri.query}');
    }

    // 拼接锚点
    if (uri.fragment.isNotEmpty) {
      buffer.write('#${uri.fragment}');
    }

    return buffer.toString();
  }

  /// 获取协议id
  ProtocolEnum get protocol;

  /// 初始化,在global里调用
  Future<void> init();

  /// 获取根目录
  String get rootPath;

  /// 打开文件
  Future<void> openFile(ViewPageEntity entity, BuildContext context);

  /// 获取父entity
  ///
  /// 如果是根目录，直接返回null
  Future<ViewPageEntity?> getParent(ViewPageEntity entity);

  /// 检测该实体是否为文件夹
  Future<CallBackResult> isDir(ViewPageEntity entity);

  /// 获取文件数据流, entity是文件夹
  ///
  /// 支持分页加载
  Future<List<ViewPageEntity>> getDataFuture(
    ViewPageEntity entity, {
    bool paging = false,
    int page = 0,
    int pageSize = 20,
  });

  /// 获取entity除了三个必要参数的其他信息，填入entity中
  Future<CallBackResult> getInfo(ViewPageEntity entity);

  /// 在当前目录新建文件/目录，部分数据源可能不支持，实现直接throw异常即可
  Future<CallBackResult> createFile(ViewPageEntity entity);

  /// 移动多个文件(文件夹)，部分数据源可能不支持，实现直接throw异常即可
  ///
  /// 选中多个地址，并移动到目标目录
  Future<CallBackResult> moveFiles(
    List<ViewPageEntity> sourceEntities,
    ViewPageEntity targetDir,
  );

  /// 导入（复制）多个文件(文件夹)，部分数据源可能不支持，实现直接throw异常即可
  ///
  /// 选中多个地址，并复制到目标目录
  Future<CallBackResult> importFiles(
    List<ViewPageEntity> sourceEntities,
    ViewPageEntity targetDir,
  );

  /// 删除多个文件(文件夹)，部分数据源可能不支持，实现直接throw异常即可
  Future<CallBackResult> deleteFiles(List<ViewPageEntity> entities);

  /// 重命名, 返回新的entity（带信息）
  Future<ViewPageEntity> renameFile(
    ViewPageEntity sourceEntity,
    ViewPageEntity targetEntity,
  );

  /// 选取多个文件，注：返回最简数据，即只有isDir，is
  Future<List<ViewPageEntity>> pickUpFiles(
    bool isDir, {
    List<String> allowedExtensions,
  });

  /// 获取缩略图
  Widget getThumbnail(ViewPageEntity entity, Color backgroundColor, int width);

  /// 刷新操作，如果有缓存必须实现，没有缓存直接return即可
  Future<CallBackResult> flushCache();

  //----------------------------------------
  // 文件图标配置
  //----------------------------------------

  /// 默认文件图标（用于未匹配的类型）
  static final Icon defaultFileIcon = Icon(
    Icons.insert_drive_file,
    color: Colors.grey[600],
  );

  /// 获取后缀对应的图标
  static Icon getFileIcon(String? extension) {
    if (DataSourceManagerInterface.supportedTypesIconMap.containsKey(
      extension,
    )) {
      return DataSourceManagerInterface.supportedTypesIconMap[extension]!;
    }
    return defaultFileIcon;
  }

  /// 文件类型对应图标映射表（扩展名 -> 图标）
  static final Map<String, Icon> supportedTypesIconMap = {
    // 图片类型
    ".jpg": Icon(Icons.image, color: Colors.blue[400]),
    ".png": Icon(Icons.image, color: Colors.blue[400]),
    ".jpeg": Icon(Icons.image, color: Colors.blue[400]),
    ".webp": Icon(Icons.image, color: Colors.blue[400]),
    ".bmp": Icon(Icons.image, color: Colors.blue[400]),
    ".gif": Icon(Icons.gif, color: Colors.blue[400]),
    ".svg": Icon(Icons.image_search, color: Colors.blue[400]),

    // 文档类型
    ".doc": Icon(Icons.description, color: Colors.deepPurple),
    ".docx": Icon(Icons.description, color: Colors.deepPurple),
    ".txt": Icon(Icons.text_fields, color: Colors.grey[700]),
    ".rtf": Icon(Icons.text_format, color: Colors.deepPurple),

    // 音频类型
    ".mp3": Icon(Icons.audiotrack, color: Colors.orange[600]),
    ".wav": Icon(Icons.audiotrack, color: Colors.orange[600]),
    ".flac": Icon(Icons.audiotrack, color: Colors.orange[600]),
    ".aac": Icon(Icons.audiotrack, color: Colors.orange[600]),

    // 视频类型
    ".mp4": Icon(Icons.videocam, color: Colors.red[600]),
    ".avi": Icon(Icons.videocam, color: Colors.red[600]),
    ".mov": Icon(Icons.videocam, color: Colors.red[600]),
    ".mkv": Icon(Icons.videocam, color: Colors.red[600]),
    ".flv": Icon(Icons.videocam, color: Colors.red[600]),

    // 压缩包类型
    ".zip": Icon(Icons.archive, color: Colors.brown[600]),
    ".rar": Icon(Icons.archive, color: Colors.brown[600]),
    ".7z": Icon(Icons.archive, color: Colors.brown[600]),
    ".tar": Icon(Icons.archive, color: Colors.brown[600]),
    ".gz": Icon(Icons.archive, color: Colors.brown[600]),

    // 代码文件
    ".dart": Icon(Icons.code, color: Colors.green[700]),
    ".java": Icon(Icons.code, color: Colors.green[700]),
    ".py": Icon(Icons.code, color: Colors.green[700]),
    ".cpp": Icon(Icons.code, color: Colors.green[700]),
    ".js": Icon(Icons.code, color: Colors.green[700]),
    ".html": Icon(Icons.code, color: Colors.green[700]),
    ".css": Icon(Icons.code, color: Colors.green[700]),
    ".json": Icon(Icons.code, color: Colors.green[700]),

    // 电子书
    ".epub": Icon(Icons.book, color: Colors.purple[300]),
    ".mobi": Icon(Icons.book, color: Colors.purple[300]),
    ".pdf": Icon(Icons.picture_as_pdf, color: Colors.red[700]),

    // 表格数据
    ".xls": Icon(Icons.table_chart, color: Colors.green[900]),
    ".xlsx": Icon(Icons.table_chart, color: Colors.green[900]),
    ".csv": Icon(Icons.table_chart, color: Colors.green[900]),

    // 演示文稿
    ".ppt": Icon(Icons.slideshow, color: Colors.pink[400]),
    ".pptx": Icon(Icons.slideshow, color: Colors.pink[400]),

    // 可执行文件
    ".exe": Icon(Icons.settings_applications, color: Colors.grey[800]),
    ".dmg": Icon(Icons.settings_applications, color: Colors.grey[800]),
    ".apk": Icon(Icons.android, color: Colors.green[500]),

    // 配置文件
    ".yml": Icon(Icons.settings, color: Colors.grey[600]),
    ".yaml": Icon(Icons.settings, color: Colors.grey[600]),
    ".xml": Icon(Icons.settings, color: Colors.grey[600]),
    ".ini": Icon(Icons.settings, color: Colors.grey[600]),

    // 数据库文件
    ".sql": Icon(Icons.storage, color: Colors.blueGrey),
    ".db": Icon(Icons.storage, color: Colors.blueGrey),

    // 日志文件
    ".log": Icon(Icons.assignment, color: Colors.brown[400]),

    // 字体文件
    ".ttf": Icon(Icons.font_download, color: Colors.deepOrange[600]),
    ".otf": Icon(Icons.font_download, color: Colors.deepOrange[600]),

    // 其他常见类型
    ".md": Icon(Icons.text_snippet, color: Colors.blue[900]),
  };
}
