import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/games/domain/entities/truth_or_dare_question.dart';
import 'package:fantavacanze_official/features/games/domain/repositories/truth_or_dare_repository.dart';

class GetTruthOrDareCards
    implements Usecase<List<TruthOrDareQuestion>, GetTruthOrDareCardsParams> {
  final TruthOrDareRepository repository;

  GetTruthOrDareCards(this.repository);

  @override
  Future<Either<Failure, List<TruthOrDareQuestion>>> call(
      GetTruthOrDareCardsParams params) async {
    return await repository.getTruthOrDareCards(limit: params.limit);
  }
}

class GetTruthOrDareCardsParams {
  final int limit;
  GetTruthOrDareCardsParams({this.limit = 50});
}
