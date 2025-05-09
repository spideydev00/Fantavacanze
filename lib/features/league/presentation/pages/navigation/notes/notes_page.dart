import 'package:flutter/material.dart';

class NotesPage extends StatelessWidget {
  static Route get route =>
      MaterialPageRoute(builder: (context) => const NotesPage());
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Note'));
  }
}
