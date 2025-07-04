import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/auth/domain/entities/user.dart';
import 'package:fantavacanze_official/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class SetHasLeftReviewParams {
  final bool hasLeftReview;

  SetHasLeftReviewParams({required this.hasLeftReview});
}

class SetHasLeftReview implements Usecase<User, SetHasLeftReviewParams> {
  final AuthRepository authRepository;

  SetHasLeftReview({required this.authRepository});

  @override
  Future<Either<Failure, User>> call(SetHasLeftReviewParams params) async {
    return await authRepository.setHasLeftReview(
      hasLeftReview: params.hasLeftReview,
    );
  }
}
