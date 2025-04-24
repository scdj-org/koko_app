import 'package:flutter/material.dart';
import 'package:koko/common/application_cache_manager.dart';
import 'package:koko/common/global.dart';
import 'package:koko/enums/epub_font_size_enmu.dart';
import 'package:koko/enums/page_style_mode_enum.dart';
import 'package:koko/enums/page_sorted_mode_enum.dart';
import 'package:koko/enums/theme_color_enum.dart';
import 'package:koko/helper/epub_preload_num_menu_item_helper.dart';
import 'package:koko/helper/grid_cross_count_menu_item_helper.dart';
import 'package:koko/helper/locale_menu_item_helper.dart';
import 'package:koko/l10n/l10n.dart';
import 'package:koko/models/entity/call_back_result.dart';
import 'package:koko/models/entity/global_profile.dart';
import 'package:koko/models/model/button_tips_model.dart';
import 'package:koko/models/model/default_page_mode.dart';
import 'package:koko/models/epub_models/default_epub_conf_model.dart';
import 'package:koko/models/model/locale_model.dart';
import 'package:koko/models/model/net_devices_model.dart';
import 'package:koko/models/model/theme_model.dart';
import 'package:koko/routes/home_page_route.dart';
import 'package:koko/states/global_profile_change_notifier.dart';
import 'package:koko/widgets/overlay/double_confirm_dialog_overlay.dart';
import 'package:koko/widgets/overlay/loading_dialog.dart';
import 'package:koko/widgets/ui_widgets/my_pop_scope.dart';
import 'package:koko/widgets/overlay/ok_confirm_dialog_overlay.dart';
import 'package:koko/widgets/ui_widgets/setting_dropdown_menu.dart';
import 'package:koko/widgets/overlay/status_toast.dart';
import 'package:koko/widgets/ui_widgets/title_list_tile.dart';
import 'package:provider/provider.dart';

/// 设置页
class SettingRoute extends StatefulWidget {
  const SettingRoute({super.key});

  @override
  State<SettingRoute> createState() => _SettingRouteState();
}

class _SettingRouteState extends State<SettingRoute> {
  /// 更新当前cache的文字显示内容
  late ValueNotifier<String?> _localCacheSizeDesc;

  /// 更新当前网络图片缓存的文字显示内容
  late ValueNotifier<String?> _netImageCacheSizeDesc;

