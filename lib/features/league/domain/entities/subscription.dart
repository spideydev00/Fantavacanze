class Subscription {
  final String id;
  final String? expirationDate;
  final bool isActive;
  final String productId;

  const Subscription({
    required this.id,
    this.expirationDate,
    required this.isActive,
    required this.productId,
  });
}
