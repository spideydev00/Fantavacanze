import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SocialButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String socialName;
  final bool isGradient;
  final List<Color>? bgGradient;
  final Color? bgColor;
  final Color foregroundColor;
  final double width;
  final bool isIconOnly;

  const SocialButton({
    super.key,
    required this.onPressed,
    required this.socialName,
    required this.isGradient,
    required this.width,
    required this.isIconOnly,
    this.bgGradient,
    this.bgColor,
    this.foregroundColor = ColorPalette.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(ThemeSizes.buttonRadius),
        ),
        color: !isGradient ? bgColor : null,
        gradient: isGradient
            ? LinearGradient(
                colors: bgGradient!,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
      ),
      child: isIconOnly
          //Mostra solo icona
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: ColorPalette.textPrimary,
                elevation: 0,
              ),
              child: SvgPicture.asset(
                'images/${socialName.toLowerCase()}.svg',
                width: Constants.getWidth(context) * 0.12,
              ),
            )
          //Mostra icona + testo
          : ElevatedButton.icon(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: ColorPalette.textPrimary,
                elevation: 0,
              ),
              label: Text(
                'Accedi con $socialName',
                style: context.textTheme.bodyLarge!.copyWith(
                  fontSize: ThemeSizes.fontSizeMd,
                  fontWeight: FontWeight.w600,
                  color: foregroundColor,
                ),
              ),
              icon: SvgPicture.asset(
                'images/${socialName.toLowerCase()}.svg',
                width: Constants.getWidth(context) * 0.1,
                colorFilter: ColorFilter.mode(
                  foregroundColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
    );
  }
}
