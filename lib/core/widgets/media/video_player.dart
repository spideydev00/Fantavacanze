import 'dart:async';
import 'package:awesome_video_player/awesome_video_player.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:flutter/material.dart';

class BetterVideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final BoxFit fit;

  const BetterVideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.fit = BoxFit.cover,
  });

  @override
  State<BetterVideoPlayerWidget> createState() =>
      _BetterVideoPlayerWidgetState();
}

class _BetterVideoPlayerWidgetState extends State<BetterVideoPlayerWidget> {
  BetterPlayerController? _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller == null) {
      _initializePlayer();
    }
  }

  Future<void> _initializePlayer() async {
    try {
      final screenRatio = MediaQuery.of(context).size.aspectRatio;

      final config = BetterPlayerConfiguration(
        aspectRatio: screenRatio,
        fit: widget.fit,
        autoPlay: true,
        looping: false,
        fullScreenByDefault: false,
        allowedScreenSleep: false,
        expandToFill: true,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          // Rimuovo i pulsanti che non servono
          enableFullscreen: false,
          enableMute: false,
          enableOverflowMenu: false,
          enableSkips: false,

          // Tengo solo play/pause e progress bar (non draggabile)
          enablePlayPause: true,
          enableProgressBar: true,
          enableProgressText: false,
          enableProgressBarDrag: false,

          // Nascondi i controlli all'avvio, ma falli scomparire dopo 2s
          showControlsOnInitialize: false,
          controlsHideTime: const Duration(seconds: 2),

          // Altezza fissa della barra per evitare NaN
          controlBarHeight: 48.0,

          // Colorazioni
          controlBarColor: Colors.black.withValues(alpha: 0.8),
          progressBarPlayedColor: ColorPalette.info,
          progressBarHandleColor: ColorPalette.info,
          progressBarBackgroundColor: Colors.white.withValues(alpha: 0.3),
          progressBarBufferedColor: ColorPalette.info.withValues(alpha: 0.5),
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ),
        ),
        errorBuilder: (ctx, msg) => Center(
          child: Text(
            msg ?? 'Errore sconosciuto',
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      );

      final dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        widget.videoUrl,
      );

      _controller = BetterPlayerController(config);
      await _controller!.setupDataSource(dataSource);

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 3,
        ),
      );
    }
    if (_hasError || _controller == null) {
      return Center(
        child: Text(
          'Errore nel caricamento video\n${_errorMessage ?? ""}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        // Ensure valid dimensions to prevent NaN
        final validWidth = w.isFinite && w > 0 ? w : 1.0;
        final validHeight = h.isFinite && h > 0 ? h : 1.0;

        final aspect = validWidth / validHeight;

        // Ensure aspect ratio is valid and reasonable
        final safeAspectRatio = aspect.isFinite && aspect > 0
            ? aspect.clamp(0.1, 10.0) // Reasonable bounds
            : 16 / 9; // Default fallback

        return ClipRect(
          child: AspectRatio(
            aspectRatio: safeAspectRatio,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                // Fa comparire subito i controlli
                _controller?.setControlsVisibility(true);
              },
              child: BetterPlayer(controller: _controller!),
            ),
          ),
        );
      },
    );
  }
}
