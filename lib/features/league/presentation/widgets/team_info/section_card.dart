import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final VoidCallback? onTitleTap;

  const SectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.onTitleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: ThemeSizes.lg,
        vertical: ThemeSizes.sm,
      ),
      decoration: BoxDecoration(
        color: context.secondaryBgColor,
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: onTitleTap,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(ThemeSizes.borderRadiusLg),
            ),
            child: Padding(
              padding: const EdgeInsets.all(ThemeSizes.md),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: context.primaryColor,
                    size: 22,
                  ),
                  const SizedBox(width: ThemeSizes.sm),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  if (onTitleTap != null) ...[
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: context.textSecondaryColor,
                      size: 16,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Divider
          Divider(
            height: 1,
            thickness: 1,
            color: context.borderColor.withValues(alpha: 0.1),
          ),

          // Content
          child,
        ],
      ),
    );
  }
}
