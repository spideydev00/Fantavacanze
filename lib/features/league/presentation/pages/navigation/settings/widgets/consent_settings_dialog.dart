import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:fantavacanze_official/features/auth/presentation/pages/social_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/main.dart';

class ConsentSettingsDialog extends StatefulWidget {
  static Future<void> show(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (_) => const ConsentSettingsDialog(),
    );
  }

  const ConsentSettingsDialog({super.key});

  @override
  State<ConsentSettingsDialog> createState() => _ConsentSettingsDialogState();
}

class _ConsentSettingsDialogState extends State<ConsentSettingsDialog> {
  late bool _isAdult;
  late bool _isTermsAccepted;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final userState = context.read<AppUserCubit>().state;
    if (userState is AppUserIsLoggedIn) {
      _isAdult = userState.user.isAdult;
      _isTermsAccepted = userState.user.isTermsAccepted;
    } else {
      _isAdult = true;
      _isTermsAccepted = true;
    }
  }

  void _updateIsAdult(bool value) {
    setState(() {
      _isAdult = value;
      _hasChanges = true;
    });
  }

  void _updateIsTermsAccepted(bool value) {
    setState(() {
      _isTermsAccepted = value;
      _hasChanges = true;
    });
  }

  Future<void> _saveChanges() async {
    final cubit = context.read<AppUserCubit>();

    if (!_isAdult || !_isTermsAccepted) {
      // First remove consents, which will then trigger logout
      await cubit.removeConsents(
        isAdult: _isAdult,
        isTermsAccepted: _isTermsAccepted,
      );

      // chiudo il dialog
      navigatorKey.currentState!.pop();

      // ripulisco lo stack portando a login
      navigatorKey.currentState!.pushAndRemoveUntil(
        SocialLoginPage.route,
        (route) => false,
      );
    } else {
      // solo chiudi il dialog
      navigatorKey.currentState!.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConfirmationDialog(
      title: 'Modifica Consensi',
      message:
          'La modifica di questi consensi potrebbe richiedere il logout. Assicurati di comprendere le implicazioni prima di procedere.',
      confirmText: 'Salva',
      cancelText: 'Annulla',
      icon: Icons.gpp_good,
      iconColor: context.primaryColor,
      onConfirm: _hasChanges ? _saveChanges : () {},
      additionalContent: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Adult Consent
          Container(
            decoration: BoxDecoration(
              color: context.bgColor,
              borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
            ),
            margin: const EdgeInsets.only(bottom: ThemeSizes.sm),
            child: SwitchListTile(
              title: Text(
                'Confermo di avere almeno 18 anni',
                style: context.textTheme.bodyMedium,
              ),
              value: _isAdult,
              onChanged: _updateIsAdult,
              activeColor: context.primaryColor,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: ThemeSizes.md),
              controlAffinity: ListTileControlAffinity.trailing,
              dense: true,
            ),
          ),

          // Terms Consent
          Container(
            decoration: BoxDecoration(
              color: context.bgColor,
              borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
            ),
            margin: const EdgeInsets.only(bottom: ThemeSizes.md),
            child: SwitchListTile(
              title: Text(
                'Accetto i termini e le condizioni',
                style: context.textTheme.bodyMedium,
              ),
              value: _isTermsAccepted,
              onChanged: _updateIsTermsAccepted,
              activeColor: context.primaryColor,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: ThemeSizes.md),
              controlAffinity: ListTileControlAffinity.trailing,
              dense: true,
            ),
          ),

          // Warning about consequences
          if (_hasChanges && (!_isAdult || !_isTermsAccepted))
            Container(
              padding: const EdgeInsets.all(ThemeSizes.sm),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.amber),
                  const SizedBox(width: ThemeSizes.sm),
                  Expanded(
                    child: Text(
                      'Revocare questi consensi comporterà la disconnessione dal tuo account.',
                      style: context.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
