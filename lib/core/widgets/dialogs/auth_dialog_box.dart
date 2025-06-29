import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthDialogBox extends StatelessWidget {
  final DialogType type;
  final String title;
  final String description;
  final String buttonText;
  final Color? bgColor;
  final bool isMultiButton;
  final VoidCallback? onPrimaryButtonPressed; // Add this callback

  const AuthDialogBox({
    super.key,
    this.type = DialogType.error,
    required this.title,
    required this.description,
    this.isMultiButton = false,
    this.buttonText = "Chiudi",
    this.bgColor,
    this.onPrimaryButtonPressed, // Add to constructor
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: bgColor ?? context.bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        ),
        // Aggiungo un po' di padding per dare aria al contenuto
        padding: const EdgeInsets.all(ThemeSizes.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icona di alert
            SvgPicture.asset(
              type == DialogType.error
                  ? 'assets/images/icons/other/error-icon.svg'
                  : type == DialogType.success
                      ? 'assets/images/icons/other/success-icon.svg'
                      : 'assets/images/icons/other/mail-notification.svg',
              width: 72,
            ),
            const SizedBox(height: 24),

            // Titolo dell'alert
            Text(
              title,
              style: context.textTheme.titleLarge!.copyWith(
                color: type == DialogType.error
                    ? ColorPalette.error
                    : type == DialogType.success
                        ? ColorPalette.success
                        : ColorPalette.info,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),

            // Testo descrittivo
            Text(
              description,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            !isMultiButton
                ? OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 32,
                      ),
                      textStyle: GoogleFonts.numans(
                        fontSize: ThemeSizes.fontSizeMd,
                        fontWeight: FontWeight.w600,
                      ),
                      foregroundColor: type == DialogType.error
                          ? ColorPalette.error
                          : type == DialogType.success
                              ? ColorPalette.success
                              : ColorPalette.info,
                      side: BorderSide(
                        color: type == DialogType.error
                            ? ColorPalette.error
                            : type == DialogType.success
                                ? ColorPalette.success
                                : ColorPalette.info,
                      ),
                    ),
                    onPressed: () {
                      // Use the callback if provided, otherwise just pop
                      if (onPrimaryButtonPressed != null) {
                        onPrimaryButtonPressed!();
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(buttonText),
                  )
                //if multi button is enabled two buttons are displayed
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 32,
                          ),
                          textStyle: GoogleFonts.numans(
                            fontSize: ThemeSizes.fontSizeMd,
                            fontWeight: FontWeight.w600,
                          ),
                          foregroundColor: type == DialogType.error
                              ? ColorPalette.error
                              : type == DialogType.success
                                  ? ColorPalette.success
                                  : ColorPalette.info,
                          side: BorderSide(
                            color: type == DialogType.error
                                ? ColorPalette.error
                                : type == DialogType.success
                                    ? ColorPalette.success
                                    : ColorPalette.info,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('No'),
                      ),
                      SizedBox(width: 4),
                      //custom elevated button
                      DialogElevatedButton(onPressed: () {
                        Navigator.of(context).pop();
                      })
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

class DialogElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  const DialogElevatedButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: context.elevatedButtonThemeData.style!.copyWith(
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 32,
          ),
        ),
        fixedSize: WidgetStatePropertyAll(
          Size.fromWidth(
            Constants.getWidth(context) * 0.32,
          ),
        ),
        textStyle: WidgetStatePropertyAll(
          GoogleFonts.numans(
            fontSize: ThemeSizes.fontSizeMd,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: WidgetStatePropertyAll(
          ColorPalette.success,
        ),
        foregroundColor: WidgetStatePropertyAll(
          ColorPalette.black,
        ),
        shape: WidgetStatePropertyAll(
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(ThemeSizes.borderRadiusXlg),
            ),
          ),
        ),
      ),
      child: Text("Si"),
    );
  }
}

enum DialogType {
  success,
  error,
  email,
}
