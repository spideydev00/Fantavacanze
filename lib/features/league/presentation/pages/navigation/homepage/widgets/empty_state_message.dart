import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

class EmptyStateMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final double iconSize;
  final EdgeInsetsGeometry padding;
  final TextStyle? textStyle;
  final Color? iconColor;

  const EmptyStateMessage({
    super.key,
    required this.icon,
    required this.message,
    this.iconSize = 64,
    this.padding = const EdgeInsets.symmetric(
      vertical: ThemeSizes.xl,
      horizontal: ThemeSizes.xl,
    ),
    this.textStyle,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: iconColor ??
                  context.textSecondaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: ThemeSizes.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textStyle ??
                  TextStyle(
                    fontSize: 16,
                    color: context.textSecondaryColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
