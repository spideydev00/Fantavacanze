import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

class GradientOptionButton extends StatelessWidget {
  final bool isSelected;
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final String? description;
  final Color primaryColor;
  final Color secondaryColor;
  final double iconSize;
  final double labelFontSize;
  final double descriptionFontSize;

  const GradientOptionButton({
    super.key,
    required this.isSelected,
    required this.label,
    required this.icon,
    required this.onTap,
    required this.primaryColor,
    this.secondaryColor = Colors.transparent,
    this.description,
    this.iconSize = 32,
    this.labelFontSize = 16,
    this.descriptionFontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          vertical: ThemeSizes.lg,
          horizontal: ThemeSizes.md,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [
                    primaryColor,
                    primaryColor.withValues(alpha: 0.9),
                    secondaryColor.withValues(alpha: 0.9),
                  ]
                : [
                    context.secondaryBgColor,
                    context.secondaryBgColor,
                  ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(ThemeSizes.md),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: isSelected ? Colors.white : primaryColor,
              ),
            ),
            const SizedBox(height: ThemeSizes.md),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: labelFontSize,
                color: isSelected ? Colors.white : context.textPrimaryColor,
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: ThemeSizes.xs),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: descriptionFontSize,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.8)
                      : context.textSecondaryColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
