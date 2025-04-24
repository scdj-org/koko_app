import 'package:koko/models/epub_models/koko_epub_item.dart';
import 'package:koko/models/epub_models/koko_epub_ncx.dart';

/// epub书籍结构
class KokoEpubBook {
  /// 书名
  String? title;

  /// 作者
  String? author;

  /// 语言
  String? language;

  /// 资源清单
  ///
  /// key为资源id，方便后续查询渲染
  Map<String, KokoEpubItem> manifest = {};

  /// 资源id，按顺序加载
  List<String> spine = [];

  /// 章节（资源）id-页数（从0开始）表，方便后续跳转查找页数（通过ncx point的content）
  Map<String, int> spineIndexMap = {};

  /// 超链接-KokoEpubItem，从超链接获取当前的EpubItem
  ///
  /// 方便后续跳转查找页数（通过ncx point的content或者加载图片资源的时候）
  ///
  /// HACK: 这里可能会有多对1的bug，暂时先不考虑
  Map<String, KokoEpubItem> hrefItemMap = {};

  /// 封面路径
  KokoEpubItem? coverItem;

  /// ncx 目录文件路径
  KokoEpubItem? ncxItem;

  /// ncx
  KokoEpubNcx? ncx;

  @override
  String toString() {
    return '''KokoEpubBook(
  title: $title,
  author: $author,
  language: $language,
  manifest: {${manifest.keys.join(', ')}},
  spine: ${spine.join(' -> ')},
  spineIndexMap: $spineIndexMap,
  hrefIdMap: {${hrefItemMap.keys.join(', ')}},
  coverItem: ${coverItem?.href ?? 'None'},
  ncxItem: ${ncxItem?.href ?? 'None'},
  ncx: ${ncx != null ? 'Loaded' : 'None'}
)''';
  }
}
