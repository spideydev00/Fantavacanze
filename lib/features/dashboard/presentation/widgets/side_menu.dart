import 'package:fantavacanze_official/core/constants/navigation_items.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/cubits/app_navigation/app_navigation_cubit.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/navigation/navigation_item.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/widgets/helpers/divider.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/widgets/helpers/plan_label.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/widgets/navigation_assets/side_menu_navigation_asset.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: Constants.getWidth(context) * 0.7,
        color: ColorPalette.secondaryBg,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildUserInfo(context),
              Padding(
                padding: const EdgeInsets.only(top: ThemeSizes.md),
                child: const CustomDivider(text: "Naviga"),
              ),
              const SizedBox(height: 10),
              // BlocBuilder listens to state changes
              BlocBuilder<AppNavigationCubit, int>(
                builder: (context, selectedIndex) {
                  return Column(
                    children: nonParticipantNavbarItems.map(
                      (item) {
                        int itemIndex = nonParticipantNavbarItems.indexOf(item);
                        bool isActive = selectedIndex == itemIndex;

                        return SideMenuNavigationAsset(
                          title: item.title!,
                          svgIcon: item.svgIcon,
                          isActive: isActive,
                          onTap: () =>
                              _handleNavigation(context, item, itemIndex),
                        );
                      },
                    ).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Handle Navigation Logic using Cubit
  void _handleNavigation(
      BuildContext context, NavigationItem item, int itemIndex) {
    if (nonParticipantNavbarItems.contains(item)) {
      // If item is in bottom navigation, update the state in Dashboard
      context.read<AppNavigationCubit>().setIndex(itemIndex);
    } else {
      // Otherwise, navigate to the new page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => item.screen),
      );
    }
  }
}

// User Info + Avatar
Widget _buildUserInfo(BuildContext context) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Image.asset(
        "assets/images/avatar.png",
        width: ThemeSizes.avatarSize,
        height: ThemeSizes.avatarSize,
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Alex",
            style: context.textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Membro dal: 07/2025",
            style: context.textTheme.labelMedium!.copyWith(
              color: ColorPalette.darkGrey,
            ),
          ),
          const SizedBox(height: 10),
          const PlanLabel(plan: "free"),
          const SizedBox(height: 10),
        ],
      ),
    ],
  );
}
