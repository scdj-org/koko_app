import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:koko/common/custom_image_cache_manager.dart';
import 'package:path/path.dart' as p;
import 'package:photo_view/photo_view.dart';

class PhotoViewRoute extends StatefulWidget {
  const PhotoViewRoute({super.key, required this.url, required this.headers});

  final String url;
  final Map<String, String> headers;

  @override
  State<PhotoViewRoute> createState() => _PhotoViewRouteState();
}

class _PhotoViewRouteState extends State<PhotoViewRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Uri.decodeComponent(p.basenameWithoutExtension(widget.url)),
        ),
      ),
      body: PhotoView(
        backgroundDecoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        loadingBuilder: (context, event) {
          double? progress;
          if (event != null && event.expectedTotalBytes != null) {
            progress = event.cumulativeBytesLoaded / event.expectedTotalBytes!;
          }
          return Container(
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(value: progress, strokeWidth: 2.0),
                Transform.scale(
                  scale: 0.7,
                  child: Text("${((progress ?? 0) * 100).toInt()}%"),
                ),
              ],
            ),
          );
        },
        imageProvider: CachedNetworkImageProvider(
          widget.url,
          headers: widget.headers,
          cacheManager: CustomImageCacheManager(),
        ),
      ),
    );
  }
}
