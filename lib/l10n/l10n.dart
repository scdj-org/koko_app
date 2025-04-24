import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_en.dart';
import 'l10n_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @homePage.
  ///
  /// In en, this message translates to:
  /// **'home'**
  String get homePage;

  /// No description provided for @defaultDesc.
  ///
  /// In en, this message translates to:
  /// **'auto'**
  String get defaultDesc;

  /// No description provided for @notSupport.
  ///
  /// In en, this message translates to:
  /// **'Not Support'**
  String get notSupport;

  /// No description provided for @convertToMp4.
  ///
  /// In en, this message translates to:
  /// **'Please Convert To MP4'**
  String get convertToMp4;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'no'**
  String get no;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'select'**
  String get select;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'finish'**
  String get finish;

  /// No description provided for @colorPink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get colorPink;

  /// No description provided for @colorPurple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get colorPurple;

  /// No description provided for @colorWhite.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get colorWhite;

  /// No description provided for @colorCyan.
  ///
  /// In en, this message translates to:
  /// **'Cyan'**
  String get colorCyan;

  /// No description provided for @colorGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorGreen;

  /// No description provided for @settingDesc.
  ///
  /// In en, this message translates to:
  /// **'Setting'**
  String get settingDesc;

  /// No description provided for @importDesc.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importDesc;

  /// No description provided for @generalSettingDesc.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get generalSettingDesc;

  /// No description provided for @themeSetting.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeSetting;

  /// No description provided for @languageSetting.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSetting;

  /// No description provided for @pageSettingDesc.
  ///
  /// In en, this message translates to:
  /// **'File Page Settings'**
  String get pageSettingDesc;

  /// No description provided for @defaultPageModeSetting.
  ///
  /// In en, this message translates to:
  /// **'Default Page Style'**
  String get defaultPageModeSetting;

  /// No description provided for @pageMode0.
  ///
  /// In en, this message translates to:
  /// **'simple list'**
  String get pageMode0;

  /// No description provided for @pageMode1.
  ///
  /// In en, this message translates to:
  /// **'grid view'**
  String get pageMode1;

  /// No description provided for @pageMode2.
  ///
  /// In en, this message translates to:
  /// **'image list'**
  String get pageMode2;

  /// No description provided for @defaultPageSortedModeSetting.
  ///
  /// In en, this message translates to:
  /// **'Default Page Sortring'**
  String get defaultPageSortedModeSetting;

  /// No description provided for @pageSortedMode0.
  ///
  /// In en, this message translates to:
  /// **'name'**
  String get pageSortedMode0;

  /// No description provided for @pageSortedMode1.
  ///
  /// In en, this message translates to:
  /// **'date'**
  String get pageSortedMode1;

  /// No description provided for @pageSortedMode2.
  ///
  /// In en, this message translates to:
  /// **'type'**
  String get pageSortedMode2;

  /// No description provided for @pageSortedMode3.
  ///
  /// In en, this message translates to:
  /// **'size'**
  String get pageSortedMode3;

  /// No description provided for @defaultPageGridCrossCountSetting.
  ///
  /// In en, this message translates to:
  /// **'Grid Columns'**
  String get defaultPageGridCrossCountSetting;

  /// No description provided for @languageSettingAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get languageSettingAuto;

  /// No description provided for @openButtonTips.
  ///
  /// In en, this message translates to:
  /// **'Button Tips'**
  String get openButtonTips;

  /// No description provided for @readingSettingDesc.
  ///
  /// In en, this message translates to:
  /// **'Reading Settings'**
  String get readingSettingDesc;

  /// No description provided for @defaultEpubFontSizeSetting.
  ///
  /// In en, this message translates to:
  /// **'Epub Font Size'**
  String get defaultEpubFontSizeSetting;

  /// No description provided for @fontSizeSuperLarge.
  ///
  /// In en, this message translates to:
  /// **'XL'**
  String get fontSizeSuperLarge;

  /// No description provided for @fontSizeLarge.
  ///
  /// In en, this message translates to:
  /// **'L'**
  String get fontSizeLarge;

  /// No description provided for @fontSizeMedium.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get fontSizeMedium;

  /// No description provided for @fontSizeSmall.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get fontSizeSmall;

  /// No description provided for @defaultEpubPreloadNumSetting.
  ///
  /// In en, this message translates to:
  /// **'Epub Pre-cached Pages'**
  String get defaultEpubPreloadNumSetting;

  /// No description provided for @defaultEpubBackgroundColorSetting.
  ///
  /// In en, this message translates to:
  /// **'Theme Color'**
  String get defaultEpubBackgroundColorSetting;

  /// No description provided for @readDirection.
  ///
  /// In en, this message translates to:
  /// **'Reading Direction'**
  String get readDirection;

  /// No description provided for @horizontal.
  ///
  /// In en, this message translates to:
  /// **'H'**
  String get horizontal;

  /// No description provided for @vertical.
  ///
  /// In en, this message translates to:
  /// **'V'**
  String get vertical;

  /// No description provided for @clearCacheSettingDesc.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCacheSettingDesc;

  /// No description provided for @clearConfigCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Configuration Cache'**
  String get clearConfigCache;

  /// No description provided for @clearConfigCacheDesc.
  ///
  /// In en, this message translates to:
  /// **'Confirm clearing the configuration cache? This action cannot be undone.'**
  String get clearConfigCacheDesc;

  /// No description provided for @clearLocalCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Local App Cache'**
  String get clearLocalCache;

  /// No description provided for @clearLocalCacheDesc.
  ///
  /// In en, this message translates to:
  /// **'Confirm clearing the Local cache? This action cannot be undone.'**
  String get clearLocalCacheDesc;

  /// No description provided for @clearImageCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Image Cache'**
  String get clearImageCache;

  /// No description provided for @clearImageCacheDesc.
  ///
  /// In en, this message translates to:
  /// **'Confirm clearing the Image cache? This action cannot be undone.'**
  String get clearImageCacheDesc;

  /// No description provided for @successClearCache.
  ///
  /// In en, this message translates to:
  /// **'Successfully released {cacheSizeDesc} storage space.'**
  String successClearCache(String cacheSizeDesc);

  /// No description provided for @homePageDevice.
  ///
  /// In en, this message translates to:
  /// **'Local Devices'**
  String get homePageDevice;

  /// No description provided for @homePageLocalRepositories.
  ///
  /// In en, this message translates to:
  /// **'Local Repositories'**
  String get homePageLocalRepositories;

  /// No description provided for @homePageNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get homePageNetwork;

  /// No description provided for @noMore.
  ///
  /// In en, this message translates to:
  /// **'No More...'**
  String get noMore;

  /// No description provided for @importFiles.
  ///
  /// In en, this message translates to:
  /// **'import'**
  String get importFiles;

  /// No description provided for @moveFiles.
  ///
  /// In en, this message translates to:
  /// **'move'**
  String get moveFiles;

  /// No description provided for @moveFilesCount.
  ///
  /// In en, this message translates to:
  /// **'move {count} file here'**
  String moveFilesCount(int count);

  /// No description provided for @exportFiles.
  ///
  /// In en, this message translates to:
  /// **'export'**
  String get exportFiles;

  /// No description provided for @deleteFiles.
  ///
  /// In en, this message translates to:
  /// **'delete'**
  String get deleteFiles;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get cancel;

  /// No description provided for @pickUpFile.
  ///
  /// In en, this message translates to:
  /// **'Select the file type'**
  String get pickUpFile;

  /// No description provided for @fileDesc.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get fileDesc;

  /// No description provided for @dirDesc.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get dirDesc;

  /// No description provided for @noSeleted.
  ///
  /// In en, this message translates to:
  /// **'No File Selected'**
  String get noSeleted;

  /// No description provided for @successImport.
  ///
  /// In en, this message translates to:
  /// **'Import Success'**
  String get successImport;

  /// No description provided for @confirmText.
  ///
  /// In en, this message translates to:
  /// **'confirm'**
  String get confirmText;

  /// No description provided for @cancleText.
  ///
  /// In en, this message translates to:
  /// **'cancle'**
  String get cancleText;

  /// No description provided for @createDirDesc.
  ///
  /// In en, this message translates to:
  /// **'Create a folder'**
  String get createDirDesc;

  /// No description provided for @createDirHintText.
  ///
  /// In en, this message translates to:
  /// **'Please enter the name...'**
  String get createDirHintText;

  /// No description provided for @emptyInputDesc.
  ///
  /// In en, this message translates to:
  /// **'Input is empty'**
  String get emptyInputDesc;

  /// No description provided for @dirHasExsit.
  ///
  /// In en, this message translates to:
  /// **'The folder already exist'**
  String get dirHasExsit;

  /// No description provided for @successCreate.
  ///
  /// In en, this message translates to:
  /// **'create success'**
  String get successCreate;

  /// No description provided for @invaildDirName.
  ///
  /// In en, this message translates to:
  /// **'Invalid folder name, don\'t use「 \\ / : * ? \" < > | 」characters in folder name.'**
  String get invaildDirName;

  /// No description provided for @renameFile.
  ///
  /// In en, this message translates to:
  /// **'Rename the file'**
  String get renameFile;

  /// No description provided for @renameFileHintText.
  ///
  /// In en, this message translates to:
  /// **'Please enter the name...'**
  String get renameFileHintText;

  /// No description provided for @successRename.
  ///
  /// In en, this message translates to:
  /// **'rename success'**
  String get successRename;

  /// No description provided for @confirmDeleteFile.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDeleteFile;

  /// No description provided for @confirmDeleteFileMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete the files? This action cannot be undone.'**
  String get confirmDeleteFileMessage;

  /// No description provided for @confirmMoveFile.
  ///
  /// In en, this message translates to:
  /// **'Confirm Move'**
  String get confirmMoveFile;

  /// No description provided for @confirmMoveFileMessage.
  ///
  /// In en, this message translates to:
  /// **'Move the files? This action cannot be undone.'**
  String get confirmMoveFileMessage;

  /// No description provided for @successDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Success'**
  String get successDelete;

  /// No description provided for @successMove.
  ///
  /// In en, this message translates to:
  /// **'Move Success'**
  String get successMove;

  /// No description provided for @restartToApplyChanges.
  ///
  /// In en, this message translates to:
  /// **'already apply changes.'**
  String get restartToApplyChanges;

  /// No description provided for @waitingDisplay.
  ///
  /// In en, this message translates to:
  /// **'take a break, Just a moment...'**
  String get waitingDisplay;

  /// No description provided for @operationFailed.
  ///
  /// In en, this message translates to:
  /// **'Operation Failed.'**
  String get operationFailed;

  /// No description provided for @ncx.
  ///
  /// In en, this message translates to:
  /// **'Contents'**
  String get ncx;

  /// No description provided for @chapter.
  ///
  /// In en, this message translates to:
  /// **'Chapter'**
  String get chapter;

  /// No description provided for @untitledChapter.
  ///
  /// In en, this message translates to:
  /// **'Untitled Chapter'**
  String get untitledChapter;

  /// No description provided for @warningClickFrequently.
  ///
  /// In en, this message translates to:
  /// **'Do not click too frequently'**
  String get warningClickFrequently;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'select all'**
  String get selectAll;

  /// No description provided for @deselectAll.
  ///
  /// In en, this message translates to:
  /// **'deselect all'**
  String get deselectAll;

  /// No description provided for @addNetDevice.
  ///
  /// In en, this message translates to:
  /// **'Adding Network Server'**
  String get addNetDevice;

  /// No description provided for @protocol.
  ///
  /// In en, this message translates to:
  /// **'protocol'**
  String get protocol;

  /// No description provided for @netHost.
  ///
  /// In en, this message translates to:
  /// **'host'**
  String get netHost;

  /// No description provided for @netPath.
  ///
  /// In en, this message translates to:
  /// **'path'**
  String get netPath;

  /// No description provided for @netName.
  ///
  /// In en, this message translates to:
  /// **'name'**
  String get netName;

  /// No description provided for @netPort.
  ///
  /// In en, this message translates to:
  /// **'port'**
  String get netPort;

  /// No description provided for @netAccount.
  ///
  /// In en, this message translates to:
  /// **'account'**
  String get netAccount;

  /// No description provided for @netPassword.
  ///
  /// In en, this message translates to:
  /// **'password'**
  String get netPassword;

  /// No description provided for @hostEmptyWarning.
  ///
  /// In en, this message translates to:
  /// **'host can\'t be empty'**
  String get hostEmptyWarning;

  /// No description provided for @hostErrorWarning.
  ///
  /// In en, this message translates to:
  /// **'please enter vaild URL, ex: https://example.com'**
  String get hostErrorWarning;

  /// No description provided for @hostNoPath.
  ///
  /// In en, this message translates to:
  /// **'host address cannot contain a path'**
  String get hostNoPath;

  /// No description provided for @pathNoHost.
  ///
  /// In en, this message translates to:
  /// **'path cannot contain a protocol or host address'**
  String get pathNoHost;

  /// No description provided for @pathErrorWarning.
  ///
  /// In en, this message translates to:
  /// **'path format is incorrect, it should be a \'folder/sub\' structure'**
  String get pathErrorWarning;

  /// No description provided for @optionNotEmpty.
  ///
  /// In en, this message translates to:
  /// **'cannot contain only spaces'**
  String get optionNotEmpty;

  /// No description provided for @vaildPort.
  ///
  /// In en, this message translates to:
  /// **'please enter a valid port number (1~65535)'**
  String get vaildPort;

  /// No description provided for @removeNetDevice.
  ///
  /// In en, this message translates to:
  /// **'Remove Service'**
  String get removeNetDevice;

  /// No description provided for @removeNetDeviceDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove the server? This operation cannot be undone and will clear all cache files for the server.'**
  String get removeNetDeviceDesc;

  /// No description provided for @connectFaild.
  ///
  /// In en, this message translates to:
  /// **'Connection Failed'**
  String get connectFaild;

  /// No description provided for @connectSuccess.
  ///
  /// In en, this message translates to:
  /// **'Connection Success'**
  String get connectSuccess;

  /// No description provided for @connectionTest.
  ///
  /// In en, this message translates to:
  /// **'test'**
  String get connectionTest;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
