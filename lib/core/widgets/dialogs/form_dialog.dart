import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/rule_dialog_header.dart';

/// A generic form dialog with customizable header, content and actions
class FormDialog extends StatelessWidget {
  /// The title of the dialog
  final String title;

  /// The rule type (affects the icon color)
  final RuleType ruleType;

  /// The form content
  final Widget content;

  /// Primary action button text
  final String primaryActionText;

  /// Secondary action button text (usually "Cancel")
  final String secondaryActionText;

  /// Callback for the primary action
  final VoidCallback onPrimaryAction;

  /// Optional callback for the secondary action
  final VoidCallback? onSecondaryAction;

  /// Form key for validation
  final GlobalKey<FormState> formKey;

  const FormDialog({
    super.key,
    required this.title,
    required this.ruleType,
    required this.content,
    required this.primaryActionText,
    this.secondaryActionText = 'Annulla',
    required this.onPrimaryAction,
    this.onSecondaryAction,
    required this.formKey,
  });

  /// Factory constructor for rule forms
  factory FormDialog.ruleForm({
    required String title,
    required bool isBonus,
    required Widget content,
    required String primaryActionText,
    required VoidCallback onPrimaryAction,
    required GlobalKey<FormState> formKey,
  }) {
    return FormDialog(
      title: title,
      ruleType: isBonus ? RuleType.bonus : RuleType.malus,
      content: content,
      primaryActionText: primaryActionText,
      onPrimaryAction: onPrimaryAction,
      formKey: formKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final screenHeight = MediaQuery.of(context).size.height;
    final availableHeight = screenHeight - viewInsets.bottom - 80;

    return Stack(
      children: [
        Positioned.fill(
          child: Container(color: Colors.black.withValues(alpha: 0.5)),
        ),
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
          ),
          elevation: 5,
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.only(
            left: ThemeSizes.md,
            right: ThemeSizes.md,
            top: viewInsets.bottom > 0 ? ThemeSizes.md : ThemeSizes.lg,
            bottom: ThemeSizes.lg,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            constraints: BoxConstraints(
              maxHeight: availableHeight,
            ),
            decoration: BoxDecoration(
              color: context.bgColor,
              borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  spreadRadius: 1,
                  blurRadius: 10,
                )
              ],
            ),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.all(ThemeSizes.md),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.only(
                          top: ThemeSizes.sm,
                          bottom: ThemeSizes.md,
                        ),
                        child: RuleDialogHeader(
                          title: title,
                          ruleType: ruleType,
                          showCloseButton: true,
                          onClose: () => Navigator.pop(context),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: ThemeSizes.md,
                        ),
                        child: content,
                      ),
                      // Actions
                      Padding(
                        padding: const EdgeInsets.only(
                          top: ThemeSizes.lg,
                          bottom: ThemeSizes.sm,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: onSecondaryAction ??
                                  () => Navigator.pop(context),
                              child: Text(
                                secondaryActionText,
                              ),
                            ),
                            const SizedBox(width: ThemeSizes.md),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: onPrimaryAction,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ruleType == RuleType.bonus
                                      ? ColorPalette.success
                                      : ColorPalette.error,
                                ),
                                child: Text(primaryActionText),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
