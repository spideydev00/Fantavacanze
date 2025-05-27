import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/auth/domain/entities/user.dart';
import 'package:fantavacanze_official/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateConsentsParams {
  final bool isAdult;
  final bool isTermsAccepted;

  UpdateConsentsParams({
    required this.isAdult,
    required this.isTermsAccepted,
  });
}

class UpdateConsents implements Usecase<User, UpdateConsentsParams> {
  final AuthRepository authRepository;

  UpdateConsents({required this.authRepository});

  @override
  Future<Either<Failure, User>> call(UpdateConsentsParams params) async {
    return await authRepository.updateConsents(
      isAdult: params.isAdult,
      isTermsAccepted: params.isTermsAccepted,
    );
  }
}
