import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/repository/subscription_repository.dart';
import 'package:fpdart/fpdart.dart';

class CheckPremiumStatus implements Usecase<bool, NoParams> {
  final SubscriptionRepository repository;

  CheckPremiumStatus({required this.repository});

  @override
  Future<Either<Failure, bool>> call(NoParams params) {
    return repository.checkPremiumStatus();
  }
}
