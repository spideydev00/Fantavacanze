import 'package:fantavacanze_official/core/navigation/navigation_asset.dart';
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
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeSizes.md,
        vertical: ThemeSizes.sm,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isActive
              ? ColorPalette.darkerGrey.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: ThemeSizes.sm,
          horizontal: ThemeSizes.md,
        ),
        child: Row(
          children: [
            const SizedBox(width: ThemeSizes.sm),
            super.build(context),
            const SizedBox(width: ThemeSizes.lg),
            Text(title),
          ],
        ),
      ),
    );
  }

  @override
  Widget buildIcon() {
    return SvgPicture.asset(
      svgIcon,
      width: width,
      height: height,
    );
  }
}
