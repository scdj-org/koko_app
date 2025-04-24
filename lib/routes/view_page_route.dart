import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:koko/common/data_source_manager/local_data_source_manager.dart';
import 'package:koko/common/global.dart';
import 'package:koko/common/route_observer_instance.dart';
import 'package:koko/enums/toast_enum.dart';
import 'package:koko/l10n/l10n.dart';
import 'package:koko/models/entity/call_back_result.dart';
import 'package:koko/models/entity/choice_option.dart';
import 'package:koko/models/model/button_tips_model.dart';
import 'package:koko/models/model/default_page_mode.dart';
import 'package:koko/models/model/move_file_model.dart';
import 'package:koko/widgets/overlay/double_confirm_dialog_overlay.dart';
import 'package:koko/widgets/overlay/extra_operation_overlay.dart';
import 'package:koko/widgets/ui_widgets/floating_button.dart';
import 'package:koko/widgets/overlay/loading_dialog.dart';
import 'package:koko/widgets/ui_widgets/loading_widget.dart';
import 'package:koko/widgets/overlay/multi_choice_dialog_overlay.dart';
import 'package:koko/widgets/overlay/multi_line_input_dialog_overlay.dart';
import 'package:koko/widgets/overlay/status_toast.dart';

import 'package:koko/common/view_page_entity_list_extension.dart';
import 'package:koko/enums/page_style_mode_enum.dart';
import 'package:koko/enums/page_sorted_mode_enum.dart';
import 'package:koko/interface/data_source_manager_interface.dart';
import 'package:koko/models/entity/page_profile.dart';
import 'package:koko/models/entity/view_page_entity.dart';
import 'package:koko/widgets/ui_widgets/keep_alive_wrapper.dart';
import 'package:koko/widgets/ui_widgets/moving_overlay_widget.dart';
import 'package:koko/widgets/ui_widgets/page_error_widget.dart';
import 'package:koko/widgets/ui_widgets/rounded_list_tile.dart';
import 'package:provider/provider.dart';

class ViewPageRoute extends StatefulWidget {
  const ViewPageRoute({
    super.key,
    required this.dataSource,
    required this.entity,
  });

  /// 加载列表尾部
  static const loadingTag = "##loading##";

  /// 数据源
  final DataSourceManagerInterface dataSource;

  /// 当前页面的entity
  final ViewPageEntity entity;

  @override
  State<ViewPageRoute> createState() => _ViewPageRouteState();
}

