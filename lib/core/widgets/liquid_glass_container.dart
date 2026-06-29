import 'dart:ui';

import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

/// Superficie con gradiente brand che cambia resa in base al tema:
///
/// - **Dark mode**: effetto *liquid glass* — blur del backdrop, fill
///   translucido del gradiente e bordo luminoso. Su sfondo scuro il vetro
///   risalta.
/// - **Light mode**: gradiente **solido** pieno. Su sfondo chiaro il vetro
///   sbiadirebbe, quindi si usa il colore a piena intensità.
///
/// Widget puro: riceve [isDark] dal chiamante (niente lettura di cubit qui),
/// così resta riusabile e testabile.
class LiquidGlassContainer extends StatelessWidget {
  final Color startColor;
  final Color endColor;
  final bool isDark;
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;
  final BoxConstraints? constraints;

  const LiquidGlassContainer({
    super.key,
    required this.startColor,
    required this.endColor,
    required this.isDark,
    required this.child,
    this.borderRadius = ThemeSizes.borderRadiusMd,
    this.margin,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    if (!isDark) {
      // Light: gradiente solido pieno.
      return Container(
        margin: margin,
        constraints: constraints,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [startColor, endColor],
          ),
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: endColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(borderRadius: radius, child: child),
      );
    }

    // Dark: liquid glass (blur + fill translucido + bordo luminoso).
    return Container(
      margin: margin,
      constraints: constraints,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  startColor.withValues(alpha: 0.38),
                  endColor.withValues(alpha: 0.26),
                ],
              ),
              borderRadius: radius,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: endColor.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
