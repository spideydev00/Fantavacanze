import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/rive_asset.dart';
import 'package:flutter/material.dart';

class RiveBottomNavigationAsset extends RiveAsset {
  final String title;
  final double additionalPadding;

  const RiveBottomNavigationAsset({
    super.key,
    required super.path,
    required super.artboard,
    required super.stateMachineName,
    super.triggerValue = "active",
    super.height = ThemeSizes.icon,
    super.width = ThemeSizes.icon,
    super.isActive = false,
    required super.onTap,
    required this.title,
    this.additionalPadding = 0,
  });

  @override
  RiveAssetState<RiveBottomNavigationAsset> createState() =>
      _RiveBottomNavigationAssetState();
}

class _RiveBottomNavigationAssetState
    extends RiveAssetState<RiveBottomNavigationAsset> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
            widget.onTap;
            triggerAnimation();
          },
          child: Column(
            children: [
              Opacity(
                opacity: widget.isActive ? 1 : 0.5,
                child: Padding(
                  padding: EdgeInsets.only(bottom: widget.additionalPadding),
                  child: buildRiveAnimation(),
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

  void triggerAnimation() {
    input?.change(true);
    Future.delayed(
      const Duration(seconds: 1),
      () {
        input?.change(false);
      },
    );
  }
}
