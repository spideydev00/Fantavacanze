import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/auth/domain/entities/user.dart';
import 'package:fantavacanze_official/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class AppleSignInParams {
  final bool isAdult;
  final bool isTermsAccepted;

  AppleSignInParams({
    required this.isAdult,
    required this.isTermsAccepted,
  });
}

class AppleSignIn implements Usecase<User, AppleSignInParams> {
  final AuthRepository authRepository;

  AppleSignIn({required this.authRepository});

  @override
  Future<Either<Failure, User>> call(AppleSignInParams params) async {
    return await authRepository.appleSignIn(
      isAdult: params.isAdult,
      isTermsAccepted: params.isTermsAccepted,
    );
  }
}
