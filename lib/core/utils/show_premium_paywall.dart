import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:fantavacanze_official/core/utils/show_snackbar.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';

Future<bool> showPremiumPaywall(BuildContext context) async {
  try {
    final result = await RevenueCatUI.presentPaywall();

    // Check the result
    if (result == PaywallResult.purchased && context.mounted) {
      // The user has made a purchase, check if it was successful
      await context.read<AppUserCubit>().becomePremium();

      showSnackBar(
        "Abbonamento Premium attivato con successo!",
        color: ColorPalette.success,
      );
      return true;
    } else if (result == PaywallResult.restored && context.mounted) {
      await context.read<AppUserCubit>().becomePremium();

      showSnackBar(
        "Abbonamento Premium ripristinato!",
        color: ColorPalette.success,
      );
      return true;
    }

    return false;
  } catch (e) {
    debugPrint("Error showing paywall: $e");
    showSnackBar(
      "Si è verificato un errore. Riprova più tardi.",
      color: ColorPalette.error,
    );
    return false;
  }
}
