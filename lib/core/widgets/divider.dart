import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  final String text;
  final double thickness;
  final double lineHeight;
  final EdgeInsets padding;
  final int? sectionNumber;
  final Color? color;

  const CustomDivider({
    super.key,
    required this.text,
    this.thickness = 0.25,
    this.lineHeight = 1,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
    this.sectionNumber,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final dividerColor =
        color ?? context.textSecondaryColor.withValues(alpha: 0.6);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ThemeSizes.md),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: lineHeight,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: dividerColor,
                    width: thickness,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: padding,
            child: Row(
              children: [
                if (sectionNumber != null)
                  Container(
                    width: 26,
                    height: 26,
                    margin: const EdgeInsets.only(right: ThemeSizes.sm),
                    decoration: BoxDecoration(
                      color: context.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$sectionNumber',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                Text(
                  text,
                  style: context.textTheme.labelMedium!.copyWith(
                    color: dividerColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              height: lineHeight,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: dividerColor,
                    width: thickness,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A text divider with gradient background for section headers
class GradientSectionDivider extends StatelessWidget {
  final String text;
  final int? sectionNumber;

  const GradientSectionDivider({
    super.key,
    required this.text,
    this.sectionNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: ThemeSizes.md),
      child: Row(
        children: [
          // Left line segment with gradient
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      ColorPalette.info.withValues(alpha: 0.6),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Center container with text
          Container(
            margin: const EdgeInsets.symmetric(horizontal: ThemeSizes.sm),
            padding: const EdgeInsets.symmetric(
                horizontal: ThemeSizes.md, vertical: ThemeSizes.xs),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorPalette.info.withValues(alpha: 0.8),
                  ColorPalette.info,
                ],
              ),
              borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (sectionNumber != null) ...[
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$sectionNumber',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: ThemeSizes.xs),
                ],
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Right line segment with gradient
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ColorPalette.info.withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
