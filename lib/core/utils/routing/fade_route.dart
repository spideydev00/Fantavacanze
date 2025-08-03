import 'package:flutter/material.dart';

Route fadeRoute(
  MaterialPageRoute route, {
  Duration duration = const Duration(milliseconds: 300),
  Curve curve = Curves.easeIn,
}) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        route.builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation.drive(
          CurveTween(curve: curve).chain(Tween<double>(begin: 0.0, end: 1.0)),
        ),
        child: child,
      );
    },
    transitionDuration: duration,
  );
}
