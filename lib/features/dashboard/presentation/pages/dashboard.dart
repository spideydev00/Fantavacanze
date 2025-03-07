import 'dart:math';

import 'package:fantavacanze_official/core/constants/navigation_items.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/widgets/helpers/custom_menu_icon.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/widgets/side_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/cubits/app_navigation/app_navigation_cubit.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/widgets/bottom_navigation_bar.dart';

class DashboardScreen extends StatefulWidget {
  static get route => MaterialPageRoute(
        builder: (context) => const DashboardScreen(),
      );

  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  bool isSideMenuOpen = false;

  late AnimationController _animationController;
  late Animation<double> animation;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a background color matching the SideMenu
      backgroundColor: ColorPalette.secondaryBg,
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
            width: Constants.getWidth(context) * 0.70,
            left: !isSideMenuOpen ? -(Constants.getWidth(context) * 0.70) : 0,
            height: Constants.getHeight(context),
            child: const SideMenu(),
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
                  animation.value * (Constants.getWidth(context) * 0.70), 0),
              child: Transform.scale(
                scale: scaleAnimation.value,
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(ThemeSizes.borderRadiusXlg),
                  child: Scaffold(
                    appBar: AppBar(
                      forceMaterialTransparency: true,
                      toolbarHeight: ThemeSizes.appBarHeight,
                      title: _buildLogo(context),
                      leading: CustomMenuIcon(
                        path: "assets/animations/rive/menu_button.riv",
                        artboard: "Artboard",
                        stateMachineName: "switch",
                        triggerValue: "toggleX",
                        onTap: () {
                          if (!isSideMenuOpen) {
                            _animationController.forward();
                          } else {
                            _animationController.reverse();
                          }

                          setState(
                            () {
                              isSideMenuOpen = !isSideMenuOpen;
                            },
                          );
                        },
                      ),
                    ),
                    resizeToAvoidBottomInset: false,
                    body: BlocBuilder<AppNavigationCubit, int>(
                      builder: (context, selectedIndex) {
                        return IndexedStack(
                          index: selectedIndex,
                          children: nonParticipantNavbarItems
                              .map((item) => item.screen)
                              .toList(),
                        );
                      },
                    ),
                    bottomNavigationBar: CustomBottomNavigationBar(
                      navItems: nonParticipantNavbarItems,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Image.asset(
      "assets/images/logo-high-padding.png",
      width: Constants.getWidth(context) * 0.40,
    );
  }
}
