import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class SignUpParams {
  final String name;
  final String email;
  final String password;
  final String gender;
  final String hCaptcha;
  final bool isAdult;

  SignUpParams({
    required this.name,
    required this.email,
    required this.gender,
    required this.password,
    required this.hCaptcha,
    required this.isAdult,
  });
}

class EmailSignUp implements Usecase<void, SignUpParams> {
  final AuthRepository authRepository;

  EmailSignUp({required this.authRepository});

  @override
  Future<Either<Failure, void>> call(SignUpParams params) async {
    return await authRepository.signUpWithEmailPassword(
      name: params.name,
      email: params.email,
      password: params.password,
      gender: params.gender,
      hCaptcha: params.hCaptcha,
      isAdult: params.isAdult,
    );
  }
}
