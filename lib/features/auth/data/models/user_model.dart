import 'package:fantavacanze_official/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.gender,
    super.isPremium = false,
    required super.isOnboarded,
    required super.isAdult,
    required super.authProvider,
    super.fcmToken,
    required super.isWordBombTrialAvailable,
    super.hasLeftReview,
  });

  factory UserModel.fromJson(Map<String, dynamic> map) {
    // Extract the auth provider from user metadata
    String authProvider = '';
    if (map['raw_app_meta_data'] != null) {
      authProvider = map['raw_app_meta_data']['provider'] ?? '';
    } else if (map['user_metadata'] != null &&
        map['user_metadata']['provider'] != null) {
      authProvider = map['user_metadata']['provider'];
    }

    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['user_metadata']?['full_name'] ?? map['name'] ?? '',
      gender: map['gender'],
      isPremium: map['is_premium'] == true,
      isOnboarded: map['is_onboarded'] == true,
      isAdult: map['is_adult'] == true,
      authProvider: authProvider,
      fcmToken: map['fcm_token'] as String?,
      isWordBombTrialAvailable: map['is_word_bomb_trial_available'] == true,
      hasLeftReview: map['has_left_review'] == true,
    );
  }

  @override
  UserModel copyWith({
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
    return UserModel(
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
