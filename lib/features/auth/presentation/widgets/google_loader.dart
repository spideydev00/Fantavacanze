import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class GoogleLoader extends StatefulWidget {
  const GoogleLoader({super.key});

  @override
  State<GoogleLoader> createState() => _GoogleLoaderState();
}

class _GoogleLoaderState extends State<GoogleLoader> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      child: RiveAnimation.asset("assets/animations/rive/google_loading.riv"),
    );
  }
}

void _riveAnimationInit(Artboard art) {}
