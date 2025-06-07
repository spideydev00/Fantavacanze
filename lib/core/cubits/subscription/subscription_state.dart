import 'package:equatable/equatable.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

enum SubscriptionStatus {
  initial,
  loading,
  loaded,
  purchasing,
  purchased,
  error,
  restored
}

class SubscriptionState extends Equatable {
  final List<ProductDetails> availableProducts;
  final ProductDetails? selectedProduct;
  final SubscriptionStatus status;
  final String? errorMessage;
  final bool hasActiveSubscription;
  final String? currentPlanType;

  const SubscriptionState({
    this.availableProducts = const [],
    this.selectedProduct,
    this.status = SubscriptionStatus.initial,
    this.errorMessage,
    this.hasActiveSubscription = false,
    this.currentPlanType,
  });

  SubscriptionState copyWith({
    List<ProductDetails>? availableProducts,
    ProductDetails? selectedProduct,
    SubscriptionStatus? status,
    String? errorMessage,
    bool? hasActiveSubscription,
    String? currentPlanType,
  }) {
    return SubscriptionState(
      availableProducts: availableProducts ?? this.availableProducts,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      status: status ?? this.status,
      errorMessage: errorMessage,
      hasActiveSubscription:
          hasActiveSubscription ?? this.hasActiveSubscription,
      currentPlanType: currentPlanType ?? this.currentPlanType,
    );
  }

  @override
  List<Object?> get props => [
        availableProducts,
        selectedProduct,
        status,
        errorMessage,
        hasActiveSubscription,
        currentPlanType,
      ];
}
