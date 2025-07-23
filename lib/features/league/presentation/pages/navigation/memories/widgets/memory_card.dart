import 'package:cached_network_image/cached_network_image.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/media/video_thumbnail.dart';
import 'package:fantavacanze_official/features/league/domain/entities/memory.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class MemoryCard extends StatelessWidget {
  final Memory memory;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isCurrentUserAuthor;

  const MemoryCard({
    super.key,
    required this.memory,
    this.onTap,
    this.onDelete,
    this.isCurrentUserAuthor = false,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM yyyy, HH:mm');
    final formattedDate = dateFormat.format(memory.createdAt);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.secondaryBgColor,
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media section with video overlay
            Stack(
              children: [
                // Media content
                AspectRatio(
                  aspectRatio: 1.1,
                  child: Hero(
                    tag: 'memory_image_${memory.id}',
                    child: memory.isVideo
                        ? _buildVideoThumbnail(context)
                        : _buildImageContent(context),
                  ),
                ),

                // Video play button overlay
                if (memory.isVideo)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                      ),
                      child: Center(
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: ColorPalette.black.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Content section
            Padding(
              padding: const EdgeInsets.all(ThemeSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author and date section
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor:
                              ColorPalette.getGradientFromId(memory.userId)
                                  .colors
                                  .first,
                          child: Text(
                            memory.participantName
                                .substring(0, 1)
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: ThemeSizes.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    memory.participantName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: context.textPrimaryColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (memory.isVideo)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: ColorPalette.info
                                          .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.videocam_rounded,
                                          size: 10,
                                          color: ColorPalette.info,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          'VIDEO',
                                          style: TextStyle(
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                            color: ColorPalette.info,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 12,
                                color: context.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Related event badge
                  if (memory.eventName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: ThemeSizes.sm),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: ThemeSizes.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: ColorPalette.info.withValues(alpha: 0.2),
                          borderRadius:
                              BorderRadius.circular(ThemeSizes.borderRadiusSm),
                        ),
                        child: Text(
                          memory.eventName!,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.textSecondaryColor
                                .withValues(alpha: 0.8),
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                  // Memory description
                  if (memory.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: ThemeSizes.sm),
                      child: Text(
                        memory.text,
                        style: TextStyle(
                          fontSize: 14,
                          color: context.textPrimaryColor,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContent(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: memory.mediaUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: context.bgColor,
        highlightColor: context.secondaryBgColor,
        child: Container(
          color: Colors.grey[300],
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: context.secondaryBgColor,
        child: Center(
          child: Icon(
            Icons.broken_image_rounded,
            color: context.primaryColor.withValues(alpha: 0.5),
            size: 40,
          ),
        ),
      ),
    );
  }

  Widget _buildVideoThumbnail(BuildContext context) {
    return VideoThumbnailWidget(
      videoUrl: memory.mediaUrl,
      fit: BoxFit.cover,
      placeholder: Shimmer.fromColors(
        baseColor: context.bgColor,
        highlightColor: context.secondaryBgColor,
        child: Container(
          color: Colors.grey[300],
          child: Center(
            child: Icon(
              Icons.movie_rounded,
              size: 40,
              color: context.primaryColor.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
      errorWidget: Container(
        color: context.secondaryBgColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.movie_rounded,
                size: 40,
                color: context.primaryColor.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 8),
              Text(
                'Video',
                style: TextStyle(
                  color: context.textSecondaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
