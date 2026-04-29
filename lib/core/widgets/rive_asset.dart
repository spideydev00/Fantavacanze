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
  File? riveFile;
  RiveWidgetController? controller;
  BooleanInput? input; // <-- niente underscore, accessibile dalle sottoclassi

  @override
  void initState() {
    super.initState();
    _loadRiveFile();
  }

  Future<void> _loadRiveFile() async {
    final file = await File.asset(
      widget.path,
      riveFactory: Factory.rive,
    );

    if (file == null || !mounted) return;

    final c = RiveWidgetController(
      file,
      artboardSelector: ArtboardSelector.byName(widget.artboard),
      stateMachineSelector:
          StateMachineSelector.byName(widget.stateMachineName),
    );

    final i = c.stateMachine.boolean(widget.triggerValue);
    i?.value = widget.isActive;

    setState(() {
      riveFile = file;
      controller = c;
      input = i;
    });
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      input?.value = widget.isActive;
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    riveFile?.dispose();
    super.dispose();
  }

  Widget buildRiveAnimation() {
    if (controller == null) {
      return SizedBox(
        height: widget.height,
        width: widget.width,
      );
    }

    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: RiveWidget(
        controller: controller!,
        fit: Fit.contain,
      ),
    );
  }
}
