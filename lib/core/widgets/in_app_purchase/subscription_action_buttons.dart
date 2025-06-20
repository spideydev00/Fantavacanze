import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class SubscribeButton extends StatelessWidget {
  final bool isLoading;
  final ProductDetails? selectedProduct;
  final VoidCallback onPressed;

  const SubscribeButton({
    super.key,
    required this.isLoading,
    required this.selectedProduct,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorPalette.premiumUser,
        ),
        onPressed: selectedProduct == null || isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text("Abbonati ora"),
      ),
    );
  }
}

class RestorePurchaseButton extends StatelessWidget {
  final VoidCallback onPressed;

  const RestorePurchaseButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        fixedSize: Size.fromWidth(Constants.getWidth(context)),
        foregroundColor: ColorPalette.premiumUser,
        side: const BorderSide(color: ColorPalette.premiumUser, width: 1.5),
      ),
      onPressed: onPressed,
      child: const Text("Ripristina acquisti"),
    );
  }
}
