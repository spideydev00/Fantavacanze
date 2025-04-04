import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  final String text;
  final double thickness;
  final double lineHeight;
  final EdgeInsets padding;

  const CustomDivider({
    super.key,
    required this.text,
    this.thickness = 0.25,
    this.lineHeight = 1,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ThemeSizes.sm),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: lineHeight,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: context.textSecondaryColor.withValues(alpha: 0.6),
                    width: thickness,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: padding,
            child: Text(
              text,
              style: context.textTheme.labelMedium!.copyWith(
                color: context.textSecondaryColor.withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: lineHeight,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: context.textSecondaryColor.withValues(alpha: 0.6),
                    width: thickness,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
