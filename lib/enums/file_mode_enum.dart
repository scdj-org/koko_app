/// 文件类型mode，这个文件记录了设置过的一些目录的文件类型
enum FileModeEnum {
  /// 默认类型，根据后缀决定
  /// 
  /// 设为这个类型或为这个类型时，需要从配置文件中删除该条记录
  suffix(0),
  /// 图片文件夹
  pics(1);

  final int fileModeId;
  const FileModeEnum(this.fileModeId);
  
  static final Map<int, FileModeEnum> _serializationMap = {
    for (final v in values) v.fileModeId: v,
  };

  static FileModeEnum? fromFileModeId(int? id) => _serializationMap[id];

}