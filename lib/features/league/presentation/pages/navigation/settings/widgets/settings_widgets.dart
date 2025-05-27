import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

// Export all settings widgets
export 'settings_tile.dart';
export 'user_profile_card.dart';
export 'logout_dialog.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isActive;
  final bool useCard;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.isActive = false,
    this.useCard = true,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.secondaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(
            ThemeSizes.borderRadiusSm,
          ),
        ),
        child: Icon(
          icon,
          color: context.primaryColor,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: context.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.textPrimaryColor,
              ),
            )
          : null,
      trailing: trailing ??
          (onTap != null
              ? Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: context.textPrimaryColor.withValues(alpha: 0.5),
                )
              : null),
      onTap: onTap,
    );

    if (useCard) {
      return Card(
        elevation: 1,
        color: context.secondaryBgColor,
        margin: const EdgeInsets.only(bottom: ThemeSizes.sm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
        ),
        child: content,
      );
    }

    return content;
  }
}
