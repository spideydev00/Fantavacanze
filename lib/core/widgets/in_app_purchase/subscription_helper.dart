import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionHelper extends ChangeNotifier {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  ProductDetails? _selectedProDetails;
  ProductDetails? get selectedProDetails => _selectedProDetails;
  set selectedProDetails(ProductDetails? productDetails) {
    _selectedProDetails = productDetails;
    notifyListeners();
  }

  bool isLoading = false;

  /// Available products
  List<ProductDetails> availableProducts = [];

  Completer<bool>? _purchaseCompleter;

  SubscriptionHelper() {
    _listenToPurchaseUpdates();
  }

  /// Keys for local storage
  final String _lastPurchaseDateKey = "last_purchase_date";
  final String _purchaseDurationKey = "purchase_duration";
  final String _planTypeKey = "plan_type";

  // Replace with your actual subscription IDs when ready
  // Use these test IDs for development
  Set<String> productIds = {
    'monthly_subscription', // Replace with your product ID
    'annual_subscription', // Replace with your product ID
  };

  /// Initialize and load available products
  Future<void> initialize() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      throw Exception("In-app purchases are not available on this device.");
    }

    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(productIds);
    if (response.notFoundIDs.isNotEmpty) {
      log("Some products were not found: ${response.notFoundIDs}");
    }

    availableProducts = response.productDetails;
    notifyListeners();

    if (availableProducts.isEmpty) {
      restorePurchases(); // Query past purchases
    }
  }

  /// Purchase a product
  Future<(bool, String)> purchaseProduct(ProductDetails product) async {
    isLoading = true;
    notifyListeners();

    try {
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
        applicationUserName: "fantavacanze_user",
      );

      if (productIds.contains(product.id)) {
        await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      }

      _purchaseCompleter = Completer<bool>();

      // Wait for the purchase process to complete or timeout
      final purchaseResult = await _purchaseCompleter!.future.timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          _purchaseCompleter?.complete(false);
          return false;
        },
      );

      if (purchaseResult) {
        return (true, "Abbonamento completato con successo!");
      } else {
        return (false, "Abbonamento fallito o cancellato.");
      }
    } on PlatformException catch (e) {
      if (e.code == 'storekit_duplicate_product_object') {
        return (false, "Transazione in corso. Attendi o riavvia l'app.");
      } else {
        log("Errore acquisto: ${e.message}");
        return (false, "Errore acquisto. Riprova o riavvia l'app.");
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Restore previous purchases
  Future<void> restorePurchases() async {
    await _inAppPurchase.restorePurchases(
        applicationUserName: "fantavacanze_user");
  }

  /// Listen to purchase updates
  void _listenToPurchaseUpdates() {
    _purchaseSubscription = _inAppPurchase.purchaseStream.listen(
      (List<PurchaseDetails> purchaseDetailsList) {
        for (PurchaseDetails purchaseDetails in purchaseDetailsList) {
          log("Aggiornamento acquisto: $purchaseDetails");
          if (purchaseDetails.status == PurchaseStatus.purchased ||
              purchaseDetails.status == PurchaseStatus.restored) {
            _processPurchase(purchaseDetails);
          } else if (purchaseDetails.status == PurchaseStatus.canceled) {
            _handlePurchaseCancellation(purchaseDetails);
          } else if (purchaseDetails.status == PurchaseStatus.error) {
            _handleError(purchaseDetails.error);
          }
        }
      },
      onError: (error) {
        debugPrint("Errore stream acquisti: $error");
      },
    );
  }

  /// Process and verify purchase
  Future<void> _processPurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchaseDetails);
    }

    try {
      final now = DateTime.now();
      final String userId =
          "user_id"; // Replace with actual user ID when available

      if (purchaseDetails.productID == 'monthly_subscription') {
        await _savePurchase(purchaseDetails.productID, userId, now, 30);
      } else if (purchaseDetails.productID == 'annual_subscription') {
        await _savePurchase(purchaseDetails.productID, userId, now, 365);
      }

      _purchaseCompleter?.complete(true);
    } catch (error) {
      debugPrint("Errore durante elaborazione acquisto: $error");
      _purchaseCompleter?.complete(false);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Save purchase information
  Future<void> _savePurchase(String productID, String uid,
      DateTime purchaseDate, int durationInDays) async {
    final expiryDate = purchaseDate.add(Duration(days: durationInDays));
    final newPlanType =
        productID == 'monthly_subscription' ? 'monthly' : 'annual';

    final prefs = await SharedPreferences.getInstance();

    // Save to SharedPreferences
    await prefs.setInt(
        _lastPurchaseDateKey, purchaseDate.millisecondsSinceEpoch);
    await prefs.setInt(_purchaseDurationKey, durationInDays);
    await prefs.setString(_planTypeKey, newPlanType);

    // Here you would also save to your backend when you have one
    log("Saved purchase: $productID, expires: ${expiryDate.toString()}");
  }

  /// Handle purchase cancellation
  Future<void> _handlePurchaseCancellation(
      PurchaseDetails purchaseDetails) async {
    // Could handle cancellation analytics or backend updates here
    log("Acquisto cancellato: ${purchaseDetails.productID}");
    _purchaseCompleter?.complete(false);

    isLoading = false;
    notifyListeners();
  }

  /// Handle purchase errors
  void _handleError(IAPError? error) {
    log("Errore acquisto: ${error?.details}");
    _purchaseCompleter?.complete(false);

    isLoading = false;
    notifyListeners();
  }

  /// Check if user has an active subscription
  Future<bool> hasActiveSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPurchaseDate = prefs.getInt(_lastPurchaseDateKey);
    final purchaseDuration = prefs.getInt(_purchaseDurationKey);

    if (lastPurchaseDate != null && purchaseDuration != null) {
      final purchaseDateTime =
          DateTime.fromMillisecondsSinceEpoch(lastPurchaseDate);
      final expiryDate = purchaseDateTime.add(Duration(days: purchaseDuration));
      return DateTime.now().isBefore(expiryDate);
    }

    return false;
  }

  /// Get current subscription plan type
  Future<String?> getCurrentPlanType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_planTypeKey);
  }

  /// Dispose resources
  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }
}
