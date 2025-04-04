import 'package:flutter/material.dart';

/* nel file in cui si utilizza bisogna: 
1. Creare _currentIndex
2. Far aumentare il valore dell'index in un arco di tempo(widget Timer.periodic)
*/
class AnimatedImage extends StatelessWidget {
  const AnimatedImage(
      {super.key,
      required this.currentIndex,
      required this.imageIndex,
      required this.imagePath});

  final int currentIndex;
  final int imageIndex;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedOpacity(
        opacity: currentIndex == imageIndex ? 1 : 0,
        duration: const Duration(
          seconds: 1,
        ),
        curve: Curves.linear,
        child: Image.network(
          imagePath,
        ),
      ),
    );
  }
}
