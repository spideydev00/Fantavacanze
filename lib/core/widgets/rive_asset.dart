import 'package:fantavacanze_official/core/utils/get_rive_controller.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

abstract class RiveAsset extends StatefulWidget {
  final String path, artboard, stateMachineName, triggerValue;
  final double height, width;
  final bool isActive;
  final VoidCallback onTap;

  const RiveAsset({
    super.key,
    required this.onTap,
    required this.path,
    required this.artboard,
    required this.stateMachineName,
    this.triggerValue = "active",
    required this.height,
    required this.width,
    this.isActive = false,
  });

  @override
  RiveAssetState createState();
}

abstract class RiveAssetState<T extends RiveAsset> extends State<T> {
  SMIBool? input;
  List<StateMachineController> controllers = [];

  void _findInput(StateMachineController controller) {
    setState(() {
      controllers.add(controller);
      input = controller.findSMI(widget.triggerValue) as SMIBool?;
    });
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget buildRiveAnimation() {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: RiveAnimation.asset(
        widget.path,
        artboard: widget.artboard,
        onInit: (artboard) {
          final controller = getRiveController(
            artboard,
            stateMachineName: widget.stateMachineName,
          );
          _findInput(controller);
        },
      ),
    );
  }
}
