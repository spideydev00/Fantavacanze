import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/auth/domain/entities/user.dart';
import 'package:fantavacanze_official/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class MarkReviewLeft implements Usecase<User, NoParams> {
  final AuthRepository _authRepository;

  MarkReviewLeft({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  @override
  Future<Either<Failure, User>> call(NoParams params) {
    return _authRepository.markReviewLeft();
  }
}
