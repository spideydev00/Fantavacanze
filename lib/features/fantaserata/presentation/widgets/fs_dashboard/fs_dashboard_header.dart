import 'package:fantavacanze_official/core/cubits/app_theme/app_theme_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_league.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/widgets/fs_dashboard/fs_league_info_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FsDashboardHeader extends StatelessWidget {
  final FsLeague league;

  const FsDashboardHeader({
    super.key,
    required this.league,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.read<AppThemeCubit>().state.themeMode;
    final isDarkMode = theme == ThemeMode.dark;

    final secondaryBgColor = isDarkMode
        ? ColorPalette.secondaryBgColor(ThemeMode.light)
        : ColorPalette.secondaryBgColor(ThemeMode.dark);

    final primaryTextColor = isDarkMode
        ? ColorPalette.textPrimary(ThemeMode.light)
        : ColorPalette.textPrimary(ThemeMode.dark);

    return Container(
      margin: const EdgeInsets.all(ThemeSizes.lg),
      padding: const EdgeInsets.all(ThemeSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            secondaryBgColor.withValues(alpha: 0.9),
            secondaryBgColor.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        boxShadow: [
          BoxShadow(
            color: context.textPrimaryColor.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.flash_on_rounded,
            color: primaryTextColor,
            size: 32,
          ),
          const SizedBox(width: ThemeSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  league.name,
                  style: context.textTheme.titleLarge?.copyWith(
                    color: primaryTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (league.description != null &&
                    league.description!.isNotEmpty)
                  Text(
                    league.description!,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: primaryTextColor.withValues(alpha: 0.9),
                    ),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => FsLeagueInfoDialog(league: league),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(ThemeSizes.sm),
              decoration: BoxDecoration(
                color: primaryTextColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.info_outline_rounded,
                color: primaryTextColor,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
