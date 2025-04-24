/// epub资源（图片，html，css等）
class KokoEpubItem {
  /// 资源 ID
  String id; 
  // 资源路径
  String href; 
  // 资源类型
  String mediaType; 
  // 是否在章节中
  bool isSpineItem; 

  KokoEpubItem({
    required this.id,
    required this.href,
    required this.mediaType,
    this.isSpineItem = false,
  });
}
