import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/subscription.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/subscription/check_premium_status.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/subscription/get_products.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/subscription/purchase_product.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/subscription/restore_purchases.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'subscription_event.dart';
part 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final GetProducts _getProducts;
  final PurchaseProduct _purchaseProduct;
  final RestorePurchases _restorePurchases;
  final CheckPremiumStatus _checkPremiumStatus;
  final AppUserCubit _appUserCubit;

  SubscriptionBloc({
    required GetProducts getProducts,
    required PurchaseProduct purchaseProduct,
    required RestorePurchases restorePurchases,
    required CheckPremiumStatus checkPremiumStatus,
    required AppUserCubit appUserCubit,
  })  : _getProducts = getProducts,
        _purchaseProduct = purchaseProduct,
        _restorePurchases = restorePurchases,
        _checkPremiumStatus = checkPremiumStatus,
        _appUserCubit = appUserCubit,
        super(SubscriptionInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<PurchaseProductRequested>(_onPurchaseProductRequested);
    on<RestorePurchasesRequested>(_onRestorePurchasesRequested);
    on<CheckPremiumStatusRequested>(_onCheckPremiumStatusRequested);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());

    final result = await _getProducts(NoParams());

    result.fold(
      (failure) => emit(SubscriptionFailure(failure.message)),
      (products) => emit(ProductsLoaded(products)),
    );
  }

  Future<void> _onPurchaseProductRequested(
    PurchaseProductRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(PurchaseInProgress());

    final result = await _purchaseProduct(event.productId);

    result.fold(
      (failure) => emit(SubscriptionFailure(failure.message)),
      (subscription) {
        if (subscription.isActive) {
          // Update user premium status in AppUserCubit
          _updateUserPremiumStatus();
        }
        emit(PurchaseSuccess(subscription));
      },
    );
  }

  Future<void> _onRestorePurchasesRequested(
    RestorePurchasesRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());

    final result = await _restorePurchases(NoParams());

    result.fold(
      (failure) => emit(SubscriptionFailure(failure.message)),
      (subscription) {
        if (subscription != null && subscription.isActive) {
          // Update user premium status in AppUserCubit
          _updateUserPremiumStatus();
        }
        emit(RestoreSuccess(subscription));
      },
    );
  }

  Future<void> _onCheckPremiumStatusRequested(
    CheckPremiumStatusRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());

    final result = await _checkPremiumStatus(NoParams());

    result.fold(
      (failure) => emit(SubscriptionFailure(failure.message)),
      (isPremium) {
        if (isPremium) {
          // Update user premium status in AppUserCubit if needed
          _updateUserPremiumStatus();
        }
        emit(PremiumStatusChecked(isPremium));
      },
    );
  }

  void _updateUserPremiumStatus() {
    // Trigger the AppUserCubit to update the user's premium status
    _appUserCubit.becomePremium();
  }
}
