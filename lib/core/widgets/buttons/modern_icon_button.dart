import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

class ModernIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double iconSize;
  final Color? iconColor;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final String? text;

  const ModernIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.iconSize = 30.0,
    this.iconColor,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(20.0),
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveIconColor = iconColor ?? context.textPrimaryColor;
    final Color effectiveBackgroundColor =
        backgroundColor ?? effectiveIconColor.withAlpha(20);

    if (text != null && text!.isNotEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: effectiveBackgroundColor,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(50),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ThemeSizes.lg,
                vertical: ThemeSizes.lg,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: effectiveIconColor,
                    size: iconSize,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    text!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: effectiveIconColor,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final buttonWidget = GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(50),
            child: Ink(
              decoration: BoxDecoration(
                color: effectiveBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: padding,
                child: Icon(
                  icon,
                  color: effectiveIconColor,
                  size: iconSize,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return buttonWidget;
  }
}
