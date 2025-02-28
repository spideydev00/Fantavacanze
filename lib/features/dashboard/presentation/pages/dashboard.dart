import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/pages/empty_branded_page.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/widgets/article_card.dart';
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
  List<RiveAsset> bottomNavIcons = [
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
    return EmptyBrandedPage.withoutImage(
      logoImagePath: "assets/images/logo-high-padding.png",
      isBackNavigationActive: false,
      mainColumnAlignment: MainAxisAlignment.start,
      widgets: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.xl),
          child: Divider(
            thickness: 0.3,
            color: ColorPalette.darkGrey,
          ),
        ),
        SizedBox(height: 15),
        Text(
          "Al momento non partecipi a nessuna lega.",
          style: context.textTheme.bodySmall!.copyWith(
            color: ColorPalette.darkGrey,
            fontStyle: FontStyle.italic,
          ),
        ),
        SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.xl),
          child: Divider(
            thickness: 0.3,
            color: ColorPalette.darkGrey,
          ),
        ),
        ArticleCard(),
        ArticleCard(),
      ],
      bottomNavBar: SafeArea(
        child: Container(
          padding: EdgeInsets.all(ThemeSizes.xs),
          margin: EdgeInsets.symmetric(horizontal: ThemeSizes.md),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.75),
            borderRadius: BorderRadius.all(Radius.circular(ThemeSizes.xl)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: bottomNavIcons,
          ),
        ),
      ),
      floatingButton: Container(
        height: 48,
        margin: EdgeInsets.only(bottom: ThemeSizes.md),
        child: FloatingActionButton(
          onPressed: () {},
          child: RiveAsset(
            path: "assets/animations/rive/icons.riv",
            artboard: "SEARCH",
            stateMachineName: "SEARCH_Interactivity",
            height: ThemeSizes.riveIconSm,
            width: ThemeSizes.riveIconSm,
          ),
        ),
      ),
    );
  }
}
