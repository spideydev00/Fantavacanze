import 'package:fantavacanze_official/core/navigation/navigation_item.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/pages/home.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/pages/subpages/articles_page.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/pages/subpages/drink_games.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/pages/subpages/quick_challenge.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/create_league_page.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/join_league_page.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/leaderboard_page.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/memories_page.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/notes_page.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/rules_page.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/team_info_page.dart';
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
    screen: const QuickChallenge(),
    subsection: "Naviga",
  ),
  NavigationItem(
    title: "Giochi",
    darkSvgIcon: 'assets/images/icons/homepage_icons/drink-games-icon.svg',
    lightSvgIcon:
        'assets/images/icons/homepage_icons/drink-games-icon-dark.svg',
    screen: const DrinkGames(),
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

List<NavigationItem> participantNavbarItems = [
  NavigationItem(
    title: "Home",
    darkSvgIcon: 'assets/images/icons/homepage_icons/home-icon.svg',
    lightSvgIcon: 'assets/images/icons/homepage_icons/home-icon-dark.svg',
    screen: const HomePage(),
    subsection: "Naviga",
  ),
  NavigationItem(
    title: "Classifica",
    darkSvgIcon: 'assets/images/icons/homepage_icons/home-icon.svg',
    lightSvgIcon: 'assets/images/icons/homepage_icons/home-icon-dark.svg',
    screen: LeaderboardPage(),
    subsection: "Naviga",
  ),
  NavigationItem(
    title: "Sfida",
    darkSvgIcon: 'assets/images/icons/homepage_icons/thunder-icon-red.svg',
    lightSvgIcon: 'assets/images/icons/homepage_icons/thunder-icon-red.svg',
    screen: const QuickChallenge(),
    subsection: "Games",
  ),
  NavigationItem(
    title: "Giochi Alcolici",
    darkSvgIcon: 'assets/images/icons/homepage_icons/drink-games-icon.svg',
    lightSvgIcon:
        'assets/images/icons/homepage_icons/drink-games-icon-dark.svg',
    screen: const DrinkGames(),
    subsection: "Games",
  ),
  NavigationItem(
    title: "Regole",
    darkSvgIcon: 'assets/images/icons/homepage_icons/drink-games-icon.svg',
    lightSvgIcon:
        'assets/images/icons/homepage_icons/drink-games-icon-dark.svg',
    screen: const RulesPage(),
    subsection: "Naviga",
  ),
  NavigationItem(
    title: "La Mia Squadra",
    darkSvgIcon: 'assets/images/icons/homepage_icons/drink-games-icon.svg',
    lightSvgIcon:
        'assets/images/icons/homepage_icons/drink-games-icon-dark.svg',
    screen: const TeamInfoPage(),
    subsection: "Naviga",
  ),
  NavigationItem(
    title: "Ricordi",
    darkSvgIcon: 'assets/images/icons/homepage_icons/drink-games-icon.svg',
    lightSvgIcon:
        'assets/images/icons/homepage_icons/drink-games-icon-dark.svg',
    screen: const MemoriesPage(),
    subsection: "Naviga",
  ),
  NavigationItem(
    title: "Note",
    darkSvgIcon: 'assets/images/icons/homepage_icons/drink-games-icon.svg',
    lightSvgIcon:
        'assets/images/icons/homepage_icons/drink-games-icon-dark.svg',
    screen: const NotesPage(),
    subsection: "Naviga",
  ),
  NavigationItem(
    title: "Crea Lega",
    darkSvgIcon: 'assets/images/icons/homepage_icons/create-league-icon.svg',
    lightSvgIcon:
        'assets/images/icons/homepage_icons/create-league-icon-dark.svg',
    screen: const CreateLeaguePage(),
    subsection: "Nuova Lega",
  ),
  NavigationItem(
    title: "Cerca Lega",
    darkSvgIcon: 'assets/images/icons/homepage_icons/search-league-icon.svg',
    lightSvgIcon:
        'assets/images/icons/homepage_icons/search-league-icon-dark.svg',
    screen: const JoinLeaguePage(),
    subsection: "Nuova Lega",
  ),
  NavigationItem(
    title: "Articoli",
    darkSvgIcon: 'assets/images/icons/homepage_icons/drink-games-icon.svg',
    lightSvgIcon:
        'assets/images/icons/homepage_icons/drink-games-icon-dark.svg',
    screen: const ArticlesPage(),
    subsection: "Altro",
  ),
];
