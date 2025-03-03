import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/get_rive_controller.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class RiveAsset extends StatefulWidget {
  final String artboard, stateMachineName, path, triggerValue;
  final String? title;
  final double additionalPadding, height, width;
  final bool isActive;
  final VoidCallback? onTap;

  const RiveAsset({
    super.key,
    required this.path,
    required this.artboard,
    required this.stateMachineName,
    this.triggerValue = "active",
    this.additionalPadding = 0,
    this.height = ThemeSizes.riveIcon,
    this.width = ThemeSizes.riveIcon,
    this.title,
    this.isActive = false,
    this.onTap,
  });

  @override
  State<RiveAsset> createState() => _RiveAssetState();
}

class _RiveAssetState extends State<RiveAsset> {
  SMIBool? input;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.onTap != null) widget.onTap!();

        input?.change(true);
        Future.delayed(
          const Duration(seconds: 1),
          () {
            input?.change(false);
          },
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: widget.isActive ? ThemeSizes.riveIconSm : 0,
            height: 4,
            decoration: BoxDecoration(
              color:
                  widget.isActive ? ColorPalette.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 1.5),
          Padding(
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
                  setState(
                    () {
                      input =
                          controller.findSMI(widget.triggerValue) as SMIBool?;
                    },
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 3),
          Padding(
            padding: EdgeInsets.only(bottom: widget.additionalPadding),
            child: widget.title != null
                ? Text(
                    widget.title!,
                    style: context.textTheme.labelSmall!.copyWith(
                      fontSize: ThemeSizes.labelSm,
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
