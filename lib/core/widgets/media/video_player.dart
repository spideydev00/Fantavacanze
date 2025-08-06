import 'dart:async';
import 'dart:io';
import 'package:awesome_video_player/awesome_video_player.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

enum VideoPlayerMode {
  memories, // Minimal controls, no fullscreen
  tutorials, // Full controls, fullscreen enabled
}

class BetterVideoPlayer extends StatefulWidget {
  final String videoSource;
  final BoxFit fit;
  final VideoPlayerMode mode;
  final bool isAsset;

  const BetterVideoPlayer({
    super.key,
    required this.videoSource,
    this.fit = BoxFit.cover,
    this.mode = VideoPlayerMode.memories,
    this.isAsset = false,
  });

  // Factory constructors for specific use cases
  const BetterVideoPlayer.forMemories({
    super.key,
    required String videoUrl,
    this.fit = BoxFit.cover,
  })  : videoSource = videoUrl,
        mode = VideoPlayerMode.memories,
        isAsset = false;

  const BetterVideoPlayer.forTutorials({
    super.key,
    required String assetPath,
    this.fit = BoxFit.cover,
  })  : videoSource = assetPath,
        mode = VideoPlayerMode.tutorials,
        isAsset = true;

  @override
  State<BetterVideoPlayer> createState() => _BetterVideoPlayerState();
}

