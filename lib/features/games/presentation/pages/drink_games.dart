import 'package:flutter/material.dart';

class DrinkGames extends StatelessWidget {
  static get route =>
      MaterialPageRoute(builder: (context) => const DrinkGames());
  const DrinkGames({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Giochi Alcolici preview'));
  }
}
