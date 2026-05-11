import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class GoogleLoader extends StatefulWidget {
  const GoogleLoader({super.key});

  @override
  State<GoogleLoader> createState() => _GoogleLoaderState();
}

class _GoogleLoaderState extends State<GoogleLoader> {
  late final FileLoader _fileLoader;

  @override
  void initState() {
    super.initState();
    _fileLoader = FileLoader.fromAsset(
      'assets/animations/rive/material_loader.riv',
      riveFactory: Factory.rive,
    );
  }

  @override
  void dispose() {
    _fileLoader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      height: 130,
      child: RiveWidgetBuilder(
        fileLoader: _fileLoader,
        builder: (context, state) => switch (state) {
          RiveLoading() => const SizedBox.shrink(),
          RiveFailed() => const Icon(Icons.error),
          RiveLoaded() => RiveWidget(
              controller: _setupController(state.file),
              fit: Fit.contain,
            ),
        },
      ),
    );
  }

  RiveWidgetController _setupController(File file) {
    final controller = RiveWidgetController(file);
    // ignore: deprecated_member_use
    final trigger = controller.stateMachine.boolean("active");
    trigger?.value = true;
    return controller;
  }
}
