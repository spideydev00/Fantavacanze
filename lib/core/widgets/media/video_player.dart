import 'dart:async';
import 'package:chewie/chewie.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ChewieVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const ChewieVideoPlayer({
    super.key,
    required this.videoUrl,
  });

  @override
  State<ChewieVideoPlayer> createState() => _ChewieVideoPlayerState();
}

class _ChewieVideoPlayerState extends State<ChewieVideoPlayer> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  bool _showControls = true;
  Timer? _controlsTimer;
  bool _controlsManuallyHidden = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      final uri = Uri.parse(widget.videoUrl);
      _videoPlayerController = VideoPlayerController.networkUrl(uri);
      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: false,
        materialProgressColors: ChewieProgressColors(
          playedColor: ColorPalette.info,
          handleColor: ColorPalette.info,
          backgroundColor: Colors.white.withValues(alpha: .3),
          bufferedColor: ColorPalette.info.withValues(alpha: .5),
        ),
        placeholder: Container(color: Colors.black),
        autoInitialize: true,
        errorBuilder: (_, __) => const SizedBox.shrink(),
      );

      _videoPlayerController!.addListener(() {
        if (_videoPlayerController!.value.isPlaying &&
            _showControls &&
            !_controlsManuallyHidden) {
          _startControlsTimer();
        }
      });

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _startControlsTimer() {
    _controlsTimer?.cancel();
    if (!_controlsManuallyHidden) {
      _controlsTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && _videoPlayerController!.value.isPlaying) {
          setState(() => _showControls = false);
        }
      });
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      _controlsManuallyHidden = !_showControls;
    });
    if (_showControls && _videoPlayerController!.value.isPlaying) {
      _controlsManuallyHidden = false;
      _startControlsTimer();
    } else {
      _controlsTimer?.cancel();
    }
  }

  void _togglePlayPause() {
    if (_videoPlayerController!.value.isPlaying) {
      _videoPlayerController!.pause();
      _controlsTimer?.cancel();
      setState(() {
        _showControls = true;
        _controlsManuallyHidden = false;
      });
    } else {
      _videoPlayerController!.play();
      if (!_controlsManuallyHidden) _startControlsTimer();
    }
  }

  void _seekBackward() {
    final currentPosition = _videoPlayerController!.value.position;
    final newPosition = currentPosition - const Duration(seconds: 10);
    _videoPlayerController!.seekTo(
      newPosition < Duration.zero ? Duration.zero : newPosition,
    );
    _afterSeek();
  }

  void _seekForward() {
    final currentPosition = _videoPlayerController!.value.position;
    final maxPosition = _videoPlayerController!.value.duration;
    final newPosition = currentPosition + const Duration(seconds: 10);
    _videoPlayerController!.seekTo(
      newPosition > maxPosition ? maxPosition : newPosition,
    );
    _afterSeek();
  }

  void _afterSeek() {
    setState(() {
      _showControls = true;
      _controlsManuallyHidden = false;
    });
    if (_videoPlayerController!.value.isPlaying) _startControlsTimer();
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: _isLoading
            ? _buildLoadingWidget() // ora compare una sola volta
            : (_hasError || _chewieController == null)
                ? _buildErrorWidget()
                : _buildVideoPlayer(),
      ),
    );
  }

  // ------- UI helpers -------------------------------------------------------

  /// Loader wrappato in Material → spariscono le righe gialle di debug.
  Widget _buildLoadingWidget() {
    return Material(
      key: const ValueKey('loading'),
      color: Colors.black,
      child: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Caricamento video...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      key: const ValueKey('error'),
      color: Colors.black,
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            const Text(
              'Errore nel caricamento del video',
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isLoading = true;
                  _errorMessage = null;
                });
                _initializePlayer();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Riprova'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.info,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Container(
      key: const ValueKey('video'),
      color: Colors.black,
      width: double.infinity,
      height: double.infinity,
      child: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: _videoPlayerController!.value.aspectRatio,
                child: Chewie(controller: _chewieController!),
              ),
            ),
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: _showControls
                    ? _buildCustomControls()
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomControls() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: .7),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: .7),
          ],
          stops: const [0, .3, .7, 1],
        ),
      ),
      child: Column(
        children: [
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _circleButton(Icons.replay_10, _seekBackward),
              const SizedBox(width: 40),
              _circleButton(
                _videoPlayerController!.value.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                _togglePlayPause,
                size: 40,
                bgOpacity: .6,
              ),
              const SizedBox(width: 40),
              _circleButton(Icons.forward_10, _seekForward),
            ],
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: _buildProgressBar(),
          ),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap,
      {double size = 28, double bgOpacity = .5}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: bgOpacity),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: size),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Material(
      color: Colors.transparent,
      child: ValueListenableBuilder(
        valueListenable: _videoPlayerController!,
        builder: (_, VideoPlayerValue v, __) {
          if (!v.isInitialized) return const SizedBox.shrink();
          final dur = v.duration;
          final pos = v.position;
          final progress = dur.inMilliseconds > 0
              ? pos.inMilliseconds / dur.inMilliseconds
              : 0.0;

          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(pos),
                      style:
                          const TextStyle(color: Colors.white, fontSize: 12)),
                  Text(_formatDuration(dur),
                      style:
                          const TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: ColorPalette.info,
                  inactiveTrackColor: Colors.white.withValues(alpha: .3),
                  thumbColor: ColorPalette.info,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayColor: ColorPalette.info.withValues(alpha: .3),
                  trackHeight: 3,
                ),
                child: Slider(
                  value: progress.clamp(0.0, 1.0),
                  onChanged: (value) {
                    _videoPlayerController!.seekTo(Duration(
                      milliseconds: (value * dur.inMilliseconds).round(),
                    ));
                  },
                  onChangeStart: (_) => _controlsTimer?.cancel(),
                  onChangeEnd: (_) {
                    if (_videoPlayerController!.value.isPlaying &&
                        !_controlsManuallyHidden) {
                      _startControlsTimer();
                    }
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }
}
