import 'package:flutter/material.dart';

class QuickChallengePreview extends StatelessWidget {
  static get route =>
      MaterialPageRoute(builder: (context) => const QuickChallengePreview());
  const QuickChallengePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Gioca una sfida veloce'));
  }
}
