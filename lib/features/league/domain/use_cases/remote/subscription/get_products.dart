import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/repository/subscription_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetProducts implements Usecase<List<String>, NoParams> {
  final SubscriptionRepository repository;

  GetProducts({required this.repository});

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) {
    return repository.getProducts();
  }
}
