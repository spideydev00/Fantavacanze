import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:flutter/material.dart';

void showLogoutDialog(BuildContext context, {required VoidCallback onConfirm}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Disconnetti'),
        content: const Text('Sei sicuro di voler uscire dal tuo account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Annulla',
              style: TextStyle(color: context.textSecondaryColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColor,
            ),
            child: const Text('Disconnetti'),
          ),
        ],
      );
    },
  );
}
