import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:koko/common/application_cache_manager.dart';
import 'package:koko/common/custom_image_cache_manager.dart';
import 'package:koko/common/epub_util/epub_stream_decoder.dart';
import 'package:koko/common/epub_util/zip_stream_decoder.dart';
import 'package:koko/common/global.dart';
import 'package:koko/enums/protocol_enum.dart';
import 'package:koko/interface/data_source_manager_interface.dart';
import 'package:koko/interface/koko_epub_data_source_interface.dart';
import 'package:koko/l10n/l10n.dart';
import 'package:koko/models/entity/call_back_result.dart';
import 'package:koko/models/epub_models/central_directory_entry.dart';
import 'package:koko/models/epub_models/koko_epub_book.dart';
import 'package:koko/models/entity/view_page_entity.dart';
import 'package:koko/widgets/overlay/loading_dialog.dart';
import 'package:koko/widgets/overlay/status_toast.dart';
import 'package:open_filex/open_filex.dart';
import 'package:webdav_client/webdav_client.dart';
import 'package:path/path.dart' as p;

/// webdav数据源管理
class WebdavDataSourceManager
    implements DataSourceManagerInterface, KokoEpubDataSourceInterface {
  /// 单例实例
  ///
  /// XXX约定项目的所有单例以instance的形式获取
  static WebdavDataSourceManager? _instance;
  static WebdavDataSourceManager get instance =>
      _instance ??= WebdavDataSourceManager._internal();
  WebdavDataSourceManager._internal();

  /// webdav客户端
  Client? _client;

  /// 根目录
  String _rootPath = "";

  @override
  String get rootPath => _rootPath.startsWith("/") ? _rootPath : "/$_rootPath";

  @override
  ProtocolEnum get protocol => ProtocolEnum.webdav;

  String? _auth;

  bool? _extraApi;

  @override
  Future<void> init({
    String uri = "",
    String rootPath = "",
    int? port,
    String user = "",
    String password = "",
  }) async {
    _auth = null;
    _extraApi = null;
    if (uri.isEmpty) return;
    if (!_rootPath.startsWith("/")) {
      _rootPath = "/$rootPath";
    } else {
      _rootPath = rootPath;
    }
    var url = "$uri${port == null ? "" : ":$port"}";
    if (user.isNotEmpty) {
      _auth = "Basic ${base64Encode(utf8.encode("$user:$password"))}";
    } else {
      _auth = null;
    }
    _client = newClient(url, user: user, password: password, debug: false)
      ..setHeaders({"accept-charset": "utf-8"});
    // 是否为优化服务器
    try {
      _client?.c
          .get("$url/koko/ping")
          .then((res) {
            var data = res.data as Map<String, dynamic>;
            if (data["message"] == "pong") {
              _extraApi = true;
            }
          })
          .onError((error, stackTrace) {
            if (kDebugMode) {
              debugPrint("不是优化服务器");
            }
            _extraApi = false;
          });
    } catch (e) {
      return;
    }
  }

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
      case ".mp4":
      case ".mov":
      case ".mkv":
      case ".avi":
      case ".flv":
        var path = "${_client!.uri}${entity.absPath}";
        await Navigator.of(context).pushNamed(
          "video_player_route",
          arguments: {
            "url": DataSourceManagerInterface.formateUri(path),
            "headers": _auth != null ? {"Authorization": _auth!} : {},
          },
        );
        break;
      case ".mp3":
      case ".aac":
      case ".wav":
      case ".flac":
        var path = "${_client!.uri}${entity.absPath}";
        await Navigator.of(context).pushNamed(
          "music_player_route",
          arguments: {
            "url": DataSourceManagerInterface.formateUri(path).toString(),
            "headers": _auth != null ? {"Authorization": _auth!} : {},
          },
        );
        break;
      case ".jpg":
      case ".jpeg":
      case ".png":
      case ".webp":
      case ".bmp":
        var path = "${_client!.uri}${entity.absPath}";
        await Navigator.of(context).pushNamed(
          "photo_view_route",
          arguments: {
            "url": DataSourceManagerInterface.formateUri(path).toString(),
            "headers": _auth != null ? {"Authorization": _auth!} : {},
          },
        );
        break;
      default:
        var entityPath = "";
        if (entity.absPath.startsWith("/")) {
          entityPath = entity.absPath.replaceFirst("/", "");
        } else {
          entityPath = entity.absPath;
        }
        var savePath =
            "${ApplicationCacheManager.instance.cacheDir.path}/${Global.instance.deviceId}/$entityPath";

        /// 已经缓存过了
        if (await ApplicationCacheManager.instance.hasCachingFile(entityPath)) {
          OpenFilex.open(savePath).onError((error, stackTrace) {
            if (context.mounted) {
              StatusToast.show(
                context: context,
                message: error.toString(),
                isSuccess: false,
              );
            }
            return OpenResult(
              type: ResultType.error,
              message: error.toString(),
            );
          });
          return;
        }

        CancelToken cancelToken = CancelToken();
        ValueNotifier<String> progress = ValueNotifier("");
        if (context.mounted) {
          await LoadingDialog.show(
            context: context,
            message: AppLocalizations.of(context).waitingDisplay,
            progressBarColor: Theme.of(context).primaryColor,
            progressBarStyle: ProgressBarStyle.circular,
            timeout: Duration(hours: 24),
            onCancel: () {
              cancelToken.cancel();
              progress.dispose();
            },
            headerWidget: ValueListenableBuilder(
              valueListenable: progress,
              builder: (context, value, child) {
                return Text(value);
              },
            ),
            task: (updateProgress) async {
              int totalSize = 0;
              await _client!.read2File(
                entity.absPath,
                savePath,
                onProgress: (count, total) {
                  updateProgress!(100 * count / total);
                  if (total != totalSize) {
                    totalSize = total;
                  }
                  progress.value =
                      "${DataSourceManagerInterface.formatBytes(count)}/${DataSourceManagerInterface.formatBytes(total)}";
                },
                cancelToken: cancelToken,
              );
              ApplicationCacheManager.instance.addCacheSize(totalSize);
              OpenFilex.open(savePath).onError((error, stackTrace) {
                if (context.mounted) {
                  StatusToast.show(
                    context: context,
                    message: error.toString(),
                    isSuccess: false,
                  );
                }
                return OpenResult(
                  type: ResultType.error,
                  message: error.toString(),
                );
              });
              progress.dispose();
              return CallBackResult.success();
            },
          );
        }
    }
  }

  @override
  Future<CallBackResult> importFiles(
    List<ViewPageEntity> sourceEntities,
    ViewPageEntity targetDir,
  ) {
    // TODO: implement copyFiles
    throw UnimplementedError();
  }

  @override
  Future<CallBackResult> createFile(ViewPageEntity entity) async {
    try {
      assert(entity.absPath.isNotEmpty, "传入路径不能为空");
      var path = entity.absPath;
      if (entity.isDir) {
        await _client!.mkdir(path);
      } else {
        await _client!.write(path, Uint8List(0));
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

  @override
  Future<CallBackResult> deleteFiles(List<ViewPageEntity> entities) async {
    try {
      for (var entity in entities) {
        assert(entity.absPath.isNotEmpty, "路径不能为空");
        var path = entity.absPath;
        if (!path.endsWith("/")) path += "/";
        await _client!.remove(path);
      }
      return CallBackResult.success();
    } catch (e) {
      // TODO:异常处理
      return CallBackResult.failure(result: e);
    }
  }

  @override
  Future<CallBackResult> flushCache() async {
    // TODO: 实现缓存
    return CallBackResult.success();
  }

  @override
  Future<List<ViewPageEntity>> getDataFuture(
    ViewPageEntity entity, {
    bool paging = false,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      // 分页之后再说
      if (paging) {}
      List<File> list = await _client!.readDir(entity.absPath);
      return list.map((file) {
        if (kDebugMode) {
          debugPrint(file.path);
        }
        return ViewPageEntity(
          absPath: file.path == null ? "" : file.path!,
          isRoot: false,
          isDir: file.isDir ?? false,
          basename: p.basenameWithoutExtension(file.name ?? ""),
          extension: p.extension(file.name ?? ""),
          size: file.size,
          sizeDesc:
              file.size != null
                  ? DataSourceManagerInterface.formatBytes(file.size!)
                  : null,
          dateTime: file.mTime,
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CallBackResult> getInfo(ViewPageEntity entity) async {
    try {
      var file = await _client!.readProps(entity.absPath);
      return CallBackResult.success(
        result:
            entity
              ..basename = p.basenameWithoutExtension(file.name ?? "")
              ..extension = p.extension(file.name ?? "")
              ..size = file.size
              ..sizeDesc =
                  file.size != null
                      ? DataSourceManagerInterface.formatBytes(file.size!)
                      : null
              ..dateTime = file.mTime,
      );
    } catch (e) {
      return CallBackResult.failure(result: e);
    }
  }

  @override
  Future<ViewPageEntity?> getParent(ViewPageEntity entity) async {
    if (entity.isRoot) return null;
    var parentUrl = Directory(entity.absPath).parent.path;
    bool isRoot = false;
    if (parentUrl == rootPath || parentUrl == "." || parentUrl == "/") {
      isRoot = true;
    }
    try {
      return ViewPageEntity(
        absPath: parentUrl,
        isRoot: isRoot,
        isDir: true,
        basename: parentUrl,
        extension: "",
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CallBackResult> isDir(ViewPageEntity entity) async {
    return await getInfo(entity);
  }

  @override
  Future<CallBackResult> moveFiles(
    List<ViewPageEntity> sourceEntities,
    ViewPageEntity targetDir,
  ) async {
    String newDir = DataSourceManagerInterface.resolvePath(targetDir);
    try {
      List<Future<void>> futureList = [];
      for (var entity in sourceEntities) {
        String oldPath = DataSourceManagerInterface.resolvePath(entity);
        String newPath = newDir + p.basename(entity.absPath);
        futureList.add(
          _client!.rename(oldPath, newPath, false).then((v) {
            entity.absPath = newPath;
          }),
        );
      }
      await Future.wait(futureList);
      return CallBackResult.success();
    } catch (e) {
      return CallBackResult.failure(result: e);
    }
  }

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
  Future<ViewPageEntity> renameFile(
    ViewPageEntity sourceEntity,
    ViewPageEntity targetEntity,
  ) async {
    var oldPath = p.normalize(sourceEntity.absPath);
    var newPath = p.normalize(targetEntity.absPath);
    await _client!.rename(oldPath, newPath, true);
    return (await getInfo(targetEntity)).result as ViewPageEntity;
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
        var url = DataSourceManagerInterface.removeLastSlash(
          encodeSpecialChars(
            (_extraApi == true
                    ? "${_client!.uri}koko/sb/getCompressPicture/"
                    : _client!.uri) +
                DataSourceManagerInterface.resolvePath(entity),
          ),
        );
        child = FittedBox(
          alignment: Alignment.bottomCenter,
          fit: BoxFit.contain,
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
                child: CachedNetworkImage(
                  cacheManager: CustomImageCacheManager(),
                  memCacheWidth: width,
                  // 存720p保证预览图的清晰度
                  maxWidthDiskCache: 720,
                  httpHeaders: _auth != null ? {"Authorization": _auth!} : {},
                  imageUrl: url, // 网络图片 URL
                  progressIndicatorBuilder:
                      (context, url, progress) => Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(24.0),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: progress.progress,
                              strokeWidth: 2.0,
                            ),
                            Transform.scale(
                              scale: 0.7,
                              child: Text(
                                "${((progress.progress ?? 0) * 100).toInt()}%",
                              ),
                            ),
                          ],
                        ),
                      ),
                  errorListener: (value) async {
                    CustomImageCacheManager().runningResizes.remove(
                      CustomImageCacheManager().getResizeKey(
                        url,
                        maxWidth: 720,
                      ),
                    );
                    // TODO: 记录日志
                    if (kDebugMode) {
                      debugPrint(value.toString());
                    }
                  },
                  errorWidget:
                      (context, url, error) => Container(
                        color: Colors.grey[300],
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.broken_image,
                          size: 40,
                          color: Colors.grey,
                        ),
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
                blurRadius: 6,
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
      padding: EdgeInsets.all(8.0),
      child: AspectRatio(aspectRatio: 3 / 4, child: child),
    );
  }

  String? _epubBasePath;

  @override
  String? get epubBasePath => _epubBasePath;

  @override
  set epubBasePath(String? path) {
    if (path != null && path.startsWith("/")) {
      _epubBasePath = path.replaceFirst("/", "");
    } else {
      _epubBasePath = path;
    }
  }

  @override
  Future<Uint8List?> getByteData(
    String href,
    Map<String, CentralDirectoryEntry> centralDirectoryMap, {
    bool needBack = true,
  }) async {
    if ((await ApplicationCacheManager.instance.hasCachingFile(
      "$rootPath/$epubBasePath/$href",
    ))) {
      // 不需要返回
      if (needBack == false) {
        return null;
      }
      return ApplicationCacheManager.instance.readFile(
        "$rootPath/$epubBasePath/$href",
      );
    }
    var entry = centralDirectoryMap[href];
    if (entry == null) {
      throw ("没有$href文件");
    }
    _client!.setHeaders({
      "range": "bytes=${entry.offset}-${entry.offset + entry.lenth - 1}",
    });
    var res = await _client!.read("$rootPath/$epubBasePath");
    var data = await ZipStreamDecoder.instance.extractZipEntry(
      Uint8List.fromList(res),
    );
    // 写入缓存目录
    await ApplicationCacheManager.instance.writeFile(
      "$rootPath/$epubBasePath/$href",
      data,
    );

    return data;
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
  Future<Map<String, CentralDirectoryEntry>> initCentralDirectoryMap(
    int fileSize,
  ) async {
    // 如果有缓存就不走网络
    if ((await ApplicationCacheManager.instance.hasCachingFile(
      "$rootPath/$epubBasePath/koko_central_direcotry",
    ))) {
      var zipData = await ApplicationCacheManager.instance.readFile(
        "$rootPath/$epubBasePath/koko_central_direcotry",
      );
      return ZipStreamDecoder.instance.parseZipDirectory(zipData!, fileSize);
    }

    /// 获取epub信息
    // var prop = await _client!.readProps(epubBasePath!);
    // int totalContentLen = prop.size!;
    Uint8List? zipData;
    _client!.setHeaders({"range": "bytes=-65536"});
    var resp = await _client!.read("$rootPath/$epubBasePath");
    // if (resp.statusCode != 206) {
    //   throw "服务器不支持流式传输";
    // }
    // TODO: 这里记得区分一下大小写，可以转换一下headers
    // etag = resp.headers["etag"]?[0] ?? "";
    zipData = Uint8List.fromList(resp);
    // 缓存
    await ApplicationCacheManager.instance.writeFile(
      "$rootPath/$epubBasePath/koko_central_direcotry",
      zipData,
    );
    return ZipStreamDecoder.instance.parseZipDirectory(zipData, fileSize);
  }

  @override
  String get requestPath =>
      "${ApplicationCacheManager.instance.requestCachePath}$rootPath/$epubBasePath";

  @override
  String get realPath =>
      "${ApplicationCacheManager.instance.currentCachePath}$rootPath/$epubBasePath";

  /// TODO:这里后面得改掉，先mock一下
  @override
  Future<int> getFileSize() async {
    var prop = await _client!.readProps("$rootPath/$epubBasePath");
    return prop.size!;
  }
}