  @override
  Widget build(BuildContext context) {
    return MyPopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (result?.isBackGesture == true) {
          Navigator.of(context).pop();
          return;
        }
        if (didPop) return;
      },
      child: Consumer2<ThemeModel, LocaleModel>(
        builder: (context, themeModel, localeModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context).settingDesc),
              // 禁止appbar滚动变色
              notificationPredicate: (notification) => false,
            ),
            // 构建设置菜单
            body: ListView(
              children: [
                ..._buildGeneralSettingTiles(),
                ..._buildPageModeSettingTiles(),
                ..._buildEpubConfSettingTiles(),
                ..._buildClearCacheSettingTiles(),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 通用基础设置
  List<Widget> _buildGeneralSettingTiles() {
    return [
      TitleListTile(
        iconData: Icons.settings,
        title: AppLocalizations.of(context).generalSettingDesc,
        padding: EdgeInsets.zero,
      ),
      // 主题
      ListTile(
        leading: Icon(Icons.color_lens),
        title: Text(
          AppLocalizations.of(context).themeSetting,
          style: TextStyle(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Consumer<ThemeModel>(
          builder: (context, themeModel, _) {
            return SettingDropdownMenu(
              dropDownItems: ThemeColorEnum.values,
              initSelection: themeModel.themeColor,
              onSelected: (color) {
                themeModel.themeColor = color!;
              },
            );
          },
        ),
      ),
      // 语言
      ListTile(
        leading: Icon(Icons.language),
        title: Text(
          AppLocalizations.of(context).languageSetting,
          style: TextStyle(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Consumer<LocaleModel>(
          builder: (context, localeModel, _) {
            // HACK: 增加国际化语言的时候需要维护该表
            var localeMap = {
              "auto": LocaleMenuItemHelper(
                AppLocalizations.of(context).languageSettingAuto,
                null,
              ),
              "zh_CN": LocaleMenuItemHelper("简体中文", "zh_CN"),
              "en_US": LocaleMenuItemHelper("ENGLISH", "en_US"),
            };
            return SettingDropdownMenu(
              dropDownItems: localeMap.values.toList(),
              initSelection: localeMap[localeModel.locale ?? "auto"]!,
              onSelected: (localeMenuItemHelper) {
                localeModel.locale = localeMenuItemHelper?.locale;
              },
            );
          },
        ),
      ),
      // 打开设置提示
      ListTile(
        leading: Icon(Icons.lightbulb),
        title: Text(
          AppLocalizations.of(context).openButtonTips,
          style: TextStyle(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Consumer<ButtonTipsModel>(
          builder: (context, buttonTipsModel, _) {
            return Switch(
              value: buttonTipsModel.buttonTips,
              onChanged: (value) {
                buttonTipsModel.buttonTips = value;
              },
            );
          },
        ),
      ),
    ];
  }

  /// 页面配置
  List<Widget> _buildPageModeSettingTiles() {
    return [
      TitleListTile(
        iconData: Icons.dashboard,
        title: AppLocalizations.of(context).pageSettingDesc,
        padding: EdgeInsets.zero,
      ),
      // 默认页面样式
      ListTile(
        leading: Icon(Icons.grid_view_rounded),
        title: Text(
          AppLocalizations.of(context).defaultPageModeSetting,
          style: TextStyle(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Builder(
          builder: (context) {
            var defaultPageModeModel = Provider.of<DefaultPageModeModel>(
              context,
              listen: false,
            );
            return SettingDropdownMenu(
              width: 90,
              dropDownItems: PageStyleModeEnum.values,
              initSelection: defaultPageModeModel.pageStyleMode,
              onSelected: (pageMode) {
                defaultPageModeModel.pageStyleMode = pageMode!;
              },
            );
          },
        ),
      ),
      // 默认排序方式
      ListTile(
        leading: Icon(Icons.sort_outlined),
        title: Text(
          AppLocalizations.of(context).defaultPageSortedModeSetting,
          style: TextStyle(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Builder(
          builder: (context) {
            var defaultPageModeModel = Provider.of<DefaultPageModeModel>(
              context,
              listen: false,
            );
            return SettingDropdownMenu(
              width: 90,
              dropDownItems: PageSortedModeEnum.values,
              initSelection: defaultPageModeModel.pageSortedMode,
              onSelected: (pageMode) {
                defaultPageModeModel.pageSortedMode = pageMode!;
              },
            );
          },
        ),
      ),
      // 默认网格模式每行图片数
      ListTile(
        leading: Icon(Icons.view_module),
        title: Text(
          AppLocalizations.of(context).defaultPageGridCrossCountSetting,
          style: TextStyle(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Builder(
          builder: (context) {
            var defaultPageModeModel = Provider.of<DefaultPageModeModel>(
              context,
              listen: false,
            );
            var crossCountMap =
                GridCrossCountMenuItemHelper.gridCrossCountItemMap;
            return SettingDropdownMenu(
              width: 40,
              dropDownItems: crossCountMap.values.toList(),
              initSelection:
                  crossCountMap[defaultPageModeModel.gridCrossCount]!,
              onSelected: (value) {
                var count = value?.crossCount;
                defaultPageModeModel.gridCrossCount =
                    count ?? defaultPageModeModel.gridCrossCount;
              },
            );
          },
        ),
      ),
    ];
  }

  /// epub阅读设置
  List<Widget> _buildEpubConfSettingTiles() {
    return [
      TitleListTile(
        iconData: Icons.menu_book,
        title: AppLocalizations.of(context).readingSettingDesc,
        padding: EdgeInsets.zero,
      ),
      // 字体大小
      ListTile(
        leading: Icon(Icons.format_size),
        title: Text(
          AppLocalizations.of(context).defaultEpubFontSizeSetting,
          style: TextStyle(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Builder(
          builder: (context) {
            var defaultEpubConfModel = Provider.of<DefaultEpubConfModel>(
              context,
              listen: false,
            );
            return SettingDropdownMenu(
              width: 40,
              dropDownItems: EpubFontSizeEnmu.values,
              initSelection: defaultEpubConfModel.fontSize,
              onSelected: (epubConf) {
                defaultEpubConfModel.fontSize = epubConf!;
              },
            );
          },
        ),
      ),
      // 预缓存页数
      ListTile(
        leading: Icon(Icons.layers),
        title: Text(
          AppLocalizations.of(context).defaultEpubPreloadNumSetting,
          style: TextStyle(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Builder(
          builder: (context) {
            var defaultEpubConfModel = Provider.of<DefaultEpubConfModel>(
              context,
              listen: false,
            );
            return SettingDropdownMenu(
              width: 40,
              dropDownItems: EpubPreloadNumMenuItemHelper.epubPreloadNumItems,
              initSelection:
                  EpubPreloadNumMenuItemHelper
                      .epubPreloadNumItems[defaultEpubConfModel.preloadNum],
              onSelected: (preloadNum) {
                defaultEpubConfModel.preloadNum = preloadNum!.preloadNum;
              },
            );
          },
        ),
      ),
      // 背景颜色
      ListTile(
        leading: Icon(Icons.invert_colors),
        title: Text(
          AppLocalizations.of(context).defaultEpubBackgroundColorSetting,
          style: TextStyle(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Builder(
          builder: (context) {
            var defaultEpubConfModel = Provider.of<DefaultEpubConfModel>(
              context,
              listen: true,
            );
            return Switch(
              value: defaultEpubConfModel.withTheme,
              onChanged: (value) {
                defaultEpubConfModel.withTheme = value;
              },
            );
          },
        ),
      ),

      // 阅读方向
      // ListTile(
      //   leading: Icon(Icons.view_carousel),
      //   title: Text(
      //     AppLocalizations.of(context).readDirection,
      //     style: TextStyle(fontWeight: FontWeight.bold),
      //     overflow: TextOverflow.ellipsis,
      //   ),
      //   trailing: Consumer<DefaultEpubConfModel>(
      //     builder: (context, defaultEpubConfModel, child) {
      //       return SettingDropdownMenu(
      //         width: 60,
      //         dropDownItems:
      //             _EpubReadingDirectionMenuItemHelper.epubPreloadNumItems.values
      //                 .toList(),
      //         initSelection:
      //             _EpubReadingDirectionMenuItemHelper
      //                 .epubPreloadNumItems[defaultEpubConfModel.direction],
      //         onSelected: (axis) {
      //           defaultEpubConfModel.direction = axis!.direction;
      //         },
      //       );
      //     },
      //   ),
      // ),
    ];
  }

  /// 缓存操作
  List<Widget> _buildClearCacheSettingTiles() {
    return [
      TitleListTile(
        iconData: Icons.cleaning_services,
        title: AppLocalizations.of(context).clearCacheSettingDesc,
        padding: EdgeInsets.zero,
      ),
      // 配置缓存
      ListTile(
        title: ElevatedButton(
          onPressed: () async {
            /// 防抖，防止用户多次点击
            Global.instance.debouncer.debounce(
              duration: Duration(milliseconds: 200),
              onDebounce: () async {
                var confirm = await DoubleConfirmDialogOverlay.show(
                  context: context,
                  confirmText: AppLocalizations.of(context).confirmText,
                  cancelText: AppLocalizations.of(context).cancleText,
                  confirmColor: Colors.red,
                  title: AppLocalizations.of(context).clearConfigCache,
                  message: AppLocalizations.of(context).clearConfigCacheDesc,
                );
                if (confirm != true) return;
                // 删除配置
                CallBackResult? success;
                if (mounted) {
                  success = await LoadingDialog.show(
                    progressBarColor: Theme.of(context).primaryColor,
                    context: context,
                    progressBarStyle: ProgressBarStyle.circular,
                    message: AppLocalizations.of(context).waitingDisplay,
                    task: (updateProgress) async {
                      var notifier = Provider.of<GlobalProfileChangeNotifier>(
                        context,
                        listen: false,
                      );
                      // netList不能刷新
                      var netList = Provider.of<NetDevicesModel>(
                        context,
                        listen: false,
                      );
                      await Global.instance.pref.clear();
                      var profile = GlobalProfile.fromJson({})
                        ..netDevices = netList.netDevices;
                      Global.instance.globalProfile = GlobalProfile.fromJson(
                        profile.toJson(),
                      );
                      notifier.notifyListeners();
                      if (context.mounted) {
                        // 刷新页面
                        Navigator.of(context).pushAndRemoveUntil(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    HomePageRoute(),
                            transitionsBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                              child,
                            ) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(
                              milliseconds: 600,
                            ), // 控制动画时长
                          ),
                          (route) => false,
                        );
                      }
                      return CallBackResult.success();
                    },
                  );
                }
                if (success == null) return;
                if (mounted) {
                  if (success.success == false) {
                    StatusToast.show(
                      context: context,
                      message: success.result ?? "",
                      isSuccess: false,
                    );
                    return;
                  }
                  StatusToast.show(
                    context: context,
                    message: AppLocalizations.of(context).successDelete,
                    isSuccess: true,
                  );
                  await OkAlertDialogOverlay.show(
                    context: context,
                    okText: AppLocalizations.of(context).confirmText,
                    title: AppLocalizations.of(context).successDelete,
                    message: AppLocalizations.of(context).restartToApplyChanges,
                  );
                }
              },
            );
          },
          style: ElevatedButton.styleFrom(elevation: 3),
          child: Text(AppLocalizations.of(context).clearConfigCache),
        ),
      ),
      // 文件缓存
      ListTile(
        title: ElevatedButton(
          onPressed: () async {
            /// 防抖，防止用户多次点击
            Global.instance.debouncer.debounce(
              duration: Duration(milliseconds: 200),
              onDebounce: () async {
                var confirm = await DoubleConfirmDialogOverlay.show(
                  context: context,
                  confirmText: AppLocalizations.of(context).confirmText,
                  cancelText: AppLocalizations.of(context).cancleText,
                  confirmColor: Colors.red,
                  title: AppLocalizations.of(context).clearLocalCache,
                  message: AppLocalizations.of(context).clearLocalCacheDesc,
                );
                if (confirm != true) return;
                var cacheSize =
                    _localCacheSizeDesc.value ??
                    await ApplicationCacheManager.instance.getCacheSizeDesc();

                // 删除缓存
                CallBackResult? success;
                if (mounted) {
                  success = await LoadingDialog.show(
                    progressBarColor: Theme.of(context).primaryColor,
                    context: context,
                    progressBarStyle: ProgressBarStyle.circular,
                    message: AppLocalizations.of(context).waitingDisplay,
                    task: (updateProgress) async {
                      await ApplicationCacheManager.instance.clearCache();
                      return CallBackResult.success();
                    },
                  );
                }
                _localCacheSizeDesc.value =
                    await ApplicationCacheManager.instance.getCacheSizeDesc();
                if (success == null) return;
                if (mounted) {
                  if (success.success == false) {
                    StatusToast.show(
                      context: context,
                      message: success.result ?? "",
                      isSuccess: false,
                    );
                    return;
                  }
                  StatusToast.show(
                    context: context,
                    message: AppLocalizations.of(context).successDelete,
                    isSuccess: true,
                  );
                  OkAlertDialogOverlay.show(
                    context: context,
                    okText: AppLocalizations.of(context).confirmText,
                    title: AppLocalizations.of(context).successDelete,
                    message: AppLocalizations.of(
                      context,
                    ).successClearCache(cacheSize),
                  );
                }
              },
            );
          },
          style: ElevatedButton.styleFrom(elevation: 3),
          child: ValueListenableBuilder(
            valueListenable: _localCacheSizeDesc,
            builder: (context, localCacheSizeDesc, _) {
              return Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "${AppLocalizations.of(context).clearLocalCache} (",
                    ),
                    localCacheSizeDesc == null
                        ? WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                            ),
                            child: SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                        : TextSpan(text: localCacheSizeDesc),
                    TextSpan(text: ")"),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      // 图片缓存
      ListTile(
        title: ElevatedButton(
          onPressed: () async {
            /// 防抖，防止用户多次点击
            Global.instance.debouncer.debounce(
              duration: Duration(milliseconds: 200),
              onDebounce: () async {
                var confirm = await DoubleConfirmDialogOverlay.show(
                  context: context,
                  confirmText: AppLocalizations.of(context).confirmText,
                  cancelText: AppLocalizations.of(context).cancleText,
                  confirmColor: Colors.red,
                  title: AppLocalizations.of(context).clearImageCache,
                  message: AppLocalizations.of(context).clearImageCacheDesc,
                );
                if (confirm != true) return;
                var cacheSize =
                    _netImageCacheSizeDesc.value ??
                    await ApplicationCacheManager.instance
                        .getCachedNetworkImageSize();

                // 删除缓存
                CallBackResult? success;
                if (mounted) {
                  success = await LoadingDialog.show(
                    progressBarColor: Theme.of(context).primaryColor,
                    context: context,
                    progressBarStyle: ProgressBarStyle.circular,
                    message: AppLocalizations.of(context).waitingDisplay,
                    task: (updateProgress) async {
                      await ApplicationCacheManager.instance
                          .clearNetworkImageCache();
                      return CallBackResult.success();
                    },
                  );
                }
                _netImageCacheSizeDesc.value =
                    await ApplicationCacheManager.instance
                        .getCachedNetworkImageSize();
                if (success == null) return;
                if (mounted) {
                  if (success.success == false) {
                    StatusToast.show(
                      context: context,
                      message: success.result ?? "",
                      isSuccess: false,
                    );
                    return;
                  }
                  StatusToast.show(
                    context: context,
                    message: AppLocalizations.of(context).successDelete,
                    isSuccess: true,
                  );
                  OkAlertDialogOverlay.show(
                    context: context,
                    okText: AppLocalizations.of(context).confirmText,
                    title: AppLocalizations.of(context).successDelete,
                    message: AppLocalizations.of(
                      context,
                    ).successClearCache(cacheSize),
                  );
                }
              },
            );
          },
          style: ElevatedButton.styleFrom(elevation: 3),
          child: ValueListenableBuilder(
            valueListenable: _netImageCacheSizeDesc,
            builder: (context, netImageCacheSizeDesc, _) {
              return Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "${AppLocalizations.of(context).clearImageCache} (",
                    ),
                    netImageCacheSizeDesc == null
                        ? WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                            ),
                            child: SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                        : TextSpan(text: netImageCacheSizeDesc),
                    TextSpan(text: ")"),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _localCacheSizeDesc = ValueNotifier(null);
    _netImageCacheSizeDesc = ValueNotifier(null);
    Future.wait([
      Future(() async {
        _localCacheSizeDesc.value =
            await ApplicationCacheManager.instance.getCacheSizeDesc();
      }),
      Future(() async {
        _netImageCacheSizeDesc.value =
            await ApplicationCacheManager.instance.getCachedNetworkImageSize();
      }),
    ]);
  }

  @override
  void dispose() {
    _localCacheSizeDesc.dispose();
    _netImageCacheSizeDesc.dispose();
    super.dispose();
  }
}
