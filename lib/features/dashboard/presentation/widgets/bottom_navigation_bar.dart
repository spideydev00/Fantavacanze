import 'package:fantavacanze_official/core/constants/navigation_items.dart';
import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_theme/app_theme_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/core/cubits/app_navigation/app_navigation_cubit.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/widgets/navigation_assets/bottom_navigation_asset.dart';

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
                    return _buildNavbarRow(
                      4,
                      (index) {
                        return BottomNavigationAsset(
                          svgIcon:
                              context.read<AppThemeCubit>().isDarkMode(context)
                                  ? participantNavbarItems[index].darkSvgIcon
                                  : participantNavbarItems[index].lightSvgIcon,
                          title: participantNavbarItems[index].title!,
                          isActive: selectedIndex == index,
                          onTap: () {
                            context.read<AppNavigationCubit>().setIndex(index);
                          },
                        );
                      },
                    );
                  }
                  return _buildNavbarRow(
                    3,
                    (index) {
                      return BottomNavigationAsset(
                        svgIcon:
                            context.read<AppThemeCubit>().isDarkMode(context)
                                ? nonParticipantNavbarItems[index].darkSvgIcon
                                : nonParticipantNavbarItems[index].lightSvgIcon,
                        title: nonParticipantNavbarItems[index].title!,
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

Widget _buildNavbarRow(int elements, Widget Function(int) generator) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: List.generate(
      elements,
      generator,
    ),
  );
}
