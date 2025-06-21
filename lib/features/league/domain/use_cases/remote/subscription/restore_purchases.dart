import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/subscription.dart';
import 'package:fantavacanze_official/features/league/domain/repository/subscription_repository.dart';
import 'package:fpdart/fpdart.dart';

class RestorePurchases implements Usecase<Subscription?, NoParams> {
  final SubscriptionRepository repository;

  RestorePurchases({required this.repository});

  @override
  Future<Either<Failure, Subscription?>> call(NoParams params) {
    return repository.restorePurchases();
  }
}
