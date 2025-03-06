// rankings_page.dart
import 'package:flutter/material.dart';

class DrinkGamesPreview extends StatelessWidget {
  static get route =>
      MaterialPageRoute(builder: (context) => const DrinkGamesPreview());
  const DrinkGamesPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Giochi Alcolici preview'));
  }
}
