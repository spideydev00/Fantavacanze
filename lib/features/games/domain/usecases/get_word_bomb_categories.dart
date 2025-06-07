import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/games/domain/repositories/word_bomb_repository.dart';

class GetWordBombCategories implements Usecase<List<String>, NoParams> {
  final WordBombRepository repository;

  GetWordBombCategories(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) async {
    return await repository.getWordBombCategories();
  }
}
