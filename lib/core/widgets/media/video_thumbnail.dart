import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoThumbnailWidget extends StatefulWidget {
  final String videoUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;

  const VideoThumbnailWidget({
    super.key,
    required this.videoUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<VideoThumbnailWidget> createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {
  Uint8List? _thumbnailBytes;
  bool _isLoading = true;
  bool _hasError = false;
  String? _currentVideoUrl;

  @override
  void initState() {
    super.initState();
    _currentVideoUrl = widget.videoUrl;
    _generateThumbnail();
  }

  @override
  void didUpdateWidget(VideoThumbnailWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Se l'URL del video è cambiato, rigenera la thumbnail
    if (oldWidget.videoUrl != widget.videoUrl) {
      _currentVideoUrl = widget.videoUrl;
      setState(() {
        _thumbnailBytes = null;
        _isLoading = true;
        _hasError = false;
      });
      _generateThumbnail();
    }
  }

  Future<void> _generateThumbnail() async {
    try {
      final uint8list = await VideoThumbnail.thumbnailData(
        video: widget.videoUrl,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 300,
        quality: 75,
      );

      // Controlla se l'URL è ancora lo stesso (evita race conditions)
      if (mounted && _currentVideoUrl == widget.videoUrl) {
        setState(() {
          _thumbnailBytes = uint8list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted && _currentVideoUrl == widget.videoUrl) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.placeholder ??
          const Center(
            child: CircularProgressIndicator(),
          );
    }

    if (_hasError || _thumbnailBytes == null) {
      return widget.errorWidget ??
          Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(
                Icons.video_library_rounded,
                size: 40,
                color: Colors.grey,
              ),
            ),
          );
    }

    return Image.memory(
      _thumbnailBytes!,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
    );
  }
}
