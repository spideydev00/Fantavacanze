import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';

/// A component to display when no rules are available
///
/// This component shows an empty state with an icon, message, and
/// optionally an action button to add a rule.
class EmptyRulesView extends StatelessWidget {
  /// The message to display
  final String message;

  /// The main color to use (usually green for bonus, red for malus)
  final Color color;

  /// Whether this is for bonus rules (affects icon and button text)
  final bool isBonus;

  /// Whether the user is an admin (determines if add button is shown)
  final bool isAdmin;

  /// The league object, needed if the add button is shown
  final League? league;

  /// Callback when the add button is pressed
  final Function(BuildContext, League)? onAddPressed;

  /// Optional icon to override the default
  final IconData? icon;

  /// Optional icon size
  final double iconSize;

  /// Optional container size for the icon
  final double containerSize;

  const EmptyRulesView({
    super.key,
    required this.message,
    required this.color,
    required this.isBonus,
    required this.isAdmin,
    this.league,
    this.onAddPressed,
    this.icon,
    this.iconSize = 64,
    this.containerSize = 120,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the appropriate icon
    final displayIcon = icon ??
        (isBonus
            ? Icons.arrow_circle_up_outlined
            : Icons.arrow_circle_down_outlined);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container
          Container(
            width: containerSize,
            height: containerSize,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              displayIcon,
              size: iconSize,
              color: color,
            ),
          ),
          const SizedBox(height: ThemeSizes.lg),

          // Message
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: context.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),

          // Add button if admin
          if (isAdmin && league != null && onAddPressed != null) ...[
            const SizedBox(height: ThemeSizes.xl),
            ElevatedButton.icon(
              onPressed: () => onAddPressed!(context, league!),
              icon: Icon(isBonus
                  ? Icons.add_circle_outline
                  : Icons.remove_circle_outline),
              label: Text('Aggiungi ${isBonus ? 'Bonus' : 'Malus'}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: ThemeSizes.lg,
                  vertical: ThemeSizes.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(ThemeSizes.borderRadiusLg),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
