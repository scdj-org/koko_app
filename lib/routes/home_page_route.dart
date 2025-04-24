import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:koko/common/application_cache_manager.dart';
import 'package:koko/common/data_source_manager/webdav_data_source_manager.dart';
import 'package:koko/common/global.dart';
import 'package:koko/common/data_source_manager/local_data_source_manager.dart';
import 'package:koko/enums/protocol_enum.dart';
import 'package:koko/l10n/l10n.dart';
import 'package:koko/models/entity/call_back_result.dart';
import 'package:koko/models/model/button_tips_model.dart';
import 'package:koko/models/model/move_file_model.dart';
import 'package:koko/models/model/net_devices_model.dart';
import 'package:koko/models/entity/view_page_entity.dart';
import 'package:koko/routes/network_device_form.dart';
import 'package:koko/widgets/overlay/buttom_setting_overlay.dart';
import 'package:koko/widgets/overlay/double_confirm_dialog_overlay.dart';
import 'package:koko/widgets/overlay/loading_dialog.dart';
import 'package:koko/widgets/overlay/status_toast.dart';
import 'package:koko/widgets/ui_widgets/floating_button.dart';
import 'package:koko/widgets/ui_widgets/rounded_list_tile.dart';
import 'package:koko/widgets/ui_widgets/title_list_tile.dart';
import 'package:provider/provider.dart';

class HomePageRoute extends StatefulWidget {
  const HomePageRoute({super.key});

  @override
  State<HomePageRoute> createState() => _HomePageRouteState();
}

