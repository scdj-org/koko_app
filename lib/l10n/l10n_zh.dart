// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get homePage => '主页';

  @override
  String get defaultDesc => '默认';

  @override
  String get notSupport => '暂不支持';

  @override
  String get convertToMp4 => '请转换为MP4格式';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String get select => '选择';

  @override
  String get finish => '完成';

  @override
  String get colorPink => '粉色';

  @override
  String get colorPurple => '紫色';

  @override
  String get colorWhite => '白色';

  @override
  String get colorCyan => '青色';

  @override
  String get colorGreen => '绿色';

  @override
  String get settingDesc => '设置';

  @override
  String get importDesc => '导入';

  @override
  String get generalSettingDesc => '通用设置';

  @override
  String get themeSetting => '主题';

  @override
  String get languageSetting => '语言';

  @override
  String get pageSettingDesc => '文件页面设置';

  @override
  String get defaultPageModeSetting => '默认页面样式';

  @override
  String get pageMode0 => '简易列表';

  @override
  String get pageMode1 => '网格视图';

  @override
  String get pageMode2 => '图片列表';

  @override
  String get defaultPageSortedModeSetting => '默认页面排序方式';

  @override
  String get pageSortedMode0 => '名称';

  @override
  String get pageSortedMode1 => '日期';

  @override
  String get pageSortedMode2 => '类型';

  @override
  String get pageSortedMode3 => '大小';

  @override
  String get defaultPageGridCrossCountSetting => '网格列数';

  @override
  String get languageSettingAuto => '跟随系统';

  @override
  String get openButtonTips => '按钮提示';

  @override
  String get readingSettingDesc => '阅读设置';

  @override
  String get defaultEpubFontSizeSetting => 'Epub阅读字体大小';

  @override
  String get fontSizeSuperLarge => '超大';

  @override
  String get fontSizeLarge => '大';

  @override
  String get fontSizeMedium => '中';

  @override
  String get fontSizeSmall => '小';

  @override
  String get defaultEpubPreloadNumSetting => 'Epub预缓存页数';

  @override
  String get defaultEpubBackgroundColorSetting => '主题同色';

  @override
  String get readDirection => '阅读方向';

  @override
  String get horizontal => '横向';

  @override
  String get vertical => '竖向';

  @override
  String get clearCacheSettingDesc => '清理缓存';

  @override
  String get clearConfigCache => '清除配置文件缓存';

  @override
  String get clearConfigCacheDesc => '确认清除配置文件？此操作不可撤销';

  @override
  String get clearLocalCache => '清除本地缓存';

  @override
  String get clearLocalCacheDesc => '确认清除本地缓存？此操作不可撤销';

  @override
  String get clearImageCache => '清除图片缓存';

  @override
  String get clearImageCacheDesc => '确认清除图片缓存？此操作不可撤销';

  @override
  String successClearCache(String cacheSizeDesc) {
    return '成功释放$cacheSizeDesc存储';
  }

  @override
  String get homePageDevice => '设备';

  @override
  String get homePageLocalRepositories => '本地存储库';

  @override
  String get homePageNetwork => '网络';

  @override
  String get noMore => '没有更多了...';

  @override
  String get importFiles => '导入';

  @override
  String get moveFiles => '移动';

  @override
  String moveFilesCount(int count) {
    return '移动$count个文件到此 ';
  }

  @override
  String get exportFiles => '导出';

  @override
  String get deleteFiles => '删除';

  @override
  String get cancel => '取消';

  @override
  String get pickUpFile => '选择文件类型';

  @override
  String get fileDesc => '文件';

  @override
  String get dirDesc => '文件夹';

  @override
  String get noSeleted => '没有选中文件';

  @override
  String get successImport => '导入成功';

  @override
  String get confirmText => '确认';

  @override
  String get cancleText => '取消';

  @override
  String get createDirDesc => '创建文件夹';

  @override
  String get createDirHintText => '请输入文件夹名称...';

  @override
  String get emptyInputDesc => '输入为空';

  @override
  String get dirHasExsit => '文件夹已经存在';

  @override
  String get successCreate => '创建成功';

  @override
  String get invaildDirName => '不合法的文件夹名称, 「 \\ / : * ? \" < > | 」这些字符不允许存在.';

  @override
  String get renameFile => '重命名文件';

  @override
  String get renameFileHintText => '请输入名称...';

  @override
  String get successRename => '改名成功';

  @override
  String get confirmDeleteFile => '确认删除';

  @override
  String get confirmDeleteFileMessage => '确认删除文件？此操作无法撤销';

  @override
  String get confirmMoveFile => '确认移动';

  @override
  String get confirmMoveFileMessage => '确认移动文件？此操作无法撤销';

  @override
  String get successDelete => '删除成功';

  @override
  String get successMove => '移动成功';

  @override
  String get restartToApplyChanges => '成功应用设置';

  @override
  String get waitingDisplay => '休息一下，马上就好...';

  @override
  String get operationFailed => '操作失败';

  @override
  String get ncx => '目录';

  @override
  String get chapter => '章节';

  @override
  String get untitledChapter => '未命名章节';

  @override
  String get warningClickFrequently => '请勿频繁点击';

  @override
  String get selectAll => '全选';

  @override
  String get deselectAll => '取消全选';

  @override
  String get addNetDevice => '添加网络服务器';

  @override
  String get protocol => '协议';

  @override
  String get netHost => '主机';

  @override
  String get netPath => '路径';

  @override
  String get netName => '名称';

  @override
  String get netPort => '端口号';

  @override
  String get netAccount => '账号';

  @override
  String get netPassword => '密码';

  @override
  String get hostEmptyWarning => '主机地址不能为空';

  @override
  String get hostErrorWarning => '请输入有效主机地址, 例: https://example.com';

  @override
  String get hostNoPath => '主机地址不能包含路径';

  @override
  String get pathNoHost => '路径不能包含协议';

  @override
  String get pathErrorWarning => '路径格式错误，结构应为\'folder/sub\'';

  @override
  String get optionNotEmpty => '不能只包含空白字符';

  @override
  String get vaildPort => '请输入一个有效的端口号 (1~65535)';

  @override
  String get removeNetDevice => '移除服务器';

  @override
  String get removeNetDeviceDesc => '确认移除服务器吗，此操作不可恢复，且会清除该服务器所属缓存文件';

  @override
  String get connectFaild => '连接失败';

  @override
  String get connectSuccess => '连接成功';

  @override
  String get connectionTest => '测试';
}
