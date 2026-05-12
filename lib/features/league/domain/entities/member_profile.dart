import 'package:equatable/equatable.dart';

class MemberProfile extends Equatable {
  final String userId;
  final String? profileImageUrl;

  const MemberProfile({
    required this.userId,
    this.profileImageUrl,
  });

  @override
  List<Object?> get props => [
        userId,
        profileImageUrl,
      ];
}