/// 主页面
class _HomePageRouteState extends State<HomePageRoute> with RestorationMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      // 悬浮按钮
      floatingActionButton: _buildFloatingButton(),
    );
  }

  // body
  Widget _buildBody() {
    return Consumer<NetDevicesModel>(
      builder: (context, netDevicesModel, child) {
        return SlidableAutoCloseBehavior(
          child: ListView(
            children: [
              // 标题项
              TitleListTile(
                iconData: Icons.devices,
                title: AppLocalizations.of(context).homePageDevice,
              ),
              // 本地目录
              RoundedListTile(
                leading: Icon(Icons.folder_open_rounded),
                title: Text(
                  AppLocalizations.of(context).homePageLocalRepositories,
                ),
                needDebounce: true,
                debounceDuration: Duration(milliseconds: 100),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () async {
                  var entity = ViewPageEntity(
                    isRoot: true,
                    isDir: true,
                    absPath: LocalDataSourceManager.instance.rootPath,
                  );
                  entity =
                      (await LocalDataSourceManager.instance.getInfo(
                            entity,
                          )).result
                          as ViewPageEntity;
                  // 更新设备id
                  Global.instance.deviceId = 0;
                  // 清理移动model
                  if (context.mounted) {
                    var moveFileModel = Provider.of<MoveFileModel>(
                      context,
                      listen: false,
                    );
                    moveFileModel.clear();
                  }
                  _viewPageRouteFuture.present([
                    {
                      "dataSource": ProtocolEnum.local.protocolId,
                      "entity": entity.toJson(),
                    },
                  ]);
                },
              ),

              // 网络云盘列表
              ...netDevicesModel.netDevices.isEmpty
                  ? []
                  : [
                    // 标题项目
                    TitleListTile(
                      iconData: Icons.language,
                      title: AppLocalizations.of(context).homePageNetwork,
                    ),
                    for (int i = 1; i < netDevicesModel.netDevices.length; i++)
                      RoundedListTile(
                        endActionPane: ActionPane(
                          extentRatio: 0.175,
                          motion: DrawerMotion(),
                          children: [
                            CustomSlidableAction(
                              autoClose: true,
                              padding: EdgeInsets.zero,
                              onPressed: (context1) async {
                                var confirm =
                                    await DoubleConfirmDialogOverlay.show(
                                      context: context,
                                      confirmColor: Colors.red,
                                      title:
                                          AppLocalizations.of(
                                            context,
                                          ).removeNetDevice,
                                      message:
                                          AppLocalizations.of(
                                            context,
                                          ).removeNetDeviceDesc,
                                    );
                                if (confirm == true && context.mounted) {
                                  var netList = Provider.of<NetDevicesModel>(
                                    context,
                                    listen: false,
                                  );
                                  netList.removeNetDevice =
                                      netDevicesModel.netDevices[i];
                                  await LoadingDialog.show(
                                    context: context,
                                    message:
                                        AppLocalizations.of(
                                          context,
                                        ).waitingDisplay,
                                    progressBarStyle: ProgressBarStyle.circular,
                                    task: (updateProgress) async {
                                      Global.instance.deviceId =
                                          netDevicesModel.netDevices[i].id;
                                      await ApplicationCacheManager.instance
                                          .deleteEntity("");
                                      return CallBackResult.success();
                                    },
                                  );
                                  if (context.mounted) {
                                    StatusToast.show(
                                      context: context,
                                      message:
                                          AppLocalizations.of(
                                            context,
                                          ).successDelete,
                                      isSuccess: true,
                                    );
                                  }
                                }
                              },
                              backgroundColor: Color(0xFFFE4A49),
                              foregroundColor: Colors.white,
                              child: Icon(Icons.delete, size: 28),
                            ),
                          ],
                        ),
                        leading: netDevicesModel.netDevices[i].protocol.icon,
                        needDebounce: true,
                        debounceDuration: Duration(milliseconds: 100),
                        title: Text(
                          netDevicesModel.netDevices[i].name ??
                              "${netDevicesModel.netDevices[i].baseurl}${netDevicesModel.netDevices[i].port == null ? "" : ":${netDevicesModel.netDevices[i].port}"}",
                        ),
                        trailing: Icon(Icons.keyboard_arrow_right),
                        onTap: () async {
                          ViewPageEntity entity = ViewPageEntity(
                            isRoot: true,
                            isDir: true,
                            absPath: "",
                          );
                          if (netDevicesModel.netDevices[i].protocol ==
                              ProtocolEnum.webdav) {
                            var uri = netDevicesModel.netDevices[i].baseurl;
                            var rootPath =
                                netDevicesModel.netDevices[i].rootPath ?? "";
                            var port = netDevicesModel.netDevices[i].port;
                            try {
                              await WebdavDataSourceManager.instance.init(
                                uri: uri,
                                port: port,
                                rootPath: rootPath,
                                user:
                                    netDevicesModel.netDevices[i].account ?? "",
                                password:
                                    netDevicesModel.netDevices[i].password ??
                                    "",
                              );
                              var temp = ViewPageEntity(
                                isRoot: true,
                                isDir: true,
                                absPath: rootPath,
                              );
                              entity =
                                  (await WebdavDataSourceManager.instance
                                          .getInfo(temp)).result
                                      as ViewPageEntity;
                            } on TypeError {
                              if (context.mounted) {
                                StatusToast.show(
                                  context: context,
                                  message:
                                      AppLocalizations.of(context).connectFaild,
                                  isSuccess: false,
                                );
                              }
                              return;
                            } catch (e) {
                              if (context.mounted) {
                                StatusToast.show(
                                  context: context,
                                  message: e.toString(),
                                  isSuccess: false,
                                );
                              }
                              return;
                            }
                          }
                          // 更新设备id
                          Global.instance.deviceId =
                              netDevicesModel.netDevices[i].id;
                          // 清理移动model
                          if (context.mounted) {
                            var moveFileModel = Provider.of<MoveFileModel>(
                              context,
                              listen: false,
                            );
                            moveFileModel.clear();
                          }
                          _viewPageRouteFuture.present([
                            {
                              "dataSource": ProtocolEnum.webdav.protocolId,
                              "entity": entity.toJson(),
                            },
                          ]);
                        },
                      ),
                  ],
            ],
          ),
        );
      },
    );
  }

  // floatingButtons
  Widget _buildFloatingButton() {
    return Consumer<ButtonTipsModel>(
      builder: (context, buttonTipsModel, _) {
        return FloatingButton(
          children: [
            // 导入
            SpeedDialChild(
              child: const Icon(Icons.add_circle),
              label:
                  buttonTipsModel.buttonTips
                      ? AppLocalizations.of(context).importDesc
                      : null,
              onTap: () {
                ButtomSettingOverlay.show(
                  context: context,
                  title: Text(
                    AppLocalizations.of(context).addNetDevice,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  tiles: [],
                  child: NetworkDeviceForm(
                    onSubmit: () {
                      StatusToast.show(
                        context: context,
                        message: AppLocalizations.of(context).successCreate,
                        isSuccess: true,
                      );
                    },
                  ),
                  panelHeight:
                      MediaQueryData.fromView(View.of(context)).size.height *
                      3 /
                      4,
                );
              },
              // 颜色与主题保持一致
              backgroundColor: Theme.of(context).colorScheme.primaryFixed,
            ),
            // 设置
            SpeedDialChild(
              child: const Icon(Icons.settings),
              label:
                  buttonTipsModel.buttonTips
                      ? AppLocalizations.of(context).settingDesc
                      : null,
              onTap: () {
                Navigator.of(context).pushNamed("setting_route");
              },
              // 颜色与主题保持一致
              backgroundColor: Theme.of(context).colorScheme.primaryFixed,
            ),
          ],
        );
      },
    );
  }

  //----------------------------------------
  // 路由恢复
  // HACK: 不知道有没有用，先加上吧
  //----------------------------------------
  @override
  String? get restorationId => "home_page_route";

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_viewPageRouteFuture, "view_page_route");
  }

  final RestorableRouteFuture<void> _viewPageRouteFuture =
      RestorableRouteFuture<void>(
        onPresent: (navigator, arguments) {
          return navigator.restorablePushNamed(
            "view_page_route",
            arguments: (arguments as List)[0],
          );
        },
        onComplete: (result) {
          if (kDebugMode) {
            debugPrint("返回主页");
          }
        },
      );
}
