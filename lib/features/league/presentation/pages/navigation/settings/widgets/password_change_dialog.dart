import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/show-snackbar-or-paywall/show_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:fantavacanze_official/features/auth/presentation/pages/social_login.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/cloudflare_turnstile_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/main.dart'; // per navigatorKey

class PasswordChangeDialog extends StatefulWidget {
  static Future<void> show(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<AppUserCubit>(),
        child: const PasswordChangeDialog(),
      ),
    );
  }

  const PasswordChangeDialog({super.key});

  @override
  State<PasswordChangeDialog> createState() => _PasswordChangeDialogState();
}

class _PasswordChangeDialogState extends State<PasswordChangeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  String _captchaToken = "";

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (_formKey.currentState?.validate() != true) return;
    if (_captchaToken.isEmpty) {
      showSnackBar('Completa la verifica CAPTCHA', color: ColorPalette.warning);
      return;
    }
    setState(() => _isLoading = true);

    try {
      await context.read<AppUserCubit>().updatePassword(
            _currentPasswordController.text,
            _newPasswordController.text,
            _captchaToken,
          );

      showSnackBar(
        'Password aggiornata con successo! Rieffettua il login.',
        color: ColorPalette.success,
      );

      // chiudo il dialog
      navigatorKey.currentState!.pop();

      // ripulisco tutta la stack e porto al login
      navigatorKey.currentState!.pushAndRemoveUntil(
        SocialLoginPage.route,
        (route) => false,
      );
    } catch (e) {
      setState(() => _isLoading = false);
      showSnackBar('Errore: ${e.toString()}', color: ColorPalette.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConfirmationDialog(
      title: 'Modifica Password',
      message: 'Inserisci la tua password attuale e la nuova password',
      confirmText: 'Aggiorna',
      cancelText: 'Annulla',
      icon: Icons.password,
      iconColor: context.primaryColor,
      onConfirm: _updatePassword,
      additionalContent: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _currentPasswordController,
              decoration: InputDecoration(
                fillColor: context.bgColor,
                labelText: 'Password attuale',
                suffixIcon: IconButton(
                  icon: Icon(
                    _showCurrentPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () => setState(
                      () => _showCurrentPassword = !_showCurrentPassword),
                ),
              ),
              obscureText: !_showCurrentPassword,
              validator: (v) => (v == null || v.isEmpty)
                  ? 'Inserisci la password attuale'
                  : null,
            ),
            const SizedBox(height: ThemeSizes.md),
            TextFormField(
              controller: _newPasswordController,
              decoration: InputDecoration(
                fillColor: context.bgColor,
                labelText: 'Nuova password',
                suffixIcon: IconButton(
                  icon: Icon(_showNewPassword
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () =>
                      setState(() => _showNewPassword = !_showNewPassword),
                ),
              ),
              obscureText: !_showNewPassword,
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Inserisci la nuova password';
                }
                if (v.length < 6) {
                  return 'La password deve avere almeno 6 caratteri';
                }
                return null;
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                'La password deve contenere almeno:\n'
                '• Una lettera minuscola (a-z)\n'
                '• Una lettera maiuscola (A-Z)\n'
                '• Un numero (0-9)\n',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.textSecondaryColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: ThemeSizes.sm),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                fillColor: context.bgColor,
                labelText: 'Conferma password',
                suffixIcon: IconButton(
                  icon: Icon(_showConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () => setState(
                      () => _showConfirmPassword = !_showConfirmPassword),
                ),
              ),
              obscureText: !_showConfirmPassword,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Conferma la nuova password';
                if (v != _newPasswordController.text) {
                  return 'Le password non corrispondono';
                }
                return null;
              },
            ),
            const SizedBox(height: ThemeSizes.md),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: ThemeSizes.sm),
              child: CloudflareTurnstileWidget(
                onTokenReceived: (token) =>
                    setState(() => _captchaToken = token),
              ),
            ),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.only(top: ThemeSizes.md),
                child: Loader(color: context.primaryColor),
              ),
          ],
        ),
      ),
    );
  }
}
