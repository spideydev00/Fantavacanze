import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:flutter/material.dart';

class FsCreateButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const FsCreateButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: ColorPalette.fsGradients),
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
      ),
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: ThemeSizes.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
          ),
        ),
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: Loader(
                  color: Colors.white,
                ),
              )
            : Icon(
                Icons.rocket_launch_rounded,
                color: Colors.white,
              ),
        label: Text(
          isLoading ? 'Creazione...' : 'Crea la Lega!',
          style: context.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
