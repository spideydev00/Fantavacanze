import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/domain/entities/notification.dart'
    as app_notification;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NotificationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String notificationType;
  final String? notificationId;
  final Map<String, dynamic>? data;

  const NotificationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.notificationType,
    this.notificationId,
    this.data,
  });

  factory NotificationDialog.fromNotification({
    required app_notification.Notification notification,
  }) {
    return NotificationDialog(
      title: notification.title,
      message: notification.message,
      notificationType: notification.type,
      notificationId: notification.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildDialogContent(context),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    // Configure colors based on notification type
    final iconPath = 'assets/images/icons/other/notification-icon.svg';

    return Container(
      padding: const EdgeInsets.only(bottom: ThemeSizes.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.info.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top color accent bar with icon
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Gradient background
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        ColorPalette.info,
                        ColorPalette.info.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                ),

                // Decorative circles
                Positioned(
                  top: -30,
                  right: -30,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),

                Positioned(
                  bottom: -20,
                  left: -20,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),

                // Icon
                SvgPicture.asset(
                  iconPath,
                  height: 60,
                  width: 60,
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimaryColor,
                  ),
                ),

                const SizedBox(height: 12),

                // Message
                Text(
                  message,
                  style: context.textTheme.labelLarge?.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),

                const SizedBox(height: 24),

                // Single close button, regardless of notification type
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.info,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Chiudi'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
