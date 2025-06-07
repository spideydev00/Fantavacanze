import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';

abstract interface class WordBombRepository {
  Future<Either<Failure, List<String>>> getWordBombCategories();
}
