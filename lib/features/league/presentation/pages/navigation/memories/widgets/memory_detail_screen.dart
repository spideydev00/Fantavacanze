import 'package:cached_network_image/cached_network_image.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:fantavacanze_official/core/widgets/media/video_player.dart';
import 'package:fantavacanze_official/features/league/domain/entities/memory.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule/rule.dart';
import 'package:fantavacanze_official/core/utils/in-game/find_event_from_memory.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MemoryDetailScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMMM yyyy, HH:mm');
    final formattedDate = dateFormat.format(memory.createdAt);

    final relatedEvent = league != null
        ? FindEventFromMemory.findRelatedEvent(memory, league!)
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
          if (memory.isVideo)
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
          if (isCurrentUserAuthor && onDelete != null)
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
                        onDelete!();
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
                tag: 'memory_image_${memory.id}',

                // 👉 sostituisce il player in volo con un placeholder statico
                flightShuttleBuilder: (flightContext, animation, direction,
                    fromContext, toContext) {
                  if (memory.isVideo) {
                    return _buildVideoThumbnailForHero(context);
                  }
                  return CachedNetworkImage(
                    imageUrl: memory.mediaUrl,
                    fit: BoxFit.cover,
                  );
                },

                child: memory.isVideo
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
                            backgroundColor:
                                ColorPalette.getGradientFromId(memory.userId)
                                    .colors
                                    .first,
                            child: Text(
                              memory.participantName[0].toUpperCase(),
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
                                memory.participantName,
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
                    if (memory.eventName != null)
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
                                  memory.eventName!,
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
                    if (memory.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: ThemeSizes.md),
                        child: Text(
                          memory.text,
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
      child: BetterVideoPlayerWidget(
        videoUrl: memory.mediaUrl,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildImageViewer(BuildContext context) {
    return InteractiveViewer(
      minScale: .5,
      maxScale: 3.0,
      child: CachedNetworkImage(
        imageUrl: memory.mediaUrl,
        fit: BoxFit.contain,
        placeholder: (_, __) => Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(context.primaryColor),
          ),
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
