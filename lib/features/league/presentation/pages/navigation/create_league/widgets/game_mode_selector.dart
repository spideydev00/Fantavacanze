import 'package:fantavacanze_official/core/constants/game_mode.dart';
import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';

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
      child: Theme(
        data: Theme.of(context).copyWith(
          radioTheme: RadioThemeData(
            fillColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) {
                return context.primaryColor;
              }
              return Colors.grey;
            }),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(ThemeSizes.md),
          child: Column(
            children: [
              ListTile(
                title: const Text('Hot Mode'),
                subtitle:
                    const Text('Regole predefinite per vacanze da sballo'),
                leading: Radio<GameMode>(
                  value: GameMode.hot,
                  groupValue: selectedMode,
                  onChanged: isLoading
                      ? null
                      : (value) {
                          if (value != null) onModeChanged(value);
                        },
                ),
              ),
              const Divider(
                thickness: 0.2,
              ),
              ListTile(
                title: const Text('Soft Mode'),
                subtitle:
                    const Text('Regole predefinite per vacanze dove chillare'),
                leading: Radio<GameMode>(
                  value: GameMode.soft,
                  groupValue: selectedMode,
                  onChanged: isLoading
                      ? null
                      : (value) {
                          if (value != null) onModeChanged(value);
                        },
                ),
              ),
              const Divider(
                thickness: 0.2,
              ),
              ListTile(
                title: const Text('Completamente Personalizzata'),
                subtitle: const Text('Crea tutte le regole da zero'),
                leading: Radio<GameMode>(
                  value: GameMode.custom,
                  groupValue: selectedMode,
                  onChanged: isLoading
                      ? null
                      : (value) {
                          if (value != null) onModeChanged(value);
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
