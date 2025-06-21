import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/features/league/data/models/subscription_model/subscription_model.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class SubscriptionRemoteDataSource {
  Future<List<String>> getProducts();
  Future<SubscriptionModel> purchaseProduct(String productId);
  Future<SubscriptionModel?> restorePurchases();
  Future<bool> checkPremiumStatus();
}

class SubscriptionRemoteDataSourceImpl implements SubscriptionRemoteDataSource {
  final SupabaseClient supabaseClient;

  SubscriptionRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<String>> getProducts() async {
    try {
      // Get offerings from RevenueCat
      final offerings = await Purchases.getOfferings();

      if (offerings.current == null) {
        return [];
      }

      // Extract product IDs from the current offering
      final products = offerings.current!.availablePackages
          .map((package) => package.identifier)
          .toList();

      return products;
    } catch (e) {
      throw ServerException('Failed to fetch products: ${e.toString()}');
    }
  }

  @override
  Future<SubscriptionModel> purchaseProduct(String productId) async {
    try {
      // Find the package with the given productId
      final offerings = await Purchases.getOfferings();
      if (offerings.current == null) {
        throw ServerException('No offerings available');
      }

      final package = offerings.current!.availablePackages.firstWhere(
        (package) => package.identifier == productId,
        orElse: () => throw ServerException('Product not found'),
      );

      // Make the purchase
      final purchaseResult = await Purchases.purchasePackage(package);

      // Create subscription model from customer info
      final subscription = SubscriptionModel.fromCustomerInfo(purchaseResult);

      return subscription;
    } catch (e) {
      throw ServerException('Purchase failed: ${e.toString()}');
    }
  }

  @override
  Future<SubscriptionModel?> restorePurchases() async {
    try {
      // Restore purchases
      final customerInfo = await Purchases.restorePurchases();

      // Create subscription model
      final subscription = SubscriptionModel.fromCustomerInfo(customerInfo);

      return subscription;
    } catch (e) {
      throw ServerException('Restore purchases failed: ${e.toString()}');
    }
  }

  @override
  Future<bool> checkPremiumStatus() async {
    try {
      // Get customer info
      final customerInfo = await Purchases.getCustomerInfo();

      // Check if premium entitlement is active
      final entitlements = customerInfo.entitlements.active;
      final isPremium = entitlements.containsKey('premium') &&
          entitlements['premium']?.isActive == true;

      return isPremium;
    } catch (e) {
      throw ServerException('Check premium status failed: ${e.toString()}');
    }
  }
}
