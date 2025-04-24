import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// 直接复制粘贴的ImageCacheManager源码并修改
class CustomImageCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'customCachedImageData';

  static final CustomImageCacheManager _instance = CustomImageCacheManager._();

  factory CustomImageCacheManager() {
    return _instance;
  }

  CustomImageCacheManager._() : super(Config(key));

  @override
  Stream<FileResponse> getImageFile(
    String url, {
    String? key,
    Map<String, String>? headers,
    bool withProgress = false,
    int? maxHeight,
    int? maxWidth,
  }) async* {
    if (maxHeight == null && maxWidth == null) {
      yield* getFileStream(
        url,
        key: key,
        headers: headers,
        withProgress: withProgress,
      );
      return;
    }
    key ??= url;

    var resizedKey = getResizeKey(
      url,
      key: key,
      maxHeight: maxHeight,
      maxWidth: maxWidth,
    );

    final fromCache = await getFileFromCache(resizedKey);
    if (fromCache != null) {
      yield fromCache;
      if (fromCache.validTill.isAfter(DateTime.now())) {
        return;
      }
      withProgress = false;
    }
    var runningResize = runningResizes[resizedKey];
    if (runningResize == null) {
      runningResize =
          _fetchedResizedFile(
            url,
            key,
            resizedKey,
            headers,
            withProgress,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
          ).asBroadcastStream();
      runningResizes[resizedKey] = runningResize;
    }
    yield* runningResize;
    runningResizes.remove(resizedKey);
  }

  final Map<String, Stream<FileResponse>> runningResizes = {};

  Future<FileInfo> _resizeImageFile(
    FileInfo originalFile,
    String key,
    int? maxWidth,
    int? maxHeight,
  ) async {
    final originalFileName = originalFile.file.path;
    final fileExtension = originalFileName.split('.').last;
    if (!supportedFileNames.contains(fileExtension)) {
      return originalFile;
    }

    final image = await _decodeImage(originalFile.file);

    final shouldResize =
        maxWidth != null
            ? image.width > maxWidth
            : false || maxHeight != null
            ? image.height > maxHeight
            : false;
    if (!shouldResize) return originalFile;
    if (maxWidth != null && maxHeight != null) {
      final resizeFactorWidth = image.width / maxWidth;
      final resizeFactorHeight = image.height / maxHeight;
      final resizeFactor = max(resizeFactorHeight, resizeFactorWidth);

      maxWidth = (image.width / resizeFactor).round();
      maxHeight = (image.height / resizeFactor).round();
    }

    final resized = await _decodeImage(
      originalFile.file,
      width: maxWidth,
      height: maxHeight,
    );
    final resizedFile =
        (await resized.toByteData(
          format: ui.ImageByteFormat.png,
        ))!.buffer.asUint8List();
    final maxAge = originalFile.validTill.difference(DateTime.now());

    final file = await putFile(
      originalFile.originalUrl,
      resizedFile,
      key: key,
      maxAge: maxAge,
      fileExtension: fileExtension,
    );

    return FileInfo(
      file,
      originalFile.source,
      originalFile.validTill,
      originalFile.originalUrl,
    );
  }

  Stream<FileResponse> _fetchedResizedFile(
    String url,
    String originalKey,
    String resizedKey,
    Map<String, String>? headers,
    bool withProgress, {
    int? maxWidth,
    int? maxHeight,
  }) async* {
    await for (final response in getFileStream(
      url,
      key: originalKey,
      headers: headers,
      withProgress: withProgress,
    )) {
      if (response is DownloadProgress) {
        yield response;
      }
      if (response is FileInfo) {
        yield await _resizeImageFile(response, resizedKey, maxWidth, maxHeight);
      }
    }
  }

  String getResizeKey(
    String url, {
    String? key,
    int? maxHeight,
    int? maxWidth,
  }) {
    key ??= url;
    var resizedKey = 'resized';
    if (maxWidth != null) resizedKey += '_w$maxWidth';
    if (maxHeight != null) resizedKey += '_h$maxHeight';
    resizedKey += '_$key';
    return resizedKey;
  }
}

Future<ui.Image> _decodeImage(
  File file, {
  int? width,
  int? height,
  bool allowUpscaling = false,
}) {
  final shouldResize = width != null || height != null;
  final fileImage = FileImage(file);
  final image =
      shouldResize
          ? ResizeImage(
            fileImage,
            width: width,
            height: height,
            allowUpscaling: allowUpscaling,
          )
          : fileImage as ImageProvider;
  final completer = Completer<ui.Image>();
  image
      .resolve(ImageConfiguration.empty)
      .addListener(
        ImageStreamListener((info, _) {
          completer.complete(info.image);
          image.evict();
        }),
      );
  return completer.future;
}
