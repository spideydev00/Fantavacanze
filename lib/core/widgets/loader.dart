import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  final Color color;
  const Loader({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: color,
      ),
    );
  }
}
