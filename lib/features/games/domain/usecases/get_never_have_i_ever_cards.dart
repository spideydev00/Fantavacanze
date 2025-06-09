import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/games/domain/entities/never_have_i_ever_question.dart';
import 'package:fantavacanze_official/features/games/domain/repositories/never_have_i_ever_repository.dart';

class GetNeverHaveIEverCards
    implements
        Usecase<List<NeverHaveIEverQuestion>, GetNeverHaveIEverCardsParams> {
  final NeverHaveIEverRepository repository;

  GetNeverHaveIEverCards(this.repository);

  @override
  Future<Either<Failure, List<NeverHaveIEverQuestion>>> call(
      GetNeverHaveIEverCardsParams params) async {
    return await repository.getNeverHaveIEverCards(
      sessionId: params.sessionId, // Pass sessionId
      limit: params.limit,
    );
  }
}

class GetNeverHaveIEverCardsParams {
  final String sessionId; // Add sessionId
  final int limit;

  GetNeverHaveIEverCardsParams({
    required this.sessionId, // Add sessionId
    this.limit = 200,
  });
}
