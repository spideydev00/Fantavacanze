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
      primaryColor: context.primaryColor,
      canvasColor: context.secondaryBgColor, // This affects Stepper background
      /* ---------------------------------------------------------------- */
      tabBarTheme: TabBarThemeData(
        indicatorColor: context.primaryColor,
      ),
      // BOTTOM SHEET THEME
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: context.secondaryBgColor,
        modalBackgroundColor: context.secondaryBgColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: context.textPrimaryColor,
      ),

      // Progress indicator theme for premium elements
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: ColorPalette.premiumUser,
        circularTrackColor: ColorPalette.premiumUser.withValues(alpha: 0.2),
      ),

      // Divider theme for premium elements
      dividerTheme: DividerThemeData(
        color: ColorPalette.premiumUser.withValues(alpha: 0.3),
        thickness: 1,
      ),

      // Custom text theme for bottom sheets with premium styling
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: ColorPalette.premiumUser,
        selectionColor: ColorPalette.premiumUser.withValues(alpha: 0.3),
        selectionHandleColor: ColorPalette.premiumUser,
      ),

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
      dialogTheme: DialogThemeData(
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

  // Add this method below getTheme method
  static TextTheme getPremiumTextTheme(BuildContext context) {
    return GoogleFonts.numansTextTheme(
      context.textTheme.copyWith(
        displayLarge: context.textTheme.displayLarge?.copyWith(color: ColorPalette.premiumUser),
        displayMedium: context.textTheme.displayMedium?.copyWith(color: ColorPalette.premiumUser),
        displaySmall: context.textTheme.displaySmall?.copyWith(color: ColorPalette.premiumUser),
        headlineLarge: context.textTheme.headlineLarge?.copyWith(color: ColorPalette.premiumUser),
        headlineMedium: context.textTheme.headlineMedium?.copyWith(color: ColorPalette.premiumUser),
        headlineSmall: context.textTheme.headlineSmall?.copyWith(color: ColorPalette.premiumUser),
        titleLarge: context.textTheme.titleLarge?.copyWith(color: ColorPalette.premiumUser),
        titleMedium: context.textTheme.titleMedium?.copyWith(color: ColorPalette.premiumUser),
        titleSmall: context.textTheme.titleSmall?.copyWith(color: ColorPalette.premiumUser),
        bodyLarge: context.textTheme.bodyLarge?.copyWith(color: ColorPalette.premiumUser),
        bodyMedium: context.textTheme.bodyMedium?.copyWith(color: ColorPalette.premiumUser),
        bodySmall: context.textTheme.bodySmall?.copyWith(color: ColorPalette.premiumUser),
        labelLarge: context.textTheme.labelLarge?.copyWith(color: ColorPalette.premiumUser),
        labelMedium: context.textTheme.labelMedium?.copyWith(color: ColorPalette.premiumUser),
        labelSmall: context.textTheme.labelSmall?.copyWith(color: ColorPalette.premiumUser),
      ),
    );
  }

  // Extension method for easy access to premium theme elements
  static ThemeData applyPremiumBottomSheetTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      textTheme: getPremiumTextTheme(context),
      iconTheme: IconThemeData(color: ColorPalette.premiumUser),
      buttonTheme: ButtonThemeData(
        buttonColor: ColorPalette.premiumUser,
        textTheme: ButtonTextTheme.primary,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.all(ColorPalette.premiumUser),
        checkColor: WidgetStateProperty.all(Colors.white),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.all(ColorPalette.premiumUser),
      ),
      // Ensure all bottom sheet dialogs get the premium styling
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: context.secondaryBgColor,
        modalBackgroundColor: context.secondaryBgColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: context.textPrimaryColor,
      ),
    );
  }
}
