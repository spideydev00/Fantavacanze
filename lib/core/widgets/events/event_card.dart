import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule/rule.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  static final _defaultDateFormat = DateFormat('dd/MM/yyyy');

  final dynamic event;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final DateFormat? dateFormat;
  final bool showDetails;
  final bool allowDismiss;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.onDismiss,
    this.dateFormat,
    this.showDetails = true,
    this.allowDismiss = false,
  });

  @override
  Widget build(BuildContext context) {
    // Extract event data
    final String eventName = event.name;
    final double points =
        event.points is int ? (event.points as int).toDouble() : event.points;
    final bool isBonus = event.type == RuleType.bonus;
    final DateTime createdAt = event.createdAt;

    // Use targetUser directly - it should already be resolved by EventWithResolvedName
    final String targetName = event.targetUser;

    final String formattedDate =
        (dateFormat ?? _defaultDateFormat).format(createdAt);

    // Format points value - only use comma for non-zero decimal parts
    String formattedPoints;
    if (points == points.truncateToDouble()) {
      // It's a whole number, don't show decimal
      formattedPoints = points.toInt().toString();
    } else {
      // It has a decimal part, use comma
      formattedPoints = points.toString().replaceAll('.', ',');
    }

    // Define colors based on event type
    final Color primaryColor =
        isBonus ? ColorPalette.success : ColorPalette.error;
    final Color secondaryColor = context.secondaryBgColor;

    // Create gradient colors based on event type and theme
    final Color gradientStart = secondaryColor;
    final Color gradientEnd = secondaryColor.withValues(alpha: 0.8);
    final Color overlayColor = primaryColor.withValues(alpha: 0.05);

    Widget cardContent = Container(
      margin: const EdgeInsets.only(bottom: ThemeSizes.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradientStart, gradientEnd],
        ),
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
          splashColor: primaryColor.withValues(alpha: 0.1),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(ThemeSizes.md),
            child: Stack(
              children: [
                // Event type indicator overlay
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: overlayColor,
                      ),
                    ),
                  ),
                ),

                Row(
                  children: [
                    // Modern event type indicator
                    Container(
                      padding: const EdgeInsets.all(ThemeSizes.sm),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            primaryColor.withValues(alpha: 0.8),
                            primaryColor,
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isBonus ? Icons.arrow_upward : Icons.arrow_downward,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: ThemeSizes.md),

                    // Event details
                    if (showDetails)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              eventName,
                              style: context.textTheme.bodySmall!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 14,
                                  color: context.textSecondaryColor,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    targetName, // This should now show the resolved name
                                    style: context.textTheme.labelSmall,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 12,
                                  color: context.textSecondaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  formattedDate,
                                  style: context.textTheme.labelSmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    // Points with modern styling
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ThemeSizes.sm,
                        vertical: ThemeSizes.xs,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            primaryColor.withValues(alpha: 0.7),
                            primaryColor,
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(ThemeSizes.borderRadiusMd),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        isBonus ? '+$formattedPoints' : formattedPoints,
                        style: context.textTheme.labelMedium!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Se allowDismiss è true, wrap con Dismissible
    if (allowDismiss && onDismiss != null) {
      return Dismissible(
        key: Key('event_${event.id}'),
        direction: DismissDirection.endToStart,
        dismissThresholds: const {DismissDirection.endToStart: 0.3},
        confirmDismiss: (direction) async {
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => ConfirmationDialog.delete(
              itemType: 'evento',
              customMessage:
                  'Sei sicuro di voler rimuovere questo evento? I punti associati verranno sottratti dalla classifica.',
              onDelete: onDismiss!,
            ),
          );
          return result ?? false;
        },
        background: Container(
          margin: const EdgeInsets.only(bottom: ThemeSizes.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [
                ColorPalette.error.withValues(alpha: 0.9),
                ColorPalette.error.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
          ),
          child: const Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Elimina',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.delete_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
        child: cardContent,
      );
    }

    return cardContent;
  }
}
