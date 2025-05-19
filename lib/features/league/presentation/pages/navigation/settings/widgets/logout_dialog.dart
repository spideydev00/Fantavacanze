import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/features/auth/presentation/pages/social_login.dart';
import 'package:flutter/material.dart';

void showLogoutDialog(BuildContext context, {required VoidCallback onConfirm}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Esci'),
        content: const Text('Sei sicuro di voler uscire dal tuo account?'),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              fixedSize: Size.fromWidth(Constants.getWidth(context) * 0.3),
            ),
            child: Text(
              'Annulla',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
              Navigator.pushAndRemoveUntil(
                context,
                SocialLoginPage.route,
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColor,
              fixedSize: Size.fromWidth(Constants.getWidth(context) * 0.35),
            ),
            child: const Text('Disconnetti'),
          ),
        ],
      );
    },
  );
}
