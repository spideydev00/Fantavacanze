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
          width: double.infinity,
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

                    return _buildResponsiveNavbarRow(
                      visibleItems.length,
                      (index, iconSize) {
                        final item = visibleItems[index];
                        final originalIndex = originalIndices[index];

                        return BottomNavigationAsset(
                          svgIcon:
                              context.read<AppThemeCubit>().isDarkMode(context)
                                  ? item.darkSvgIcon
                                  : item.lightSvgIcon,
                          title: item.title,
                          height: iconSize,
                          width: iconSize,
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

                  // For non-participants, use the same responsive layout
                  return _buildResponsiveNavbarRow(
                    2,
                    (index, iconSize) {
                      return BottomNavigationAsset(
                        svgIcon:
                            context.read<AppThemeCubit>().isDarkMode(context)
                                ? nonParticipantNavbarItems[index].darkSvgIcon
                                : nonParticipantNavbarItems[index].lightSvgIcon,
                        title: nonParticipantNavbarItems[index].title,
                        height: iconSize,
                        width: iconSize,
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

Widget _buildResponsiveNavbarRow(
  int elements,
  Widget Function(int index, double iconSize) generator,
) {
  if (elements == 0) return const SizedBox.shrink();

  return LayoutBuilder(
    builder: (context, constraints) {
      final itemWidth = constraints.maxWidth / elements;
      final iconSize = (itemWidth * 0.3)
          .clamp(ThemeSizes.iconSm, ThemeSizes.iconXl)
          .toDouble();
      final horizontalPadding =
          (itemWidth * 0.08).clamp(ThemeSizes.xs, ThemeSizes.sm).toDouble();

      return Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(elements, (index) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: SizedBox(
                width: double.infinity,
                child: generator(index, iconSize),
              ),
            ),
          );
        }),
      );
    },
  );
}
