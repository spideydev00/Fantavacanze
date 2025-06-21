class User {
  final String id;
  final String email;
  final String name;
  final String? gender;
  final bool isPremium;
  final bool isOnboarded;
  final bool isAdult;
  final String authProvider;
  final String? fcmToken;
  final bool isWordBombTrialAvailable;
  final bool hasLeftReview;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.gender,
    this.isPremium = false,
    required this.isOnboarded,
    required this.isAdult,
    this.authProvider = '',
    this.fcmToken,
    required this.isWordBombTrialAvailable,
    this.hasLeftReview = false,
  });

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? gender,
    bool? isPremium,
    bool? isOnboarded,
    bool? isAdult,
    String? authProvider,
    String? fcmToken,
    bool? isWordBombTrialAvailable,
    bool? hasLeftReview,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      isPremium: isPremium ?? this.isPremium,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      isAdult: isAdult ?? this.isAdult,
      authProvider: authProvider ?? this.authProvider,
      fcmToken: fcmToken ?? this.fcmToken,
      isWordBombTrialAvailable:
          isWordBombTrialAvailable ?? this.isWordBombTrialAvailable,
      hasLeftReview: hasLeftReview ?? this.hasLeftReview,
    );
  }
}
