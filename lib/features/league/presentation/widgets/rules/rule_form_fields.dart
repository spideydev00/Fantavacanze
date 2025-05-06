import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule.dart';

/// A component that provides form fields for rule creation/editing
///
/// This component displays name and points fields for rules,
/// with appropriate validation and styling.
class RuleFormFields extends StatelessWidget {
  /// The form key for validation
  final GlobalKey<FormState> formKey;

  /// Controller for the rule name field
  final TextEditingController nameController;

  /// Controller for the points field
  final TextEditingController pointsController;

  /// The rule type (bonus or malus)
  final RuleType ruleType;

  /// Optional info message to show below the fields
  final String? infoMessage;

  /// Optional styles for the fields
  final InputDecoration? nameDecoration;
  final InputDecoration? pointsDecoration;

  const RuleFormFields({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.pointsController,
    required this.ruleType,
    this.infoMessage,
    this.nameDecoration,
    this.pointsDecoration,
  });

  @override
  Widget build(BuildContext context) {
    // Determine appropriate color based on rule type
    final color =
        ruleType == RuleType.bonus ? ColorPalette.success : ColorPalette.error;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name field
          TextFormField(
            controller: nameController,
            cursorColor: context.textPrimaryColor,
            style: TextStyle(
              color: context.textPrimaryColor,
            ),
            decoration: nameDecoration ??
                InputDecoration(
                  labelText: 'Nome',
                  labelStyle: TextStyle(
                    color: context.textPrimaryColor,
                  ),
                  hintText: 'Inserisci il nome della regola',
                  hintStyle: TextStyle(
                    color: context.textSecondaryColor.withValues(alpha: 0.7),
                  ),
                  prefixIcon: Icon(
                    Icons.title,
                    color: context.textSecondaryColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(ThemeSizes.borderRadiusLg),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(ThemeSizes.borderRadiusLg),
                    borderSide: BorderSide(
                      color: color,
                      width: 2.0,
                    ),
                  ),
                ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Inserisci un nome per la regola';
              }
              return null;
            },
          ),

          const SizedBox(height: ThemeSizes.md),

          // Points field
          TextFormField(
            controller: pointsController,
            cursorColor: context.textPrimaryColor,
            style: TextStyle(
              color: context.textPrimaryColor,
            ),
            decoration: pointsDecoration ??
                InputDecoration(
                  labelText: 'Punti',
                  labelStyle: TextStyle(
                    color: context.textPrimaryColor,
                  ),
                  hintText: 'Inserisci il valore dei punti',
                  hintStyle: TextStyle(
                    color: context.textSecondaryColor.withValues(alpha: 0.7),
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(ThemeSizes.borderRadiusLg),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(ThemeSizes.borderRadiusLg),
                    borderSide: BorderSide(
                      color: color,
                      width: 2.0,
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.leaderboard,
                    color: context.textSecondaryColor,
                  ),
                ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Inserisci un valore';
              }
              try {
                double.parse(value);
                return null;
              } catch (e) {
                return 'Inserisci un numero valido';
              }
            },
          ),

          // Optional info message
          if (infoMessage != null) ...[
            const SizedBox(height: ThemeSizes.lg),
            Container(
              padding: const EdgeInsets.all(ThemeSizes.sm),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
                border: Border.all(
                  color: color.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: color,
                    size: 18,
                  ),
                  const SizedBox(width: ThemeSizes.sm),
                  Expanded(
                    child: Text(
                      infoMessage!,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
