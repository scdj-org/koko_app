import 'dart:typed_data';

import 'package:koko/models/epub_models/central_directory_entry.dart';
import 'package:koko/models/epub_models/koko_epub_book.dart';

/// 实现epub阅读的相关接口
abstract interface class KokoEpubDataSourceInterface {
  /// 获取相对于当前文件夹根目录的basePath
  String? get epubBasePath;

  /// 设置相对于当前文件夹根目录的basePath
  ///
  /// **加载epub先设置这个路径**
  set epubBasePath(String? basePath);

  /// 初始化文件中心头表，文件路径-文件中心头
  Future<Map<String, CentralDirectoryEntry>> initCentralDirectoryMap(
    int fileSize,
  );

  /// 初始化epubbook
  Future<KokoEpubBook> initBook(
    Map<String, CentralDirectoryEntry> centralDirectoryMap,
  );

  /// 获取href的字节流数据
  ///
  /// needBack为false时，该接口不返回值，用于性能优化，
  /// 这样有缓存的情况就不用去读一遍数据了，needBack为true时返回值不能为null
  ///
  /// **实现接口支持流式阅读**
  /// 
  /// **href是对于epub书籍的相对路径**
  Future<Uint8List?> getByteData(
    String href,
    Map<String, CentralDirectoryEntry> centralDirectoryMap, {
    bool needBack = true,
  });

  /// 获取请求路径
  String get requestPath;

  /// 获取真实路径
  String get realPath;

  ///TODO:不能有这个接口，先mock一下，后面更改
  Future<int> getFileSize();
}
