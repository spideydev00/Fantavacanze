import 'package:fantavacanze_official/core/constants/navigation_items.dart';
import 'package:fantavacanze_official/core/cubits/app_theme/app_theme_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/widgets/helpers/become_premium_button.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/widgets/helpers/theme_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/cubits/app_navigation/app_navigation_cubit.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/navigation/navigation_item.dart';
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
        color: context.secondaryBgColor,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildUserInfo(context),
                      Padding(
                        padding: const EdgeInsets.only(top: ThemeSizes.sm),
                        child: CustomDivider(
                          text:
                              nonParticipantNavbarItems[0].subsection ?? "Menù",
                        ),
                      ),
                      const SizedBox(height: 5),

                      // BlocBuilder listens to state changes
                      BlocBuilder<AppNavigationCubit, int>(
                        builder: (context, selectedIndex) {
                          return Column(
                            children: buildNavigationMenu(
                              context: context,
                              selectedIndex: selectedIndex,
                            ),
                          );
                        },
                      ),

                      Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: ThemeSizes.md),
                        child: CustomDivider(text: "Sostienici"),
                      ),

                      BecomePremiumButton(onPressed: () {}),

                      // Add theme switch section
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: ThemeSizes.md),
                        child: CustomDivider(text: "Impostazioni"),
                      ),

                      ThemeSwitch(),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Footer Section - fixed at bottom
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 30),
                  Text(
                    "© Fantavacanze - 2024",
                    style: context.textTheme.bodySmall!.copyWith(
                      color: context.textSecondaryColor.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 5),
                  GestureDetector(
                    onTap: () {
                      // Open privacy policy link
                    },
                    child: RichText(
                      text: TextSpan(
                        style: context.textTheme.labelSmall,
                        children: [
                          TextSpan(
                            text: "Leggi la ",
                            style: context.textTheme.bodySmall!.copyWith(
                              color: context.textSecondaryColor
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                          TextSpan(
                            text: "policy",
                            style: context.textTheme.bodySmall!.copyWith(
                              color: context.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> buildNavigationMenu({
    required BuildContext context,
    required int selectedIndex,
    int? maxItems,
  }) {
    final itemsToShow = nonParticipantNavbarItems
        .take(maxItems ?? nonParticipantNavbarItems.length)
        .toList();

    List<Widget> menuItems = [];
    String? lastSubsection;

    for (int index = 0; index < itemsToShow.length; index++) {
      final item = itemsToShow[index];

      // If subsection changes, add a divider
      if (lastSubsection != null && lastSubsection != item.subsection) {
        menuItems.add(
          CustomDivider(text: item.subsection ?? "Menù"),
        );
      }

      // Add the navigation item
      menuItems.add(
        SideMenuNavigationAsset(
          title: item.title!,
          svgIcon: context.read<AppThemeCubit>().isDarkMode(context)
              ? item.darkSvgIcon
              : item.lightSvgIcon,
          isActive: selectedIndex == index,
          onTap: () => _handleNavigation(context, item, index),
        ),
      );

      lastSubsection = item.subsection;
    }

    return menuItems;
  }

  // Handle Navigation Logic using Cubit
  void _handleNavigation(
      BuildContext context, NavigationItem item, int itemIndex) {
    if (itemIndex < 3) {
      // Se l'elemento è nei primi 3, aggiorna l'indice della bottom navigation
      context.read<AppNavigationCubit>().setIndex(itemIndex);
    } else {
      // Altrimenti, naviga direttamente alla pagina
      context.read<AppNavigationCubit>().setIndex(itemIndex);
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
              color: context.textSecondaryColor.withValues(alpha: 0.8),
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
