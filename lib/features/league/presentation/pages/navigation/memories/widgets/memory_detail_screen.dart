import 'package:cached_network_image/cached_network_image.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:fantavacanze_official/core/widgets/media/video_player.dart';
import 'package:fantavacanze_official/features/league/domain/entities/memory.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule/rule.dart';
import 'package:fantavacanze_official/core/utils/in-game/find_event_from_memory.dart';
import 'package:fantavacanze_official/core/utils/media/downloader.dart';
import 'package:fantavacanze_official/core/utils/show-snackbar-or-paywall/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MemoryDetailScreen extends StatefulWidget {
  final Memory memory;
  final VoidCallback? onDelete;
  final bool isCurrentUserAuthor;
  final League? league;

  const MemoryDetailScreen({
    super.key,
    required this.memory,
    this.onDelete,
    this.isCurrentUserAuthor = false,
    this.league,
  });

  @override
  State<MemoryDetailScreen> createState() => _MemoryDetailScreenState();
}

class _MemoryDetailScreenState extends State<MemoryDetailScreen> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  final Downloader _downloader = Downloader();

  @override
  void dispose() {
    _downloader.cancelDownloads();
    super.dispose();
  }

  /// Handle download action for both images and videos
  Future<void> _handleDownload() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    final String? downloadedPath;
    if (widget.memory.isVideo) {
      downloadedPath = await _downloader.downloadVideo(
        widget.memory.mediaUrl,
        onProgress: (progress) {
          setState(() {
            _downloadProgress = progress;
          });
        },
        onComplete: () {
          setState(() {
            _isDownloading = false;
          });
          showSnackBar(
            'Video salvato nella galleria!',
            color: ColorPalette.success,
          );
        },
        onError: (error) {
          setState(() {
            _isDownloading = false;
          });
          showSnackBar(error);
        },
      );
    } else {
      downloadedPath = await _downloader.downloadImage(
        widget.memory.mediaUrl,
        onProgress: (progress) {
          setState(() {
            _downloadProgress = progress;
          });
        },
        onComplete: () {
          setState(() {
            _isDownloading = false;
          });
          showSnackBar(
            'Immagine salvata nella galleria!',
            color: ColorPalette.success,
          );
        },
        onError: (error) {
          setState(() {
            _isDownloading = false;
          });
          showSnackBar(error);
        },
      );
    }

    if (downloadedPath == null) {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMMM yyyy, HH:mm');
    final formattedDate = dateFormat.format(widget.memory.createdAt);

    final relatedEvent = widget.league != null
        ? FindEventFromMemory.findRelatedEvent(widget.memory, widget.league!)
        : null;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(ThemeSizes.sm),
          child: BackButton(
            color: Colors.white,
            style: ButtonStyle(
              padding: WidgetStatePropertyAll(
                EdgeInsets.all(ThemeSizes.sm),
              ),
              iconSize: WidgetStatePropertyAll(23),
            ),
          ),
        ),
        actions: [
          if (widget.memory.isVideo)
            Padding(
              padding: const EdgeInsets.only(right: ThemeSizes.sm),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorPalette.info.withValues(alpha: .8),
                  borderRadius:
                      BorderRadius.circular(ThemeSizes.borderRadiusMd),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.videocam_rounded, size: 12, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'VIDEO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Download button
          _isDownloading
              ? Container(
                  width: 40,
                  height: 40,
                  padding: const EdgeInsets.all(8),
                  child: CircularProgressIndicator(
                    value: _downloadProgress,
                    strokeWidth: 2,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.download_rounded, size: 25),
                  color: Colors.white,
                  onPressed: _handleDownload,
                  tooltip: widget.memory.isVideo
                      ? 'Scarica video'
                      : 'Scarica immagine',
                ),

          if (widget.isCurrentUserAuthor && widget.onDelete != null)
            Padding(
              padding: const EdgeInsets.all(ThemeSizes.xs),
              child: IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 25),
                color: Colors.white,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => ConfirmationDialog.deleteMemory(
                      onDelete: () {
                        Navigator.pop(ctx);
                        widget.onDelete!();
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // ------------------- MEDIA -------------------
          Expanded(
            flex: 3,
            child: Center(
              child: Hero(
                tag: 'memory_image_${widget.memory.id}',

                // 👉 sostituisce il player in volo con un placeholder statico
                flightShuttleBuilder: (flightContext, animation, direction,
                    fromContext, toContext) {
                  if (widget.memory.isVideo) {
                    return _buildVideoThumbnailForHero(context);
                  }
                  return CachedNetworkImage(
                    imageUrl: widget.memory.mediaUrl,
                    fit: BoxFit.cover,
                  );
                },

                child: widget.memory.isVideo
                    ? _buildVideoPlayer(context)
                    : _buildImageViewer(context),
              ),
            ),
          ),

          // ------------------- DETTAGLI -------------------
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(ThemeSizes.lg),
              decoration: BoxDecoration(
                color: context.bgColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(ThemeSizes.borderRadiusXlg),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .2),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------- AUTHOR ----------
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: .1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: ColorPalette.getGradientFromId(
                                    widget.memory.userId)
                                .colors
                                .first,
                            child: Text(
                              widget.memory.participantName[0].toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: ThemeSizes.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.memory.participantName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: context.textPrimaryColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.access_time_rounded,
                                      size: 14,
                                      color: context.textSecondaryColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    formattedDate,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: context.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // ---------- DIVIDER ----------
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: ThemeSizes.md),
                      child: Divider(
                        color: context.borderColor.withValues(alpha: .3),
                        height: 1,
                      ),
                    ),

                    // ---------- EVENT ----------
                    if (widget.memory.eventName != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: ThemeSizes.md),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: ThemeSizes.md,
                              vertical: ThemeSizes.sm),
                          decoration: BoxDecoration(
                            color: _getEventColor(relatedEvent?.type)
                                .withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(
                                ThemeSizes.borderRadiusLg),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getEventIcon(relatedEvent?.type),
                                size: 16,
                                color: _getEventColor(relatedEvent?.type),
                              ),
                              const SizedBox(width: ThemeSizes.sm),
                              Expanded(
                                child: Text(
                                  widget.memory.eventName!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _getEventColor(relatedEvent?.type),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // ---------- DESCRIPTION ----------
                    if (widget.memory.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: ThemeSizes.md),
                        child: Text(
                          widget.memory.text,
                          style: TextStyle(
                            fontSize: 16,
                            color: context.textPrimaryColor,
                            height: 1.4,
                            letterSpacing: .2,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------- MEDIA WIDGETS -------------------

  Widget _buildVideoPlayer(BuildContext context) {
    return SizedBox.expand(
      child: BetterVideoPlayer(
        videoSource: widget.memory.mediaUrl,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildImageViewer(BuildContext context) {
    return InteractiveViewer(
      minScale: .5,
      maxScale: 3.0,
      child: CachedNetworkImage(
        imageUrl: widget.memory.mediaUrl,
        fit: BoxFit.contain,
        placeholder: (_, __) => Loader(
          color: ColorPalette.info,
        ),
        errorWidget: (_, __, ___) => const Center(
          child: Icon(Icons.broken_image_rounded, color: Colors.red, size: 60),
        ),
      ),
    );
  }

  /// Placeholder statico usato dalla Hero mentre vola
  Widget _buildVideoThumbnailForHero(BuildContext context) {
    return Container(
      color: context.secondaryBgColor,
      child: Center(
        child: Icon(
          Icons.movie_rounded,
          size: 50,
          color: ColorPalette.info.withValues(alpha: .7),
        ),
      ),
    );
  }

  // ------------------- EVENT UTILS -------------------

  Color _getEventColor(RuleType? t) {
    switch (t) {
      case RuleType.bonus:
        return ColorPalette.success;
      case RuleType.malus:
        return ColorPalette.error;
      default:
        return ColorPalette.info;
    }
  }

  IconData _getEventIcon(RuleType? t) {
    switch (t) {
      case RuleType.bonus:
        return Icons.add_circle_outline_rounded;
      case RuleType.malus:
        return Icons.remove_circle_outline_rounded;
      default:
        return Icons.event_available_rounded;
    }
  }
}
