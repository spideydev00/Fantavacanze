import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/navigation/navigation_asset.dart';
import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:flutter_svg/svg.dart';

class BottomNavigationAsset extends NavigationAsset {
  const BottomNavigationAsset({
    super.key,
    required super.title,
    required super.svgIcon,
    super.height,
    super.width,
    super.isActive = false,
    super.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAnimatedIndicator(context),
          const SizedBox(height: ThemeSizes.sm),
          super.build(context),
          const SizedBox(height: ThemeSizes.sm),
          Text(
            title,
            style: context.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedIndicator(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 600),
      opacity: isActive ? 1 : 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: isActive ? 5 : 2,
        width: width * 0.6,
        decoration: BoxDecoration(
          color: context.primaryColor,
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusSm),
          boxShadow: [
            BoxShadow(
              color: context.primaryColor.withValues(alpha: 0.6),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget buildIcon() {
    return Column(
      children: [
        SvgPicture.asset(
          svgIcon,
          width: width,
          height: height,
        ),
      ],
    );
  }
}
