import 'package:fantavacanze_official/core/navigation/navigation_item.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/pages/previews/create_league.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/pages/home.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/pages/previews/join_league.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/pages/previews/drink_games_preview.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/pages/previews/quick_challenge_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

bool isDarkMode() {
  var brightness =
      SchedulerBinding.instance.platformDispatcher.platformBrightness;
  return brightness == Brightness.dark;
}

List<NavigationItem> nonParticipantNavbarItems = [
  NavigationItem(
    title: "Home",
    darkSvgIcon: 'assets/images/icons/homepage_icons/home-icon.svg',
    lightSvgIcon: 'assets/images/icons/homepage_icons/home-icon-dark.svg',
    screen: const HomePage(),
    subsection: "Naviga",
  ),
  NavigationItem(
    title: "Sfida",
    darkSvgIcon: 'assets/images/icons/homepage_icons/thunder-icon-red.svg',
    lightSvgIcon: 'assets/images/icons/homepage_icons/thunder-icon-red.svg',
    screen: const QuickChallengePreview(),
    subsection: "Naviga",
  ),
  NavigationItem(
    title: "Giochi",
    darkSvgIcon: 'assets/images/icons/homepage_icons/drink-games-icon.svg',
    lightSvgIcon:
        'assets/images/icons/homepage_icons/drink-games-icon-dark.svg',
    screen: const DrinkGamesPreview(),
    subsection: "Naviga",
  ),
  NavigationItem(
    title: "Crea Lega",
    darkSvgIcon: 'assets/images/icons/homepage_icons/create-league-icon.svg',
    lightSvgIcon:
        'assets/images/icons/homepage_icons/create-league-icon-dark.svg',
    screen: const CreateLeaguePage(),
    subsection: "Lega",
  ),
  NavigationItem(
    title: "Cerca Lega",
    darkSvgIcon: 'assets/images/icons/homepage_icons/search-league-icon.svg',
    lightSvgIcon:
        'assets/images/icons/homepage_icons/search-league-icon-dark.svg',
    screen: const JoinLeaguePage(),
    subsection: "Lega",
  ),
];
