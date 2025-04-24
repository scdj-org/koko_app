import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:koko/common/global.dart';
import 'package:koko/common/route_observer_instance.dart';
import 'package:koko/enums/theme_color_enum.dart';
import 'package:koko/interface/data_source_manager_interface.dart';
import 'package:koko/l10n/l10n.dart';
import 'package:koko/models/model/button_tips_model.dart';
import 'package:koko/models/model/default_page_mode.dart';
import 'package:koko/models/epub_models/default_epub_conf_model.dart';
import 'package:koko/models/model/locale_model.dart';
import 'package:koko/models/model/move_file_model.dart';
import 'package:koko/models/model/net_devices_model.dart';
import 'package:koko/models/model/theme_model.dart';
import 'package:koko/models/entity/view_page_entity.dart';
import 'package:koko/routes/epub_page_route.dart';
import 'package:koko/routes/home_page_route.dart';
import 'package:koko/routes/music_player_route.dart';
import 'package:koko/routes/photo_view_route.dart';
import 'package:koko/routes/setting_route.dart';
import 'package:koko/routes/video_player_route.dart';
import 'package:koko/routes/view_page_route.dart';
import 'package:koko/states/global_profile_change_notifier.dart';
import 'package:provider/provider.dart';

void main() async {
  //TODO:全局异常处理

  await Global.instance.init();
  runApp(RestorationScope(restorationId: 'root', child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // 监听的Provider状态
      // 新增model的时候记得添加到这里
      providers: [
        ChangeNotifierProvider(create: (_) => GlobalProfileChangeNotifier()),
        ChangeNotifierProvider(create: (_) => ThemeModel()),
        ChangeNotifierProvider(create: (_) => LocaleModel()),
        ChangeNotifierProvider(create: (_) => DefaultPageModeModel()),
        ChangeNotifierProvider(create: (_) => NetDevicesModel()),
        ChangeNotifierProvider(create: (_) => DefaultEpubConfModel()),
        ChangeNotifierProvider(create: (_) => ButtonTipsModel()),
        ChangeNotifierProvider(create: (_) => MoveFileModel()),
      ],
      // 树根使用ThemeModel和LocaleModel，保证语言、主题更新整个树都更新
      child: Consumer<GlobalProfileChangeNotifier>(
        builder: (context, _, _) {
          return Consumer2<ThemeModel, LocaleModel>(
            builder: (context, themeModel, localeModel, child) {
              return MaterialApp(
                // 路由监听
                navigatorObservers: [
                  RouteObserverInstance.instance.routeObserver,
                ],
                // 标题
                title: "koko",
                // 本地化相关配置
                locale: localeModel.getLocale(),
                restorationScopeId: "app",
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: [
                  // intl国际化插件代理
                  AppLocalizations.delegate,
                  // 本地化的代理类
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                // 路由相关配置
                // 路由表
                routes: {
                  "/": (context) => HomePageRoute(),
                  "setting_route": (context) => SettingRoute(),
                  "view_page_route": (context) {
                    var argument =
                        (ModalRoute.of(context)?.settings.arguments as Map?);
                    var dataSource =
                        DataSourceManagerInterface.getDataSourceManagerFromId(
                          argument?["dataSource"] as int,
                        );
                    var entity = ViewPageEntity.fromJson(argument?["entity"]);
                    return ViewPageRoute(
                      dataSource: dataSource,
                      entity: entity,
                    );
                  },
                  "epub_page_route": (context) {
                    var argument =
                        (ModalRoute.of(context)?.settings.arguments as Map?);
                    var dataSource =
                        DataSourceManagerInterface.getDataSourceManagerFromId(
                          argument?["dataSource"] as int,
                        );
                    var entity = ViewPageEntity.fromJson(argument?["entity"]);
                    (ModalRoute.of(context)?.settings.arguments as Map?);
                    return EpubPageRoute(
                      entity: entity,
                      dataSourceManager: dataSource,
                    );
                  },
                  "video_player_route": (context) {
                    var argument =
                        (ModalRoute.of(context)?.settings.arguments as Map?);
                    var url = argument!["url"] as Uri;
                    var headers = argument["headers"] as Map<String, String>;
                    return VideoPlayerRoute(url: url, headers: headers);
                  },
                  "music_player_route": (context) {
                    var argument =
                        (ModalRoute.of(context)?.settings.arguments as Map?);
                    var url = argument!["url"] as String;
                    var headers = argument["headers"] as Map<String, String>;
                    return MusicPlayerRoute(url: url, headers: headers);
                  },
                  "photo_view_route": (context) {
                    var argument =
                        (ModalRoute.of(context)?.settings.arguments as Map?);
                    var url = argument!["url"] as String;
                    var headers = argument["headers"] as Map<String, String>;
                    return PhotoViewRoute(url: url, headers: headers);
                  },
                },
                // 初始路由
                initialRoute: "/",
                // 主题相关配置
                theme: ThemeData(
                  // This is the theme of your application.
                  //
                  // TRY THIS: Try running your application with "flutter run". You'll see
                  // the application has a purple toolbar. Then, without quitting the app,
                  // try changing the seedColor in the colorScheme below to Colors.green
                  // and then invoke "hot reload" (save your changes or press the "hot
                  // reload" button in a Flutter-supported IDE, or press "r" if you used
                  // the command line to start the app).
                  //
                  // Notice that the counter didn't reset back to zero; the application
                  // state is not lost during the reload. To reset the state, use hot
                  // restart instead.
                  //
                  // This works for code too, not just values: Most code changes can be
                  // tested with just a hot reload.
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: themeModel.themeColor.color,
                  ).copyWith(
                    surface:
                        themeModel.themeColor == ThemeColorEnum.white
                            ? ThemeColorEnum.white.color
                            : null,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
