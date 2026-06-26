import 'package:cached_network_image/cached_network_image.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:flutter/material.dart';

class PartnerDestinationCard extends StatelessWidget {
  final String name;
  final String? description;
  final String? imageUrl;
  final Color accentColor;
  final bool? selected;
  final VoidCallback onTap;
  final Widget? trailing;

  const PartnerDestinationCard({
    super.key,
    required this.name,
    required this.accentColor,
    required this.onTap,
    this.description,
    this.imageUrl,
    this.selected,
    this.trailing,
  });

  static const double _imageHeight = 140;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ThemeSizes.md),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: context.secondaryBgColor,
              borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImage(),
                Padding(
                  padding: const EdgeInsets.all(ThemeSizes.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: context.textTheme.titleLarge?.copyWith(
                                color: context.textPrimaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (trailing != null) ...[
                            const SizedBox(width: ThemeSizes.sm),
                            trailing!,
                          ] else if (selected != null) ...[
                            const SizedBox(width: ThemeSizes.sm),
                            Icon(
                              selected!
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color: selected!
                                  ? accentColor
                                  : context.textSecondaryColor,
                            ),
                          ],
                        ],
                      ),
                      if (description != null) ...[
                        const SizedBox(height: ThemeSizes.xs),
                        Text(
                          description!,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.textSecondaryColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final placeholder = Container(
      height: _imageHeight,
      width: double.infinity,
      color: accentColor.withValues(alpha: 0.12),
      child: Icon(
        Icons.business_center_outlined,
        color: accentColor,
        size: ThemeSizes.iconLg,
      ),
    );

    final url = imageUrl;
    if (url == null || url.isEmpty) return placeholder;

    return CachedNetworkImage(
      imageUrl: url,
      height: _imageHeight,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, _) => Container(
        height: _imageHeight,
        color: accentColor.withValues(alpha: 0.12),
        child: Center(child: Loader(color: accentColor)),
      ),
      errorWidget: (context, _, __) => placeholder,
    );
  }
}
