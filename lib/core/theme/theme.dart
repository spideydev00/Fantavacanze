// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/cubits/app_theme/app_theme_cubit.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static get fontFamily => GoogleFonts.numans;

  //border re-usable function
  static border(
      [Color color = Colors.grey, double width = 3, double radius = 10]) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: color, width: width),
      borderRadius: BorderRadius.circular(radius),
    );
  }

  //getTheme
  static ThemeData getTheme(BuildContext context) {
    final cubit = context.read<AppThemeCubit>();
    final isDark = cubit.isDarkMode(context);

    final baseTheme = isDark ? ThemeData.dark() : ThemeData.light();

    return baseTheme.copyWith(
      /* ---------------------------------------------------------------- */
      // GLOBAL COLOR SCHEME
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: context.primaryColor,
        onPrimary: ColorPalette.white,
        secondary: context.secondaryColor,
        onSecondary: ColorPalette.white,
        error: ColorPalette.error,
        onError: ColorPalette.white,
        surface: context.bgColor,
        onSurface: context.textPrimaryColor,
      ),

      // Additional theming to ensure consistent colors across components
      indicatorColor: context.primaryColor,
      primaryColor: context.primaryColor,
      canvasColor: context.secondaryBgColor, // This affects Stepper background
      /* ---------------------------------------------------------------- */
      // SWITCH THEME
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return context.primaryColor;
          }
          return isDark ? ColorPalette.grey : ColorPalette.white;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return context.primaryColor.withValues(alpha: 0.5);
          }
          return isDark ? ColorPalette.darkerGrey : ColorPalette.grey;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.transparent;
          }
          return isDark ? ColorPalette.darkGrey : ColorPalette.grey;
        }),
      ),
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
        fillColor: context.secondaryBgColor,
        border: border(),
        enabledBorder: border(Colors.transparent, 0),
        focusedBorder: border(ColorPalette.focusedBorder),
        errorBorder: border(ColorPalette.error),
      ),

      /* ---------------------------------------------------------------- */
      //ELEVATED BUTTON
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: context.primaryColor,
          foregroundColor: ColorPalette.textPrimary(ThemeMode.dark),
          //button padding
          padding: const EdgeInsets.all(ThemeSizes.md),
          //button text
          textStyle: fontFamily(
            fontSize: ThemeSizes.fontSizeMd,
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
          elevation: 2,
        ),
      ),

      /* ---------------------------------------------------------------- */
      //OUTLINED BUTTON
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: context.primaryColor,
          side: BorderSide(
            color: context.primaryColor,
            width: 1.5,
          ),
          padding: const EdgeInsets.all(ThemeSizes.md),
          textStyle: fontFamily(
            fontSize: ThemeSizes.fontSizeMd,
            fontWeight: FontWeight.w600,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(ThemeSizes.borderRadiusLg),
            ),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: context.primaryColor,
          textStyle: context.textTheme.bodyLarge!.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: context.secondaryBgColor,
      ),
      /* ---------------------------------------------------------------- */
      //FLOATING BUTTON
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: context.primaryColor,
        shape: const CircleBorder(),
        elevation: 2,
      ),
      /* ---------------------------------------------------------------- */
      //SCAFFOLD
      scaffoldBackgroundColor: context.bgColor,
      appBarTheme: AppBarTheme(
        foregroundColor: context.textPrimaryColor,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(
          color: context.textPrimaryColor,
          size: 15,
        ),
      ),
      /* ---------------------------------------------------------------- */
      //TEXT THEME
      textTheme: GoogleFonts.numansTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ),
    );
  }

  //getLightTheme
  static ThemeData getLightTheme(BuildContext context) {
    return getTheme(context);
  }

  //getDarkTheme
  static ThemeData getDarkTheme(BuildContext context) {
    return getTheme(context);
  }
}
