import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdatePassword implements Usecase<void, UpdatePasswordParams> {
  final AuthRepository authRepository;

  const UpdatePassword({required this.authRepository});

  @override
  Future<Either<Failure, void>> call(UpdatePasswordParams params) async {
    return await authRepository.updatePassword(
      params.oldPassword,
      params.newPassword,
      params.captchaToken,
    );
  }
}

class UpdatePasswordParams {
  final String oldPassword;
  final String newPassword;
  final String captchaToken;

  UpdatePasswordParams({
    required this.oldPassword,
    required this.newPassword,
    required this.captchaToken,
  });
}
