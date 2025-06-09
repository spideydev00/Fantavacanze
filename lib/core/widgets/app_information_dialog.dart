import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';

class AppInformationDialog extends StatelessWidget {
  final String title;
  final IconData titleIcon;
  final Color? titleIconColor;
  final List<InformationSection> sections;
  final VoidCallback? onClose;
  final String closeButtonText;
  final Widget? footer;

  const AppInformationDialog({
    super.key,
    required this.title,
    this.titleIcon = Icons.info_outline_rounded,
    this.titleIconColor,
    required this.sections,
    this.onClose,
    this.closeButtonText = 'Chiudi',
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: context.secondaryBgColor,
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(ThemeSizes.md),
              decoration: BoxDecoration(
                color: context.secondaryBgColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(ThemeSizes.borderRadiusLg),
                  topRight: Radius.circular(ThemeSizes.borderRadiusLg),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    titleIcon,
                    color: titleIconColor ?? context.primaryColor,
                    size: 28,
                  ),
                  const SizedBox(width: ThemeSizes.md),
                  Expanded(
                    child: Text(
                      title,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ThemeSizes.md,
                    vertical: ThemeSizes.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: sections
                        .map((section) => _buildSection(context, section))
                        .toList(),
                  ),
                ),
              ),
            ),

            // Footer
            if (footer != null) footer!,

            // Close Button
            Padding(
              padding: const EdgeInsets.all(ThemeSizes.md),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (onClose != null) {
                      onClose!();
                    }
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: ThemeSizes.sm),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(ThemeSizes.borderRadiusMd),
                    ),
                  ),
                  child: Text(
                    closeButtonText,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, InformationSection section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ThemeSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.title != null) ...[
            Padding(
              padding: const EdgeInsets.only(
                top: ThemeSizes.sm,
                bottom: ThemeSizes.xs,
              ),
              child: Row(
                children: [
                  if (section.icon != null) ...[
                    Icon(
                      section.icon,
                      color: section.iconColor ?? context.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: ThemeSizes.xs),
                  ],
                  Text(
                    section.title!,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: section.titleColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (section.content != null)
            Text(
              section.content!,
              style: context.textTheme.bodyMedium,
            ),
          if (section.widgets != null && section.widgets!.isNotEmpty) ...[
            const SizedBox(height: ThemeSizes.xs),
            ...section.widgets!,
          ],
        ],
      ),
    );
  }
}

class InformationSection {
  final String? title;
  final IconData? icon;
  final Color? iconColor;
  final Color? titleColor;
  final String? content;
  final List<Widget>? widgets;

  InformationSection({
    this.title,
    this.icon,
    this.iconColor,
    this.titleColor,
    this.content,
    this.widgets,
  });
}

class FeatureItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const FeatureItem({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: ThemeSizes.sm),
      decoration: BoxDecoration(
        color: context.secondaryBgColor,
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(ThemeSizes.xs),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusSm),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: ThemeSizes.xs / 2),
          child: Text(
            description,
            style: context.textTheme.bodySmall,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ThemeSizes.sm,
          vertical: ThemeSizes.xs,
        ),
      ),
    );
  }
}
