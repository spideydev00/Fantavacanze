import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

class AdminSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? actionButton;

  const AdminSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: ThemeSizes.lg),
      decoration: BoxDecoration(
        color: context.secondaryBgColor,
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with section number, title and icon
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeSizes.md,
              vertical: ThemeSizes.md,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.textPrimaryColor.withValues(alpha: 0.05),
                    borderRadius:
                        BorderRadius.circular(ThemeSizes.borderRadiusMd),
                  ),
                  child: Icon(
                    icon,
                    color: context.textSecondaryColor.withValues(alpha: 0.8),
                    size: 22,
                  ),
                ),
                const SizedBox(width: ThemeSizes.md),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: context.textPrimaryColor,
                    ),
                  ),
                ),
                if (actionButton != null) actionButton!,
              ],
            ),
          ),
          // Content
          child,
        ],
      ),
    );
  }
}
