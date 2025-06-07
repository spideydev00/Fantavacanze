import 'dart:math';

import 'package:fantavacanze_official/core/constants/navigation_items.dart';
import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_theme/app_theme_cubit.dart';
import 'package:fantavacanze_official/core/cubits/notification_count/notification_count_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/utils/ad_helper.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/notification_dialog.dart';
import 'package:fantavacanze_official/core/widgets/notification_badge.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_state.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/notifications/notifications_page.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/settings/settings.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/dashboard/widgets/side_menu/custom_menu_icon.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/dashboard/sections/side_menu.dart';
import 'package:fantavacanze_official/init_dependencies/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/cubits/app_navigation/app_navigation_cubit.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/dashboard/sections/bottom_navigation_bar.dart';

class DashboardScreen extends StatefulWidget {
  static const String routeName = '/dashboard';

  static get route => MaterialPageRoute(
        builder: (context) => const DashboardScreen(),
        settings: const RouteSettings(name: routeName),
      );

  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  bool isSideMenuOpen = false;
  AdHelper? _adHelper;

  late AnimationController _animationController;
  late Animation<double> animation;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() {
        setState(() {});
      });

    animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );
    scaleAnimation = Tween<double>(begin: 1, end: 0.9).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );

    // Carica le notifiche
    context.read<LeagueBloc>().add(GetNotificationsEvent());

    // Inizializza l'ascolto delle notifiche
    context.read<LeagueBloc>().add(ListenToNotificationEvent());

    // Inizializza l'AdHelper e avvia il timer per gli interstitial ads
    _initializeAds();
  }

  Future<void> _initializeAds() async {
    // Get AdHelper from service locator
    _adHelper = serviceLocator<AdHelper>();

    // Start the periodic ad timer after a short delay
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _adHelper?.startAdTimer(context);
      }
    });
  }

  @override
  void dispose() {
    // Stop the ad timer when the dashboard is disposed
    _adHelper?.stopAdTimer();
    _animationController.dispose();
    super.dispose();
  }

  // Function to close the side menu
  void _closeSideMenu() {
    _animationController.reverse();
    setState(() {
      isSideMenuOpen = false;
    });
  }

  // Function to toggle the side menu
  void _toggleSideMenu() {
    if (isSideMenuOpen) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
    setState(() {
      isSideMenuOpen = !isSideMenuOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if keyboard is visible
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return BlocListener<LeagueBloc, LeagueState>(
      listener: (context, state) {
        if (state is NotificationReceived) {
          showDialog(
            context: context,
            builder: (context) => NotificationDialog.fromNotification(
              notification: state.notification,
            ),
          );
        }
      },
      child: Scaffold(
        // Use a background color matching the SideMenu
        backgroundColor: context.secondaryBgColor,
        body: GestureDetector(
          // Detector principale per aprire il menu con swipe da sinistra a destra
          onHorizontalDragEnd: (details) {
            // Determina se il gesto è sufficientemente veloce e nella giusta direzione
            if (details.primaryVelocity != null) {
              // Velocità positiva significa swipe da sinistra a destra (apre il menu)
              if (details.primaryVelocity! > 300 && !isSideMenuOpen) {
                _toggleSideMenu();
              }
              // Velocità negativa significa swipe da destra a sinistra (chiude il menu)
              else if (details.primaryVelocity! < -300 && isSideMenuOpen) {
                _closeSideMenu();
              }
            }
          },
          // Rileva anche l'inizio dello swipe vicino al bordo sinistro per aprire il menu
          onHorizontalDragStart: (details) {
            // Se il gesto inizia vicino al bordo sinistro dello schermo (< 20px)
            // e il menu è chiuso, è probabile che l'utente voglia aprire il menu
            if (details.globalPosition.dx < 20 && !isSideMenuOpen) {
              _toggleSideMenu();
            }
          },
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.fastOutSlowIn,
                width: Constants.getWidth(context) * 0.70,
                left:
                    !isSideMenuOpen ? -(Constants.getWidth(context) * 0.70) : 0,
                height: Constants.getHeight(context),
                // Pass the close callback to SideMenu
                child: SideMenu(closeMenuCallback: _closeSideMenu),
              ),
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(
                    animation.value - 30 * animation.value * pi / 180,
                  ),
                child: Transform.translate(
                  offset: Offset(
                      animation.value * (Constants.getWidth(context) * 0.70),
                      0),
                  child: Transform.scale(
                    scale: scaleAnimation.value,
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(ThemeSizes.borderRadiusXlg),
                      child: Scaffold(
                        appBar: AppBar(
                          centerTitle: true,
                          forceMaterialTransparency: true,
                          toolbarHeight: ThemeSizes.appBarHeight,
                          title: _buildLogo(context),
                          actions: [
                            // Notification icon with badge
                            BlocBuilder<NotificationCountCubit, int>(
                              builder: (context, count) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      NotificationsPage.route,
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        right: ThemeSizes.md),
                                    child: NotificationBadge(
                                      count: count,
                                      child: Icon(
                                        Icons.notifications_outlined,
                                        size: 24,
                                        color: context.textPrimaryColor,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Settings icon
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, SettingsPage.route);
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(right: ThemeSizes.lg),
                                child: Icon(
                                  Icons.settings,
                                  size: 24,
                                  color: context.textPrimaryColor,
                                ),
                              ),
                            ),
                          ],
                          leading: CustomMenuIcon(
                            path: context
                                    .read<AppThemeCubit>()
                                    .isDarkMode(context)
                                ? "assets/animations/rive/menu_button.riv"
                                : "assets/animations/rive/menu_button_black.riv",
                            artboard: "Artboard",
                            stateMachineName: "switch",
                            triggerValue: "toggleX",
                            // Use the toggle function
                            onTap: _toggleSideMenu,
                            // Pass the actual menu state to control the icon
                            isActive: isSideMenuOpen,
                          ),
                        ),
                        resizeToAvoidBottomInset: false,
                        body: BlocBuilder<AppLeagueCubit, AppLeagueState>(
                          builder: (context, leagueState) {
                            final hasLeagues = leagueState is AppLeagueExists;

                            return BlocBuilder<AppNavigationCubit, int>(
                              builder: (context, selectedIndex) {
                                final navItems = hasLeagues
                                    ? participantNavbarItems
                                    : nonParticipantNavbarItems;

                                // Ensure index is within bounds
                                if (selectedIndex < 0 ||
                                    selectedIndex >= navItems.length) {
                                  //default screen
                                  return navItems[0].screen;
                                }

                                final selectedItem = navItems[selectedIndex];

                                // Handle "Nuova Lega" subsection and specific items
                                if (selectedItem.title == "Crea Lega" ||
                                    selectedItem.title == "Cerca Lega") {
                                  WidgetsBinding.instance.addPostFrameCallback(
                                    (_) {
                                      if (mounted) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                selectedItem.screen,
                                          ),
                                        );
                                        // Reset navigation index after push
                                        context
                                            .read<AppNavigationCubit>()
                                            .setIndex(0);
                                      }
                                    },
                                  );
                                }

                                // Display the screen directly
                                return selectedItem.screen;
                              },
                            );
                          },
                        ),
                        // Hide the bottom navigation bar when keyboard is visible
                        bottomNavigationBar: isKeyboardVisible
                            ? null
                            : const CustomBottomNavigationBar(),
                      ),
                    ),
                  ),
                ),
              ),
              // Overlay GestureDetector to close menu when tapped outside or dragged
              if (isSideMenuOpen)
                Positioned.fill(
                  // Position over the transformed content area
                  left: animation.value * (Constants.getWidth(context) * 0.70),
                  child: GestureDetector(
                    onTap: _closeSideMenu,
                    onHorizontalDragUpdate: (details) {
                      // Chiude se si trascina significativamente verso sinistra
                      if (details.delta.dx < -1.0) {
                        _closeSideMenu();
                      }
                    },
                    // Prevent gestures below when menu is open and overlay is active
                    behavior: HitTestBehavior.opaque,
                    // Use a transparent color to make it tappable but invisible
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Image.asset(
      context.read<AppThemeCubit>().isDarkMode(context)
          ? "assets/images/logo.png"
          : "assets/images/logo-dark.png",
      width: Constants.getWidth(context) * 0.18,
    );
  }
}
