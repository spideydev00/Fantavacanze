import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/features/games/domain/entities/truth_or_dare_question.dart';

abstract interface class TruthOrDareRepository {
  Future<Either<Failure, List<TruthOrDareQuestion>>> getTruthOrDareCards({
    int limit = 50, // Default limit
  });
}
