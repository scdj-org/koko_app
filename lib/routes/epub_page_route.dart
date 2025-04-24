import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/parser.dart' as parser;
import 'package:koko/common/application_cache_manager.dart';
import 'package:koko/common/epub_util/epub_stream_decoder.dart';
import 'package:koko/common/global.dart';
import 'package:koko/enums/epub_font_size_enmu.dart';
import 'package:koko/helper/default_menu_item_helper.dart';
import 'package:koko/helper/epub_preload_num_menu_item_helper.dart';
import 'package:koko/interface/data_source_manager_interface.dart';
import 'package:koko/interface/koko_epub_data_source_interface.dart';
import 'package:koko/l10n/l10n.dart';
import 'package:koko/models/epub_models/central_directory_entry.dart';
import 'package:koko/models/epub_models/epub_conf.dart';
import 'package:koko/models/epub_models/koko_epub_book.dart';
import 'package:koko/models/entity/view_page_entity.dart';
import 'package:koko/models/epub_models/koko_epub_ncx_ponit.dart';
import 'package:koko/widgets/overlay/buttom_setting_overlay.dart';
import 'package:koko/widgets/overlay/reader_setting_overlay.dart';
import 'package:koko/widgets/overlay/status_toast.dart';
import 'package:koko/widgets/ui_widgets/gradient_divider.dart';
import 'package:koko/widgets/ui_widgets/loading_widget.dart';
import 'package:koko/widgets/ui_widgets/page_error_widget.dart';
import 'package:koko/widgets/ui_widgets/setting_dropdown_menu.dart';
import 'package:path/path.dart' as p;
import 'package:preload_page_view/preload_page_view.dart';
import 'package:webdav_client/webdav_client.dart';

/// XXX写不来JS目前先这么实现
///
/// TODO:**这里存在严重的性能问题，频繁创建和销毁webview会导致cpu占用高**
///
/// TODO:**后续用js重构**
///
/// XXX实际手机上效果其实还不错，但是很可能有隐患
class EpubPageRoute extends StatefulWidget {
  const EpubPageRoute({
    super.key,
    required this.entity,
    required this.dataSourceManager,
  });

  final ViewPageEntity entity;

  final DataSourceManagerInterface dataSourceManager;

  @override
  State<EpubPageRoute> createState() => _EpubPageRouteState();
}

class _EpubPageRouteState extends State<EpubPageRoute> {
  /// 支持epub的数据源
  late KokoEpubDataSourceInterface _epubDataSource;

  // late final InAppWebViewController _webViewController;

  /// 页面控制器
  late PreloadPageController _pageController;

  late final ScrollController _scrollController;

  /// epub文件头map，用于寻址
  Map<String, CentralDirectoryEntry> _centralDirectoryMap = {};

  /// 书籍
  KokoEpubBook _book = KokoEpubBook();
  List<Widget>? _ncxTiles;

  // /// 章节
  // int _chapterIndex = 0;

  /// 是否内部链接跳转, 手动触发request的时候设为false
  List<bool> _isInnerJumps = [];

  String _path = "";

  // final path =
  // "/q8u220s/other/public/漫画/邻家的吸血鬼小妹/[Kox][鄰家的吸血鬼小妹]卷02.kepub.epub";

  /// 初始化函数
  late Future<void> _futureInit;

  /// 刷新
  final ValueNotifier<bool> _refresh = ValueNotifier(false);

  /// 让preloadpageview强制初始化
  int _preloadKey = 0;

  /// 长宽
  double _screenHeight = 0;
  double _screenWidth = 0;
  double _topPadding = 0;
  double _buttomPadding = 0;
  Rect _centerRect = Rect.zero;

  /// 当前页码
  final ValueNotifier<int> _currentPageNotify = ValueNotifier(0);

  /// 手势判断
  DateTime? _pointerDownTime;
  Offset? _pointerDownPosition;

