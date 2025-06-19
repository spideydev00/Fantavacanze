import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/auth/domain/entities/user.dart';
import 'package:fantavacanze_official/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateGender implements Usecase<User, String> {
  final AuthRepository authRepository;

  UpdateGender({required this.authRepository});

  @override
  Future<Either<Failure, User>> call(String? gender) async {
    return await authRepository.updateGender(gender: gender);
  }
}
