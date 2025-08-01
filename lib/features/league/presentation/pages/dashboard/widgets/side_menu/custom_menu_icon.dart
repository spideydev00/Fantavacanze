import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/rive_asset.dart';
import 'package:flutter/material.dart';

class CustomMenuIcon extends RiveAsset {
  const CustomMenuIcon({
    super.key,
    required super.path,
    required super.artboard,
    required super.stateMachineName,
    super.triggerValue = "active",
    super.height = ThemeSizes.iconSm,
    super.width = ThemeSizes.iconSm,
    required super.onTap,
    super.isActive = false,
  });

  @override
  RiveAssetState<CustomMenuIcon> createState() => _CustomMenuIconState();
}

class _CustomMenuIconState extends RiveAssetState<CustomMenuIcon> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: ThemeSizes.lg + 6),
      child: GestureDetector(
        onTap: () {
          widget.onTap.call();
        },
        child: buildRiveAnimation(),
      ),
    );
  }
}