  /// 检测当前页面是否在滚动
  bool _isScrolling = false;

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQueryData.fromView(View.of(context));
    _screenWidth = mediaQueryData.size.width;
    _screenHeight = mediaQueryData.size.height;
    _topPadding = mediaQueryData.padding.top;
    _buttomPadding = mediaQueryData.padding.bottom + 24;
    _centerRect = Rect.fromLTRB(
      _screenWidth * 0.3,
      _screenHeight * 0.3,
      _screenWidth * 0.7,
      _screenHeight * 0.7,
    );
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return Scaffold(
      body: FutureBuilder(
        future: _futureInit,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return LoadingWidget();
          }
          if (snap.hasError) {
            return PageErrorWidget(message: snap.error.toString());
          }
          return Listener(
            onPointerDown: (event) {
              // 滑动点按暂停
              if (_isScrolling || ReaderSettingsOverlay.isVisible) {
                return;
              }
              _pointerDownTime = DateTime.now();
              _pointerDownPosition = event.position;
            },
            onPointerUp: (event) {
              // 截流，防止手势过于频繁
              Global.instance.throttler.throttle(
                duration: Duration(milliseconds: 500),
                onThrottle: () {
                  if (_pointerDownTime == null ||
                      _pointerDownPosition == null) {
                    return;
                  }

                  Duration pressDuration = DateTime.now().difference(
                    _pointerDownTime!,
                  );
                  double distance =
                      (event.position - _pointerDownPosition!).distance;

                  _pointerDownTime = null;
                  _pointerDownPosition = null;

                  // 时间>0.5s或者距离大于10不为点按直接返回
                  if (pressDuration >= Duration(milliseconds: 450) ||
                      distance >= 10) {
                    return;
                  }
                  var x = event.position.dx;
                  var y = event.position.dy;
                  if (x > _centerRect.left &&
                      x < _centerRect.right &&
                      y > _centerRect.top &&
                      y < _centerRect.bottom) {
                    if (kDebugMode) {
                      debugPrint("tapUp");
                    }
                    _handleSettingPage();
                  }
                },
              );
            },
            child: ValueListenableBuilder(
              valueListenable: _refresh,
              builder: (context, _, _) {
                return PreloadPageView.builder(
                  key: ValueKey(_preloadKey),
                  controller: _pageController,
                  scrollDirection: Axis.horizontal,
                  preloadPagesCount: _preloadNum,
                  onPageChanged: (value) {
                    _currentPageNotify.value = value;
                    // 过0.3s存
                    Future.delayed(Duration(milliseconds: 300), () async {
                      Global.instance.pref.setInt(
                        "epub_page_num_$_path",
                        value,
                      );
                    });
                  },
                  itemCount: _book.spine.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder(
                      future: _buildWebView(index),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return LoadingWidget();
                        }
                        if (snap.hasError) {
                          return ErrorWidget(snap.error.toString());
                        }
                        return snapshot.data!;
                      },
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      // floatingActionButton: ElevatedButton(
      //   onPressed: () => {_requestChapter(_chapterIndex++, _webViewController)},
      //   child: Icon(Icons.tips_and_updates),
      // ),
    );
  }

  Future<Widget> _buildWebView(int index) async {
    // 延迟加载，防止动画卡顿
    // await Future.delayed(Duration(milliseconds: 800));
    return InAppWebView(
      initialData: InAppWebViewInitialData(
        data: """
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>加载中...</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            font-family: Arial, sans-serif;
        }
        .loading-container {
            text-align: center;
        }
        .spinner {
            width: 40px;
            height: 40px;
            border: 4px solid rgba(0, 0, 0, 0.2);
            border-top-color: #${Theme.of(context).primaryColor.value.toRadixString(16).substring(2)};
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin: 10px auto;
        }
        @keyframes spin {
            to {
                transform: rotate(360deg);
            }
        }
        .text {
            font-size: 16px;
            color: #333;
        }
    </style>
</head>
<body>
    <div class="loading-container">
        <div class="spinner"></div>
        <p class="text">loading...</p>
    </div>
</body>
</html>
""",
      ),
      onLoadResource: (controller, resource) {},
      gestureRecognizers: {
        Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
        Factory<LongPressGestureRecognizer>(() => LongPressGestureRecognizer()),
        Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
        Factory<PanGestureRecognizer>(() => PanGestureRecognizer()),
      },
      initialSettings: InAppWebViewSettings(
        useHybridComposition: true,
        isElementFullscreenEnabled: true,
        javaScriptEnabled: true,
        supportZoom: true,
        useShouldInterceptRequest: true, // 启用拦截资源请求
        transparentBackground: _withTheme,
        cacheEnabled: true,
        allowsBackForwardNavigationGestures: false,
        allowFileAccessFromFileURLs: true,
        allowUniversalAccessFromFileURLs: true,
        allowFileAccess: true,
        allowContentAccess: true,
        domStorageEnabled: true,
        mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
        hardwareAcceleration: true,
        // disableVerticalScroll: true,
        // disableHorizontalScroll: true,
      ),
      onReceivedError: (controller, request, error) {
        if (kDebugMode) {
          debugPrint(error.description);
        }
      },
      onConsoleMessage: (controller, consoleMessage) {
        if (kDebugMode) {
          debugPrint(consoleMessage.message);
        }
      },
      onWebViewCreated: (controller) async {
        // _webViewController = controller;
        controller.addJavaScriptHandler(
          handlerName: "onScroll",
          callback: (args) {
            _isScrolling = args[0]; // 更新滚动状态
            if (kDebugMode) {
              debugPrint("WebView 滚动状态: $_isScrolling");
            }
          },
        );
        _requestChapter(index, controller).onError((error, stackTrace) {
          // TODO: 异常处理
          if (mounted) {
            StatusToast.show(
              context: context,
              message: error.toString(),
              isSuccess: false,
            );
          }
        });
      },
      onLoadStop: (controller, url) async {
        // 样式
        await controller.evaluateJavascript(
          source: """
(() => {
  var meta = document.createElement('meta');
  meta.name = 'viewport';
  meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=2.0';
  document.getElementsByTagName('head')[0].appendChild(meta);

  document.documentElement.style.fontSize = '${_fontSize.fontSize}vw';

  if (document.body.innerText.trim() === '') {
    document.querySelectorAll("img").forEach(img => {
      img.style.position = "absolute";
      img.style.top = "45%";
      img.style.left = "50%";
      img.style.transform = "translate(-50%, -50%)";
      img.style.objectFit = "contain";
      img.style.maxWidth = "100%";
      img.style.maxHeight = "100%";
    });
  } else {
    var style = document.createElement('style');
    style.innerHTML = 'img { max-width: 98vw !important; height: auto !important; }';
    document.head.appendChild(style);
  }

  return null;
})()
          """,
        );
        // 留白，防遮挡
        await controller.evaluateJavascript(
          source: """
      document.body.style.paddingTop = '${_topPadding}px'; // 顶部留白
      document.body.style.paddingBottom = '${_buttomPadding}px'; // 底部留白
      document.body.style.boxSizing = 'border-box';
""",
        );
        // 滚动监听，这里没必要同步
        controller.evaluateJavascript(
          source: """
      let isScrolling = false;
      
      window.addEventListener('scroll', function() {
        if (!isScrolling) {
          isScrolling = true;
          window.flutter_inappwebview.callHandler('onScroll', true);
        }
        
        clearTimeout(window.scrollTimeout);
        window.scrollTimeout = setTimeout(function() {
          isScrolling = false;
          window.flutter_inappwebview.callHandler('onScroll', false);
        }, 100);
      });
    """,
        );
      },
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        var url = navigationAction.request.url;
        if (_isInnerJumps[index] == false) {
          return NavigationActionPolicy.ALLOW;
        }
        // 处理跳转
        if (url?.scheme == "file") {
          await _loadPageContent(
            DataSourceManagerInterface.stripUrlScheme(url!.toString()),
            index,
          );
        } else if (url?.scheme == "content") {
          // 安卓特制拦截
          await _loadPageContent(
            ApplicationCacheManager.instance.converCachePathToRealPath(
              DataSourceManagerInterface.stripUrlScheme(url!.toString()),
            ),

            index,
          );
        }
        return NavigationActionPolicy.ALLOW;
      },
    );
  }

  /// 请求章节
  Future<void> _requestChapter(
    int chapterIndex,
    InAppWebViewController controller,
  ) async {
    if (chapterIndex >= _book.spine.length) {
      return;
    }
    // 获取当前的的 idref
    String pageIdref = _book.spine[chapterIndex];

    // 通过 idref 查找对应的 EpubItem
    var epubItem = _book.manifest[pageIdref];

    // 跳转
    _isInnerJumps[chapterIndex] = false;

    // 处理资源，安卓不走shouldOverrideUrlLoading
    await _loadPageContent(
      "${_epubDataSource.realPath}/${epubItem!.href}",
      chapterIndex,
    );

    controller.loadUrl(
      allowingReadAccessTo: WebUri(
        "file://${ApplicationCacheManager.instance.currentCachePath}",
      ),
      urlRequest: URLRequest(
        url: WebUri(
          encodeSpecialChars("${_epubDataSource.requestPath}/${epubItem.href}"),
        ),
      ),
    );
  }

  /// 处理 HTML 内容
  Future<void> _loadPageContent(String path, int chapterIndex) async {
    var href = p.relative(
      DataSourceManagerInterface.decodeComponent(path),
      from: _epubDataSource.realPath,
    );
    // 本篇跳转，不处理
    if (_isInnerJumps[chapterIndex] == true &&
        href == _book.manifest[_book.spine[chapterIndex]]!.href) {
      return;
    }
    // 读取 HTML 内容
    var data = (await _epubDataSource.getByteData(href, _centralDirectoryMap));

    // 解析html
    await _resolveHttpContent(data!, href);

    // 内部跳转
    if (_isInnerJumps[chapterIndex]) {
      _resolveInnerJump(href);
    } else {
      _isInnerJumps[chapterIndex] = true;
    }
  }

  /// 处理内部跳转
  void _resolveInnerJump(String href) {
    var index = _book.spineIndexMap[_book.hrefItemMap[href]?.id];
    if (index != null) {
      _pageController
          .animateToPage(
            index,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          )
          .then((_) => {_currentPageNotify.value = index});
    }
  }

  /// 解析html
  Future<void> _resolveHttpContent(Uint8List data, String htmlPath) async {
    var htmlContent = utf8.decode(data);
    // debugPrint(htmlContent);
    var document = parser.parse(htmlContent);
    // 处理资源的Future列表，最后汇总即可
    var resolveFutureList = <Future<void>>[];

    // 解析html的标签
    for (var element in document.querySelectorAll("*")) {
      for (var attr in element.attributes.entries) {
        if (_isUrlAttribute(attr.key.toString(), attr.value)) {
          resolveFutureList.add(
            _getHtmlResouce(Uri.parse(attr.value).path, htmlPath),
          );
        }
      }
    }

    // 等待所有资源加载完毕
    await Future.wait(resolveFutureList);
  }

  /// 获取html里面的资源文件
  Future<void> _getHtmlResouce(String href, String htmlPath) async {
    var resolvedPath = DataSourceManagerInterface.decodeComponent(
      EpubStreamDecoder.normalizeEpubPath(htmlPath, href),
    );
    // 没有这个资源，不做操作
    if (!_centralDirectoryMap.containsKey(resolvedPath)) {
      return;
    }
    // 加载资源，无需返回data
    await _epubDataSource.getByteData(
      resolvedPath,
      _centralDirectoryMap,
      needBack: false,
    );
  }

  /// 检验是否为资源路径
  static const urlAttributes = {
    'src',
    'href',
    'data-src',
    'data-href',
    'xlink:href',
    'poster',
    'content',
    "srcset",
  };
  bool _isUrlAttribute(String attrKey, String attrValue) {
    // 仅匹配实际的资源路径
    return urlAttributes.contains(attrKey) &&
        attrValue.isNotEmpty &&
        !attrValue.startsWith('#') && // 锚点链接
        !attrValue.startsWith('mailto:') && //
        !attrValue.startsWith('javascript:') &&
        !attrValue.startsWith('http') &&
        !attrValue.startsWith('data:') &&
        !attrValue.endsWith("html");
  }

  /// 处理设置页面
  void _handleSettingPage() {
    /// 设置菜单
    ReaderSettingsOverlay.show(
      title: p.basename(_path),
      context: context,
      onBack: () {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
      totalPages: _book.spine.length - 1,
      currentPageNotify: _currentPageNotify,
      onPageChanged: (page) {
        _pageController.jumpToPage(page);
      },
      rightButton: IconButton(
        onPressed: () {
          Global.instance.debouncer.debounce(
            duration: Duration(milliseconds: 200),
            onDebounce: () {
              _refresh.value = !_refresh.value;
            },
          );
        },
        icon: Icon(Icons.refresh_rounded),
      ),
      bottomLeftButton: IconButton(
        onPressed: () {
          ButtomSettingOverlay.show(
            context: context,
            sperated: GradientDivider(
              height: 1.5,
              direction: GradientDirection.leftToRight,
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.format_list_bulleted, color: Colors.grey),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    AppLocalizations.of(context).ncx,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      color: Colors.grey[700],
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
            tiles:
                _ncxTiles == null || _ncxTiles!.isEmpty
                    ? [
                      for (int i = 0; i < _book.spine.length; i++)
                        ListTile(
                          contentPadding: EdgeInsets.only(
                            left: 0 * 16.0,
                          ), // 层级缩进
                          title: Text(
                            "${AppLocalizations.of(context).chapter} $i",
                          ),
                          onTap:
                              () => _onChapterSelected(
                                _book.manifest[_book.spine[i]]!.href,
                              ), // 直接跳转
                        ),
                    ]
                    : _ncxTiles!,
          );
        },
        icon: Icon(Icons.format_list_bulleted),
      ),
      // 书签功能之后再做
      bottomRightButton: IconButton(
        onPressed: () {
          ButtomSettingOverlay.show(
            context: context,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.menu_book, color: Colors.grey),
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 3),
                  child: Text(
                    AppLocalizations.of(context).settingDesc,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      color: Colors.grey[700],
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
            tiles: _buildEpubConfSettingTiles(),
          );
        },
        icon: Icon(Icons.settings),
      ),
    );
  }

  /// 深度搜索递归遍历ncx
  Widget _buildNavPoint(KokoEpubNcxPonit point, {int depth = 0}) {
    if (point.children.isEmpty) {
      // 直接跳转的情况
      return ListTile(
        contentPadding: EdgeInsets.only(left: depth * 16.0), // 层级缩进
        title: Text(
          point.label ?? AppLocalizations.of(context).untitledChapter,
        ),
        onTap: () => _onChapterSelected(point.contentSrc), // 直接跳转
      );
    } else {
      // 有子目录，使用可展开的 `ExpansionTile`
      return ExpansionTile(
        title: Padding(
          padding: EdgeInsets.only(left: depth * 16.0), // 层级缩进
          child: Text(
            point.label ?? AppLocalizations.of(context).untitledChapter,
          ),
        ),
        children:
            point.children
                .map((child) => _buildNavPoint(child, depth: depth + 1))
                .toList(),
      );
    }
  }

  void _onChapterSelected(String href) {
    var chapterNum = _book.spineIndexMap[_book.hrefItemMap[href]?.id];
    if (chapterNum == null) return;
    _pageController
        .animateToPage(
          chapterNum,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        )
        .then((_) => {_currentPageNotify.value = chapterNum});
  }

  /// 初始化函数
  Future<void> _initFunc() async {
    // await ApplicationCacheManager.instance.clearCache();

    var len = await _epubDataSource.getFileSize();

    /// 先初始化epub文件头map和webviewcontroller
    _centralDirectoryMap = await _epubDataSource.initCentralDirectoryMap(len);

    /// 初始化epub书
    _book = await _epubDataSource.initBook(_centralDirectoryMap);

    _ncxTiles =
        _book.ncx?.navPoints.map((point) => _buildNavPoint(point)).toList();
    // /// 初始化webview
    // await _initWebView();

    // 初始化跳转标识
    _isInnerJumps = List.filled(_book.spine.length, false);
  }

  @override
  void initState() {
    if (widget.dataSourceManager is! KokoEpubDataSourceInterface) {
      throw "数据源不支持流式阅读";
    }

    _path = p.relative(
      widget.entity.absPath,
      from: widget.dataSourceManager.rootPath,
    );
    if (_path.startsWith("/")) {
      _path = _path.replaceFirst("/", "");
    }

    // 数据源初始化
    _epubDataSource = widget.dataSourceManager as KokoEpubDataSourceInterface;
    _epubDataSource.epubBasePath = _path;

    _recoverEpubConf();

    // 页面控制器初始化
    _pageController = PreloadPageController(initialPage: _pageNum);
    _currentPageNotify.value = _pageNum;

    _scrollController = ScrollController();
    // TODO: 预检对文件的读写权限

    // webviewcontroller初始化
    // _webViewController = WebViewController();

    _futureInit = _initFunc();
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // _webViewController.dispose();
    ReaderSettingsOverlay.dismiss();
    _scrollController.dispose();
    _refresh.dispose();
    _pageController.dispose();
    _currentPageNotify.dispose();
    super.dispose();
  }

  //----------------------------------------
  // 配置恢复
  //----------------------------------------

  /// 第几页
  int _pageNum = 0;
  // epub的配置文件
  late EpubConf _epubConf;
  late EpubConf _defaultConf;

  /// 恢复配置文件
  void _recoverEpubConf() {
    // pagenum存很频繁，单独存
    _pageNum = Global.instance.pref.getInt("epub_page_num_$_path") ?? 0;
    // epub的常规配置文件，如果没有就取全局配置的default
    _defaultConf = Global.instance.globalProfile.defaultEpubConf;
    var epubConfString = Global.instance.pref.getString("epubconf_$_path");
    if (epubConfString != null) {
      _epubConf = EpubConf.fromJson(jsonDecode(epubConfString));
    } else {
      _epubConf = EpubConf();
    }
  }

  EpubFontSizeEnmu get _fontSize =>
      _epubConf.fontSize ?? _defaultConf.fontSize!;

  int get _preloadNum => _epubConf.preloadNum ?? _defaultConf.preloadNum!;

  bool get _withTheme => _epubConf.withTheme ?? _defaultConf.withTheme!;

  /// epub阅读设置
  List<Widget> _buildEpubConfSettingTiles() {
    return [
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
            var defaultItem = DefaultMenuItemHelper();
            return SettingDropdownMenu(
              width: 40,
              dropDownItems: [defaultItem, ...EpubFontSizeEnmu.values],
              initSelection: _epubConf.fontSize ?? defaultItem,
              onSelected: (fontSize) {
                if (fontSize == defaultItem) {
                  if (_epubConf.fontSize == null) return;
                  _epubConf.fontSize = null;
                } else {
                  var size = fontSize as EpubFontSizeEnmu;
                  if (_epubConf.fontSize == size) return;
                  _epubConf.fontSize = size;
                }
                Global.instance.pref.setString(
                  "epubconf_$_path",
                  jsonEncode(_epubConf.toJson()),
                );
                _refresh.value = !_refresh.value;
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
            var defaultItem = DefaultMenuItemHelper();
            return SettingDropdownMenu(
              width: 40,
              dropDownItems: [
                defaultItem,
                ...EpubPreloadNumMenuItemHelper.epubPreloadNumItems,
              ],
              initSelection:
                  _epubConf.preloadNum == null
                      ? defaultItem
                      : EpubPreloadNumMenuItemHelper
                          .epubPreloadNumItems[_epubConf.preloadNum!],
              onSelected: (preloadNum) {
                if (preloadNum == defaultItem) {
                  if (_epubConf.preloadNum == null) return;
                  _epubConf.preloadNum = null;
                } else {
                  var num = preloadNum as EpubPreloadNumMenuItemHelper;
                  if (_epubConf.preloadNum == num.preloadNum) return;
                  _epubConf.preloadNum = num.preloadNum;
                }
                Global.instance.pref.setString(
                  "epubconf_$_path",
                  jsonEncode(_epubConf.toJson()),
                );
                _preloadKey++;
                _pageController.dispose();
                _pageController = PreloadPageController(
                  initialPage: _currentPageNotify.value,
                );
                _refresh.value = !_refresh.value;
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
            var defaultMenuItem = DefaultMenuItemHelper(value: null);
            var yesMenuItem = DefaultMenuItemHelper(
              label: AppLocalizations.of(context).yes,
              value: true,
            );
            var noMenuItem = DefaultMenuItemHelper(
              label: AppLocalizations.of(context).no,
              value: false,
            );
            return SettingDropdownMenu<DefaultMenuItemHelper>(
              width: 40,
              dropDownItems: [defaultMenuItem, yesMenuItem, noMenuItem],
              onSelected: (menuItem) {
                if (menuItem == defaultMenuItem) {
                  if (_epubConf.withTheme == null) return;
                  _epubConf.withTheme = null;
                } else {
                  var value = menuItem!.value as bool;
                  if (_epubConf.withTheme == value) return;
                  _epubConf.withTheme = value;
                }
                Global.instance.pref.setString(
                  "epubconf_$_path",
                  jsonEncode(_epubConf.toJson()),
                );
                _refresh.value = !_refresh.value;
              },
              initSelection:
                  _epubConf.withTheme == null
                      ? defaultMenuItem
                      : _epubConf.withTheme!
                      ? yesMenuItem
                      : noMenuItem,
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
}
