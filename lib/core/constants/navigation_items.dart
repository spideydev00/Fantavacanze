import 'package:fantavacanze_official/core/navigation/navigation_item.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/admin/admin_page.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/homepage/home.dart';
import 'package:fantavacanze_official/features/games/presentation/pages/drink_games.dart';
// import 'package:fantavacanze_official/features/games/presentation/pages/quick_challenge.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/create_league/create_league_page.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/join_league/search_league_page.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/leaderboard/leaderboard_page.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/memories/memories_page.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/notes/notes_page.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/rules/rules_page.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/team_info/team_info_page.dart';
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
  // NavigationItem(
  //   title: "Sfida",
  //   darkSvgIcon: 'assets/images/icons/homepage_icons/thunder-icon-red.svg',
  //   lightSvgIcon: 'assets/images/icons/homepage_icons/thunder-icon-red.svg',
  //   screen: const QuickChallenge(),
  //   subsection: "Naviga",
  // ),
  NavigationItem(
    title: "Giochi",
    darkSvgIcon: 'assets/images/icons/homepage_icons/drink-games-icon-red.svg',
    lightSvgIcon: 'assets/images/icons/homepage_icons/drink-games-icon-red.svg',
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
    screen: const SearchLeaguePage(),
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
    title: "Giochi",
    darkSvgIcon: 'assets/images/icons/homepage_icons/drink-games-icon-red.svg',
    lightSvgIcon: 'assets/images/icons/homepage_icons/drink-games-icon-red.svg',
    screen: const DrinkGames(),
    subsection: "Games",
  ),
  NavigationItem(
    title: "Classifica",
    darkSvgIcon: 'assets/images/icons/homepage_icons/rankings-icon.svg',
    lightSvgIcon: 'assets/images/icons/homepage_icons/rankings-icon-dark.svg',
    screen: LeaderboardPage(),
    subsection: "Naviga",
  ),
  // NavigationItem(
  //   title: "Sfida",
  //   darkSvgIcon: 'assets/images/icons/homepage_icons/thunder-icon-red.svg',
  //   lightSvgIcon: 'assets/images/icons/homepage_icons/thunder-icon-red.svg',
  //   screen: const QuickChallenge(),
  //   subsection: "Games",
  // ),
  NavigationItem(
    title: "Regole",
    darkSvgIcon: 'assets/images/icons/homepage_icons/rules-icon.svg',
    lightSvgIcon: 'assets/images/icons/homepage_icons/rules-icon-dark.svg',
    screen: const RulesPage(),
    subsection: "Naviga",
  ),
  NavigationItem(
    title: "La Mia Squadra",
    darkSvgIcon: 'assets/images/icons/homepage_icons/team-icon.svg',
    lightSvgIcon: 'assets/images/icons/homepage_icons/team-icon-dark.svg',
    screen: const TeamInfoPage(),
    subsection: "Naviga",
  ),
  NavigationItem(
    title: "Ricordi",
    darkSvgIcon: 'assets/images/icons/homepage_icons/memories-icon.svg',
    lightSvgIcon: 'assets/images/icons/homepage_icons/memories-icon-dark.svg',
    screen: const MemoriesPage(),
    subsection: "Naviga",
  ),
  NavigationItem(
    title: "Note",
    darkSvgIcon: 'assets/images/icons/homepage_icons/notes-icon.svg',
    lightSvgIcon: 'assets/images/icons/homepage_icons/notes-icon-dark.svg',
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
    screen: const SearchLeaguePage(),
    subsection: "Nuova Lega",
  ),
  NavigationItem(
    title: "Admin",
    darkSvgIcon: 'assets/images/icons/homepage_icons/admin-icon.svg',
    lightSvgIcon: 'assets/images/icons/homepage_icons/admin-icon-dark.svg',
    screen: const AdminPage(),
    subsection: "Gestione Lega",
    isAdminOnly: true,
  )
  //   title: "Articoli",
  //   darkSvgIcon: 'assets/images/icons/homepage_icons/articles-icon.svg',
  //   lightSvgIcon: 'assets/images/icons/homepage_icons/articles-icon-dark.svg',
  //   screen: const ArticlesPage(),
  //   subsection: "Altro",
  // ),
];
