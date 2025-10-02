import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class FsInfoBanner extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final String? svgIconPath;
  final Color color;

  const FsInfoBanner({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.svgIconPath,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ThemeSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          color.withValues(alpha: 0.08),
          color.withValues(alpha: 0.08),
        ]),
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          icon != null
              ? Icon(
                  icon,
                  size: 40,
                  color: color,
                )
              : svgIconPath != null
                  ? SvgPicture.asset(
                      svgIconPath!,
                      width: ThemeSizes.iconMd,
                    )
                  : SizedBox.shrink(),
          const SizedBox(height: ThemeSizes.md),
          Text(
            title,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.textPrimaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ThemeSizes.sm),
          Text(
            message,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
