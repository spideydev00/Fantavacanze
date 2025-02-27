import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/get_rive_controller.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class RiveAsset extends StatefulWidget {
  final String artboard, stateMachineName, path, triggerValue;
  final String? title;
  final double additionalPadding, height, width;

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
        input?.change(true);
        //wait 1 second...
        Future.delayed(
          Duration(seconds: 1),
          () {
            //stop animation
            input?.change(false);
          },
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          SizedBox(height: 3),
          Padding(
            padding: EdgeInsets.only(bottom: widget.additionalPadding),
            child: widget.title != null
                ? Text(
                    widget.title!,
                    style: context.textTheme.labelSmall,
                  )
                : null,
          )
        ],
      ),
    );
  }
}
