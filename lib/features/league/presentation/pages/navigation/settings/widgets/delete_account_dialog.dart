import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/show_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:fantavacanze_official/features/auth/presentation/pages/social_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/main.dart';

class DeleteAccountDialog extends StatefulWidget {
  static Future<void> show(BuildContext context) async {
    return showDialog(
      context: context,
      useRootNavigator: true,
      builder: (_) => BlocProvider.value(
        value: context.read<AppUserCubit>(),
        child: const DeleteAccountDialog(),
      ),
    );
  }

  const DeleteAccountDialog({super.key});

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final _textController = TextEditingController();
  bool _isLoading = false;
  bool _isConfirmed = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _checkConfirmation(String value) {
    setState(() {
      _isConfirmed = value.trim().toLowerCase() == 'elimina';
    });
  }

  Future<void> _deleteAccount() async {
    if (!_isConfirmed) return;
    setState(() => _isLoading = true);

    try {
      late bool success;
      await context.read<AppLeagueCubit>().clearCache();

      // Call deleteAccount and get success status
      if (mounted) {
        success = await context.read<AppUserCubit>().deleteAccount();
      }

      if (success) {
        // Navigate to login screen only on success
        navigatorKey.currentState!.pushAndRemoveUntil(
          SocialLoginPage.route,
          (route) => false,
        );
      }
    } catch (e) {
      showSnackBar(e.toString(), color: ColorPalette.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConfirmationDialog(
      title: 'Elimina Account',
      message:
          'Questa azione è irreversibile! Tutti i tuoi dati, leghe, partecipazioni e contenuti saranno eliminati permanentemente.',
      confirmText: 'Elimina',
      cancelText: 'Annulla',
      icon: Icons.warning_amber_rounded,
      iconColor: ColorPalette.error,
      onConfirm: _isConfirmed ? _deleteAccount : () {},
      isPrimaryAction: false,
      elevatedButtonStyle: ElevatedButton.styleFrom(
        backgroundColor: ColorPalette.error,
        disabledBackgroundColor: ColorPalette.error.withValues(alpha: 0.3),
      ),
      additionalContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Per confermare, scrivi "elimina" nel campo sottostante:',
            style: context.textTheme.bodySmall,
          ),
          const SizedBox(height: ThemeSizes.sm),
          TextField(
            controller: _textController,
            decoration: InputDecoration(
              fillColor: context.bgColor,
              hintText: 'elimina',
              contentPadding: EdgeInsets.symmetric(
                horizontal: ThemeSizes.md,
                vertical: ThemeSizes.sm,
              ),
            ),
            onChanged: _checkConfirmation,
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(top: ThemeSizes.md),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
