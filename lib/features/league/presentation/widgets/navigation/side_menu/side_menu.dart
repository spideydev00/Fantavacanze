// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:fantavacanze_official/core/constants/navigation_items.dart';
import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_theme/app_theme_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/core/become_premium_button.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/navigation/side_menu/league_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/cubits/app_navigation/app_navigation_cubit.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/navigation/navigation_item.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/core/divider.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/core/plan_label.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/navigation/side_menu/side_menu_navigation_asset.dart';

class SideMenu extends StatelessWidget {
  final VoidCallback? closeMenuCallback;

  const SideMenu({
    super.key,
    this.closeMenuCallback,
  });

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
                      const LeagueDropdown(),
                      BlocBuilder<AppLeagueCubit, AppLeagueState>(
                        builder: (context, leagueState) {
                          final hasLeagues = leagueState is AppLeagueExists;
                          return BlocBuilder<AppNavigationCubit, int>(
                            builder: (context, selectedIndex) {
                              return Column(
                                children: buildNavigationMenu(
                                  context: context,
                                  selectedIndex: selectedIndex,
                                  hasLeagues: hasLeagues,
                                ),
                              );
                            },
                          );
                        },
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: ThemeSizes.md),
                        child: CustomDivider(text: "Sostienici"),
                      ),
                      BecomePremiumButton(onPressed: () {}),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> buildNavigationMenu({
    required BuildContext context,
    required int selectedIndex,
    required bool hasLeagues,
  }) {
    final navItems =
        hasLeagues ? participantNavbarItems : nonParticipantNavbarItems;

    // Mappa per trovare l'indice originale di un item basato sul suo titolo
    final originalIndices = {
      for (var i = 0; i < navItems.length; i++) navItems[i].title!: i
    };

    final itemsToShow = navItems.take(navItems.length).toList();

    // Raggruppa gli item per sottosezione
    final groupedItems = groupBy(
      itemsToShow,
      (NavigationItem item) => item.subsection ?? "Menù",
    );

    List<Widget> menuWidgets = [];

    groupedItems.forEach((subsection, items) {
      // Aggiungi il divisore per la sottosezione
      menuWidgets.add(
        Padding(
          padding: const EdgeInsets.only(top: ThemeSizes.sm),
          child: CustomDivider(text: subsection),
        ),
      );
      menuWidgets.add(const SizedBox(height: 5));

      // Aggiungi gli item della sottosezione
      for (final item in items) {
        final originalIndex = originalIndices[item.title!];
        if (originalIndex == null) continue; // Salta se non trova l'indice

        menuWidgets.add(
          SideMenuNavigationAsset(
            title: item.title!,
            svgIcon: context.read<AppThemeCubit>().isDarkMode(context)
                ? item.darkSvgIcon
                : item.lightSvgIcon,
            // Usa l'indice originale per determinare se l'item è attivo
            isActive: selectedIndex == originalIndex,
            onTap: () {
              // Pass the callback to the handler
              _handleNavigation(context, item, originalIndex, hasLeagues);
            },
          ),
        );
      }
    });

    return menuWidgets;
  }

  // Gestisce la logica di navigazione
  void _handleNavigation(BuildContext context, NavigationItem item,
      int originalItemIndex, bool hasLeagues) {
    if (item.title == "Crea Lega" || item.title == "Cerca Lega") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => item.screen),
      );
      // Close menu even after pushing a new route
      closeMenuCallback?.call();
      return; // Non aggiornare l'indice del Cubit
    }

    // Per gli item di navigazione standard, usa l'indice originale passato
    context.read<AppNavigationCubit>().setIndex(originalItemIndex);

    // Call the callback to close the menu
    closeMenuCallback?.call();
  }

  // Footer fisso in basso
  Widget _buildFooter(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 30),
        Text(
          "© Fantavacanze - 2024", // Considera di aggiornare l'anno dinamicamente
          style: context.textTheme.bodySmall!.copyWith(
            color: context.textSecondaryColor.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: () {
            // TODO: Implementa apertura link policy
          },
          child: RichText(
            text: TextSpan(
              style: context.textTheme.labelSmall,
              children: [
                TextSpan(
                  text: "Leggi la ",
                  style: context.textTheme.bodySmall!.copyWith(
                    color: context.textSecondaryColor.withValues(alpha: 0.6),
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
    );
  }
}

// User Info + Avatar (invariato)
Widget _buildUserInfo(BuildContext context) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Image.asset(
        "assets/images/avatar.png",
        width: ThemeSizes.avatarSize,
        height: ThemeSizes.avatarSize,
      ),
      const SizedBox(width: ThemeSizes.md), // Aggiunto spazio
      Expanded(
        // Usa Expanded per evitare overflow se il testo è lungo
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Alex", // Considera di ottenere il nome utente dinamicamente
              style: context.textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis, // Gestisce testo lungo
            ),
            const SizedBox(height: ThemeSizes.xs),
            Text(
              "Membro dal: 07/2025", // Considera data dinamica
              style: context.textTheme.labelMedium!.copyWith(
                color: context.textSecondaryColor.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: ThemeSizes.sm + 2),
            const PlanLabel(),
          ],
        ),
      ),
    ],
  );
}
