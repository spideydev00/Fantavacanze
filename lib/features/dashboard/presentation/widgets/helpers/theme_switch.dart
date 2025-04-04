import 'package:fantavacanze_official/core/cubits/app_theme/app_theme_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeSwitch extends StatelessWidget {
  const ThemeSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppThemeCubit, AppThemeState>(
      builder: (context, state) {
        final isDark = context.read<AppThemeCubit>().isDarkMode(context);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Tema Scuro",
                style: context.textTheme.bodyMedium,
              ),
              SizedBox(width: 10),
              Switch(
                value: isDark,
                onChanged: (_) {
                  context.read<AppThemeCubit>().toggleTheme();
                },
                activeColor: context.primaryColor,
                activeTrackColor: context.secondaryColor,
              ),
            ],
          ),
        );
      },
    );
  }
}
