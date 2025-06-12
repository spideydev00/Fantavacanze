import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class RemoveConsentsParams {
  final bool isAdult;

  RemoveConsentsParams({
    required this.isAdult,
  });
}

class RemoveConsents implements Usecase<void, RemoveConsentsParams> {
  final AuthRepository authRepository;

  RemoveConsents({required this.authRepository});

  @override
  Future<Either<Failure, void>> call(RemoveConsentsParams params) async {
    return await authRepository.removeConsents(
      isAdult: params.isAdult,
    );
  }
}
