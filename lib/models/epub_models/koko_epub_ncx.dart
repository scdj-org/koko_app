import 'package:koko/models/epub_models/koko_epub_ncx_ponit.dart';
import 'package:xml/xml.dart';

/// ncx目录
class KokoEpubNcx {
  /// 顺序加载的深搜目录节点
  final List<KokoEpubNcxPonit> navPoints;

  KokoEpubNcx({required this.navPoints});

  factory KokoEpubNcx.fromXml(XmlDocument xml, String basePath) {
    final navMap = xml.findAllElements('navMap').first;
    List<KokoEpubNcxPonit> parseNavPoints(Iterable<XmlElement> elements) {
      return elements
          .map((element) => KokoEpubNcxPonit.fromXml(element, basePath))
          .toList();
    }

    return KokoEpubNcx(
      navPoints: parseNavPoints(navMap.findElements('navPoint')),
    );
  }

  @override
  String toString() {
    return 'KokoEpubNcx: $navPoints';
  }
}
