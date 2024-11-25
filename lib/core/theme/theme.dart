// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static get fontFamily => GoogleFonts.numans;

  //border re-usable function
  static _border([Color color = ColorPalette.borderColor]) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: color, width: 3),
      borderRadius: BorderRadius.circular(10),
    );
  }

  //getDarkTheme
  static getDarkTheme(BuildContext context) => ThemeData.dark().copyWith(
        /* ---------------------------------------------------------------- */
        //TEXT FORM
        //form fields theming
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: context.textTheme.bodyLarge!.copyWith(
            color: ColorPalette.darkerGrey,
            fontWeight: FontWeight.w400,
          ),
          contentPadding: const EdgeInsets.all(24),
          filled: true,
          fillColor: ColorPalette.white.withOpacity(0.85),
          border: _border(),
          enabledBorder: _border(),
          focusedBorder: _border(ColorPalette.focusedBorder),
          errorBorder: _border(ColorPalette.error),
        ),

        /* ---------------------------------------------------------------- */
        //ELEVATED BUTTON
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorPalette.buttonPrimary,
            foregroundColor: ColorPalette.textPrimary,
            //button padding
            padding: const EdgeInsets.all(ThemeSizes.md),
            //button text
            textStyle: fontFamily(
              fontSize: ThemeSizes.fontSizeLg,
              fontWeight: FontWeight.w600,
            ),
            //button size
            fixedSize: Size.fromWidth(
              Constants.getWidth(context) * 0.75,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(ThemeSizes.borderRadiusLg),
              ),
            ),
            elevation: 2.0,
          ),
        ),
        /* ---------------------------------------------------------------- */
        //TEXT THEME
        textTheme: GoogleFonts.numansTextTheme(ThemeData.dark().textTheme),
      );
}
