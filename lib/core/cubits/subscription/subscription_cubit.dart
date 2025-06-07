import 'dart:async';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  // Keys for local storage
  final String _lastPurchaseDateKey = "last_purchase_date";
  final String _purchaseDurationKey = "purchase_duration";
  final String _planTypeKey = "plan_type";

  // Replace with your actual subscription IDs when ready
  final Set<String> productIds = {
    'monthly_subscription', // Replace with your product ID
    'annual_subscription', // Replace with your product ID
  };

  SubscriptionCubit() : super(const SubscriptionState()) {
    _listenToPurchaseUpdates();
    initialize();
    checkSubscriptionStatus();
  }

  Future<void> initialize() async {
    emit(state.copyWith(status: SubscriptionStatus.loading));

    try {
      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        emit(state.copyWith(
            status: SubscriptionStatus.error,
            errorMessage:
                "In-app purchases are not available on this device."));
        return;
      }

      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(productIds);

      if (response.notFoundIDs.isNotEmpty) {
        log("Some products were not found: ${response.notFoundIDs}");
      }

      emit(state.copyWith(
        availableProducts: response.productDetails,
        status: SubscriptionStatus.loaded,
      ));

      if (response.productDetails.isEmpty) {
        restorePurchases();
      }
    } catch (e) {
      emit(state.copyWith(
          status: SubscriptionStatus.error, errorMessage: e.toString()));
    }
  }

  void selectProduct(ProductDetails? product) {
    emit(state.copyWith(selectedProduct: product));
  }

  Future<(bool, String)> purchaseProduct(ProductDetails product) async {
    emit(state.copyWith(status: SubscriptionStatus.purchasing));

    try {
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
        applicationUserName: "fantavacanze_user",
      );

      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);

      // The actual purchase result will be handled in the purchase stream listener
      return (true, "Processo di acquisto avviato");
    } on PlatformException catch (e) {
      if (e.code == 'storekit_duplicate_product_object') {
        emit(state.copyWith(
            status: SubscriptionStatus.error,
            errorMessage: "Transazione in corso. Attendi o riavvia l'app."));
        return (false, "Transazione in corso. Attendi o riavvia l'app.");
      } else {
        log("Errore acquisto: ${e.message}");
        emit(state.copyWith(
            status: SubscriptionStatus.error,
            errorMessage: "Errore acquisto: ${e.message}"));
        return (false, "Errore acquisto. Riprova o riavvia l'app.");
      }
    } catch (e) {
      emit(state.copyWith(
          status: SubscriptionStatus.error, errorMessage: e.toString()));
      return (false, "Si è verificato un errore durante l'acquisto.");
    }
  }

  Future<void> restorePurchases() async {
    emit(state.copyWith(status: SubscriptionStatus.loading));
    try {
      await _inAppPurchase.restorePurchases(
          applicationUserName: "fantavacanze_user");
      // Results will be delivered via the purchase stream
    } catch (e) {
      emit(state.copyWith(
          status: SubscriptionStatus.error,
          errorMessage:
              "Errore durante il ripristino degli acquisti: ${e.toString()}"));
    }
  }

  void _listenToPurchaseUpdates() {
    _purchaseSubscription = _inAppPurchase.purchaseStream.listen(
      (List<PurchaseDetails> purchaseDetailsList) {
        for (PurchaseDetails purchaseDetails in purchaseDetailsList) {
          _handlePurchaseUpdate(purchaseDetails);
        }
      },
      onError: (error) {
        emit(state.copyWith(
            status: SubscriptionStatus.error,
            errorMessage: "Errore stream acquisti: $error"));
      },
    );
  }

  Future<void> _handlePurchaseUpdate(PurchaseDetails purchaseDetails) async {
    log("Purchase update received: ${purchaseDetails.status}");

    if (purchaseDetails.status == PurchaseStatus.pending) {
      // Could update UI to show pending state if needed
    } else if (purchaseDetails.status == PurchaseStatus.purchased ||
        purchaseDetails.status == PurchaseStatus.restored) {
      await _processPurchase(purchaseDetails);
    } else if (purchaseDetails.status == PurchaseStatus.error) {
      emit(state.copyWith(
          status: SubscriptionStatus.error,
          errorMessage:
              purchaseDetails.error?.message ?? "Errore sconosciuto"));
    } else if (purchaseDetails.status == PurchaseStatus.canceled) {
      emit(state.copyWith(status: SubscriptionStatus.loaded));
    }

    // Complete the purchase regardless of status
    if (purchaseDetails.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchaseDetails);
    }
  }

  Future<void> _processPurchase(PurchaseDetails purchaseDetails) async {
    try {
      final now = DateTime.now();
      final String userId =
          "user_id"; // Replace with actual user ID when available

      if (purchaseDetails.productID == 'monthly_subscription') {
        await _savePurchase(purchaseDetails.productID, userId, now, 30);
      } else if (purchaseDetails.productID == 'annual_subscription') {
        await _savePurchase(purchaseDetails.productID, userId, now, 365);
      }

      await checkSubscriptionStatus();

      emit(state.copyWith(
          status: purchaseDetails.status == PurchaseStatus.restored
              ? SubscriptionStatus.restored
              : SubscriptionStatus.purchased));
    } catch (e) {
      emit(state.copyWith(
          status: SubscriptionStatus.error,
          errorMessage:
              "Errore durante l'elaborazione dell'acquisto: ${e.toString()}"));
    }
  }

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

  Future<void> checkSubscriptionStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastPurchaseDate = prefs.getInt(_lastPurchaseDateKey);
      final purchaseDuration = prefs.getInt(_purchaseDurationKey);
      final planType = prefs.getString(_planTypeKey);

      bool hasActive = false;

      if (lastPurchaseDate != null && purchaseDuration != null) {
        final purchaseDateTime =
            DateTime.fromMillisecondsSinceEpoch(lastPurchaseDate);
        final expiryDate =
            purchaseDateTime.add(Duration(days: purchaseDuration));
        hasActive = DateTime.now().isBefore(expiryDate);
      }

      emit(state.copyWith(
          hasActiveSubscription: hasActive, currentPlanType: planType));
    } catch (e) {
      log("Error checking subscription status: ${e.toString()}");
    }
  }

  @override
  Future<void> close() {
    _purchaseSubscription?.cancel();
    return super.close();
  }
}
