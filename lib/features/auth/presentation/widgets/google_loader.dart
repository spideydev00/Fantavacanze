import 'package:fantavacanze_official/core/utils/get_rive_controller.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class GoogleLoader extends StatelessWidget {
  const GoogleLoader({super.key});

  _onRiveInit(Artboard artboard) {
    final controller = getRiveController(artboard);

    final animationTrigger = controller.findSMI("active") as SMIBool;
    animationTrigger.value = true;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      height: 130,
      child: RiveAnimation.asset(
        "assets/animations/rive/material_loader.riv",
        onInit: (artboard) => _onRiveInit(artboard),
      ),
    );
  }
}
