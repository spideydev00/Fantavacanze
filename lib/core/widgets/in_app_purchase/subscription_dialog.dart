import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/cubits/subscription/subscription_cubit.dart';
import 'package:fantavacanze_official/core/cubits/subscription/subscription_state.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

void showSubscriptionDialog(
  BuildContext context, {
  required Function(ProductDetails?) onProductSelected,
  String title = "Abbonamento Premium",
}) {
  showModalBottomSheet<bool?>(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    backgroundColor: context.secondaryBgColor,
    showDragHandle: true,
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return BlocProvider.value(
        value: BlocProvider.of<SubscriptionCubit>(context),
        child: SubscriptionBottomSheet(
          title: title,
          onProductSelected: onProductSelected,
        ),
      );
    },
  ).then((value) async {
    if (value != true || !context.mounted) return;

    final selectedProduct =
        context.read<SubscriptionCubit>().state.selectedProduct;
    if (selectedProduct == null && context.mounted) {
      log("Seleziona un piano Premium");
      return;
    }

    onProductSelected(selectedProduct);
  });
}

class SubscriptionBottomSheet extends StatelessWidget {
  final String title;
  final Function(ProductDetails?) onProductSelected;

  const SubscriptionBottomSheet({
    super.key,
    required this.title,
    required this.onProductSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SubscriptionCubit, SubscriptionState>(
      listener: (context, state) {
        if (state.status == SubscriptionStatus.error &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        } else if (state.status == SubscriptionStatus.restored) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Acquisti ripristinati con successo")),
          );
        }
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context),
                const SizedBox(height: 5),
                _buildFeatures(context),
                const SizedBox(height: 15),
                _buildSubscriptionOptions(context, state),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    // Handle terms and conditions link
                  },
                  child: Text(
                    "Termini e Condizioni",
                    style: TextStyle(color: context.primaryColor),
                  ),
                ),
                const SizedBox(height: 15),
                _buildSubscribeButton(context, state),
                _buildRestorePurchaseButton(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: context.primaryColor,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          "Sblocca funzionalità premium",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: context.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatures(BuildContext context) {
    return Column(
      children: [
        for (var feature in _premiumFeatures)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: context.primaryColor,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    feature,
                    style: TextStyle(
                      color: context.textSecondaryColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSubscriptionOptions(
      BuildContext context, SubscriptionState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5, bottom: 10),
          child: Text(
            "Scegli il tuo piano",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: context.textPrimaryColor,
            ),
          ),
        ),
        if (state.availableProducts.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: state.status == SubscriptionStatus.loading ||
                      state.status == SubscriptionStatus.purchasing
                  ? CircularProgressIndicator(color: context.primaryColor)
                  : Text(
                      "Nessun piano disponibile",
                      style: TextStyle(color: context.textSecondaryColor),
                    ),
            ),
          ),
        ...List.generate(state.availableProducts.length, (index) {
          final plan = state.availableProducts[index];
          final isSelected = state.selectedProduct?.id == plan.id;

          return GestureDetector(
            onTap: () {
              context.read<SubscriptionCubit>().selectProduct(plan);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? context.primaryColor : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                decoration: BoxDecoration(
                  color: context.bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Radio(
                      value: plan.id,
                      groupValue: state.selectedProduct?.id,
                      onChanged: (_) {
                        context.read<SubscriptionCubit>().selectProduct(plan);
                      },
                      activeColor: context.primaryColor,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getLocalizedTitle(plan),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: context.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            plan.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: context.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          plan.price,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimaryColor,
                          ),
                        ),
                        Text(
                          _getDurationTitle(plan.id),
                          style: TextStyle(
                            fontSize: 12,
                            color: context.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSubscribeButton(BuildContext context, SubscriptionState state) {
    bool isLoading = state.status == SubscriptionStatus.loading ||
        state.status == SubscriptionStatus.purchasing;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: state.selectedProduct == null || isLoading
            ? null
            : () {
                Navigator.of(context).pop(true);
              },
        child: isLoading
            ? SizedBox(
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

  Widget _buildRestorePurchaseButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        context.read<SubscriptionCubit>().restorePurchases();
      },
      child: Text(
        "Ripristina acquisti",
        style: TextStyle(color: context.textSecondaryColor),
      ),
    );
  }

  String _getLocalizedTitle(ProductDetails product) {
    if (product.id.contains('monthly')) {
      return 'Piano Mensile';
    } else if (product.id.contains('annual')) {
      return 'Piano Annuale';
    }
    return product.title.split('(').first;
  }

  String _getDurationTitle(String idCode) {
    if (idCode.contains('monthly')) {
      return "al mese";
    }
    return "all'anno";
  }
}

final _premiumFeatures = [
  "Accesso a tutte le funzionalità premium",
  "Nessuna pubblicità",
  "3 obiettivi giornalieri",
  "Accesso diretto ai giochi alcolici",
  "Whitelist per future posizioni lavorative",
  "Supporto prioritario",
  "Molte altre funzionalità in arrivo",
];
