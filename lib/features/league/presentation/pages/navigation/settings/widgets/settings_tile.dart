import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
          vertical: ThemeSizes.xs, horizontal: ThemeSizes.md),
      leading: Container(
        padding: const EdgeInsets.all(ThemeSizes.sm),
        decoration: BoxDecoration(
          color: context.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusSm),
        ),
        child: Icon(icon, color: context.primaryColor),
      ),
      title: Text(
        title,
        style: context.textTheme.titleMedium,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: context.textTheme.bodyMedium,
            )
          : null,
      trailing: trailing ??
          (onTap != null
              ? Icon(
                  Icons.arrow_forward_ios,
                  size: ThemeSizes.labelLg,
                  color: context.textSecondaryColor,
                )
              : null),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusSm),
      ),
      tileColor: context.secondaryBgColor.withValues(alpha: 0.8),
    );
  }
}
