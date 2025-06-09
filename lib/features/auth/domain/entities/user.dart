class User {
  final String id;
  final String email;
  final String name;
  final String? gender;
  final bool isPremium;
  final bool isOnboarded;
  final bool isAdult;
  final bool isTermsAccepted;
  final String authProvider;
  final String? fcmToken;
  final bool isWordBombTrialAvailable;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.gender,
    this.isPremium = false,
    required this.isOnboarded,
    required this.isAdult,
    required this.isTermsAccepted,
    this.authProvider = '',
    this.fcmToken,
    required this.isWordBombTrialAvailable,
  });

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? gender,
    bool? isPremium,
    bool? isOnboarded,
    bool? isAdult,
    bool? isTermsAccepted,
    String? authProvider,
    String? fcmToken,
    bool? isWordBombTrialAvailable,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      isPremium: isPremium ?? this.isPremium,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      isAdult: isAdult ?? this.isAdult,
      isTermsAccepted: isTermsAccepted ?? this.isTermsAccepted,
      authProvider: authProvider ?? this.authProvider,
      fcmToken: fcmToken ?? this.fcmToken,
      isWordBombTrialAvailable:
          isWordBombTrialAvailable ?? this.isWordBombTrialAvailable,
    );
  }
}
