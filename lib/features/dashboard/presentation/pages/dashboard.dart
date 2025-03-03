import 'package:fantavacanze_official/core/pages/empty_branded_page.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/pages/challenge.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/pages/home.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/pages/memories.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/pages/rankings.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/widgets/rive_asset.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  static get route =>
      MaterialPageRoute(builder: (context) => const DashboardScreen());
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    RankingsPage(),
    ChallengePage(),
    MemoriesPage()
  ];

  @override
  Widget build(BuildContext context) {
    return EmptyBrandedPage.withoutImage(
      logoImagePath: "assets/images/logo-high-padding.png",
      isBackNavigationActive: false,
      mainColumnAlignment: MainAxisAlignment.start,
      widgets: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: _pages[_selectedIndex],
        ),
      ],
      bottomNavBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(bottomNavIcons.length, (index) {
              return RiveAsset(
                path: bottomNavIcons[index].path,
                artboard: bottomNavIcons[index].artboard,
                stateMachineName: bottomNavIcons[index].stateMachineName,
                triggerValue: bottomNavIcons[index].triggerValue,
                title: bottomNavIcons[index].title,
                additionalPadding: bottomNavIcons[index].additionalPadding,
                isActive: _selectedIndex == index,
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              );
            }),
          ),
        ),
      ),
    );
  }

  List<RiveAsset> get bottomNavIcons => [
        RiveAsset(
          path: "assets/animations/rive/icons.riv",
          artboard: "HOME",
          stateMachineName: "HOME_interactivity",
          title: "Home",
        ),
        RiveAsset(
          path: "assets/animations/rive/icons.riv",
          artboard: "SCORE",
          stateMachineName: "State Machine 1",
          triggerValue: "showingStar",
          title: "Classifica",
          additionalPadding: 10.0,
        ),
        RiveAsset(
          path: "assets/animations/rive/icons.riv",
          artboard: "TIMER",
          stateMachineName: "TIMER_Interactivity",
          title: "Sfida",
        ),
        RiveAsset(
          path: "assets/animations/rive/icons.riv",
          artboard: "CHAT",
          stateMachineName: "CHAT_Interactivity",
          title: "Ricordi",
        ),
      ];
}
