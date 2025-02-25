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
  static border(
      [Color color = ColorPalette.borderColor,
      double width = 3,
      double radius = 10]) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: color, width: width),
      borderRadius: BorderRadius.circular(radius),
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
          border: border(),
          enabledBorder: border(),
          focusedBorder: border(ColorPalette.focusedBorder),
          errorBorder: border(ColorPalette.error),
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
            elevation: 0,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: ColorPalette.primary,
            textStyle: context.textTheme.bodyLarge!.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        dialogBackgroundColor: ColorPalette.dialogBg,
        /* ---------------------------------------------------------------- */
        //SCAFFOLD
        scaffoldBackgroundColor: ColorPalette.darkBg,
        appBarTheme: const AppBarTheme(
          foregroundColor: ColorPalette.white,
          backgroundColor: Colors.transparent,
        ),
        /* ---------------------------------------------------------------- */
        //TEXT THEME
        textTheme: GoogleFonts.numansTextTheme(ThemeData.dark().textTheme),
      );
}
