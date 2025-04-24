class CentralDirectoryEntry {
  // 文件路径
  final String filePath;
  // 文件在 ZIP 中的起始偏移量
  final int offset;
  // 文件长度（多少byte）
  int lenth;
  // 压缩后大小
  final int compressedSize;
  // 原始大小
  final int uncompressedSize;
  // 是否压缩 (0 = 未压缩, 8 = deflate)
  final bool isInflate;

  CentralDirectoryEntry({
    required this.filePath,
    required this.offset,
    required this.lenth,
    required this.compressedSize,
    required this.uncompressedSize,
    required this.isInflate,
  });

  @override
  String toString() {
    return "文件: $filePath, 偏移量: $offset, 长度: $lenth, 压缩后大小: $compressedSize, 压缩前大小: $uncompressedSize, 是否无损压缩: $isInflate";
  }
}
