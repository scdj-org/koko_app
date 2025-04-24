import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:koko/models/epub_models/koko_epub_book.dart';
import 'package:koko/models/epub_models/koko_epub_item.dart';
import 'package:koko/models/epub_models/koko_epub_ncx.dart';
import 'package:xml/xml.dart';

class EpubStreamDecoder {
  /// 单例实例
  ///
  /// XXX约定项目的所有单例以instance的形式获取
  static EpubStreamDecoder? _instance;
  static EpubStreamDecoder get instance =>
      _instance ??= EpubStreamDecoder._internal();
  EpubStreamDecoder._internal();

  /// 将相对路径转换为basePath为根目录的绝对路径
  static String normalizeEpubPath(String basePath, String relativePath) {
    return Uri.parse(basePath).resolve(relativePath).path;
  }

  /// 获取opf文件的路径
  ///
  /// META-INF/container.xml的Uint8List
  String? getOpfPath(Uint8List containerData) {
    // 解析 XML
    final xmlDoc = XmlDocument.parse(utf8.decode(containerData));
    final rootFileElement = xmlDoc.findAllElements("rootfile").firstOrNull;

    if (rootFileElement == null) {
      throw ("未找到rootfile节点，错误的epub文件");
    }

    // 获取 content.opf 的路径
    String? contentOpfPath = normalizeEpubPath(
      "",
      rootFileElement.getAttribute("full-path")!,
    );

    return contentOpfPath;
  }

  /// 读书，传入opf的bytes流即可获取Book
  KokoEpubBook readBook(Uint8List opfData, String opfAbsPath) {
    // 解析 XML
    final xmlDoc = XmlDocument.parse(utf8.decode(opfData));

    // 解析 Metadata
    final metadata =
        xmlDoc.findElements("package").first.findElements("metadata").first;
    String? title = metadata.findElements("dc:title").firstOrNull?.innerText;
    String? author = metadata.findElements("dc:creator").firstOrNull?.innerText;
    String? language =
        metadata.findElements("dc:language").firstOrNull?.innerText;

    /// 找封面的引用
    String? coverContent;
    final meta = metadata.findElements("meta");
    for (final item in meta) {
      if (item.getAttribute("name") == "cover") {
        coverContent = item.getAttribute("content");
        break;
      }
    }

    // 解析 Manifest
    Map<String, KokoEpubItem> manifest = {};
    Map<String, KokoEpubItem> hrefItemMap = {};
    final manifestElements = xmlDoc
        .findElements("package")
        .first
        .findElements("manifest")
        .first
        .findElements("item");
    for (var item in manifestElements) {
      final id = item.getAttribute("id")!;
      final href = normalizeEpubPath(opfAbsPath, item.getAttribute("href")!);
      final mediaType = item.getAttribute("media-type")!;
      final entry = (KokoEpubItem(id: id, href: href, mediaType: mediaType));
      manifest[id] = entry;
      hrefItemMap[href] = entry;
    }

    // 封面
    final coverItem = manifest[coverContent];

    // ncx路径
    final ncxItem = manifest["ncx"];

    // 解析 Spine（阅读顺序）
    List<String> spine = [];
    Map<String, int> spineIndexMap = {};
    final spineElements = xmlDoc
        .findElements("package")
        .first
        .findElements("spine")
        .first
        .findElements("itemref");
    int i = 0;
    for (var item in spineElements) {
      final idref = item.getAttribute("idref")!;
      spine.add(idref);
      spineIndexMap[idref] = i++;
    }
    if (spine.isEmpty) {
      throw ("epub格式错误，不存在spine");
    }

    // 组装 EpubBook
    return KokoEpubBook()
      ..title = title
      ..author = author
      ..language = language
      ..manifest = manifest
      ..spine = spine
      ..spineIndexMap = spineIndexMap
      ..hrefItemMap = hrefItemMap
      ..coverItem = coverItem
      ..ncxItem = ncxItem;
  }

  /// 载入NCX文件
  KokoEpubNcx loadNCX(Uint8List ncxData, String ncxAbsPath) {
    final document = XmlDocument.parse(utf8.decode(ncxData));
    return KokoEpubNcx.fromXml(document, ncxAbsPath);
  }
}
