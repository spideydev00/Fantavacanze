import 'package:fantavacanze_official/core/navigation/navigation_item.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/pages/create_league.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/pages/home.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/pages/join_league.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/pages/previews/become_premium_preview.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/pages/previews/drink_games_preview.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/pages/previews/quick_challenge_preview.dart';

List<NavigationItem> nonParticipantNavbarItems = [
  NavigationItem(
    title: "Home",
    svgIcon: 'assets/images/icons/homepage_icons/home-icon.svg',
    screen: const HomePage(),
  ),
  NavigationItem(
    title: "Sfida",
    svgIcon: 'assets/images/icons/homepage_icons/thunder-icon.svg',
    screen: const QuickChallengePreview(),
  ),
  NavigationItem(
    title: "Giochi",
    svgIcon: 'assets/images/icons/homepage_icons/drink-games-icon.svg',
    screen: const DrinkGamesPreview(),
  ),
  NavigationItem(
    title: "Crea Lega",
    svgIcon: 'assets/images/icons/homepage_icons/create-league-icon.svg',
    screen: const CreateLeaguePage(),
  ),
  NavigationItem(
    title: "Cerca Lega",
    svgIcon: 'assets/images/icons/homepage_icons/search-league-icon.svg',
    screen: const JoinLeaguePage(),
  ),
  NavigationItem(
    title: "Premium",
    svgIcon: 'assets/images/icons/homepage_icons/premium-icon.svg',
    screen: const BecomePremiumPreview(),
  ),
];