class _BetterVideoPlayerState extends State<BetterVideoPlayer>
    with WidgetsBindingObserver {
  BetterPlayerController? _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  bool _isDisposed = false;
  String? _tempFilePath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller == null && !_isDisposed) {
      _initializePlayer();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (_controller != null && !_isDisposed) {
      switch (state) {
        case AppLifecycleState.paused:
          _controller?.pause();
          break;
        case AppLifecycleState.resumed:
          // Don't auto-resume for tutorials
          if (widget.mode == VideoPlayerMode.memories) {
            _controller?.play();
          }
          break;
        default:
          break;
      }
    }
  }

  Future<void> _initializePlayer() async {
    if (_isDisposed) return;

    try {
      final config = _buildPlayerConfiguration();
      final dataSource = await _buildDataSource();

      if (_isDisposed) return;

      _controller = BetterPlayerController(config);
      await _controller!.setupDataSource(dataSource);

      if (_isDisposed) {
        _controller?.dispose();
        return;
      }

      if (mounted && !_isDisposed) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted && !_isDisposed) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  BetterPlayerConfiguration _buildPlayerConfiguration() {
    // Get screen dimensions with proper validation
    final screenSize = MediaQuery.sizeOf(context);
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Validate screen dimensions and provide fallbacks
    final safeWidth =
        (screenWidth.isFinite && screenWidth > 0) ? screenWidth : 390.0;
    final safeHeight =
        (screenHeight.isFinite && screenHeight > 0) ? screenHeight : 844.0;

    double safeScreenRatio = safeWidth / safeHeight;

    // Additional validation for the calculated ratio
    if (!safeScreenRatio.isFinite || safeScreenRatio <= 0) {
      safeScreenRatio = 9.0 / 16.0;
    }

    // Clamp to reasonable bounds
    safeScreenRatio = safeScreenRatio.clamp(0.1, 10.0);

    switch (widget.mode) {
      case VideoPlayerMode.memories:
        return BetterPlayerConfiguration(
          aspectRatio: 9.0 / 16.0,
          fit: widget.fit,
          looping: false,
          fullScreenByDefault: false,
          allowedScreenSleep: false,
          expandToFill: true,
          deviceOrientationsAfterFullScreen: [
            DeviceOrientation.portraitUp,
          ],
          controlsConfiguration: BetterPlayerControlsConfiguration(
            // Minimal controls for memories
            enableFullscreen: false,
            enableMute: false,
            enableOverflowMenu: false,
            enableSkips: false,
            enablePlayPause: true,
            enableProgressBar: true,
            enableProgressText: false,
            enableProgressBarDrag: false,
            showControlsOnInitialize: true,
            controlsHideTime: const Duration(milliseconds: 300),
            controlBarHeight: 48.0,
            // Colors
            controlBarColor: Colors.black.withValues(alpha: 0.8),
            progressBarPlayedColor: ColorPalette.info,
            progressBarHandleColor: ColorPalette.info,
            progressBarBackgroundColor: Colors.white.withValues(alpha: 0.3),
            progressBarBufferedColor: ColorPalette.info.withValues(alpha: 0.5),
          ),
          placeholder: _buildPlaceholder(),
          errorBuilder: _buildErrorWidget,
        );

      case VideoPlayerMode.tutorials:
        return BetterPlayerConfiguration(
          aspectRatio: safeScreenRatio,
          fullScreenAspectRatio: safeScreenRatio,
          fit: widget.fit,
          allowedScreenSleep: false,
          deviceOrientationsOnFullScreen: [
            DeviceOrientation.portraitDown,
          ],
          deviceOrientationsAfterFullScreen: [
            DeviceOrientation.portraitDown,
          ],
          controlsConfiguration: BetterPlayerControlsConfiguration(
            // Full controls for tutorials
            enableFullscreen: true,
            enableMute: true,
            enableOverflowMenu: false,
            enableSkips: true,
            enablePlayPause: true,
            enableProgressBar: true,
            enableProgressText: true,
            enableProgressBarDrag: true,
            showControlsOnInitialize: true,
            controlsHideTime: const Duration(milliseconds: 300),
            controlBarHeight: 56.0,
            // Enhanced colors for tutorials
            controlBarColor: Colors.black.withValues(alpha: 0.9),
            progressBarPlayedColor: ColorPalette.success,
            progressBarHandleColor: ColorPalette.success,
            progressBarBackgroundColor: Colors.white.withValues(alpha: 0.4),
            progressBarBufferedColor:
                ColorPalette.success.withValues(alpha: 0.6),
            iconsColor: Colors.white,
            textColor: Colors.white,
          ),
          placeholder: _buildPlaceholder(),
          errorBuilder: _buildErrorWidget,
        );
    }
  }

  Future<BetterPlayerDataSource> _buildDataSource() async {
    if (widget.isAsset) {
      // Handle asset files - convert to temporary file
      try {
        // Load asset bytes
        final ByteData assetData = await rootBundle.load(widget.videoSource);
        final Uint8List bytes = assetData.buffer.asUint8List();

        // Get temporary directory
        final Directory tempDir = await getTemporaryDirectory();

        // Create unique filename based on asset path
        final String assetFileName = path.basename(widget.videoSource);
        final String tempFileName =
            'video_${assetFileName.hashCode}_$assetFileName';

        // Create temporary file
        final File tempFile = File(path.join(tempDir.path, tempFileName));

        // Check if file already exists to avoid unnecessary writes
        if (!await tempFile.exists()) {
          await tempFile.writeAsBytes(bytes);
        }

        // Store path for cleanup
        _tempFilePath = tempFile.path;

        return BetterPlayerDataSource(
          BetterPlayerDataSourceType.file,
          tempFile.path,
        );
      } catch (e) {
        throw Exception('Errore nel caricamento dell\'asset video: $e');
      }
    } else {
      // Handle network URLs
      return BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        widget.videoSource,
      );
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      color: widget.mode == VideoPlayerMode.tutorials
          ? Colors.black87
          : Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: widget.mode == VideoPlayerMode.tutorials
                  ? ColorPalette.success
                  : Colors.white,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String? message) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: ColorPalette.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              widget.mode == VideoPlayerMode.tutorials
                  ? 'Errore nel caricamento del tutorial'
                  : 'Errore nel caricamento video',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _cleanupTempFile() async {
    if (_tempFilePath != null) {
      try {
        final tempFile = File(_tempFilePath!);
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      } catch (e) {
        // Ignore cleanup errors
        debugPrint('Failed to cleanup temp file: $e');
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);

    if (widget.mode == VideoPlayerMode.tutorials) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }

    _controller?.dispose();
    _controller = null;
    _cleanupTempFile();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildPlaceholder();
    }

    if (_hasError || _controller == null || _isDisposed) {
      return _buildErrorWidget(context, _errorMessage);
    }

    // Calculate safe aspect ratio for the widget wrapper
    double aspectRatio = 9.0 / 16.0; // Default for memories

    if (widget.mode == VideoPlayerMode.tutorials) {
      final screenSize = MediaQuery.sizeOf(context);
      final screenWidth = screenSize.width;
      final screenHeight = screenSize.height;

      if (screenWidth.isFinite &&
          screenHeight.isFinite &&
          screenWidth > 0 &&
          screenHeight > 0) {
        aspectRatio = (screenWidth / screenHeight).clamp(0.1, 10.0);
      }
    }

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _controller?.setControlsVisibility(true),
        child: BetterPlayer(controller: _controller!),
      ),
    );
  }
}
