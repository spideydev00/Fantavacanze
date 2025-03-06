import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/get_rive_controller.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class RiveBottomNavigationAsset extends StatefulWidget {
  final String artboard, stateMachineName, path, triggerValue, title;
  final double additionalPadding, height, width;
  final bool isActive;
  final VoidCallback? onTap;

  const RiveBottomNavigationAsset({
    super.key,
    required this.path,
    required this.artboard,
    required this.stateMachineName,
    this.triggerValue = "active",
    this.additionalPadding = 0,
    this.height = ThemeSizes.icon,
    this.width = ThemeSizes.icon,
    required this.title,
    this.isActive = false,
    this.onTap,
  });

  @override
  State<RiveBottomNavigationAsset> createState() =>
      _RiveBottomNavigationAssetState();
}

class _RiveBottomNavigationAssetState extends State<RiveBottomNavigationAsset> {
  SMIBool? input;
  List<StateMachineController> controllers = [];

  void _findInput(StateMachineController controller) {
    setState(() {
      controllers.add(controller);
      input = controller.findSMI(widget.triggerValue) as SMIBool?;
    });
  }

  void _triggerAnimation() {
    input?.change(true);
    Future.delayed(const Duration(seconds: 1), () {
      input?.change(false);
    });
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // AnimatedContainer moderno sopra l'icona
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: widget.isActive ? 5 : 2,
          width: widget.width * 0.6,
          decoration: BoxDecoration(
            color: widget.isActive ? ColorPalette.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusSm),
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () {
            widget.onTap?.call();
            _triggerAnimation();
          },
          child: Column(
            children: [
              Opacity(
                opacity: widget.isActive ? 1 : 0.5,
                child: Padding(
                  padding: EdgeInsets.only(bottom: widget.additionalPadding),
                  child: SizedBox(
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
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.title,
                style: context.textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
