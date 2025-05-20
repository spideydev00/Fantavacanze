import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class SignUpParams {
  final String name;
  final String email;
  final String password;
  final String hCaptcha;
  final bool isAdult;
  final bool isTermsAccepted;

  SignUpParams({
    required this.name,
    required this.email,
    required this.password,
    required this.hCaptcha,
    required this.isAdult,
    required this.isTermsAccepted,
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
      hCaptcha: params.hCaptcha,
      isAdult: params.isAdult,
      isTermsAccepted: params.isTermsAccepted,
    );
  }
}
