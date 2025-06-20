import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';

class SubscriptionFeatureList extends StatelessWidget {
  final List<String> features;
  
  const SubscriptionFeatureList({
    super.key,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var feature in features)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: ColorPalette.success,
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
}

// Premium features list
const List<String> premiumFeatures = [
  "Nessuna pubblicità",
  "3 obiettivi giornalieri",
  "Accesso diretto ai giochi",
  "Whitelist per future posizioni lavorative",
  "Supporto prioritario",
];
