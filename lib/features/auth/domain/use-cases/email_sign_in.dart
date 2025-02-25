import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/auth/domain/entities/user.dart';
import 'package:fantavacanze_official/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class EmailSignIn implements Usecase<User, SignInParams> {
  final AuthRepository authRepository;

  EmailSignIn({required this.authRepository});

  @override
  Future<Either<Failure, User>> call(SignInParams params) async {
    return await authRepository.loginWithEmailPassword(
        email: params.email,
        password: params.password,
        hCaptcha: params.hCaptcha);
  }
}

class SignInParams {
  final String email;
  final String password;
  final String hCaptcha;

  SignInParams(
      {required this.email, required this.password, required this.hCaptcha});
}
