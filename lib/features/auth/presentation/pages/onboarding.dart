import 'package:flutter/material.dart';

class OnBoardingPage extends StatelessWidget {
  static get route =>
      MaterialPageRoute(builder: (context) => const OnBoardingPage());
  const OnBoardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Welcome")),
    );
  }
}
