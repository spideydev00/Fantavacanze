import 'dart:math';

import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/constants/navigation_items.dart';
import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_navigation/app_navigation_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_theme/app_theme_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/cubits/notification_count/notification_count_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/services/ad_helper.dart';
import 'package:fantavacanze_official/core/services/review_service.dart';
import 'package:fantavacanze_official/core/theme/brand_assets.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/notification_dialog.dart';
import 'package:fantavacanze_official/core/widgets/notification_badge.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/daily_challenges_bloc/daily_challenges_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/daily_challenges_bloc/daily_challenges_state.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/notifications_bloc/notifications_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/notifications_bloc/notifications_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/notifications_bloc/notifications_state.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/dashboard/sections/bottom_navigation_bar.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/dashboard/sections/side_menu.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/dashboard/widgets/side_menu/custom_menu_icon.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/notifications/notifications_page.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/settings/settings.dart';
import 'package:fantavacanze_official/init_dependencies/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class DashboardScreen extends StatefulWidget {
  static const String routeName = '/dashboard';

  static MaterialPageRoute<dynamic> get route => MaterialPageRoute(
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
  final _reviewService = GetIt.instance<ReviewService>();
  late final List<Widget> _participantScreens;
  late final List<Widget> _nonParticipantScreens;

  late AnimationController _animationController;
  late Animation<double> animation;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() => setState(() {}));

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
    _participantScreens = participantNavbarItems
        .map(
          (item) => KeyedSubtree(
            key: ValueKey('participant-${item.title}'),
            child: item.screen,
          ),
        )
        .toList();
    _nonParticipantScreens = nonParticipantNavbarItems
        .map(
          (item) => KeyedSubtree(
            key: ValueKey('non-participant-${item.title}'),
            child: item.screen,
          ),
        )
        .toList();

    _loadAds();
    _checkAndRequestReview();

    // Load notifications and update count on startup
    context.read<NotificationsBloc>().add(GetNotificationsEvent());
    // Listen for new notifications
    context.read<NotificationsBloc>().add(ListenToNotificationEvent());
  }

  @override
  void dispose() {
    _adHelper?.stopAdTimer();
    _animationController.dispose();
    super.dispose();
  }

  void _closeSideMenu() {
    _animationController.reverse();
    setState(() => isSideMenuOpen = false);
  }

  void _toggleSideMenu() {
    if (isSideMenuOpen) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
    setState(() => isSideMenuOpen = !isSideMenuOpen);
  }

  void _loadAds() async {
    // Pre-carica gli annunci usando il tuo AdHelper.
    // Usa l'istanza singleton
    _adHelper = AdHelper();

    await _adHelper!.initialize();

    _adHelper!.connectToUserCubit(serviceLocator<AppUserCubit>());

    if (mounted) {
      _adHelper!.startAdTimer(context);
    }
  }

  void _checkAndRequestReview() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        final dailyChallengesState = context.read<DailyChallengesBloc>().state;

        if (dailyChallengesState is DailyChallengesLoaded) {
          // Daily challenges are loaded, now check for reviews
          _reviewService.checkAndRequestReview(
            context,
            context.read<AppUserCubit>(),
            context.read<AppLeagueCubit>(),
          );
        } else {
          // If challenges aren't loaded yet, try again after a short delay
          Future.delayed(
            const Duration(milliseconds: 1000),
            () {
              if (mounted) {
                _checkAndRequestReview();
              }
            },
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final double menuWidth = Constants.getWidth(context) * 0.70;

    final leagueBloc = context.read<LeagueBloc>();

    return BlocListener<NotificationsBloc, NotificationsState>(
      listener: (context, state) {
        if (state is NotificationReceived) {
          // Show dialog for new notifications
          showDialog(
            context: context,
            builder: (_) => NotificationDialog.fromNotification(
              notification: state.notification,
            ),
          );
        }
        // Update notification count whenever notifications state changes
        if (state is NotificationsLoaded) {
          final notificationCount = state.notifications.length;
          context.read<NotificationCountCubit>().setCount(notificationCount);
        }
      },
      child: Scaffold(
        backgroundColor: context.secondaryBgColor,
        body: GestureDetector(
          child: Stack(
            children: [
              // Side menu
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.fastOutSlowIn,
                width: menuWidth,
                left: isSideMenuOpen ? 0 : -menuWidth,
                height: Constants.getHeight(context),
                child: SideMenu(closeMenuCallback: _closeSideMenu),
              ),

              // Main content 3D transform
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(
                    animation.value - 30 * animation.value * pi / 180,
                  ),
                child: Transform.translate(
                  offset: Offset(animation.value * menuWidth, 0),
                  child: Transform.scale(
                    scale: scaleAnimation.value,
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(ThemeSizes.borderRadiusXlg),
                      child: BlocBuilder<AppThemeCubit, AppThemeState>(
                        builder: (context, themeState) {
                          return Scaffold(
                            appBar: AppBar(
                              centerTitle: true,
                              forceMaterialTransparency: true,
                              toolbarHeight: ThemeSizes.appBarHeight,
                              title: _buildLogo(context),
                              leading: CustomMenuIcon(
                                path: context
                                        .read<AppThemeCubit>()
                                        .isDarkMode(context)
                                    ? 'assets/animations/rive/menu_button.riv'
                                    : 'assets/animations/rive/menu_button_black.riv',
                                artboard: 'Artboard',
                                stateMachineName: 'switch',
                                triggerValue: 'toggleX',
                                onTap: _toggleSideMenu,
                                isActive: isSideMenuOpen,
                              ),
                              actions: [
                                // Show notifications for league admins - with proper state management
                                BlocBuilder<AppLeagueCubit, AppLeagueState>(
                                  builder: (context, leagueState) {
                                    final bool shouldShowNotifications =
                                        leagueState is AppLeagueExists &&
                                            leagueBloc.isAdmin();

                                    if (shouldShowNotifications) {
                                      return BlocBuilder<NotificationCountCubit,
                                          int>(
                                        builder: (_, count) => GestureDetector(
                                          onTap: () => Navigator.push(
                                            context,
                                            NotificationsPage.route,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              right: ThemeSizes.md,
                                            ),
                                            child: NotificationBadge(
                                              count: count,
                                              child: Icon(
                                                Icons.notifications_outlined,
                                                size: 24,
                                                color: context.textPrimaryColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),

                                GestureDetector(
                                  onTap: () => Navigator.push(
                                      context, SettingsPage.route),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        right: ThemeSizes.lg),
                                    child: Icon(
                                      Icons.settings,
                                      size: 24,
                                      color: context.textPrimaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            resizeToAvoidBottomInset: false,
                            body: BlocBuilder<AppLeagueCubit, AppLeagueState>(
                              builder: (context, leagueState) {
                                final hasLeagues =
                                    leagueState is AppLeagueExists;
                                final screens = hasLeagues
                                    ? _participantScreens
                                    : _nonParticipantScreens;
                                final navItems = hasLeagues
                                    ? participantNavbarItems
                                    : nonParticipantNavbarItems;
                                return BlocBuilder<AppNavigationCubit, int>(
                                  builder: (context, selectedIndex) {
                                    int safeIndex = selectedIndex;

                                    if (safeIndex < 0 ||
                                        safeIndex >= navItems.length) {
                                      safeIndex = 0;
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        if (mounted &&
                                            context
                                                    .read<AppNavigationCubit>()
                                                    .state !=
                                                0) {
                                          context
                                              .read<AppNavigationCubit>()
                                              .setIndex(0);
                                        }
                                      });
                                    }

                                    final selectedItem = navItems[safeIndex];

                                    if (selectedItem.title == 'Crea Lega' ||
                                        selectedItem.title == 'Cerca Lega') {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        if (!mounted) return;
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => selectedItem.screen,
                                          ),
                                        );
                                        context
                                            .read<AppNavigationCubit>()
                                            .setIndex(0);
                                      });
                                      safeIndex = 0;
                                    }

                                    return IndexedStack(
                                      index: safeIndex,
                                      children: screens
                                          .take(navItems.length)
                                          .toList(),
                                    );
                                  },
                                );
                              },
                            ),
                            bottomNavigationBar: isKeyboardVisible
                                ? null
                                : const CustomBottomNavigationBar(),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // Swipe area to open menu
              if (!isSideMenuOpen)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 20,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragStart: (_) => _toggleSideMenu(),
                  ),
                ),

              // Overlay to close menu
              if (isSideMenuOpen)
                Positioned.fill(
                  left: animation.value * menuWidth,
                  child: GestureDetector(
                    onTap: _closeSideMenu,
                    onHorizontalDragUpdate: (details) {
                      if (details.delta.dx < -1) _closeSideMenu();
                    },
                    behavior: HitTestBehavior.translucent,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final widthFactor = isTablet ? 0.20 : 0.25; //after fall go back to 0.3
    final logoWidth = Constants.getWidth(context) * widthFactor;
    final isDark = context.read<AppThemeCubit>().isDarkMode(context);
    
    final appLogoPath = isDark
        ? 'assets/images/logos/logo-neon.png'
        : 'assets/images/logos/logo-naked.png';

    return BlocBuilder<AppLeagueCubit, AppLeagueState>(
      builder: (context, leagueState) {
        final partnerLogo = leagueState is AppLeagueExists
            ? BrandAssets.logoFor(
                leagueState.selectedLeague.partner,
                isDark: isDark,
              )
            : null;

        final appLogo = Image.asset(appLogoPath, width: logoWidth);

        if (partnerLogo == null) return appLogo;

        return FittedBox(
          fit: BoxFit.scaleDown,
          child: Image.asset(
            partnerLogo,
            width: logoWidth,
            errorBuilder: (_, __, ___) => appLogo,
          ),
        );
      },
    );
  }
}
