import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/auth/domain/entities/user.dart';
import 'package:fantavacanze_official/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class SetHasPlayedFsParams {
  final bool hasPlayedFs;

  SetHasPlayedFsParams({required this.hasPlayedFs});
}

class SetHasPlayedFs implements Usecase<User, SetHasPlayedFsParams> {
  final AuthRepository authRepository;

  SetHasPlayedFs({required this.authRepository});

  @override
  Future<Either<Failure, User>> call(SetHasPlayedFsParams params) async {
    return await authRepository.setHasPlayedFs(
        setHasPlayedFs: params.hasPlayedFs);
  }
}
