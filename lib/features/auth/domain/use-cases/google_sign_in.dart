import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/auth/domain/entities/user.dart';
import 'package:fantavacanze_official/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class GoogleSignInParams {
  final bool isAdult;
  final bool isTermsAccepted;

  GoogleSignInParams({
    required this.isAdult,
    required this.isTermsAccepted,
  });
}

class GoogleSignIn implements Usecase<User, GoogleSignInParams> {
  final AuthRepository authRepository;

  GoogleSignIn({required this.authRepository});

  @override
  Future<Either<Failure, User>> call(GoogleSignInParams params) async {
    return await authRepository.googleSignIn(
      isAdult: params.isAdult,
      isTermsAccepted: params.isTermsAccepted,
    );
  }
}
