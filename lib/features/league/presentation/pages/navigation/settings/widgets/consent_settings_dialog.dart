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
      builder: (_) => BlocProvider.value(
        value: context.read<AppUserCubit>(),
        child: const ConsentSettingsDialog(),
      ),
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
      // Should not happen if dialog is shown for logged-in user
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

    // This part handles app-specific consent (age, terms) and potential logout
    if (!_isAdult || !_isTermsAccepted) {
      // First remove consents, which will then trigger logout
      await cubit.removeConsents(
        isAdult: _isAdult,
        isTermsAccepted: _isTermsAccepted,
      );

      // chiudo il dialog
      if (mounted) Navigator.of(context).pop(); // Pop this dialog

      // ripulisco lo stack portando a login
      navigatorKey.currentState!.pushAndRemoveUntil(
        SocialLoginPage.route,
        (route) => false,
      );
    } else {
      // solo chiudi il dialog
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConfirmationDialog(
      title: 'Consensi App',
      message:
          'Gestisci i tuoi consensi relativi all\'età e ai termini di servizio dell\'applicazione.',
      confirmText: 'Salva',
      cancelText: 'Annulla',
      icon: Icons.fact_check_rounded,
      iconColor: context.primaryColor,
      onConfirm: _hasChanges
          ? _saveChanges
          : () {
              if (mounted) Navigator.of(context).pop();
            },
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
        ],
      ),
    );
  }
}
