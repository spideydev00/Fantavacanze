import 'package:flutter/material.dart';

class QuickChallenge extends StatelessWidget {
  static MaterialPageRoute<dynamic> get route =>
      MaterialPageRoute(builder: (context) => const QuickChallenge());
  const QuickChallenge({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Gioca una sfida veloce'));
  }
}
