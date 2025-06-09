import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/features/games/domain/entities/never_have_i_ever_question.dart';

abstract interface class NeverHaveIEverRepository {
  Future<Either<Failure, List<NeverHaveIEverQuestion>>> getNeverHaveIEverCards({
    required String sessionId, // Add sessionId
    int limit = 200,
  });
}
