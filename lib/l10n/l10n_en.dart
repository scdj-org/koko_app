// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get homePage => 'home';

  @override
  String get defaultDesc => 'auto';

  @override
  String get notSupport => 'Not Support';

  @override
  String get convertToMp4 => 'Please Convert To MP4';

  @override
  String get yes => 'yes';

  @override
  String get no => 'no';

  @override
  String get select => 'select';

  @override
  String get finish => 'finish';

  @override
  String get colorPink => 'Pink';

  @override
  String get colorPurple => 'Purple';

  @override
  String get colorWhite => 'White';

  @override
  String get colorCyan => 'Cyan';

  @override
  String get colorGreen => 'Green';

  @override
  String get settingDesc => 'Setting';

  @override
  String get importDesc => 'Import';

  @override
  String get generalSettingDesc => 'General Settings';

  @override
  String get themeSetting => 'Theme';

  @override
  String get languageSetting => 'Language';

  @override
  String get pageSettingDesc => 'File Page Settings';

  @override
  String get defaultPageModeSetting => 'Default Page Style';

  @override
  String get pageMode0 => 'simple list';

  @override
  String get pageMode1 => 'grid view';

  @override
  String get pageMode2 => 'image list';

  @override
  String get defaultPageSortedModeSetting => 'Default Page Sortring';

  @override
  String get pageSortedMode0 => 'name';

  @override
  String get pageSortedMode1 => 'date';

  @override
  String get pageSortedMode2 => 'type';

  @override
  String get pageSortedMode3 => 'size';

  @override
  String get defaultPageGridCrossCountSetting => 'Grid Columns';

  @override
  String get languageSettingAuto => 'Auto';

  @override
  String get openButtonTips => 'Button Tips';

  @override
  String get readingSettingDesc => 'Reading Settings';

  @override
  String get defaultEpubFontSizeSetting => 'Epub Font Size';

  @override
  String get fontSizeSuperLarge => 'XL';

  @override
  String get fontSizeLarge => 'L';

  @override
  String get fontSizeMedium => 'M';

  @override
  String get fontSizeSmall => 'S';

  @override
  String get defaultEpubPreloadNumSetting => 'Epub Pre-cached Pages';

  @override
  String get defaultEpubBackgroundColorSetting => 'Theme Color';

  @override
  String get readDirection => 'Reading Direction';

  @override
  String get horizontal => 'H';

  @override
  String get vertical => 'V';

  @override
  String get clearCacheSettingDesc => 'Clear Cache';

  @override
  String get clearConfigCache => 'Clear Configuration Cache';

  @override
  String get clearConfigCacheDesc => 'Confirm clearing the configuration cache? This action cannot be undone.';

  @override
  String get clearLocalCache => 'Clear Local App Cache';

  @override
  String get clearLocalCacheDesc => 'Confirm clearing the Local cache? This action cannot be undone.';

  @override
  String get clearImageCache => 'Clear Image Cache';

  @override
  String get clearImageCacheDesc => 'Confirm clearing the Image cache? This action cannot be undone.';

  @override
  String successClearCache(String cacheSizeDesc) {
    return 'Successfully released $cacheSizeDesc storage space.';
  }

  @override
  String get homePageDevice => 'Local Devices';

  @override
  String get homePageLocalRepositories => 'Local Repositories';

  @override
  String get homePageNetwork => 'Network';

  @override
  String get noMore => 'No More...';

  @override
  String get importFiles => 'import';

  @override
  String get moveFiles => 'move';

  @override
  String moveFilesCount(int count) {
    return 'move $count file here';
  }

  @override
  String get exportFiles => 'export';

  @override
  String get deleteFiles => 'delete';

  @override
  String get cancel => 'cancel';

  @override
  String get pickUpFile => 'Select the file type';

  @override
  String get fileDesc => 'Files';

  @override
  String get dirDesc => 'Folder';

  @override
  String get noSeleted => 'No File Selected';

  @override
  String get successImport => 'Import Success';

  @override
  String get confirmText => 'confirm';

  @override
  String get cancleText => 'cancle';

  @override
  String get createDirDesc => 'Create a folder';

  @override
  String get createDirHintText => 'Please enter the name...';

  @override
  String get emptyInputDesc => 'Input is empty';

  @override
  String get dirHasExsit => 'The folder already exist';

  @override
  String get successCreate => 'create success';

  @override
  String get invaildDirName => 'Invalid folder name, don\'t use「 \\ / : * ? \" < > | 」characters in folder name.';

  @override
  String get renameFile => 'Rename the file';

  @override
  String get renameFileHintText => 'Please enter the name...';

  @override
  String get successRename => 'rename success';

  @override
  String get confirmDeleteFile => 'Confirm Delete';

  @override
  String get confirmDeleteFileMessage => 'Delete the files? This action cannot be undone.';

  @override
  String get confirmMoveFile => 'Confirm Move';

  @override
  String get confirmMoveFileMessage => 'Move the files? This action cannot be undone.';

  @override
  String get successDelete => 'Delete Success';

  @override
  String get successMove => 'Move Success';

  @override
  String get restartToApplyChanges => 'already apply changes.';

  @override
  String get waitingDisplay => 'take a break, Just a moment...';

  @override
  String get operationFailed => 'Operation Failed.';

  @override
  String get ncx => 'Contents';

  @override
  String get chapter => 'Chapter';

  @override
  String get untitledChapter => 'Untitled Chapter';

  @override
  String get warningClickFrequently => 'Do not click too frequently';

  @override
  String get selectAll => 'select all';

  @override
  String get deselectAll => 'deselect all';

  @override
  String get addNetDevice => 'Adding Network Server';

  @override
  String get protocol => 'protocol';

  @override
  String get netHost => 'host';

  @override
  String get netPath => 'path';

  @override
  String get netName => 'name';

  @override
  String get netPort => 'port';

  @override
  String get netAccount => 'account';

  @override
  String get netPassword => 'password';

  @override
  String get hostEmptyWarning => 'host can\'t be empty';

  @override
  String get hostErrorWarning => 'please enter vaild URL, ex: https://example.com';

  @override
  String get hostNoPath => 'host address cannot contain a path';

  @override
  String get pathNoHost => 'path cannot contain a protocol or host address';

  @override
  String get pathErrorWarning => 'path format is incorrect, it should be a \'folder/sub\' structure';

  @override
  String get optionNotEmpty => 'cannot contain only spaces';

  @override
  String get vaildPort => 'please enter a valid port number (1~65535)';

  @override
  String get removeNetDevice => 'Remove Service';

  @override
  String get removeNetDeviceDesc => 'Are you sure you want to remove the server? This operation cannot be undone and will clear all cache files for the server.';

  @override
  String get connectFaild => 'Connection Failed';

  @override
  String get connectSuccess => 'Connection Success';

  @override
  String get connectionTest => 'test';
}
