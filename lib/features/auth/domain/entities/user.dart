class User {
  final String id;
  final String email;
  final String name;
  final bool isPremium;
  final bool isOnboarded;
  final bool isAdult;
  final bool isTermsAccepted;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.isPremium = false,
    required this.isOnboarded,
    required this.isAdult,
    required this.isTermsAccepted,
  });
}
