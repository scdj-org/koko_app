import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:koko/common/application_cache_manager.dart';
import 'package:koko/common/epub_util/epub_stream_decoder.dart';
import 'package:koko/common/epub_util/zip_stream_decoder.dart';
import 'package:koko/common/global.dart';
import 'package:koko/enums/protocol_enum.dart';
import 'package:koko/interface/data_source_manager_interface.dart';
import 'package:koko/interface/koko_epub_data_source_interface.dart';
import 'package:koko/models/entity/call_back_result.dart';
import 'package:koko/models/entity/view_page_entity.dart';
import 'package:koko/models/epub_models/central_directory_entry.dart';
import 'package:koko/models/epub_models/koko_epub_book.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// 实现本地数据源
class LocalDataSourceManager
    implements DataSourceManagerInterface, KokoEpubDataSourceInterface {
  /// 单例实例
  ///
  /// XXX约定项目的所有单例以instance的形式获取
  static LocalDataSourceManager? _instance;
  static LocalDataSourceManager get instance =>
      _instance ??= LocalDataSourceManager._internal();
  LocalDataSourceManager._internal();
  // LocalDataSourceManager._internal() {
  //   _isRoot = true;
  //   // 提前加载
  //   getApplicationDocumentsDirectory().then((dir) {
  //     _currentDir = dir;
  //   });
  // }

  // /// 当前文件夹
  // Directory? _currentDir;

  // bool? _isRoot;

  /// 当前数据源的根目录
  String? _rootPath;

  @override
  ProtocolEnum get protocol => ProtocolEnum.local;

  @override
  Future<void> init() async {
    _rootPath =
        "${(await getApplicationDocumentsDirectory()).path}/Koko_Repository";
    var rootDir = Directory(_rootPath!);
    if (rootDir.existsSync()) {
      return;
    }
    rootDir.createSync(recursive: true);
  }

  @override
  String get rootPath => _rootPath!;

  @override
  Future<void> openFile(ViewPageEntity entity, BuildContext context) async {
    switch (entity.extension) {
      case ".epub":
        await Navigator.of(context).pushNamed(
          "epub_page_route",
          arguments: {
            "dataSource": protocol.protocolId,
            "entity": entity.toJson(),
          },
        );
        break;
      default:
        await OpenFilex.open(entity.absPath);
    }
  }

  @override
  Future<ViewPageEntity?> getParent(ViewPageEntity entity) async {
    if (entity.isRoot) {
      return null;
    }

    var parent = Directory(entity.absPath).parent;
    var isRoot = parent.path == rootPath;

    return ViewPageEntity(
      isRoot: isRoot,
      isDir: true,
      absPath: parent.path,
      basename: basenameWithoutExtension(parent.path),
      extension: extension(parent.path),
      dateTime: null,
      imageUint8: null,
    );
  }

  /// 检测该实体是否为文件夹
  @override
  Future<CallBackResult> isDir(ViewPageEntity entity) async {
    return CallBackResult(success: await Directory(entity.absPath).exists());
  }

  /// 获取文件数据流, entity是文件夹
  ///
  /// 支持分页加载
  @override
  Future<List<ViewPageEntity>> getDataFuture(
    ViewPageEntity entity, {
    bool paging = false,
    int page = 0,
    int pageSize = 20,
  }) async {
    //分页
    if (paging) {}
    var dir = Directory(entity.absPath);

    assert((await isDir(entity)).success!, "entity必须为文件夹");

    // 封装返回值
    List<FileSystemEntity> entities = await Global.instance.loadBalancer.run((
      dir,
    ) async {
      return await dir.list().toList();
    }, dir);
    List<Future<ViewPageEntity>> futureList = [];
    for (var entity in entities) {
      futureList.add(
        Future(() async {
          FileSystemEntityType type = await FileSystemEntity.type(entity.path);
          var item = ViewPageEntity(
            isRoot: false,
            isDir: type == FileSystemEntityType.directory,
            absPath: entity.path,
          );
          var result = await getInfo(item);
          return result.result as ViewPageEntity;
        }),
      );
    }
    return await Future.wait(futureList);
  }

  /// 给entity计算参数
  @override
  Future<CallBackResult> getInfo(ViewPageEntity entity) async {
    return await Global.instance.loadBalancer.run((entity) async {
      entity.basename = basenameWithoutExtension(entity.absPath);
      entity.extension = extension(entity.absPath).toLowerCase();
      entity.imageUint8 = null;
      if (await FileSystemEntity.isDirectory(entity.absPath)) {
        // 目录，不计算
        entity.size = null;
        entity.sizeDesc = "Folder";
        entity.dateTime = Directory(entity.absPath).statSync().modified;
        return CallBackResult.success(result: entity);
      } else {
        final file = File(entity.absPath);
        if (await file.exists()) {
          entity.dateTime = await file.lastModified();
          int fileSize = await file.length();
          entity.size = fileSize;
          entity.sizeDesc = DataSourceManagerInterface.formatBytes(fileSize);
          return CallBackResult.success(result: entity);
        } else {
          entity.size = null;
          entity.sizeDesc = "Unknown";
          return CallBackResult.failure(result: entity);
        }
      }
    }, entity);
  }

  /// 在当前目录新建文件/目录，部分数据源可能不支持，实现直接 throw 异常即可
  @override
  Future<CallBackResult> createFile(ViewPageEntity entity) async {
    try {
      assert(entity.absPath.isNotEmpty, "传入路径不能为空");

      final path = entity.absPath;

      if (entity.isDir) {
        // 创建文件夹
        final directory = Directory(path);
        await directory.create(recursive: true);
      } else {
        // 创建文件
        final file = File(path);
        assert(!await file.exists(), "文件已经存在了");
        await file.create(recursive: true);
      }

      return CallBackResult.success();
    } catch (e) {
      // TODO: 记录日志
      if (e is FileSystemException) {
        throw "创建失败，可能是因为同名文件夹";
      }
      rethrow;
      // return CallBackResult.failure();
    }
  }

  /// 移动多个文件(文件夹)，部分数据源可能不支持，实现直接 throw 异常即可
  ///
  /// 选中多个地址，并移动到目标目录
  @override
  Future<CallBackResult> moveFiles(
    List<ViewPageEntity> sourceEntities,
    ViewPageEntity targetDir,
  ) async {
    try {
      assert(targetDir.absPath.isNotEmpty, "传入路径不能为空");
      assert((await isDir(targetDir)).success!, "必须传入文件夹");

      final targetPath = targetDir.absPath;

      for (var entity in sourceEntities) {
        assert(entity.absPath.isNotEmpty, "传入路径不能为空");

        var sourcePath = entity.absPath;
        final fileName = basename(sourcePath);
        final destinationPath = '$targetPath/$fileName';

        // // TODO: 莫名其妙，临时解决方案，直接替换tmp
        // if (Platform.isIOS) {
        //   sourcePath = sourcePath.replaceFirst("/tmp/", "/Documents/");
        // }

        if (entity.isDir) {
          // 处理文件夹
          final sourceDir = Directory(sourcePath);

          assert(await sourceDir.exists(), "源文件需要不存在");
          await sourceDir.rename(destinationPath);
        } else {
          // 处理文件
          final sourceFile = File(sourcePath);

          assert(await sourceFile.exists(), "源文件不需要存在");
          await sourceFile.rename(destinationPath);
        }

        // abs也需要更新
        entity.absPath = destinationPath;
      }

      return CallBackResult.success();
    } catch (e) {
      rethrow;
      // return CallBackResult.failure();
    }
  }

  /// 复制文件
  @override
  Future<CallBackResult> importFiles(
    List<ViewPageEntity> sourceEntities,
    ViewPageEntity targetDir,
  ) async {
    try {
      assert(targetDir.absPath.isNotEmpty, "传入路径不能为空");
      assert((await isDir(targetDir)).success!, "必须传入文件夹");

      final targetPath = targetDir.absPath;

      for (var entity in sourceEntities) {
        assert(entity.absPath.isNotEmpty, "传入路径不能为空");

        final sourcePath = entity.absPath;
        final fileName = basename(sourcePath);
        final destinationPath = join(targetPath, fileName);

        if (entity.isDir) {
          // 复制文件夹
          await copyDirectory(
            Directory(sourcePath),
            Directory(destinationPath),
          );
        } else {
          // 复制文件
          final sourceFile = File(sourcePath);
          // 直接复制
          await sourceFile.copy(destinationPath);
        }

        // abs也需要复制
        entity.absPath = destinationPath;
      }
      return CallBackResult.success();
    } catch (e) {
      return CallBackResult.failure(result: e);
    }
  }

  /// 复制文件夹
  Future<CallBackResult> copyDirectory(
    Directory sourceDir,
    Directory targetDir,
  ) async {
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    await for (FileSystemEntity entity in sourceDir.list(recursive: true)) {
      /// 相对路径
      final relativePath = relative(entity.path, from: sourceDir.path);
      final newPath = join(targetDir.path, relativePath);

      if (entity is Directory) {
        await Directory(newPath).create(recursive: true);
      } else if (entity is File) {
        await entity.copy(newPath);
      }
    }
    return CallBackResult.success();
  }

  @override
  Future<CallBackResult> deleteFiles(List<ViewPageEntity> entities) async {
    try {
      for (var entity in entities) {
        assert(entity.absPath.isNotEmpty, "路径不能为空");

        final path = entity.absPath;

        if (entity.isDir) {
          // 删除文件夹（包括其内部所有文件）
          final dir = Directory(path);
          assert(await dir.exists(), "传入参数与实际不符");
          await dir.delete(recursive: true);
        } else {
          // 删除文件
          final file = File(path);
          assert(await file.exists(), "文件不存在");
          await file.delete();
        }
      }

      return CallBackResult.success();
    } catch (e) {
      // TODO:异常处理
      return CallBackResult.failure(result: e);
    }
  }

  @override
  Future<ViewPageEntity> renameFile(
    ViewPageEntity sourceEntity,
    ViewPageEntity targetEntity,
  ) async {
    if (sourceEntity.isDir) {
      await Directory(sourceEntity.absPath).rename(targetEntity.absPath);
    } else {
      await File(sourceEntity.absPath).rename(targetEntity.absPath);
    }
    targetEntity = (await getInfo(targetEntity)).result as ViewPageEntity;
    return targetEntity;
  }

  /// 选取多个文件，注：返回最简数据，即只有isDir，is
  @override
  Future<List<ViewPageEntity>> pickUpFiles(
    bool isDir, {
    List<String>? allowedExtensions,
  }) async {
    // 选择文件夹
    if (isDir) {
      var path = await FilePicker.platform.getDirectoryPath();
      if (path == null) {
        return [];
      }
      return [
        ViewPageEntity(isRoot: path == rootPath, isDir: true, absPath: path),
      ];
    }

    // 选择文件
    FilePickerResult? result;
    if (allowedExtensions == null) {
      result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        allowCompression: false,
      );
    } else {
      result = await FilePicker.platform.pickFiles(
        allowCompression: false,
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );
    }
    // 用户取消选择或者没有选
    if (result == null || result.count == 0) {
      return [];
    }
    return result.paths.map<ViewPageEntity>((path) {
      return ViewPageEntity(isRoot: false, isDir: false, absPath: path!);
    }).toList();
  }

  @override
  Future<CallBackResult> flushCache() async {
    // TODO: 实现缓存
    return CallBackResult.success();
  }

  @override
  Widget getThumbnail(ViewPageEntity entity, Color backgroundColor, int width) {
    var radius = width * 0.1;
    Widget child;
    switch (entity.extension) {
      // 图片类型
      case ".jpg":
      case ".png":
      case ".jpeg":
      case ".webp":
      case ".bmp":
      case ".gif":
      case ".svg":
        child = FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: radius,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white, // 背景颜色
                ),
                child: Image(
                  image: ResizeImage(
                    FileImage(File(entity.absPath)),
                    width: width, // 缩略
                  ),
                ),
              ),
            ),
          ),
        );
        break;
      default:
        child = Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: radius,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: FittedBox(
            fit: BoxFit.contain, // 铺满
            alignment: Alignment.center,
            child:
                entity.isDir
                    ? const Icon(Icons.folder, color: Colors.amber)
                    : DataSourceManagerInterface.getFileIcon(entity.extension),
          ),
        );
    }
    return Container(
      margin: EdgeInsets.all(8.0),
      child: AspectRatio(aspectRatio: 3 / 4, child: child),
    );
  }

  @override
  String? epubBasePath;

  @override
  Future<Uint8List?> getByteData(
    String href,
    Map<String, CentralDirectoryEntry> centralDirectoryMap, {
    bool needBack = true,
  }) async {
    if ((await ApplicationCacheManager.instance.hasCachingFile(
      "$epubBasePath/$href",
    ))) {
      // 不需要返回
      if (needBack == false) {
        return null;
      }
      return ApplicationCacheManager.instance.readFile("$epubBasePath/$href");
    }

    var entry = centralDirectoryMap[href];
    if (entry == null) {
      throw ("没有$href文件");
    }

    var zipData = await Global.instance.loadBalancer.run((arguments) async {
      var path = arguments[0] as String;
      var entry = arguments[1] as CentralDirectoryEntry;
      var fileStream = File(
        path,
      ).openRead(entry.offset, entry.offset + entry.lenth);
      var zipData = await fileStream.fold<Uint8List>(
        Uint8List(0),
        (previous, element) => Uint8List.fromList([...previous, ...element]),
      );
      return zipData;
    }, ["$_rootPath/$epubBasePath", entry]);

    var data = await ZipStreamDecoder.instance.extractZipEntry(zipData);
    // 写入缓存目录
    await ApplicationCacheManager.instance.writeFile(
      "$epubBasePath/$href",
      data,
    );

    return data;
  }

  @override
  Future<int> getFileSize() async {
    var file = File("$_rootPath/$epubBasePath");
    return file.length();
  }

  @override
  Future<KokoEpubBook> initBook(
    Map<String, CentralDirectoryEntry> centralDirectoryMap,
  ) async {
    KokoEpubBook book = KokoEpubBook();

    /// 获取epub信息
    Uint8List byteList;
    byteList =
        (await getByteData("META-INF/container.xml", centralDirectoryMap))!;
    String? contentOpfPath = EpubStreamDecoder.instance.getOpfPath(byteList);

    /// 解析opf文件
    byteList = (await getByteData(contentOpfPath!, centralDirectoryMap))!;
    book = EpubStreamDecoder.instance.readBook(byteList, contentOpfPath);

    /// 解析ncx文件
    byteList = (await getByteData(book.ncxItem!.href, centralDirectoryMap))!;
    book.ncx = EpubStreamDecoder.instance.loadNCX(byteList, book.ncxItem!.href);

    return book;
  }

  @override
  /// 本地文件解压
  Future<Map<String, CentralDirectoryEntry>> initCentralDirectoryMap(
    int fileSize,
  ) async {
    // 有缓存了
    if ((await ApplicationCacheManager.instance.hasCachingFile(
      "$epubBasePath/koko_central_direcotry",
    ))) {
      var zipData = await ApplicationCacheManager.instance.readFile(
        "$epubBasePath/koko_central_direcotry",
      );
      return ZipStreamDecoder.instance.parseZipDirectory(zipData!, fileSize);
    }

    // 读取文件末尾64KB
    var zipData = await Global.instance.loadBalancer.run((arguments) async {
      var path = arguments;
      var fileStream = File(path).openRead(fileSize - 65536);
      var zipData = await fileStream.fold<Uint8List>(
        Uint8List(0),
        (previous, element) => Uint8List.fromList([...previous, ...element]),
      );
      return zipData;
    }, "$_rootPath/$epubBasePath");

    // 缓存
    await ApplicationCacheManager.instance.writeFile(
      "$epubBasePath/koko_central_direcotry",
      zipData,
    );
    return ZipStreamDecoder.instance.parseZipDirectory(zipData, fileSize);
  }

  @override
  String get realPath =>
      "${ApplicationCacheManager.instance.currentCachePath}/$epubBasePath";

  @override
  String get requestPath =>
      "${ApplicationCacheManager.instance.requestCachePath}/$epubBasePath";
}
