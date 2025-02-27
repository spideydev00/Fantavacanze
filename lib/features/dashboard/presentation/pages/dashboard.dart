import 'package:fantavacanze_official/core/theme/sizes.dart';
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
  List bottomNavIcons = [
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
      additionalPadding: 11.0,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: RiveAsset(
          path: "assets/animations/rive/icons.riv",
          artboard: "CHAT",
          stateMachineName: "CHAT_Interactivity",
          title: "",
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.all(ThemeSizes.xs),
          margin: EdgeInsets.symmetric(horizontal: ThemeSizes.md),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.90),
            borderRadius: BorderRadius.all(
              Radius.circular(ThemeSizes.lg),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ...List.generate(
                bottomNavIcons.length,
                (index) {
                  return bottomNavIcons[index];
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
