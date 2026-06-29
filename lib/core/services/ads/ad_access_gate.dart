import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/services/ads/ad_manager.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/utils/show-snackbar-or-paywall/show_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/premium_access_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Garantisce accesso a una sezione gate-able: premium, sessione o rewarded.
Future<bool> ensureAccess(
  BuildContext context, {
  required String feature,
  required Duration? timed,
  required String unlockedMessage,
}) async {
  final ads = AdManager();

  final userState = context.read<AppUserCubit>().state;
  final isPremium = userState is AppUserIsLoggedIn && userState.user.isPremium;
  if (isPremium || ads.session.isActive(feature)) return true;

  final granted = await showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (_) => PremiumAccessDialog(
          description: 'Scegli come sbloccare:',
          onAdsBtnTapped: () async {
            try {
              return await ads.showRewardedAd(context);
            } catch (_) {
              return false;
            }
          },
        ),
      ) ??
      false;

  if (!granted) return false;

  if (timed != null) {
    ads.session.grantTimed(feature, timed);
  } else {
    ads.session.grantForLaunch(feature);
  }

  if (context.mounted) {
    showSnackBar(unlockedMessage, color: ColorPalette.success);
  }
  return true;
}
