import 'dart:math';

import 'package:fantavacanze_official/core/constants/navigation_items.dart';
import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_theme/app_theme_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/cubits/notification_count/notification_count_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/services/ad_helper.dart';
import 'package:fantavacanze_official/core/services/review_service.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/notification_dialog.dart';
import 'package:fantavacanze_official/core/widgets/notification_badge.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc/league_state.dart';
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
import 'package:get_it/get_it.dart';

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
  final _reviewService = GetIt.instance<ReviewService>();

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

    _loadAds();
    _checkAndRequestReview();

    context.read<LeagueBloc>().add(GetNotificationsEvent());
    // Ascolto notifiche
    context.read<LeagueBloc>().add(ListenToNotificationEvent());
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
    final adHelper = AdHelper();

    await adHelper.initialize();

    adHelper.connectToUserCubit(serviceLocator<AppUserCubit>());
    if (mounted) {
      adHelper.startAdTimer(context);
    }
  }

  void _checkAndRequestReview() {
    _reviewService.checkAndRequestReview(
      context,
      context.read<AppUserCubit>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final double menuWidth = Constants.getWidth(context) * 0.70;

    return BlocListener<LeagueBloc, LeagueState>(
      listener: (context, state) {
        if (state is NotificationReceived) {
          showDialog(
            context: context,
            builder: (_) => NotificationDialog.fromNotification(
              notification: state.notification,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: context.secondaryBgColor,
        body: Stack(
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
                    child: Scaffold(
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
                          BlocBuilder<NotificationCountCubit, int>(
                            builder: (_, count) => GestureDetector(
                              onTap: () => Navigator.push(
                                  context, NotificationsPage.route),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(right: ThemeSizes.md),
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
                          ),
                          GestureDetector(
                            onTap: () =>
                                Navigator.push(context, SettingsPage.route),
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
                              if (selectedIndex < 0 ||
                                  selectedIndex >= navItems.length) {
                                return navItems[0].screen;
                              }
                              final selectedItem = navItems[selectedIndex];
                              if (selectedItem.title == 'Crea Lega' ||
                                  selectedItem.title == 'Cerca Lega') {
                                WidgetsBinding.instance.addPostFrameCallback(
                                  (_) {
                                    if (mounted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => selectedItem.screen,
                                        ),
                                      );
                                      context
                                          .read<AppNavigationCubit>()
                                          .setIndex(0);
                                    }
                                  },
                                );
                              }
                              return selectedItem.screen;
                            },
                          );
                        },
                      ),
                      bottomNavigationBar: isKeyboardVisible
                          ? null
                          : const CustomBottomNavigationBar(),
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
    );
  }

  Widget _buildLogo(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final widthFactor = isTablet ? 0.13 : 0.18;

    return Image.asset(
      context.read<AppThemeCubit>().isDarkMode(context)
          ? 'assets/images/logo.png'
          : 'assets/images/logo-dark.png',
      width: Constants.getWidth(context) * widthFactor,
    );
  }
}
