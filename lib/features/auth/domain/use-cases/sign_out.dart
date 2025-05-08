import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class SignOut implements Usecase<void, NoParams> {
  final AuthRepository authRepository;

  SignOut({required this.authRepository});

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await authRepository.signOut();
  }
}
