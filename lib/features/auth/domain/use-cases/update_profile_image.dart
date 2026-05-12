import 'dart:io';

import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/auth/domain/entities/user.dart';
import 'package:fantavacanze_official/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateProfileImage implements Usecase<User, UpdateProfileImageParams> {
  final AuthRepository authRepository;

  UpdateProfileImage({required this.authRepository});

  @override
  Future<Either<Failure, User>> call(UpdateProfileImageParams params) async {
    return await authRepository.updateProfileImage(params.imageFile);
  }
}

class UpdateProfileImageParams {
  final File imageFile;

  UpdateProfileImageParams({required this.imageFile});
}
