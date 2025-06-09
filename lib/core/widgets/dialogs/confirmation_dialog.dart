import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/info_banner.dart';
import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  /// The primary title text of the dialog
  final String title;

  /// The descriptive message shown to the user
  final String message;

  /// Callback executed when user confirms the action
  final VoidCallback onConfirm;

  /// Callback executed when user cancels the action (optional)
  final VoidCallback? onCancel;

  /// Text for the confirm button (default: "Conferma")
  final String confirmText;

  /// Text for the cancel button (default: "Annulla")
  final String cancelText;

  /// Icon to display at the top of the dialog
  final IconData icon;

  /// Color of the icon and its background
  final Color iconColor;

  /// Whether the icon should use a circular background
  final bool useIconBackground;

  /// Additional content to display below the message (optional)
  final Widget? additionalContent;

  /// Whether the confirm button should be highlighted as primary
  final bool isPrimaryAction;

  final ButtonStyle? outlinedButtonStyle;

  final ButtonStyle? elevatedButtonStyle;

  final Color? backgroundColor;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.backgroundColor,
    this.onCancel,
    this.confirmText = 'Conferma',
    this.cancelText = 'Annulla',
    this.icon = Icons.check_circle_outline,
    this.iconColor = Colors.green,
    this.useIconBackground = true,
    this.additionalContent,
    this.isPrimaryAction = true,
    this.outlinedButtonStyle,
    this.elevatedButtonStyle,
  });

  /// Factory constructor for creating an exit league confirmation dialog
  factory ConfirmationDialog.exitLeague({
    required VoidCallback onExit,
  }) {
    return ConfirmationDialog(
      title: 'Lascia la Lega',
      message:
          'Sei sicuro di voler uscire da questa lega? Questa azione non può essere annullata.',
      confirmText: 'Esci',
      icon: Icons.warning_amber_rounded,
      iconColor: Colors.red,
      onConfirm: onExit,
    );
  }

  /// Factory constructor for creating an logout confirmation dialog
  factory ConfirmationDialog.logOut({
    required VoidCallback onExit,
  }) {
    return ConfirmationDialog(
      title: 'Esci',
      message: 'Sei sicuro di voler uscire dal tuo account?',
      confirmText: 'Esci',
      icon: Icons.warning_amber_rounded,
      iconColor: Colors.red,
      onConfirm: onExit,
    );
  }

  /// Factory constructor for creating a delete confirmation dialog
  factory ConfirmationDialog.delete({
    required String itemType,
    required VoidCallback onDelete,
    String? customMessage,
  }) {
    return ConfirmationDialog(
      title: 'Elimina $itemType',
      message: customMessage ??
          'Sei sicuro di voler eliminare questo $itemType? Questa azione non può essere annullata.',
      confirmText: 'Elimina',
      icon: Icons.delete_outline,
      iconColor: Colors.red,
      onConfirm: onDelete,
    );
  }

  /// Factory constructor for creating a rule deletion dialog
  factory ConfirmationDialog.deleteRule({
    required String ruleName,
    required VoidCallback onDelete,
  }) {
    return ConfirmationDialog(
      title: 'Elimina Regola',
      message:
          'Sei sicuro di voler eliminare la regola "$ruleName"? Questa azione non può essere annullata.',
      confirmText: 'Elimina',
      icon: Icons.delete_outline,
      iconColor: ColorPalette.error,
      onConfirm: onDelete,
    );
  }

  /// Factory constructor for creating a delete memory confirmation dialog
  factory ConfirmationDialog.deleteMemory({
    required VoidCallback onDelete,
  }) {
    return ConfirmationDialog(
      title: 'Elimina Ricordo',
      message:
          'Sei sicuro di voler eliminare questo ricordo? Questa azione non può essere annullata.',
      confirmText: 'Elimina',
      icon: Icons.delete_outline,
      iconColor: ColorPalette.error,
      onConfirm: onDelete,
    );
  }

  /// Factory constructor for creating a "league found" confirmation dialog
  factory ConfirmationDialog.leagueFound({
    required String leagueName,
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
    String? description,
    Color? iconColor,
    IconData? icon,
    ButtonStyle? outlinedButtonStyle,
    ButtonStyle? elevatedButtonStyle,
  }) {
    return ConfirmationDialog(
      title: 'Lega Trovata',
      message: 'È "$leagueName" la lega che stavi cercando?',
      confirmText: 'Sì',
      cancelText: 'No',
      icon: icon ?? Icons.emoji_events_rounded,
      iconColor: iconColor ?? ColorPalette.info,
      onConfirm: onConfirm,
      outlinedButtonStyle: outlinedButtonStyle,
      elevatedButtonStyle: elevatedButtonStyle,
      isPrimaryAction: true,
    );
  }

  /// Factory constructor for creating a challenge completion confirmation dialog
  factory ConfirmationDialog.completeChallenge({
    required String challengeName,
    required Function onComplete,
  }) {
    return ConfirmationDialog(
      title: 'Completare Obiettivo',
      message: 'Confermi di aver completato l\'obiettivo?\n\n"$challengeName"',
      confirmText: 'Completa',
      cancelText: 'Annulla',
      icon: Icons.check_circle_rounded,
      iconColor: ColorPalette.success,
      useIconBackground: true,
      isPrimaryAction: true,
      elevatedButtonStyle: ElevatedButton.styleFrom(
        backgroundColor: ColorPalette.success,
      ),
      additionalContent: InfoBanner(
        message:
            "Se sei un admin, verrà già aggiornata la classifica. In alternativa, verrà inviata una notifica agli admin.",
        icon: Icons.info_outline_rounded,
        color: ColorPalette.success,
      ),
      onConfirm: () => onComplete(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: ThemeSizes.lg,
        vertical: ThemeSizes.md,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? context.secondaryBgColor,
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(ThemeSizes.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (useIconBackground)
                  Container(
                    padding: const EdgeInsets.all(ThemeSizes.md),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 38,
                    ),
                  )
                else
                  Icon(
                    icon,
                    color: iconColor,
                    size: 48,
                  ),
                const SizedBox(height: ThemeSizes.md),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: ThemeSizes.sm),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.textSecondaryColor,
                    fontSize: 14,
                  ),
                ),
                if (additionalContent != null) ...[
                  const SizedBox(height: ThemeSizes.md),
                  additionalContent!,
                ],
                const SizedBox(height: ThemeSizes.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: outlinedButtonStyle,
                        onPressed: () {
                          Navigator.pop(context);
                          onCancel?.call(); // Call onCancel if provided
                        },
                        child: Text(cancelText),
                      ),
                    ),
                    const SizedBox(width: ThemeSizes.md),
                    Expanded(
                      child: ElevatedButton(
                        style: elevatedButtonStyle,
                        onPressed: () {
                          Navigator.pop(context);
                          onConfirm();
                        },
                        child: Text(confirmText),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
