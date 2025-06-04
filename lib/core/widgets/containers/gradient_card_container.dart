import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

class GradientCardContainer extends StatelessWidget {
  final Widget child;
  final Color startColor;
  final Color endColor;
  final Color? overlayColor;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final double elevation;
  final BorderRadius? borderRadius;

  const GradientCardContainer({
    super.key,
    required this.child,
    required this.startColor,
    required this.endColor,
    this.overlayColor,
    this.margin = const EdgeInsets.only(bottom: ThemeSizes.md),
    this.onTap,
    this.elevation = 2,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [startColor, endColor],
        ),
        borderRadius:
            borderRadius ?? BorderRadius.circular(ThemeSizes.borderRadiusMd),
        boxShadow: [
          BoxShadow(
            color: endColor.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius:
              borderRadius ?? BorderRadius.circular(ThemeSizes.borderRadiusMd),
          splashColor: startColor.withValues(alpha: 0.1),
          highlightColor: Colors.transparent,
          child: Stack(
            children: [
              if (overlayColor != null)
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
              child,
            ],
          ),
        ),
      ),
    );
  }
}
