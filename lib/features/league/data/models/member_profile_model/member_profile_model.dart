import 'package:fantavacanze_official/features/league/domain/entities/member_profile.dart';

class MemberProfileModel extends MemberProfile {
  const MemberProfileModel({
    required super.userId,
    super.profileImageUrl,
  });

  factory MemberProfileModel.fromJson(Map<String, dynamic> map) {
    final profileImageUrl = map['profile_image_url'] as String?;

    return MemberProfileModel(
      userId: map['id'] as String,
      profileImageUrl: profileImageUrl != null && profileImageUrl.isNotEmpty
          ? profileImageUrl
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': userId,
      'profile_image_url': profileImageUrl,
    };
  }
}
