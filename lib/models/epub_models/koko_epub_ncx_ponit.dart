import 'package:koko/common/epub_util/epub_stream_decoder.dart';
import 'package:xml/xml.dart';

/// ncx目录节点，包含一颗ncx子树
class KokoEpubNcxPonit {
  ///
  final String id;
  final String? label;
  final String contentSrc;
  final List<KokoEpubNcxPonit> children;

  KokoEpubNcxPonit({
    required this.id,
    this.label,
    required this.contentSrc,
    this.children = const [],
  });

  factory KokoEpubNcxPonit.fromXml(XmlElement element, String basePath) {
    final id = element.getAttribute('id') ?? '';
    final label =
        element
            .findElements('navLabel')
            .first
            .findElements('text')
            .first
            .innerText;
    var contentSrc =
        element.findElements('content').first.getAttribute('src') ?? '';
    contentSrc = EpubStreamDecoder.normalizeEpubPath(basePath, contentSrc);

    final children =
        element
            .findElements('navPoint')
            .map((e) => KokoEpubNcxPonit.fromXml(e, basePath))
            .toList();

    return KokoEpubNcxPonit(
      id: id,
      label: label,
      contentSrc: contentSrc,
      children: children,
    );
  }

  @override
  String toString() {
    return 'KokoEpubNavPoint(id: $id, label: $label, contentSrc: $contentSrc, children: $children)';
  }
}
