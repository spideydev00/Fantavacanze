import 'package:flutter/material.dart';

class JournalPage extends StatelessWidget {
  static Route get route =>
      MaterialPageRoute(builder: (context) => const JournalPage());
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Ultimi eventi della lega'));
  }
}
