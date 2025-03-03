import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  final String text;
  final double thickness;
  final double lineHeight;
  final Color color;
  final EdgeInsets padding;

  const CustomDivider({
    super.key,
    required this.text,
    this.thickness = 0.25,
    this.lineHeight = 1,
    this.color = ColorPalette.darkGrey,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: lineHeight,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: color,
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
              style: context.textTheme.labelLarge!.copyWith(
                color: ColorPalette.darkGrey,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: lineHeight,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: color,
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
