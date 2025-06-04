import 'package:fantavacanze_official/core/constants/game_mode.dart';
import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';

class RuleModeSelector extends StatelessWidget {
  final GameMode selectedMode;
  final bool isLoading;
  final Function(GameMode) onModeChanged;

  const RuleModeSelector({
    super.key,
    required this.selectedMode,
    required this.isLoading,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.secondaryBgColor,
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(ThemeSizes.md),
        child: Column(
          children: [
            _getRuleModeTile(
              GameMode.broCode,
              'Bro-code',
              'Regole tarate per gruppi di maschi',
              ColorPalette.success,
              "assets/images/icons/homepage_icons/bro-code-icon.png",
            ),
            const Divider(thickness: 0.2),
            _getRuleModeTile(
              GameMode.baddies,
              'Baddies',
              'Regole tarate per gruppi di ragazze',
              ColorPalette.secondary(ThemeMode.light),
              "assets/images/icons/homepage_icons/baddies-icon.png",
            ),
            const Divider(thickness: 0.2),
            _getRuleModeTile(
              GameMode.allTogether,
              'All Together',
              'Mix di regole per gruppi misti',
              ColorPalette.info,
              "assets/images/icons/homepage_icons/mixed-genders-icon.png",
            ),
            const Divider(thickness: 0.2),
            _getRuleModeTile(
              GameMode.custom,
              'Completamente Personalizzata',
              'Crea tutte le regole da zero',
              ColorPalette.accent(ThemeMode.light),
              "assets/images/icons/homepage_icons/custom-rules-icon.png",
            ),
          ],
        ),
      ),
    );
  }

  /// Creates a ListTile for a rule mode option with gradient background and background icon
  Widget _getRuleModeTile(
    GameMode mode,
    String title,
    String subtitle,
    Color accentColor,
    String imagePath,
  ) {
    return Builder(
      builder: (context) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
            gradient: LinearGradient(
              colors: [
                context.secondaryBgColor,
                context.secondaryBgColor,
                accentColor.withValues(alpha: 0.25),
              ],
              stops: const [0.0, 0.45, 1.0],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Stack(
            children: [
              // Background icon with opacity
              Positioned(
                right: 10,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Image.asset(
                    imagePath,
                    width: 80,
                    height: 75,
                    color: accentColor.withValues(alpha: 0.15),
                  ),
                ),
              ),
              // ListTile content
              ListTile(
                title: Text(
                  title,
                  style: TextStyle(
                    fontWeight: mode == selectedMode
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                subtitle: Text(subtitle),
                leading: Radio<GameMode>(
                  activeColor: accentColor,
                  fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return accentColor;
                    }
                    return ColorPalette.darkGrey;
                  }),
                  value: mode,
                  groupValue: selectedMode,
                  onChanged: isLoading
                      ? null
                      : (value) {
                          if (value != null) onModeChanged(value);
                        },
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(ThemeSizes.borderRadiusMd),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: ThemeSizes.sm,
                  vertical: ThemeSizes.xs,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
