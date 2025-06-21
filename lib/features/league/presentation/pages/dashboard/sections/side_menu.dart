// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:fantavacanze_official/core/constants/navigation_items.dart';
import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_theme/app_theme_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/widgets/become_premium_button.dart';
// import 'package:fantavacanze_official/core/widgets/become_premium_button.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/dashboard/widgets/side_menu/league_dropdown.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/settings/privacy_policy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/cubits/app_navigation/app_navigation_cubit.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/navigation/navigation_item.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/divider.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/dashboard/widgets/side_menu/side_menu_navigation_asset.dart';
import 'package:google_fonts/google_fonts.dart';

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
                      BlocBuilder<AppUserCubit, AppUserState>(
                        builder: (context, state) {
                          if (state is AppUserIsLoggedIn) {
                            return _buildUserInfo(
                              context,
                              state.user.name,
                              state.user.email,
                            );
                          }
                          return SizedBox();
                        },
                      ),
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
                      BlocBuilder<AppUserCubit, AppUserState>(
                        builder: (context, state) {
                          if (state is AppUserIsLoggedIn &&
                              state.user.isPremium == true) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: ThemeSizes.md),
                                child: CustomDivider(text: "Sostienici"),
                              ),
                              BecomePremiumButton(),
                              const SizedBox(height: 20),
                            ],
                          );
                        },
                      ),
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
    // 1. Prendo l’elenco base degli item
    final navItems =
        hasLeagues ? participantNavbarItems : nonParticipantNavbarItems;

    // 2. Controllo se l’utente è admin (solo haLeagues=true ha senso)
    final bloc = context.read<LeagueBloc>();
    final bool userIsAdmin = hasLeagues && bloc.isAdmin();

    // 3. Mappa titolo->indice originale su tutta la lista (serve per selectedIndex)
    final originalIndices = {
      for (var i = 0; i < navItems.length; i++) navItems[i].title: i
    };

    // 4. Filtra fuori gli item riservati agli admin se non è admin
    final itemsToShow = navItems
        .where((item) =>
            !item.isAdminOnly || // tutti gli standard…
            (item.isAdminOnly &&
                userIsAdmin)) // …e solo gli admin-only se userIsAdmin
        .toList();

    // 5. Raggruppo per sottosezione
    final groupedItems = groupBy<NavigationItem, String>(
      itemsToShow,
      (item) => item.subsection,
    );

    // 6. Costruisco i widget
    List<Widget> menuWidgets = [];

    groupedItems.forEach((subsection, items) {
      menuWidgets.add(
        Padding(
          padding: const EdgeInsets.only(top: ThemeSizes.sm),
          child: CustomDivider(text: subsection),
        ),
      );
      menuWidgets.add(const SizedBox(height: 5));

      for (final item in items) {
        final originalIndex = originalIndices[item.title];
        if (originalIndex == null) continue;

        menuWidgets.add(
          SideMenuNavigationAsset(
            title: item.title,
            svgIcon: context.read<AppThemeCubit>().isDarkMode(context)
                ? item.darkSvgIcon
                : item.lightSvgIcon,
            isActive: selectedIndex == originalIndex,
            onTap: () {
              _handleNavigation(
                context,
                item,
                originalIndex,
                hasLeagues,
              );
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
    if (item.title == "Crea Lega" ||
        item.title == "Cerca Lega" ||
        item.title == "Nuovo Evento" ||
        item.title == "Admin") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => item.screen),
      );
      // Close menu even after pushing a new route
      closeMenuCallback?.call();
      return;
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
          "© Fantavacanze - 2025",
          style: context.textTheme.bodySmall!.copyWith(
            color: context.textSecondaryColor.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(PrivacyPolicyPage.route);
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

Widget _buildUserInfo(BuildContext context, String name, String email) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      // Check if user is admin and show PRO label
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.md),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // The avatar
            CircleAvatar(
              radius: ThemeSizes.avatarSize,
              backgroundColor: context.primaryColor.withValues(alpha: 0.1),
              child: Icon(
                Icons.person,
                size: ThemeSizes.avatarSize,
                color: context.primaryColor,
              ),
            ),

            // PRO label (only for admins)
            BlocBuilder<AppUserCubit, AppUserState>(
              builder: (context, state) {
                if (state is AppUserIsLoggedIn &&
                    state.user.isPremium == true) {
                  return Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: context.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        'PRO',
                        style: GoogleFonts.passeroOne(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),

      // User info (name and email)
      Expanded(
        // Usa Expanded per evitare overflow se il testo è lungo
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: context.textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: ThemeSizes.xs),
            Text(
              email,
              style: context.textTheme.labelMedium!.copyWith(
                color: context.textSecondaryColor.withValues(alpha: 0.8),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
