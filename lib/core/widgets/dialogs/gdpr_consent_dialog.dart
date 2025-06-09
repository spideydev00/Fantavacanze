import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/services/gdpr_service.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/show_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/buttons/danger_action_button.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:fantavacanze_official/features/auth/presentation/pages/social_login.dart';
import 'package:fantavacanze_official/init_dependencies/init_dependencies.dart';
import 'package:fantavacanze_official/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GdprConsentDialog extends StatefulWidget {
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: BlocProvider.of<AppUserCubit>(context)),
          BlocProvider.value(value: BlocProvider.of<AppLeagueCubit>(context)),
        ],
        child: const GdprConsentDialog(),
      ),
    );
  }

  const GdprConsentDialog({super.key});

  @override
  State<GdprConsentDialog> createState() => _GdprConsentDialogState();
}

class _GdprConsentDialogState extends State<GdprConsentDialog> {
  String? _adConsentStatus;
  bool _isGdprLoading = false;
  final GdprService _gdprService = serviceLocator<GdprService>();

  @override
  void initState() {
    super.initState();
    _loadAdConsentStatus();
  }

  Future<void> _loadAdConsentStatus() async {
    if (!mounted) return;
    setState(() => _isGdprLoading = true);
    final status = await _gdprService.getConsentStatusString();
    if (mounted) {
      setState(() {
        _adConsentStatus = status;
        _isGdprLoading = false;
      });
    }
  }

  Future<void> _manageAdConsent() async {
    if (!mounted) return;
    setState(() => _isGdprLoading = true);

    // To ensure the UMP form is shown by gdpr_admob's initialize method,
    // we first reset the consent status. This makes the status 'REQUIRED',
    // which then triggers the form display in the gdpr_admob's logic.
    await _gdprService.resetConsentStatus();

    if (mounted) {
      if (_gdprService.errorMessage != null) {
        // Error during reset
        showSnackBar(_gdprService.errorMessage!, color: ColorPalette.error);
        setState(() => _isGdprLoading = false);
        return;
      }

      // After successful reset, attempt to initialize and show the form
      await _gdprService.initializeAndShowForm();

      if (mounted) {
        if (_gdprService.errorMessage != null) {
          // Error during initialize/show form
          showSnackBar(_gdprService.errorMessage!, color: ColorPalette.error);
        }
        await _loadAdConsentStatus(); // Refresh status from the service
        if (mounted) {
          setState(() => _isGdprLoading = false);
        }
      }
    } else {
      // Widget was unmounted during async operations
      _isGdprLoading = false;
    }
  }

  Future<void> _revokeAdConsentAndLogout() async {
    if (!mounted) return;
    setState(() => _isGdprLoading = true);

    await _gdprService.resetConsentStatus();

    if (!mounted) return;

    if (_gdprService.errorMessage != null) {
      showSnackBar(_gdprService.errorMessage!, color: ColorPalette.error);
      setState(() => _isGdprLoading = false);
    } else {
      // Successfully reset ad consent. Now, perform full logout.
      final appUserCubit = context.read<AppUserCubit>();
      final appLeagueCubit = context.read<AppLeagueCubit>();

      // Pop the GdprConsentDialog itself.
      Navigator.of(context).pop();

      // Perform logout actions
      await appLeagueCubit.clearCache();

      navigatorKey.currentState!.pushAndRemoveUntil(
        SocialLoginPage.route,
        (route) => false,
      );

      await appUserCubit.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConfirmationDialog(
      title: 'Consenso Annunci (GDPR)',
      message:
          'Gestisci le tue preferenze per la personalizzazione degli annunci o revoca il consenso.',
      confirmText: 'Chiudi',
      elevatedButtonStyle: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          Color.fromARGB(255, 30, 137, 231),
        ),
      ),
      outlinedButtonStyle: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(
          Color.fromARGB(255, 30, 137, 231),
        ),
        side: WidgetStatePropertyAll(
          BorderSide(
            color: Color.fromARGB(255, 30, 137, 231),
            width: 1.5,
          ),
        ),
      ),
      icon: Icons.ads_click_rounded,
      iconColor: const Color.fromARGB(255, 30, 137, 231),
      onConfirm: () {
        if (mounted) Navigator.of(context).pop();
      },
      additionalContent: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isGdprLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: ThemeSizes.sm),
              child: Loader(color: Color.fromARGB(255, 30, 137, 231)),
            )
          else ...[
            Text(
              "Consenso ${_adConsentStatus!.contains("obtained") ? 'dato' : 'non dato'}",
              style: context.textTheme.bodySmall,
            ),
            const SizedBox(height: ThemeSizes.sm),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit_notifications_rounded),
                label: const Text('Gestisci Preferenze'),
                onPressed: _manageAdConsent,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 30, 137, 231),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            DangerActionButton(
              title: 'Revoca Consenso',
              description: 'Disconnessione immediata.',
              icon: Icons.block_rounded,
              onTap: _revokeAdConsentAndLogout,
            ),
          ],
        ],
      ),
    );
  }
}
