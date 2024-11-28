import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class PromoText extends StatelessWidget {
  final String text;
  const PromoText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: context.textTheme.displayMedium!.copyWith(
        color: ColorPalette.white,
        shadows: [
          const Shadow(
            color: ColorPalette.darkerGrey,
            blurRadius: 55.0,
          ),
        ],
      ),
    );
  }
}
