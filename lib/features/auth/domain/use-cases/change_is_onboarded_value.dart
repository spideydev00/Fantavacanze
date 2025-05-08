import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/auth/domain/entities/user.dart';
import 'package:fantavacanze_official/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class ChangeIsOnboardedValue
    implements Usecase<void, ChangeIsOnboardedValueParams> {
  final AuthRepository authRepository;

  ChangeIsOnboardedValue({required this.authRepository});

  @override
  Future<Either<Failure, User>> call(
      ChangeIsOnboardedValueParams params) async {
    return await authRepository.changeIsOnboardedValue(
      newValue: params.newValue,
    );
  }
}

class ChangeIsOnboardedValueParams {
  final bool newValue;

  ChangeIsOnboardedValueParams({required this.newValue});
}
