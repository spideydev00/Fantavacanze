part of 'subscription_bloc.dart';

@immutable
sealed class SubscriptionEvent {}

class LoadProducts extends SubscriptionEvent {}

class PurchaseProductRequested extends SubscriptionEvent {
  final String productId;

  PurchaseProductRequested(this.productId);
}

class RestorePurchasesRequested extends SubscriptionEvent {}

class CheckPremiumStatusRequested extends SubscriptionEvent {}
