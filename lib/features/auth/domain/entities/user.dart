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
  final bool hasBeenPromptedToLeaveReview;
  final String? imageUrl; // New field for user profile image

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
    this.hasBeenPromptedToLeaveReview = false,
    this.imageUrl, // Add to constructor
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
    bool? hasBeenPromptedToLeaveReview,
    String? imageUrl, // Add to copyWith
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
      hasBeenPromptedToLeaveReview:
          hasBeenPromptedToLeaveReview ?? this.hasBeenPromptedToLeaveReview,
      imageUrl: imageUrl ?? this.imageUrl, // Include in copyWith
    );
  }
}
