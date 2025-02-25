import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/auth/domain/entities/user.dart';
import 'package:fantavacanze_official/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class EmailSignUp implements Usecase<User, SignUpParams> {
  final AuthRepository authRepository;

  EmailSignUp({required this.authRepository});

  @override
  Future<Either<Failure, User>> call(SignUpParams params) async {
    return await authRepository.signUpWithEmailPassword(
        name: params.name,
        email: params.email,
        password: params.password,
        hCaptcha: params.hCaptcha);
  }
}

class SignUpParams {
  final String name;
  final String email;
  final String password;
  final String hCaptcha;

  SignUpParams(
      {required this.name,
      required this.email,
      required this.password,
      required this.hCaptcha});
}
