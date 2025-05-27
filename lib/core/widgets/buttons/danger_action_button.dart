import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

class DangerActionButton extends StatelessWidget {
  /// Title of the danger action
  final String title;

  /// Description of what happens when the action is performed
  final String description;

  /// Icon to display
  final IconData icon;

  /// Callback when the button is tapped
  final VoidCallback onTap;

  /// Whether to use gradient background (default: true)
  final bool useGradient;

  /// Custom color to use instead of default error color
  final Color? color;

  const DangerActionButton({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    this.useGradient = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final dangerColor = color ?? ColorPalette.error;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: ThemeSizes.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        gradient: useGradient
            ? LinearGradient(
                colors: [
                  dangerColor.withValues(alpha: 0.05),
                  dangerColor.withValues(alpha: 0.1),
                ],
              )
            : null,
        color: useGradient ? null : context.secondaryBgColor,
        border: Border.all(color: dangerColor.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
          splashColor: dangerColor.withValues(alpha: 0.1),
          highlightColor: dangerColor.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(ThemeSizes.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: dangerColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: dangerColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: ThemeSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.textTheme.bodyLarge!.copyWith(
                          color: dangerColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        description,
                        maxLines: 2,
                        style: context.textTheme.bodySmall!.copyWith(
                          color: dangerColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
