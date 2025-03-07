import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/core/cubits/app_navigation/app_navigation_cubit.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/navigation/navigation_item.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/widgets/navigation_assets/bottom_navigation_asset.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final List<NavigationItem> navItems;

  const CustomBottomNavigationBar({super.key, required this.navItems});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.sm),
        child: BlocBuilder<AppNavigationCubit, int>(
          builder: (context, selectedIndex) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                3,
                (index) {
                  return BottomNavigationAsset(
                    svgIcon: navItems[index].svgIcon,
                    title: navItems[index].title!,
                    isActive: selectedIndex == index,
                    onTap: () {
                      context.read<AppNavigationCubit>().setIndex(index);
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
