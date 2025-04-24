import 'package:flutter/material.dart';
import 'package:koko/widgets/ui_widgets/loading_widget.dart';
import 'package:koko/widgets/ui_widgets/page_error_widget.dart';
import 'package:path/path.dart' as p;
import 'package:just_audio/just_audio.dart';

class MusicPlayerRoute extends StatefulWidget {
  const MusicPlayerRoute({super.key, required this.url, required this.headers});

  final String url;
  final Map<String, String> headers;

  @override
  State<MusicPlayerRoute> createState() => _MusicPlayerRouteState();
}

class _MusicPlayerRouteState extends State<MusicPlayerRoute>
    with SingleTickerProviderStateMixin {
  late final AudioPlayer _player;
  late final Future<void> _initFuture;
  late final AnimationController _iconAnimationController;
  Duration _duration = Duration.zero;
  late final ValueNotifier<Duration> _position;

  @override
  void initState() {
    super.initState();
    _position = ValueNotifier(Duration.zero);
    _player = AudioPlayer();
    _iconAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _initFuture = _initFunc();

    // 监听播放状态
    _player.playingStream.listen((playing) {
      if (playing) {
        _iconAnimationController.forward();
      } else {
        _iconAnimationController.reverse();
      }
    });

    // 监听进度
    _player.positionStream.listen((position) {
      _position.value = position;
    });
  }

  Future<void> _initFunc() async {
    _duration =
        (await _player.setUrl(widget.url, headers: widget.headers)) ??
        Duration.zero;
    _player.play();
  }

  @override
  void dispose() {
    _player.stop().then((_) {
      _player.dispose();
      _position.dispose();
      _iconAnimationController.dispose();
    });
    super.dispose();
  }

  void _togglePlayPause() {
    if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  void _seekTo(double value) {
    final newPosition = Duration(seconds: value.toInt());
    _player.seek(newPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Uri.decodeComponent(p.basenameWithoutExtension(widget.url)),
        ),
      ),
      body: FutureBuilder(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return LoadingWidget();
          }
          if (snapshot.hasError) {
            return PageErrorWidget(message: snapshot.error.toString());
          }
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  iconSize: 64,
                  icon: AnimatedIcon(
                    icon: AnimatedIcons.play_pause,
                    progress: _iconAnimationController,
                  ),
                  onPressed: _togglePlayPause,
                ),
                SizedBox(height: 20),
                // 进度条
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ValueListenableBuilder(
                    valueListenable: _position,
                    child: Text(_formatDuration(_duration)),
                    builder: (context, position, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(position)),
                          Expanded(
                            child: Slider(
                              value: position.inSeconds.toDouble().clamp(
                                0.0,
                                _duration.inSeconds.toDouble(),
                              ),
                              min: 0.0,
                              max: _duration.inSeconds.toDouble(),
                              onChanged: (value) {
                                _position.value = Duration(
                                  seconds: value.toInt(),
                                );
                              },
                              onChangeEnd: _seekTo,
                            ),
                          ),
                          child!,
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String minutes = duration.inMinutes.toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
}
