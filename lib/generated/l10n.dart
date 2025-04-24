// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `home`
  String get homePage {
    return Intl.message('home', name: 'homePage', desc: '', args: []);
  }

  /// `auto`
  String get defaultDesc {
    return Intl.message('auto', name: 'defaultDesc', desc: '', args: []);
  }

  /// `Not Support`
  String get notSupport {
    return Intl.message('Not Support', name: 'notSupport', desc: '', args: []);
  }

  /// `Please Convert To MP4`
  String get convertToMp4 {
    return Intl.message(
      'Please Convert To MP4',
      name: 'convertToMp4',
      desc: '',
      args: [],
    );
  }

  /// `yes`
  String get yes {
    return Intl.message('yes', name: 'yes', desc: '', args: []);
  }

  /// `no`
  String get no {
    return Intl.message('no', name: 'no', desc: '', args: []);
  }

  /// `select`
  String get select {
    return Intl.message('select', name: 'select', desc: '', args: []);
  }

  /// `finish`
  String get finish {
    return Intl.message('finish', name: 'finish', desc: '', args: []);
  }

  /// `Pink`
  String get colorPink {
    return Intl.message('Pink', name: 'colorPink', desc: '', args: []);
  }

  /// `Purple`
  String get colorPurple {
    return Intl.message('Purple', name: 'colorPurple', desc: '', args: []);
  }

  /// `White`
  String get colorWhite {
    return Intl.message('White', name: 'colorWhite', desc: '', args: []);
  }

  /// `Cyan`
  String get colorCyan {
    return Intl.message('Cyan', name: 'colorCyan', desc: '', args: []);
  }

  /// `Green`
  String get colorGreen {
    return Intl.message('Green', name: 'colorGreen', desc: '', args: []);
  }

  /// `Setting`
  String get settingDesc {
    return Intl.message('Setting', name: 'settingDesc', desc: '', args: []);
  }

  /// `Import`
  String get importDesc {
    return Intl.message('Import', name: 'importDesc', desc: '', args: []);
  }

  /// `General Settings`
  String get generalSettingDesc {
    return Intl.message(
      'General Settings',
      name: 'generalSettingDesc',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get themeSetting {
    return Intl.message('Theme', name: 'themeSetting', desc: '', args: []);
  }

  /// `Language`
  String get languageSetting {
    return Intl.message(
      'Language',
      name: 'languageSetting',
      desc: '',
      args: [],
    );
  }

  /// `File Page Settings`
  String get pageSettingDesc {
    return Intl.message(
      'File Page Settings',
      name: 'pageSettingDesc',
      desc: '',
      args: [],
    );
  }

  /// `Default Page Style`
  String get defaultPageModeSetting {
    return Intl.message(
      'Default Page Style',
      name: 'defaultPageModeSetting',
      desc: '',
      args: [],
    );
  }

  /// `simple list`
  String get pageMode0 {
    return Intl.message('simple list', name: 'pageMode0', desc: '', args: []);
  }

  /// `grid view`
  String get pageMode1 {
    return Intl.message('grid view', name: 'pageMode1', desc: '', args: []);
  }

  /// `image list`
  String get pageMode2 {
    return Intl.message('image list', name: 'pageMode2', desc: '', args: []);
  }

  /// `Default Page Sortring`
  String get defaultPageSortedModeSetting {
    return Intl.message(
      'Default Page Sortring',
      name: 'defaultPageSortedModeSetting',
      desc: '',
      args: [],
    );
  }

  /// `name`
  String get pageSortedMode0 {
    return Intl.message('name', name: 'pageSortedMode0', desc: '', args: []);
  }

  /// `date`
  String get pageSortedMode1 {
    return Intl.message('date', name: 'pageSortedMode1', desc: '', args: []);
  }

  /// `type`
  String get pageSortedMode2 {
    return Intl.message('type', name: 'pageSortedMode2', desc: '', args: []);
  }

  /// `size`
  String get pageSortedMode3 {
    return Intl.message('size', name: 'pageSortedMode3', desc: '', args: []);
  }

  /// `Grid Columns`
  String get defaultPageGridCrossCountSetting {
    return Intl.message(
      'Grid Columns',
      name: 'defaultPageGridCrossCountSetting',
      desc: '',
      args: [],
    );
  }

  /// `Auto`
  String get languageSettingAuto {
    return Intl.message(
      'Auto',
      name: 'languageSettingAuto',
      desc: '',
      args: [],
    );
  }

  /// `Button Tips`
  String get openButtonTips {
    return Intl.message(
      'Button Tips',
      name: 'openButtonTips',
      desc: '',
      args: [],
    );
  }

  /// `Reading Settings`
  String get readingSettingDesc {
    return Intl.message(
      'Reading Settings',
      name: 'readingSettingDesc',
      desc: '',
      args: [],
    );
  }

  /// `Epub Font Size`
  String get defaultEpubFontSizeSetting {
    return Intl.message(
      'Epub Font Size',
      name: 'defaultEpubFontSizeSetting',
      desc: '',
      args: [],
    );
  }

  /// `XL`
  String get fontSizeSuperLarge {
    return Intl.message('XL', name: 'fontSizeSuperLarge', desc: '', args: []);
  }

  /// `L`
  String get fontSizeLarge {
    return Intl.message('L', name: 'fontSizeLarge', desc: '', args: []);
  }

  /// `M`
  String get fontSizeMedium {
    return Intl.message('M', name: 'fontSizeMedium', desc: '', args: []);
  }

  /// `S`
  String get fontSizeSmall {
    return Intl.message('S', name: 'fontSizeSmall', desc: '', args: []);
  }

  /// `Epub Pre-cached Pages`
  String get defaultEpubPreloadNumSetting {
    return Intl.message(
      'Epub Pre-cached Pages',
      name: 'defaultEpubPreloadNumSetting',
      desc: '',
      args: [],
    );
  }

  /// `Theme Color`
  String get defaultEpubBackgroundColorSetting {
    return Intl.message(
      'Theme Color',
      name: 'defaultEpubBackgroundColorSetting',
      desc: '',
      args: [],
    );
  }

  /// `Reading Direction`
  String get readDirection {
    return Intl.message(
      'Reading Direction',
      name: 'readDirection',
      desc: '',
      args: [],
    );
  }

  /// `H`
  String get horizontal {
    return Intl.message('H', name: 'horizontal', desc: '', args: []);
  }

  /// `V`
  String get vertical {
    return Intl.message('V', name: 'vertical', desc: '', args: []);
  }

  /// `Clear Cache`
  String get clearCacheSettingDesc {
    return Intl.message(
      'Clear Cache',
      name: 'clearCacheSettingDesc',
      desc: '',
      args: [],
    );
  }

  /// `Clear Configuration Cache`
  String get clearConfigCache {
    return Intl.message(
      'Clear Configuration Cache',
      name: 'clearConfigCache',
      desc: '',
      args: [],
    );
  }

  /// `Confirm clearing the configuration cache? This action cannot be undone.`
  String get clearConfigCacheDesc {
    return Intl.message(
      'Confirm clearing the configuration cache? This action cannot be undone.',
      name: 'clearConfigCacheDesc',
      desc: '',
      args: [],
    );
  }

  /// `Clear Local App Cache`
  String get clearLocalCache {
    return Intl.message(
      'Clear Local App Cache',
      name: 'clearLocalCache',
      desc: '',
      args: [],
    );
  }

  /// `Confirm clearing the Local cache? This action cannot be undone.`
  String get clearLocalCacheDesc {
    return Intl.message(
      'Confirm clearing the Local cache? This action cannot be undone.',
      name: 'clearLocalCacheDesc',
      desc: '',
      args: [],
    );
  }

  /// `Clear Image Cache`
  String get clearImageCache {
    return Intl.message(
      'Clear Image Cache',
      name: 'clearImageCache',
      desc: '',
      args: [],
    );
  }

  /// `Confirm clearing the Image cache? This action cannot be undone.`
  String get clearImageCacheDesc {
    return Intl.message(
      'Confirm clearing the Image cache? This action cannot be undone.',
      name: 'clearImageCacheDesc',
      desc: '',
      args: [],
    );
  }

  /// `Successfully released {cacheSizeDesc} storage space.`
  String successClearCache(String cacheSizeDesc) {
    return Intl.message(
      'Successfully released $cacheSizeDesc storage space.',
      name: 'successClearCache',
      desc: '',
      args: [cacheSizeDesc],
    );
  }

  /// `Local Devices`
  String get homePageDevice {
    return Intl.message(
      'Local Devices',
      name: 'homePageDevice',
      desc: '',
      args: [],
    );
  }

  /// `Local Repositories`
  String get homePageLocalRepositories {
    return Intl.message(
      'Local Repositories',
      name: 'homePageLocalRepositories',
      desc: '',
      args: [],
    );
  }

  /// `Network`
  String get homePageNetwork {
    return Intl.message('Network', name: 'homePageNetwork', desc: '', args: []);
  }

  /// `No More...`
  String get noMore {
    return Intl.message('No More...', name: 'noMore', desc: '', args: []);
  }

  /// `import`
  String get importFiles {
    return Intl.message('import', name: 'importFiles', desc: '', args: []);
  }

  /// `move`
  String get moveFiles {
    return Intl.message('move', name: 'moveFiles', desc: '', args: []);
  }

  /// `move {count} file here`
  String moveFilesCount(int count) {
    return Intl.message(
      'move $count file here',
      name: 'moveFilesCount',
      desc: '',
      args: [count],
    );
  }

  /// `export`
  String get exportFiles {
    return Intl.message('export', name: 'exportFiles', desc: '', args: []);
  }

  /// `delete`
  String get deleteFiles {
    return Intl.message('delete', name: 'deleteFiles', desc: '', args: []);
  }

  /// `cancel`
  String get cancel {
    return Intl.message('cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Select the file type`
  String get pickUpFile {
    return Intl.message(
      'Select the file type',
      name: 'pickUpFile',
      desc: '',
      args: [],
    );
  }

  /// `Files`
  String get fileDesc {
    return Intl.message('Files', name: 'fileDesc', desc: '', args: []);
  }

  /// `Folder`
  String get dirDesc {
    return Intl.message('Folder', name: 'dirDesc', desc: '', args: []);
  }

  /// `No File Selected`
  String get noSeleted {
    return Intl.message(
      'No File Selected',
      name: 'noSeleted',
      desc: '',
      args: [],
    );
  }

  /// `Import Success`
  String get successImport {
    return Intl.message(
      'Import Success',
      name: 'successImport',
      desc: '',
      args: [],
    );
  }

  /// `confirm`
  String get confirmText {
    return Intl.message('confirm', name: 'confirmText', desc: '', args: []);
  }

  /// `cancle`
  String get cancleText {
    return Intl.message('cancle', name: 'cancleText', desc: '', args: []);
  }

  /// `Create a folder`
  String get createDirDesc {
    return Intl.message(
      'Create a folder',
      name: 'createDirDesc',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the name...`
  String get createDirHintText {
    return Intl.message(
      'Please enter the name...',
      name: 'createDirHintText',
      desc: '',
      args: [],
    );
  }

  /// `Input is empty`
  String get emptyInputDesc {
    return Intl.message(
      'Input is empty',
      name: 'emptyInputDesc',
      desc: '',
      args: [],
    );
  }

  /// `The folder already exist`
  String get dirHasExsit {
    return Intl.message(
      'The folder already exist',
      name: 'dirHasExsit',
      desc: '',
      args: [],
    );
  }

  /// `create success`
  String get successCreate {
    return Intl.message(
      'create success',
      name: 'successCreate',
      desc: '',
      args: [],
    );
  }

  /// `Invalid folder name, don't use「 \ / : * ? " < > | 」characters in folder name.`
  String get invaildDirName {
    return Intl.message(
      'Invalid folder name, don\'t use「 \\ / : * ? " < > | 」characters in folder name.',
      name: 'invaildDirName',
      desc: '',
      args: [],
    );
  }

  /// `Rename the file`
  String get renameFile {
    return Intl.message(
      'Rename the file',
      name: 'renameFile',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the name...`
  String get renameFileHintText {
    return Intl.message(
      'Please enter the name...',
      name: 'renameFileHintText',
      desc: '',
      args: [],
    );
  }

  /// `rename success`
  String get successRename {
    return Intl.message(
      'rename success',
      name: 'successRename',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Delete`
  String get confirmDeleteFile {
    return Intl.message(
      'Confirm Delete',
      name: 'confirmDeleteFile',
      desc: '',
      args: [],
    );
  }

  /// `Delete the files? This action cannot be undone.`
  String get confirmDeleteFileMessage {
    return Intl.message(
      'Delete the files? This action cannot be undone.',
      name: 'confirmDeleteFileMessage',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Move`
  String get confirmMoveFile {
    return Intl.message(
      'Confirm Move',
      name: 'confirmMoveFile',
      desc: '',
      args: [],
    );
  }

  /// `Move the files? This action cannot be undone.`
  String get confirmMoveFileMessage {
    return Intl.message(
      'Move the files? This action cannot be undone.',
      name: 'confirmMoveFileMessage',
      desc: '',
      args: [],
    );
  }

  /// `Delete Success`
  String get successDelete {
    return Intl.message(
      'Delete Success',
      name: 'successDelete',
      desc: '',
      args: [],
    );
  }

  /// `Move Success`
  String get successMove {
    return Intl.message(
      'Move Success',
      name: 'successMove',
      desc: '',
      args: [],
    );
  }

  /// `already apply changes.`
  String get restartToApplyChanges {
    return Intl.message(
      'already apply changes.',
      name: 'restartToApplyChanges',
      desc: '',
      args: [],
    );
  }

  /// `take a break, Just a moment...`
  String get waitingDisplay {
    return Intl.message(
      'take a break, Just a moment...',
      name: 'waitingDisplay',
      desc: '',
      args: [],
    );
  }

  /// `Operation Failed.`
  String get operationFailed {
    return Intl.message(
      'Operation Failed.',
      name: 'operationFailed',
      desc: '',
      args: [],
    );
  }

  /// `Contents`
  String get ncx {
    return Intl.message('Contents', name: 'ncx', desc: '', args: []);
  }

  /// `Chapter`
  String get chapter {
    return Intl.message('Chapter', name: 'chapter', desc: '', args: []);
  }

  /// `Untitled Chapter`
  String get untitledChapter {
    return Intl.message(
      'Untitled Chapter',
      name: 'untitledChapter',
      desc: '',
      args: [],
    );
  }

  /// `Do not click too frequently`
  String get warningClickFrequently {
    return Intl.message(
      'Do not click too frequently',
      name: 'warningClickFrequently',
      desc: '',
      args: [],
    );
  }

  /// `select all`
  String get selectAll {
    return Intl.message('select all', name: 'selectAll', desc: '', args: []);
  }

  /// `deselect all`
  String get deselectAll {
    return Intl.message(
      'deselect all',
      name: 'deselectAll',
      desc: '',
      args: [],
    );
  }

  /// `Adding Network Server`
  String get addNetDevice {
    return Intl.message(
      'Adding Network Server',
      name: 'addNetDevice',
      desc: '',
      args: [],
    );
  }

  /// `protocol`
  String get protocol {
    return Intl.message('protocol', name: 'protocol', desc: '', args: []);
  }

  /// `host`
  String get netHost {
    return Intl.message('host', name: 'netHost', desc: '', args: []);
  }

  /// `path`
  String get netPath {
    return Intl.message('path', name: 'netPath', desc: '', args: []);
  }

  /// `name`
  String get netName {
    return Intl.message('name', name: 'netName', desc: '', args: []);
  }

  /// `port`
  String get netPort {
    return Intl.message('port', name: 'netPort', desc: '', args: []);
  }

  /// `account`
  String get netAccount {
    return Intl.message('account', name: 'netAccount', desc: '', args: []);
  }

  /// `password`
  String get netPassword {
    return Intl.message('password', name: 'netPassword', desc: '', args: []);
  }

  /// `host can't be empty`
  String get hostEmptyWarning {
    return Intl.message(
      'host can\'t be empty',
      name: 'hostEmptyWarning',
      desc: '',
      args: [],
    );
  }

  /// `please enter vaild URL, ex: https://example.com`
  String get hostErrorWarning {
    return Intl.message(
      'please enter vaild URL, ex: https://example.com',
      name: 'hostErrorWarning',
      desc: '',
      args: [],
    );
  }

  /// `host address cannot contain a path`
  String get hostNoPath {
    return Intl.message(
      'host address cannot contain a path',
      name: 'hostNoPath',
      desc: '',
      args: [],
    );
  }

  /// `path cannot contain a protocol or host address`
  String get pathNoHost {
    return Intl.message(
      'path cannot contain a protocol or host address',
      name: 'pathNoHost',
      desc: '',
      args: [],
    );
  }

  /// `path format is incorrect, it should be a 'folder/sub' structure`
  String get pathErrorWarning {
    return Intl.message(
      'path format is incorrect, it should be a \'folder/sub\' structure',
      name: 'pathErrorWarning',
      desc: '',
      args: [],
    );
  }

  /// `cannot contain only spaces`
  String get optionNotEmpty {
    return Intl.message(
      'cannot contain only spaces',
      name: 'optionNotEmpty',
      desc: '',
      args: [],
    );
  }

  /// `please enter a valid port number (1~65535)`
  String get vaildPort {
    return Intl.message(
      'please enter a valid port number (1~65535)',
      name: 'vaildPort',
      desc: '',
      args: [],
    );
  }

  /// `Remove Service`
  String get removeNetDevice {
    return Intl.message(
      'Remove Service',
      name: 'removeNetDevice',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to remove the server? This operation cannot be undone and will clear all cache files for the server.`
  String get removeNetDeviceDesc {
    return Intl.message(
      'Are you sure you want to remove the server? This operation cannot be undone and will clear all cache files for the server.',
      name: 'removeNetDeviceDesc',
      desc: '',
      args: [],
    );
  }

  /// `Connection Failed`
  String get connectFaild {
    return Intl.message(
      'Connection Failed',
      name: 'connectFaild',
      desc: '',
      args: [],
    );
  }

  /// `Connection Success`
  String get connectSuccess {
    return Intl.message(
      'Connection Success',
      name: 'connectSuccess',
      desc: '',
      args: [],
    );
  }

  /// `test`
  String get connectionTest {
    return Intl.message('test', name: 'connectionTest', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
