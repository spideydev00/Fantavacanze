import 'package:fantavacanze_official/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.isPremium = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['user_metadata']?['full_name'] ?? map['name'] ?? '',
      isPremium: map['is_premium'] == true,
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    bool? isPremium,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}
