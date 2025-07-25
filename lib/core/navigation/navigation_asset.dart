import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

abstract class NavigationAsset extends StatelessWidget {
  final String svgIcon;
  final String title;
  final bool isActive;
  final bool effectsEnabled;
  final VoidCallback? onTap; //implementato nelle sottoclassi
  final double height, width;

  const NavigationAsset({
    super.key,
    required this.svgIcon,
    required this.title,
    this.height = ThemeSizes.iconSm,
    this.width = ThemeSizes.iconSm,
    this.isActive = false,
    this.effectsEnabled = true,
    this.onTap,
  });

  Widget buildIcon();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: effectsEnabled ? ((isActive) ? 1 : 0.7) : 1,
      child: SizedBox(
        height: height,
        width: width,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isActive && effectsEnabled) _buildGlowEffect(),
            buildIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildGlowEffect() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: height * 0.3,
      width: height * 0.3,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}
