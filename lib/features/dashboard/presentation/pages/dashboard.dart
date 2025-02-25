import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  static get route =>
      MaterialPageRoute(builder: (context) => const DashboardScreen());
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Welcome",
        ),
      ),
    );
  }
}
