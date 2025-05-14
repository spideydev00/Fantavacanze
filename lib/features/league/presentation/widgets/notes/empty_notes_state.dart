import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

class EmptyNotesState extends StatelessWidget {
  final String message;
  final IconData icon;
  final double iconSize;
  final VoidCallback? onAddTap;
  final String? addButtonText;
  final double height;

  const EmptyNotesState({
    super.key,
    this.message = 'Nessuna nota ancora',
    this.icon = Icons.note_alt_outlined,
    this.iconSize = 64,
    this.onAddTap,
    this.addButtonText,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: context.textSecondaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: ThemeSizes.md),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                color: context.textSecondaryColor,
              ),
            ),
            if (onAddTap != null) ...[
              const SizedBox(height: ThemeSizes.lg),
              ElevatedButton.icon(
                onPressed: onAddTap,
                icon: const Icon(Icons.add),
                label: Text(addButtonText ?? 'Aggiungi una nota'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
