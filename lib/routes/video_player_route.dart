import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:koko/l10n/l10n.dart';
import 'package:koko/widgets/ui_widgets/loading_widget.dart';
import 'package:koko/widgets/ui_widgets/page_error_widget.dart';

import 'package:path/path.dart' as p;
import 'package:universal_io/io.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerRoute extends StatefulWidget {
  const VideoPlayerRoute({super.key, required this.url, required this.headers});

  final Uri url;
  final Map<String, String> headers;

  @override
  State<VideoPlayerRoute> createState() => _VideoPlayerRouteState();
}

class _VideoPlayerRouteState extends State<VideoPlayerRoute> {
  late final VideoPlayerController _videoPlayerController;

  ChewieController? _chewieController;

  late Future<void> _initFuture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Uri.decodeComponent(p.basenameWithoutExtension(widget.url.path)),
        ),
      ),
      body: FutureBuilder(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return LoadingWidget();
          }
          if (snapshot.hasError) {
            // TODO: 日志
            if (kDebugMode) {
              debugPrint(snapshot.error.toString());
            }
            return PageErrorWidget(
              message:
                  "${Uri.decodeComponent(p.basename(widget.url.path))}\n${AppLocalizations.of(context).notSupport}\n${AppLocalizations.of(context).convertToMp4}",
            );
          }
          return SafeArea(child: Chewie(controller: _chewieController!));
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.networkUrl(
      widget.url,
      httpHeaders: widget.headers,
    );

    /// 安卓定制
    if (Platform.isAndroid) {
      _videoPlayerController.addListener(() {
        if (_videoPlayerController.value.isBuffering &&
            !_videoPlayerController.value.isPlaying) {
          _videoPlayerController.value = _videoPlayerController.value.copyWith(
            isBuffering: false,
          );
        }
      });
    }
    _initFuture = _initFunc();
  }

  Future<void> _initFunc() async {
    await _videoPlayerController.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
}
