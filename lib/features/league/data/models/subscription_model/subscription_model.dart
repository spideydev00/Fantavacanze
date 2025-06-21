import 'package:equatable/equatable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionModel extends Equatable {
  final bool isActive;
  final String? planType;
  final DateTime? expirationDate;
  final String? productId;

  const SubscriptionModel({
    required this.isActive,
    this.planType,
    this.expirationDate,
    this.productId,
  });

  factory SubscriptionModel.fromCustomerInfo(CustomerInfo customerInfo) {
    // Check for premium entitlement
    final entitlements = customerInfo.entitlements.active;

    final isPremium = entitlements.containsKey('premium_benefit') &&
        entitlements['premium_benefit']?.isActive == true;

    // Get product ID and expiration date if available
    String? productId;
    DateTime? expirationDate;
    String? planType;

    if (isPremium && entitlements['premium_benefit'] != null) {
      final premiumEntitlement = entitlements['premium_benefit']!;
      productId = premiumEntitlement.productIdentifier;

      if (premiumEntitlement.expirationDate != null) {
        expirationDate = DateTime.parse(premiumEntitlement.expirationDate!);
      }

      // Determine plan type based on product ID
      if (productId.contains('monthly')) {
        planType = 'monthly';
      } else if (productId.contains('annual')) {
        planType = 'annual';
      }
    }

    return SubscriptionModel(
      isActive: isPremium,
      planType: planType,
      expirationDate: expirationDate,
      productId: productId,
    );
  }

  @override
  List<Object?> get props => [isActive, planType, expirationDate, productId];
}
