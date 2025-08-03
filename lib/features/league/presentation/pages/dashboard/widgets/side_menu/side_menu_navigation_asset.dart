import 'package:fantavacanze_official/core/entities/navigation/navigation_asset.dart';
import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter_svg/svg.dart';

class SideMenuNavigationAsset extends NavigationAsset {
  const SideMenuNavigationAsset({
    super.key,
    required super.svgIcon,
    required super.title,
    super.height,
    super.width,
    super.isActive = false,
    super.effectsEnabled = false,
    super.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeSizes.xs,
          vertical: ThemeSizes.xs,
        ),
        child: _buildAnimatedContainer(
          child: Row(
            children: [
              const SizedBox(width: ThemeSizes.sm),
              super.build(context),
              const SizedBox(width: ThemeSizes.lg),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedContainer({required Widget child}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isActive
            ? ColorPalette.darkerGrey.withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: ThemeSizes.sm,
        horizontal: ThemeSizes.md,
      ),
      child: child,
    );
  }

  @override
  Widget buildIcon() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: SvgPicture.asset(
        svgIcon,
        width: width,
        height: height,
      ),
    );
  }
}