/// 文件列表渲染页
class _ViewPageRouteState extends State<ViewPageRoute>
    with RouteAware, SingleTickerProviderStateMixin, RestorationMixin {
  //----------------------------------------
  // 全局配置文件
  //----------------------------------------

  /// 强制刷新
  ///
  /// 采用动画局部更新时，改参数用于动画数据为0但是需要强制刷新的情况
  late final ValueNotifier<bool> _forceRefreshNotifier;

  /// 多选状态管理
  late final ValueNotifier<Set<ViewPageEntity>> _selectedItems;

  /// 是否多选状态
  late final ValueNotifier<bool> _isMultipleSelect;

  /// 滚动监听配置
  /// HACK: 后续用来控制查找文件自动跳转
  late final ScrollController _scrollController;

  //----------------------------------------
  // 页面骨架构建
  //----------------------------------------

  @override
  Widget build(BuildContext context) {
    /// HACK 这里可能会有bug，之后测试一下
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  /// AppBar构造
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: FutureBuilder(
        // 等待初始化完成
        future: _waitInitFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Text("");
          }
          return Text(
            widget.entity.showName(),
            overflow: TextOverflow.ellipsis,
          );
        },
      ),
      actions: _buildAppbarActions(),
      notificationPredicate: (notification) => false,
    );
  }

  /// AppbarAction按钮
  List<Widget> _buildAppbarActions() {
    return [
      ValueListenableBuilder(
        valueListenable: _isMultipleSelect,
        builder: (context, isMultipleSelect, _) {
          return Consumer<MoveFileModel>(
            child: Text(
              isMultipleSelect
                  ? AppLocalizations.of(context).finish
                  : AppLocalizations.of(context).select,
              style: TextStyle(fontSize: 16),
            ),
            builder: (context, moveFileModel, child) {
              return TextButton(
                onPressed:
                    moveFileModel.isMoving
                        ? null
                        : () {
                          if (!_isMultipleSelect.value) {
                            if (!ExtraOperationOverlay.isVisible) {
                              ExtraOperationOverlay.show(
                                context: context,
                                child: IntrinsicHeight(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          _selectAll(true);
                                        },
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          ).selectAll,
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        width: 0.5,
                                        color: Colors.grey[500],
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          _selectAll(false);
                                        },
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          ).deselectAll,
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        width: 0.5,
                                        color: Colors.grey[500],
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          var moveFileModel =
                                              Provider.of<MoveFileModel>(
                                                context,
                                                listen: false,
                                              );
                                          moveFileModel.init(
                                            source: widget.entity,
                                            entities: _selectedItems.value,
                                          );
                                          _selectedItems.value.clear();
                                          _isMultipleSelect.value = false;
                                          ExtraOperationOverlay.dismiss();
                                        },
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          ).moveFiles,
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        width: 0.5,
                                        color: Colors.grey[500],
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          var success = await _deleteFiles(
                                            _selectedItems.value.toList(),
                                          );
                                          if (success) {
                                            _selectedItems.value.clear();
                                            _isMultipleSelect.value = false;
                                            ExtraOperationOverlay.dismiss();
                                          }
                                        },
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          ).deleteFiles,
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              StatusToast.show(
                                context: context,
                                message:
                                    AppLocalizations.of(
                                      context,
                                    ).warningClickFrequently,
                                isSuccess: false,
                              );
                              return;
                            }
                          } else {
                            if (ExtraOperationOverlay.isVisible) {
                              ExtraOperationOverlay.dismiss();
                            } else {
                              StatusToast.show(
                                context: context,
                                message:
                                    AppLocalizations.of(
                                      context,
                                    ).warningClickFrequently,
                                isSuccess: false,
                              );
                              return;
                            }
                          }
                          _isMultipleSelect.value = !_isMultipleSelect.value;
                          _selectedItems.value.clear();
                        },
                child: child!,
              );
            },
          );
        },
      ),
    ];
  }

  /// body骨架构造
  Widget _buildBody(BuildContext context) {
    return FutureBuilder(
      future: _waitInitFuture,
      builder: (context, snapshot) {
        // 没有初始化完返回一个加载中
        if (snapshot.connectionState != ConnectionState.done) {
          return ListView(children: [_buildLoading(context)]);
        }

        // 加载pageMode
        _loadRealPageProfile(context);

        /// 通过pageMode载入对应的模式视图
        return Scrollbar(
          controller: _scrollController,
          child: ValueListenableBuilder<bool>(
            valueListenable: _forceRefreshNotifier,
            builder: (context, _, child) {
              return Stack(
                children: [
                  switch (pageStyleMode) {
                    // 简单列表
                    PageStyleModeEnum.simpleList => _buildSimpleListModeView(
                      context,
                    ),
                    // 网格视图
                    PageStyleModeEnum.gridView => _buildGridModeView(context),
                    // 图片列表
                    PageStyleModeEnum.picList => _buildPicListModeView(context),
                  },
                  Consumer<MoveFileModel>(
                    builder: (context, moveFileModel, child) {
                      if (moveFileModel.isMoving) {
                        return MovingOverlayWidget(
                          moveFileModel: moveFileModel,
                          onConfirm:
                              moveFileModel.sourceDir == widget.entity
                                  ? null
                                  : () async {
                                    // 二次确认dialog
                                    var confirm =
                                        await DoubleConfirmDialogOverlay.show(
                                          context: context,
                                          confirmText:
                                              AppLocalizations.of(
                                                context,
                                              ).confirmText,
                                          cancelText:
                                              AppLocalizations.of(
                                                context,
                                              ).cancleText,
                                          title:
                                              AppLocalizations.of(
                                                context,
                                              ).confirmMoveFile,
                                          message:
                                              AppLocalizations.of(
                                                context,
                                              ).confirmMoveFileMessage,
                                          confirmColor: Colors.red,
                                        );
                                    if (confirm != true) return;
                                    var entitys =
                                        moveFileModel.sourceEntities.toList();
                                    CallBackResult? result;
                                    if (context.mounted) {
                                      result = await LoadingDialog.show(
                                        progressBarColor:
                                            Theme.of(context).primaryColor,
                                        context: context,
                                        progressBarStyle:
                                            ProgressBarStyle.circular,
                                        message:
                                            AppLocalizations.of(
                                              context,
                                            ).waitingDisplay,
                                        task: (updateProgress) async {
                                          return await widget.dataSource
                                              .moveFiles(
                                                entitys,
                                                widget.entity,
                                              );
                                        },
                                      );
                                    }

                                    // 检查一下是否成功
                                    if (result == null ||
                                        result.success != true) {
                                      if (context.mounted) {
                                        StatusToast.show(
                                          context: context,
                                          message:
                                              result?.result.toString() ??
                                              AppLocalizations.of(
                                                context,
                                              ).operationFailed,
                                          isSuccess: false,
                                          position: ToastPosition.bottom,
                                        );
                                      }
                                      return;
                                    }

                                    // 移动后需要拿到真实信息
                                    entitys = await _loadEntitesInfo(entitys);

                                    // 3. 更新页面
                                    if (context.mounted) {
                                      StatusToast.show(
                                        context: context,
                                        message:
                                            AppLocalizations.of(
                                              context,
                                            ).successMove,
                                        isSuccess: true,
                                        position: ToastPosition.bottom,
                                      );
                                    }

                                    // 4. 更新数据
                                    var itemsSet = _items.toSet();
                                    for (final entity in entitys) {
                                      // 看一下是否相同，相同先删再插
                                      if (itemsSet.contains(entity)) {
                                        _items.remove(entity);
                                        if (kDebugMode) {
                                          print("相同entity，先删再导");
                                        }
                                      }
                                      int index = await _getInsertIndex(
                                        _items,
                                        entity,
                                      );
                                      _items.insert(index, entity);
                                    }

                                    // 5. 刷新页面
                                    if (moveFileModel.sourceDir != null) {
                                      var nowPath =
                                          DataSourceManagerInterface.resolvePath(
                                            widget.entity,
                                          );
                                      var sourcePath =
                                          DataSourceManagerInterface.resolvePath(
                                            moveFileModel.sourceDir!,
                                          );
                                      // 来源是父文件夹，需要更新
                                      if (nowPath.startsWith(sourcePath)) {
                                        Global.instance.backRouteRefreshPath =
                                            moveFileModel.sourceDir;
                                      } else {
                                        Global.instance.backRouteRefreshPath =
                                            null;
                                      }
                                    } else {
                                      Global.instance.backRouteRefreshPath =
                                          null;
                                    }
                                    moveFileModel.clear();
                                    _forceRefreshNotifier.value =
                                        !_forceRefreshNotifier.value;
                                    return;
                                  },
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  /// 悬浮按钮构造
  Widget _buildFloatingActionButton(BuildContext context) {
    return Consumer<ButtonTipsModel>(
      builder: (context, buttonTipsModel, _) {
        return FloatingButton(
          children: [
            // 导入
            _buildImportButton(context, buttonTipsModel.buttonTips),
            // 创建新文件夹
            _buildCreateNewDirButton(context, buttonTipsModel.buttonTips),
            // 返回主页
            _buildBackToHome(context, buttonTipsModel.buttonTips),
          ],
        );
      },
    );
  }

  //----------------------------------------
  // 悬浮按钮
  //----------------------------------------

  /// 导入悬浮按钮
  SpeedDialChild _buildImportButton(BuildContext context, bool buttonTips) {
    return SpeedDialChild(
      label: buttonTips ? AppLocalizations.of(context).importDesc : null,
      // labelBackgroundColor: Theme.of(context).colorScheme.primaryFixed,
      child: const Icon(Icons.file_download_outlined),
      onTap: () async {
        if (widget.dataSource is! LocalDataSourceManager) {
          StatusToast.show(
            context: context,
            message: "暂不支持",
            isSuccess: false,
            position: ToastPosition.bottom,
          );
        }

        // 1. 获取文件
        var pickedFiles = await _pickUpFiles(context);
        if (pickedFiles.isEmpty) {
          if (context.mounted) {
            StatusToast.show(
              context: context,
              message: AppLocalizations.of(context).noSeleted,
              isSuccess: false,
              position: ToastPosition.bottom,
            );
          }
          return;
        }

        // 2. 导入当前文件夹
        CallBackResult? result;
        if (context.mounted) {
          result = await LoadingDialog.show(
            progressBarColor: Theme.of(context).primaryColor,
            context: context,
            progressBarStyle: ProgressBarStyle.circular,
            message: AppLocalizations.of(context).waitingDisplay,
            task: (updateProgress) async {
              return await widget.dataSource.importFiles(
                pickedFiles,
                widget.entity,
              );
            },
          );
        }
        // 检查一下是否成功
        if (result == null || result.success != true) {
          if (context.mounted) {
            StatusToast.show(
              context: context,
              message:
                  result?.result.toString() ??
                  AppLocalizations.of(context).operationFailed,
              isSuccess: false,
              position: ToastPosition.bottom,
            );
          }
          return;
        }
        // copy后需要拿到真实信息
        pickedFiles = await _loadEntitesInfo(pickedFiles);

        // 3. 更新页面
        if (context.mounted) {
          StatusToast.show(
            context: context,
            message: AppLocalizations.of(context).successImport,
            isSuccess: true,
            position: ToastPosition.bottom,
          );
        }

        // 4. 更新数据
        var itemsSet = _items.toSet();
        for (final entity in pickedFiles) {
          // 看一下是否相同，相同先删再插
          if (itemsSet.contains(entity)) {
            _items.remove(entity);
            if (kDebugMode) {
              print("相同entity，先删再导");
            }
          }
          int index = await _getInsertIndex(_items, entity);
          _items.insert(index, entity);
        }

        // 5. 刷新页面
        _forceRefreshNotifier.value = !_forceRefreshNotifier.value;
      },
      // 颜色与主题保持一致
      backgroundColor: Theme.of(context).colorScheme.primaryFixed,
    );
  }

  /// 创建文件夹
  SpeedDialChild _buildCreateNewDirButton(BuildContext context, buttonTips) {
    return SpeedDialChild(
      label: buttonTips ? AppLocalizations.of(context).createDirDesc : null,
      // labelBackgroundColor: Theme.of(context).colorScheme.primaryFixed,
      child: Icon(Icons.create_new_folder),
      // 颜色与主题保持一致
      backgroundColor: Theme.of(context).colorScheme.primaryFixed,
      onTap: () async {
        /// 1.接受用户的输入名称
        var name = await MultiLineInputDialogOverlay.show(
          context: context,
          title: AppLocalizations.of(context).createDirDesc,
          hintText: AppLocalizations.of(context).createDirHintText,
          confirmText: AppLocalizations.of(context).confirmText,
          cancelText: AppLocalizations.of(context).cancleText,
        );

        /// 输入检测
        // 用户取消输入了
        if (name == null) {
          return;
        }
        // 输入为空
        name = name.trim();
        if (name.isEmpty) {
          if (context.mounted) {
            StatusToast.show(
              context: context,
              message: AppLocalizations.of(context).emptyInputDesc,
              isSuccess: false,
              position: ToastPosition.bottom,
            );
          }
          return;
        }
        if (name.contains(RegExp(r'[\\/:\*\?"<>|]'))) {
          if (context.mounted) {
            StatusToast.show(
              context: context,
              message: AppLocalizations.of(context).invaildDirName,
              isSuccess: false,
              position: ToastPosition.bottom,
            );
          }
          return;
        }

        var entity = ViewPageEntity(
          isRoot: false,
          isDir: true,
          absPath: "${widget.entity.absPath}/$name",
        );
        // 如果当前文件夹有该名字了，直接返回
        if (_items.contains(entity)) {
          if (context.mounted) {
            StatusToast.show(
              context: context,
              message: AppLocalizations.of(context).dirHasExsit,
              isSuccess: false,
              position: ToastPosition.bottom,
            );
          }
          return;
        }

        /// 2.创建文件夹
        try {
          var result = await widget.dataSource.createFile(entity);
          // 检查一下是否成功
          if (result.success != true) {
            if (context.mounted) {
              StatusToast.show(
                context: context,
                message: result.result.toString(),
                isSuccess: false,
                position: ToastPosition.bottom,
              );
            }
            return;
          }
        } catch (e) {
          // TODO: 异常操作，记录日志
          if (context.mounted) {
            StatusToast.show(
              context: context,
              message: e.toString(),
              isSuccess: false,
              position: ToastPosition.bottom,
            );
          }
          return;
        }
        entity = (await _loadEntitesInfo([entity])).first;
        // 创建成功写入数据
        int index = await _getInsertIndex(_items, entity);
        _items.insert(index, entity);
        // 刷新
        if (context.mounted) {
          StatusToast.show(
            context: context,
            message: AppLocalizations.of(context).successCreate,
            isSuccess: true,
            position: ToastPosition.bottom,
          );
        }
        _forceRefreshNotifier.value = !_forceRefreshNotifier.value;
      },
    );
  }

  /// 返回根路由
  SpeedDialChild _buildBackToHome(BuildContext context, buttonTips) {
    return SpeedDialChild(
      child: Icon(Icons.home),
      backgroundColor: Theme.of(context).colorScheme.primaryFixed,
      label: buttonTips ? AppLocalizations.of(context).homePage : null,
      onTap: () {
        Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
      },
    );
  }

  //----------------------------------------
  // 简易列表构建
  //----------------------------------------

  /// 简易列表body
  Widget _buildSimpleListModeView(BuildContext context) {
    if (_hasError) {
      return PageErrorWidget(message: _errorData.toString());
    }
    return SlidableAutoCloseBehavior(
      child: ListView.builder(
        restorationId: "simpleList${widget.entity.absPath}",
        controller: _scrollController,
        itemCount: _items.length,
        cacheExtent: MediaQueryData.fromView(View.of(context)).size.height / 2,
        // // item高度，性能优化
        // itemExtent: 88.0,
        itemBuilder: (context, index) {
          // 到末尾了
          if (_items[index].basename == ViewPageRoute.loadingTag) {
            // 如果有数据
            if (_hasMore) {
              // 获取数据
              _retrieveData();
              // 加载
              return _buildLoading(context);
            } else {
              // 没有数据
              return _buildEnding(context);
            }
          }

          // 返回列表项
          var entity = _items[index];
          var icon =
              entity.isDir
                  ? const Icon(Icons.folder, color: Colors.amber)
                  : DataSourceManagerInterface.getFileIcon(entity.extension);

          /// ListView的动画
          ///
          /// 这里重构了，采用animate库
          return KeepAliveWrapper(
            keepAlive: false,
            // 子项抽屉菜单
            child:
                _buildSimpleListItem(
                  icon: icon,
                  entity: entity,
                  context: context,
                ).animate().fade(),
          );
        },
      ),
    );
  }

  /// 简易列表item构造
  Widget _buildSimpleListItem({
    required Widget icon,
    required ViewPageEntity entity,
    required BuildContext context,
  }) {
    return ValueListenableBuilder(
      valueListenable: _isMultipleSelect,
      builder: (context, isMultipleSelect, _) {
        return ValueListenableBuilder(
          valueListenable: _selectedItems,
          builder: (context, itemsSet, _) {
            return Consumer<MoveFileModel>(
              builder: (context, moveFileModel, _) {
                return RoundedListTile(
                  key: ValueKey("${entity.absPath}${entity.isDir}"),
                  endActionPane:
                      moveFileModel.isMoving || isMultipleSelect
                          ? null
                          : _buildActionPane(context, entity),
                  leading: icon,
                  title: Text(
                    entity.showName(showExtension: true),
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing:
                      isMultipleSelect
                          ? IconButton(
                            onPressed: () {
                              _toggleSelection(entity);
                            },
                            icon: Icon(
                              size: 24,
                              color: Theme.of(context).primaryColor,
                              itemsSet.contains(entity)
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                            ),
                          )
                          : entity.isDir
                          ? const Icon(Icons.keyboard_arrow_right)
                          : Text(entity.sizeDesc!),
                  onTap:
                      isMultipleSelect
                          ? () {
                            _toggleSelection(entity);
                          }
                          : entity.isDir
                          ? moveFileModel.isMoving &&
                                  moveFileModel.sourceEntities.contains(entity)
                              ? null
                              : () async {
                                await _openDir(entity);
                              }
                          : moveFileModel.isMoving
                          ? null
                          : () async {
                            /// 防抖，防止用户多次点击不同文件
                            Global.instance.debouncer.debounce(
                              duration: Duration(milliseconds: 200),
                              onDebounce: () async {
                                await _openFile(entity);
                              },
                            );
                          },
                );
              },
            );
          },
        );
      },
    );
  }

  ActionPane _buildActionPane(BuildContext context, ViewPageEntity entity) {
    return ActionPane(
      extentRatio: 0.35,
      motion: DrawerMotion(),
      children: [
        CustomSlidableAction(
          autoClose: true,
          padding: EdgeInsets.zero,
          // 这里的context很可能已经无了，所以用父组件的
          onPressed: (context1) async {
            /// 1.接受用户的输入名称
            var name = await MultiLineInputDialogOverlay.show(
              context: context,
              title: AppLocalizations.of(context).renameFile,
              hintText: AppLocalizations.of(context).renameFileHintText,
              confirmText: AppLocalizations.of(context).confirmText,
              cancelText: AppLocalizations.of(context).cancleText,
            );

            /// 输入检测
            // 用户取消输入了
            if (name == null) {
              return;
            }
            // 输入为空
            name = name.trim();
            if (name.isEmpty) {
              if (context.mounted) {
                StatusToast.show(
                  context: context,
                  message: AppLocalizations.of(context).emptyInputDesc,
                  isSuccess: false,
                  position: ToastPosition.bottom,
                );
              }
              return;
            }
            if (name.contains(RegExp(r'[\\/:\*\?"<>|]'))) {
              if (context.mounted) {
                StatusToast.show(
                  context: context,
                  message: AppLocalizations.of(context).invaildDirName,
                  isSuccess: false,
                  position: ToastPosition.bottom,
                );
              }
              return;
            }

            // 2.重命名
            var newName =
                "${(await widget.dataSource.getParent(entity))!.absPath}/$name${entity.extension != null && entity.extension!.isNotEmpty && !entity.isDir ? "${entity.extension}" : ""}";
            ViewPageEntity targetEntity = ViewPageEntity(
              isRoot: false,
              isDir: entity.isDir,
              absPath: newName,
            );

            try {
              targetEntity = await widget.dataSource.renameFile(
                entity,
                targetEntity,
              );
            } catch (e) {
              // TODO: 异常操作，记录日志
              if (context.mounted) {
                StatusToast.show(
                  context: context,
                  message: e.toString(),
                  isSuccess: false,
                  position: ToastPosition.bottom,
                );
              }
              return;
            }

            // 3.更新数据
            _items.remove(entity);
            var index = await _getInsertIndex(_items, targetEntity);
            _items.insert(index, targetEntity);

            // 4.刷新页面
            _forceRefreshNotifier.value = !_forceRefreshNotifier.value;
            if (context.mounted) {
              StatusToast.show(
                context: context,
                message: AppLocalizations.of(context).successRename,
                isSuccess: true,
              );
            }
          },
          backgroundColor: Color(0xFF21B7CA),
          foregroundColor: Colors.white,
          child: Icon(Icons.edit, size: 28),
        ),
        // 删除
        CustomSlidableAction(
          autoClose: true,
          padding: EdgeInsets.zero,
          onPressed: (context1) async {
            await _deleteFiles([entity]);
          },
          backgroundColor: Color(0xFFFE4A49),
          foregroundColor: Colors.white,
          child: Icon(Icons.delete, size: 28),
        ),
      ],
    );
  }

  /// 删除
  Future<bool> _deleteFiles(List<ViewPageEntity> entitys) async {
    {
      // 二次确认dialog
      var confirm = await DoubleConfirmDialogOverlay.show(
        context: context,
        confirmText: AppLocalizations.of(context).confirmText,
        cancelText: AppLocalizations.of(context).cancleText,
        title: AppLocalizations.of(context).confirmDeleteFile,
        message: AppLocalizations.of(context).confirmDeleteFileMessage,
        confirmColor: Colors.red,
      );
      if (confirm != true) return false;

      CallBackResult? result;
      if (mounted) {
        result = await LoadingDialog.show(
          progressBarColor: Theme.of(context).primaryColor,
          context: context,
          progressBarStyle: ProgressBarStyle.circular,
          message: AppLocalizations.of(context).waitingDisplay,
          task: (updateProgress) async {
            return await widget.dataSource.deleteFiles(entitys);
          },
        );
      }

      // 检查一下是否成功
      if (result == null || result.success != true) {
        if (mounted) {
          StatusToast.show(
            context: context,
            message:
                result?.result.toString() ??
                AppLocalizations.of(context).operationFailed,
            isSuccess: false,
            position: ToastPosition.bottom,
          );
        }
        return false;
      }
      for (var entity in entitys) {
        _items.remove(entity);
      }
      _forceRefreshNotifier.value = !_forceRefreshNotifier.value;
      if (mounted) {
        StatusToast.show(
          context: context,
          message: AppLocalizations.of(context).successDelete,
          isSuccess: true,
        );
      }
      return true;
    }
  }

  //----------------------------------------
  // 网格模式构造
  //----------------------------------------

  /// 网格模式body
  Widget _buildGridModeView(BuildContext context) {
    // 没有item
    if (!_hasMore && _items.length == 1) {
      return Column(children: [_buildEnding(context)]);
    }
    if (_hasMore && _items.length != 1) {}
    if (_hasError) {
      return PageErrorWidget(message: _errorData.toString());
    }
    // 背景色加深
    HSLColor hsl = HSLColor.fromColor(
      Theme.of(context).scaffoldBackgroundColor,
    );
    var color =
        hsl.withLightness((hsl.lightness - 0.05).clamp(0.8, 0.9)).toColor();

    return GridView.builder(
      restorationId: "grid${widget.entity.absPath}",
      controller: _scrollController,
      itemCount: _items.length,
      cacheExtent: MediaQueryData.fromView(View.of(context)).size.height / 2,
      // // item高度，性能优化
      // itemExtent: 88.0,
      itemBuilder: (context, index) {
        // 到末尾了
        if (_items[index].basename == ViewPageRoute.loadingTag) {
          // 如果有数据
          if (_hasMore) {
            // 获取数据
            _retrieveData();
            // 加载
            return FittedBox(child: _buildLoading(context));
          } else {
            // 没有数据
            return Container();
          }
        }

        // 返回列表项
        var entity = _items[index];

        /// ListView的动画
        ///
        /// 这里重构了，采用animate库
        return KeepAliveWrapper(
          keepAlive: false,
          // 子项抽屉菜单
          child:
              _buildGridViewItem(
                entity: entity,
                context: context,
                backgroundColor: color,
              ).animate().fade(),
        );
      },
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridCrossCount,
        crossAxisSpacing: 0.5,
        mainAxisSpacing: 0.5,
        childAspectRatio: 3 / 5,
      ),
    );
  }

  Widget _buildGridViewItem({
    required ViewPageEntity entity,
    required BuildContext context,
    required Color backgroundColor,
  }) {
    return ValueListenableBuilder(
      valueListenable: _isMultipleSelect,
      builder: (context, isMultipleSelect, _) {
        return ValueListenableBuilder(
          valueListenable: _selectedItems,
          builder: (context, itemsSet, _) {
            return Consumer<MoveFileModel>(
              builder: (context, moveFileModel, _) {
                double opacity = 1.0;
                if (isMultipleSelect) {
                  if (!itemsSet.contains(entity)) {
                    opacity = 0.5;
                  }
                } else if (entity.isDir &&
                    moveFileModel.isMoving &&
                    moveFileModel.sourceEntities.contains(entity)) {
                  opacity = 0.5;
                } else if (!entity.isDir && moveFileModel.isMoving) {
                  opacity = 0.5;
                }
                return InkWell(
                  key: ValueKey("${entity.absPath}${entity.isDir}"),
                  onTap:
                      isMultipleSelect
                          ? () {
                            _toggleSelection(entity);
                          }
                          : entity.isDir
                          ? moveFileModel.isMoving &&
                                  moveFileModel.sourceEntities.contains(entity)
                              ? null
                              : () async {
                                await _openDir(entity);
                              }
                          : moveFileModel.isMoving
                          ? null
                          : () async {
                            /// 防抖，防止用户多次点击不同文件
                            Global.instance.debouncer.debounce(
                              duration: Duration(milliseconds: 200),
                              onDebounce: () async {
                                await _openFile(entity);
                              },
                            );
                          },
                  child: AnimatedOpacity(
                    duration: Duration(microseconds: 300),
                    opacity: opacity,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        var width = constraints.maxWidth;
                        var fontSize = width / 10.clamp(9, 18);
                        var fontHeight = 1.2;
                        var leading = 0.5;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            /// 图片 / 图标区域
                            Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                widget.dataSource.getThumbnail(
                                  entity,
                                  backgroundColor,
                                  width.toInt(),
                                ),
                                isMultipleSelect
                                    ? IconButton(
                                      onPressed: () {
                                        _toggleSelection(entity);
                                      },
                                      icon: Icon(
                                        size: 24,
                                        color: Theme.of(context).primaryColor,
                                        itemsSet.contains(entity)
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                      ),
                                    )
                                    : SizedBox.shrink(),
                              ],
                            ),

                            /// 文本区域（最多两行）
                            SizedBox(
                              height: (fontHeight + leading) * fontSize * 2,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  entity.basename,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    height: fontHeight,
                                    letterSpacing: leading,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  //----------------------------------------
  // 图片列表构建
  //----------------------------------------

  /// 图片列表body
  Widget _buildPicListModeView(BuildContext context) {
    return Center(child: Text("图片列表", style: TextStyle(fontSize: 40)));
  }

  //----------------------------------------
  // 数据源操作
  //----------------------------------------

  /// 打开文件
  Future<void> _openFile(ViewPageEntity entity) async {
    // await Future.delayed(Duration(milliseconds: 200));
    try {
      await widget.dataSource.openFile(entity, context);
    } catch (e) {
      if (!mounted) return;
      StatusToast.show(
        context: context,
        message: e.toString(),
        isSuccess: false,
      );
    }
  }

  /// 打开文件夹
  Future<void> _openDir(ViewPageEntity entity) async {
    /// 对于文件夹
    var protocolId = widget.dataSource.protocol.protocolId;
    _viewPageRouteFuture.present([
      {"dataSource": protocolId, "entity": entity.toJson()},
    ]);
  }

  /// 选择多个文件
  Future<List<ViewPageEntity>> _pickUpFiles(BuildContext context) async {
    var isDir = await MultiChoiceDialogOverlay.show<bool>(
      layoutMode: Axis.horizontal,
      context: context,
      title: AppLocalizations.of(context).pickUpFile,
      options: [
        ChoiceOption(
          label: AppLocalizations.of(context).fileDesc,
          icon: Icons.library_books,
          value: false,
        ),
        ChoiceOption(
          label: AppLocalizations.of(context).dirDesc,
          icon: Icons.folder,
          value: true,
        ),
      ],
    );
    if (isDir == null) {
      return [];
    }
    var entities = await widget.dataSource.pickUpFiles(isDir);

    return entities;
  }

  /// 加载信息
  Future<List<ViewPageEntity>> _loadEntitesInfo(
    List<ViewPageEntity> entities,
  ) async {
    List<Future<ViewPageEntity>> futureList = [];
    for (var entity in entities) {
      futureList.add(
        Future(() async {
          var result = await widget.dataSource.getInfo(entity);
          return result.result as ViewPageEntity;
        }),
      );
    }
    return await Future.wait(futureList).onError((error, stackTrace) {
      if (mounted) {
        StatusToast.show(
          context: context,
          message: error.toString(),
          isSuccess: false,
        );
      }
      throw error.toString();
    });
  }

  //----------------------------------------
  // 通用小组件
  //----------------------------------------

  /// 缓存一下
  Widget? _loadingWidget;

  /// 构造加载中组件
  Widget _buildLoading(BuildContext context) {
    _loadingWidget ??= LoadingWidget();
    return _loadingWidget!;
  }

  /// 构造末尾组件
  Widget _buildEnding(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(16),
      child: Text(
        AppLocalizations.of(context).noMore,
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  //----------------------------------------
  // 数据构造
  //----------------------------------------

  /// 取值列表
  final _items = <ViewPageEntity>[
    ViewPageEntity(
      basename: ViewPageRoute.loadingTag,
      isDir: false,
      isRoot: false,
      absPath: '',
    ),
  ];

  /// 获取数据
  Future<void> _retrieveData() async {
    /// 当前时间戳
    // var beginTick = DateTime.now();
    try {
      var data = await widget.dataSource.getDataFuture(
        widget.entity,
        paging: needPaginate,
        page: _page,
        pageSize: pageSize,
      );

      if (needPaginate) {
        // 如果分页了，不排序
        _hasMore = data.isNotEmpty && data.length % pageSize == 0;
      } else {
        // 如果没分页，则需要排序data
        _hasMore = false;
        data = await _sortItems(data);
      }

      /// 更新列表
      _items.insertAll(_items.length - 1, data);
      if (needPaginate) {
        _page++;
      }
    } catch (e) {
      _hasError = true;
      _errorData = e;
    }

    /// 刷新页面
    _forceRefreshNotifier.value = !_forceRefreshNotifier.value;
  }

  //----------------------------------------
  // 列表排序相关
  //----------------------------------------

  Future<List<ViewPageEntity>> _sortItems(List<ViewPageEntity> list) async {
    return Global.instance.loadBalancer.run((arguments) async {
      var pageSortedMode = arguments[0] as PageSortedModeEnum;
      var list = arguments[1] as List<ViewPageEntity>;
      switch (pageSortedMode) {
        case PageSortedModeEnum.byName:
          return await list.sortByName;
        case PageSortedModeEnum.byDate:
          return await list.sortByDate;
        case PageSortedModeEnum.byType:
          return await list.sortByType;
        case PageSortedModeEnum.bySize:
          return await list.sortBySize;
      }
    }, [pageSortedMode, list]);
  }

  Future<int> _getInsertIndex(
    List<ViewPageEntity> list,
    ViewPageEntity entity,
  ) async {
    switch (pageSortedMode) {
      case PageSortedModeEnum.byName:
        return await list.getInsertIndexByName(entity);
      case PageSortedModeEnum.byDate:
        return await list.getInsertIndexByDate(entity);
      case PageSortedModeEnum.byType:
        return await list.getInsertIndexByType(entity);
      case PageSortedModeEnum.bySize:
        return await list.getInsertIndexBySize(entity);
    }
  }

  //----------------------------------------
  // 多选相关
  //----------------------------------------

  /// 切换单个项的选中状态
  void _toggleSelection(ViewPageEntity entity) {
    final newSet = Set<ViewPageEntity>.from(_selectedItems.value);
    newSet.contains(entity) ? newSet.remove(entity) : newSet.add(entity);
    _selectedItems.value = newSet; // 触发监听器
  }

  /// 全选/全不选
  void _selectAll(bool selectAll) {
    _selectedItems.value = selectAll ? _items.toSet() : {};
  }

  //----------------------------------------
  // 初始化
  //----------------------------------------

  /// 等待初始化
  late Future<void> _waitInitFuture;

  /// 初始化配置文件
  ///
  /// 后续有需要初始化的代码加里面即可
  Future<void> _initPageProfile() async {
    _pageProfile = null;
    _realPageProfile = PageProfile();

    // // 获取sharedpreference单例
    // _preferences = await SharedPreferences.getInstance();

    // 页面配置文件的key为文件目录
    String? profile = Global.instance.pref.getString(widget.entity.absPath);

    if (profile != null) {
      try {
        _pageProfile = PageProfile.fromJson(jsonDecode(profile));
      } catch (e) {
        // TODO: 异常处理，记录日志
        rethrow;
      }
    } else {
      // 没有对应的配置文件，则将所有的页面配置设为null
      _pageProfile = PageProfile();
      _pageProfile!.fileModeMap = {};
    }
  }

  //----------------------------------------
  // 生命周期方法
  //----------------------------------------

  /// 是否已经订阅，防止重复订阅内存泄漏
  bool _isSubscribe = false;

  @override
  void didPopNext() {
    if (widget.entity == Global.instance.backRouteRefreshPath) {
      _page = 1;
      _hasMore = true;
      _items.clear();
      _items.add(
        ViewPageEntity(
          basename: ViewPageRoute.loadingTag,
          isDir: false,
          isRoot: false,
          absPath: '',
        ),
      );
      Global.instance.backRouteRefreshPath = null;
    }
    super.didPopNext();
  }

  @override
  void initState() {
    super.initState();

    // ValueNotifier
    _forceRefreshNotifier = ValueNotifier<bool>(false);

    // 多选
    _selectedItems = ValueNotifier({});
    _isMultipleSelect = ValueNotifier(false);

    // controller
    _scrollController = ScrollController();
    // _slidableController = SlidableController(this);

    // 初始化数据的Future
    _waitInitFuture = _getInitFuture();
  }

  Future<void> _getInitFuture() async {
    await _initPageProfile();
  }

  @override
  void didChangeDependencies() {
    if (!_isSubscribe) {
      RouteObserverInstance.instance.routeObserver.subscribe(
        this,
        ModalRoute.of(context)!,
      );
      _isSubscribe = true;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // _slidableController.dispose();
    _scrollController.dispose();
    _forceRefreshNotifier.dispose();
    _selectedItems.dispose();
    _isMultipleSelect.dispose();
    ExtraOperationOverlay.dismiss();

    if (_isSubscribe) {
      RouteObserverInstance.instance.routeObserver.unsubscribe(this);
      _isSubscribe = false;
    }
    super.dispose();
  }

  //----------------------------------------
  // 页面配置
  //----------------------------------------

  /// 第几页
  int _page = 1;

  /// 是否出错
  bool _hasError = false;
  Object? _errorData;

  /// 是否还有
  bool _hasMore = true;

  /// 当前页面的配置文件，如果参数为null则取全局的默认配置文件
  PageProfile? _pageProfile;
  PageProfile? _realPageProfile;

  /// 加载最终的页面配置文件
  void _loadRealPageProfile(BuildContext context) {
    // pageProfile的相关配置为null则获取全局默认配置
    _realPageProfile!
      ..pageStyleMode =
          _pageProfile!.pageStyleMode ??
          Provider.of<DefaultPageModeModel>(context).pageStyleMode
      ..pageSortedMode =
          _pageProfile!.pageSortedMode ??
          Provider.of<DefaultPageModeModel>(context).pageSortedMode
      ..gridCrossCount =
          _pageProfile!.gridCrossCount ??
          Provider.of<DefaultPageModeModel>(context).gridCrossCount;
  }

  /// 页面模式
  PageStyleModeEnum get pageStyleMode => _realPageProfile!.pageStyleMode!;

  /// 页面排序模式
  PageSortedModeEnum get pageSortedMode => _realPageProfile!.pageSortedMode!;

  /// 网格模式列数
  int get gridCrossCount => _realPageProfile!.gridCrossCount!;

  /// 是否需要分页加载
  bool get needPaginate => false;

  /// 分页大小
  int get pageSize => 20;

  //----------------------------------------
  // 页面恢复
  //----------------------------------------

  @override
  String? get restorationId => "view_page_route_${widget.entity.absPath}";

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(
      _viewPageRouteFuture,
      "view_page_route_${widget.entity.absPath}",
    );
    registerForRestoration(
      _epubPageRouteFuture,
      "view_page_route_${widget.entity.absPath}",
    );
    if (kDebugMode) {
      debugPrint("$initialRestore");
      debugPrint("进入恢复状态");
    }
  }

  final RestorableRouteFuture<void> _epubPageRouteFuture =
      RestorableRouteFuture<void>(
        onPresent: (navigator, arguments) {
          return navigator.restorablePushNamed(
            "epub_page_route",
            arguments: (arguments as List)[0],
          );
        },
        onComplete: (result) {
          if (kDebugMode) {
            debugPrint("返回上一页");
          }
        },
      );

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
            debugPrint("返回上一页");
          }
        },
      );
}
