import 'package:flutter/material.dart';

class DrinkGamesSelection extends StatelessWidget {
  static const String routeName = '/drink_games_selection';

  static get route => MaterialPageRoute(
        builder: (context) => const DrinkGamesSelection(),
        settings: const RouteSettings(name: routeName),
      );
  const DrinkGamesSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Giochi Alcolici Selection'));
  }
}
