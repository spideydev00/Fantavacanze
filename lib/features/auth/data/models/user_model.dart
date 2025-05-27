import 'package:fantavacanze_official/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.isPremium = false,
    required super.isOnboarded,
    required super.isAdult,
    required super.isTermsAccepted,
    required super.authProvider,
    super.fcmToken,
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
      isPremium: map['is_premium'] == true,
      isOnboarded: map['is_onboarded'] == true,
      isAdult: map['is_adult'] == true,
      isTermsAccepted: map['is_terms_accepted'] == true,
      authProvider: authProvider,
      fcmToken: map['fcm_token'] as String?,
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    bool? isPremium,
    bool? isOnboarded,
    bool? isAdult,
    bool? isTermsAccepted,
    String? authProvider,
    String? fcmToken,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      isPremium: isPremium ?? this.isPremium,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      isAdult: isAdult ?? this.isAdult,
      isTermsAccepted: isTermsAccepted ?? this.isTermsAccepted,
      authProvider: authProvider ?? this.authProvider,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
