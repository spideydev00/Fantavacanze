import 'package:cached_network_image/cached_network_image.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/number_formatter.dart';
import 'package:flutter/material.dart';

class ParticipantCard extends StatelessWidget {
  final String name;
  final double points;
  final String? formattedPoints; // Add this parameter
  final bool isSelected;
  final bool showPoints;
  final bool isFullWidth;
  final String? avatarUrl;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool showBadge;
  final IconData? badgeIcon;
  final Color? badgeColor;
  final Color? cardColor;

  const ParticipantCard({
    super.key,
    required this.name,
    required this.points,
    this.formattedPoints, // Optional formatted points
    this.isSelected = false,
    this.showPoints = false,
    this.isFullWidth = false,
    this.avatarUrl,
    this.subtitle,
    this.onTap,
    this.showBadge = false,
    this.badgeIcon,
    this.badgeColor,
    this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    // Format points if not already provided
    final displayPoints =
        formattedPoints ?? NumberFormatter.formatPoints(points);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: cardColor ?? context.secondaryBgColor,
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? context.primaryColor.withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isSelected ? 12 : 4,
              spreadRadius: isSelected ? 2 : 0,
              offset: const Offset(0, 2),
            ),
          ],
          border: isSelected
              ? Border.all(color: context.primaryColor, width: 2)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(ThemeSizes.md),
          child: Row(
            children: [
              // Avatar with possible rank badge
              _buildAvatar(context),

              const SizedBox(width: ThemeSizes.md),

              // Name, subtitle and badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isFullWidth ? 16 : 14,
                              color: isSelected
                                  ? context.primaryColor
                                  : context.textPrimaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: ThemeSizes.xs),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.textSecondaryColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Points display
              if (showPoints)
                Padding(
                  padding: const EdgeInsets.only(left: ThemeSizes.sm),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeSizes.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: context.primaryColor.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(ThemeSizes.borderRadiusSm),
                      border: Border.all(
                        color: context.primaryColor,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      displayPoints, // Use formatted points here
                      style: TextStyle(
                        color: context.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

              // Optional trailing widget
              if (showBadge)
                Padding(
                  padding: const EdgeInsets.only(left: ThemeSizes.sm),
                  child: Icon(
                    badgeIcon,
                    color: badgeColor ?? context.primaryColor,
                    size: isFullWidth ? 20 : 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Stack(
      children: [
        // Main avatar
        Container(
          width: isFullWidth ? 50 : 40,
          height: isFullWidth ? 50 : 40,
          decoration: BoxDecoration(
            color: context.primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: isSelected
                ? Border.all(color: context.primaryColor, width: 2)
                : null,
          ),
          child: avatarUrl != null && avatarUrl!.isNotEmpty
              ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: avatarUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.primaryColor,
                      ),
                    ),
                    errorWidget: (context, url, error) =>
                        _buildDefaultAvatar(context),
                  ),
                )
              : _buildDefaultAvatar(context),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar(BuildContext context) {
    return Center(
      child: Text(
        name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
        style: TextStyle(
          fontSize: isFullWidth ? 20 : 16,
          fontWeight: FontWeight.bold,
          color: context.primaryColor,
        ),
      ),
    );
  }
}
