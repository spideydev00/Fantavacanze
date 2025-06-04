import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/containers/gradient_card_container.dart';
import 'package:fantavacanze_official/features/league/domain/entities/daily_challenge_notification.dart';
import 'package:fantavacanze_official/features/league/domain/entities/notification.dart'
    as app_notification;
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/notifications/widgets/notification_action_buttons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationCard extends StatelessWidget {
  static final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  final app_notification.Notification notification;
  final bool isAdmin;
  final VoidCallback? onTap;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const NotificationCard({
    super.key,
    required this.notification,
    this.isAdmin = false,
    this.onTap,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    // Define colors based on notification type and read status
    final bool isChallenge = notification is DailyChallengeNotification;
    final bool isRead = notification.isRead;

    // Choose colors based on notification type and read status
    Color primaryColor = isChallenge ? ColorPalette.warning : ColorPalette.info;
    if (isRead) primaryColor = primaryColor.withValues(alpha: 0.7);

    final Color startColor = context.secondaryBgColor;
    final Color endColor = context.secondaryBgColor.withValues(alpha: 0.9);
    final Color overlayColor = primaryColor.withValues(alpha: 0.05);

    // Choose the appropriate icon
    final IconData iconData =
        isChallenge ? Icons.emoji_events : Icons.notifications;

    return GradientCardContainer(
      startColor: startColor,
      endColor: endColor,
      overlayColor: overlayColor,
      onTap: onTap,
      elevation: isRead ? 1 : 3,
      child: Padding(
        padding: const EdgeInsets.all(ThemeSizes.md),
        child: Stack(
          children: [
            // Add large background icon with opacity (moved to left side)
            Positioned(
              left: -5,
              bottom: 0,
              child: Icon(
                iconData,
                size: 90,
                color: primaryColor.withValues(alpha: 0.05),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with timestamp
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and timestamp (now starts at the beginning)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.title,
                            style: context.textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isRead
                                  ? context.textSecondaryColor
                                  : primaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 12,
                                color: context.textSecondaryColor
                                    .withValues(alpha: 0.7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _dateFormat.format(notification.createdAt),
                                style: context.textTheme.labelSmall?.copyWith(
                                  color: context.textSecondaryColor
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Unread indicator
                    if (!isRead)
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),

                // Message
                Padding(
                  padding: const EdgeInsets.only(top: ThemeSizes.sm),
                  child: Text(
                    notification.message,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: isRead
                          ? context.textSecondaryColor.withValues(alpha: 0.8)
                          : context.textSecondaryColor,
                    ),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Admin actions for challenge notifications
                if (notification is DailyChallengeNotification &&
                    isAdmin &&
                    onApprove != null &&
                    onReject != null) ...[
                  const SizedBox(height: ThemeSizes.sm),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: ThemeSizes.xl + ThemeSizes.sm),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        NotificationActionButtons(
                          onApprove: onApprove!,
                          onReject: onReject!,
                          compact: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
