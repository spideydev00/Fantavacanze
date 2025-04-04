import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

class UserProfileCard extends StatelessWidget {
  final String name;
  final String avatarAsset;
  final VoidCallback? onTap;

  const UserProfileCard({
    super.key,
    required this.name,
    required this.avatarAsset,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.secondaryBgColor,
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: ThemeSizes.md,
          horizontal: ThemeSizes.md,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: ThemeSizes.iconLg / 2,
              backgroundImage: AssetImage(avatarAsset),
            ),
            const SizedBox(width: ThemeSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: ThemeSizes.xs / 2),
                  Text(
                    'Modifica profilo',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.arrow_forward_ios,
                size: ThemeSizes.labelLg,
                color: context.textSecondaryColor,
              ),
              onPressed: onTap,
            ),
          ],
        ),
      ),
    );
  }
}
