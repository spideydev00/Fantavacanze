import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:flutter/material.dart';

class ModernIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double iconSize;
  final Color? iconColor;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;

  const ModernIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconSize = 30.0,
    this.iconColor,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(20.0),
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveIconColor = iconColor ?? context.textPrimaryColor;
    final Color effectiveBackgroundColor =
        backgroundColor ?? effectiveIconColor.withAlpha(20);

    return Container(
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
    );
  }
}
