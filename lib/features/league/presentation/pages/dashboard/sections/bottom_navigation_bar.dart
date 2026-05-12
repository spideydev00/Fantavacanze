import 'package:fantavacanze_official/core/constants/navigation_items.dart';
import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_navigation/app_navigation_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_theme/app_theme_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/dashboard/widgets/bottom_navbar/bottom_navigation_asset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const int maxSlots = 4;

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppThemeCubit, AppThemeState>(
      builder: (context, state) {
        return Container(
          color: state.themeMode == ThemeMode.dark
              ? Colors.transparent
              : context.secondaryBgColor,
          padding: const EdgeInsets.only(
            left: ThemeSizes.sm,
            right: ThemeSizes.sm,
            bottom: ThemeSizes.xl,
          ),
          child: BlocBuilder<AppNavigationCubit, int>(
            builder: (context, selectedIndex) {
              return BlocBuilder<AppLeagueCubit, AppLeagueState>(
                builder: (context, state) {
                  if (state is AppLeagueExists) {
                    final isAdmin = context.read<LeagueBloc>().isAdmin();
                    final visibleItems = participantNavbarItems
                        .where((item) => !item.isAdminOnly || isAdmin)
                        .take(maxSlots)
                        .toList();
                    final originalIndices = visibleItems
                        .map((item) => participantNavbarItems.indexOf(item))
                        .toList();

                    return _buildFixedWidthNavbarRow(
                      visibleItems.length,
                      (index) {
                        final item = visibleItems[index];
                        final originalIndex = originalIndices[index];

                        return BottomNavigationAsset(
                          svgIcon:
                              context.read<AppThemeCubit>().isDarkMode(context)
                                  ? item.darkSvgIcon
                                  : item.lightSvgIcon,
                          title: item.title,
                          isActive: selectedIndex == originalIndex,
                          onTap: () {
                            context
                                .read<AppNavigationCubit>()
                                .setIndex(originalIndex);
                          },
                        );
                      },
                    );
                  }

                  // For non-participants, use the same fixed-width layout
                  return _buildFixedWidthNavbarRow(
                    2,
                    (index) {
                      return BottomNavigationAsset(
                        svgIcon:
                            context.read<AppThemeCubit>().isDarkMode(context)
                                ? nonParticipantNavbarItems[index].darkSvgIcon
                                : nonParticipantNavbarItems[index].lightSvgIcon,
                        title: nonParticipantNavbarItems[index].title,
                        isActive: selectedIndex == index,
                        onTap: () {
                          context.read<AppNavigationCubit>().setIndex(index);
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

// New fixed-width layout function to ensure equal spacing
Widget _buildFixedWidthNavbarRow(
  int elements,
  Widget Function(int) generator,
) {
  final itemWidth = elements >= maxSlots ? 75.0 : 85.0;

  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: List.generate(elements, (index) {
      // Wrap each navigation item in a fixed-width container
      return Container(
        width: itemWidth,
        margin: const EdgeInsets.symmetric(horizontal: ThemeSizes.sm),
        child: generator(index),
      );
    }),
  );
}
