part of 'subscription_bloc.dart';

@immutable
sealed class SubscriptionState {}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class ProductsLoaded extends SubscriptionState {
  final List<String> products;

  ProductsLoaded(this.products);
}

class PurchaseInProgress extends SubscriptionState {}

class PurchaseSuccess extends SubscriptionState {
  final Subscription subscription;

  PurchaseSuccess(this.subscription);
}

class RestoreSuccess extends SubscriptionState {
  final Subscription? subscription;

  RestoreSuccess(this.subscription);
}

class PremiumStatusChecked extends SubscriptionState {
  final bool isPremium;

  PremiumStatusChecked(this.isPremium);
}

class SubscriptionFailure extends SubscriptionState {
  final String message;

  SubscriptionFailure(this.message);
}
