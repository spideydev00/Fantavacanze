import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/features/games/data/models/truth_or_dare_question_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class TruthOrDareRemoteDataSource {
  Future<List<TruthOrDareQuestionModel>> getTruthOrDareCards({int limit});
}

class TruthOrDareRemoteDataSourceImpl implements TruthOrDareRemoteDataSource {
  final SupabaseClient supabaseClient;

  TruthOrDareRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<TruthOrDareQuestionModel>> getTruthOrDareCards(
      {int limit = 50}) async {
    try {
      // Fetch random questions. Supabase doesn't directly support ORDER BY RANDOM() easily in RPC or views for RLS.
      // A common workaround is to fetch IDs from a function or fetch more and pick randomly client-side.
      // For simplicity, fetching with a limit. For true randomness, a DB function is better.
      final response = await supabaseClient
          .from('truth_or_dare_questions')
          .select()
          .limit(limit); // This is not random, just limited.

      // If you have a Postgres function like 'get_random_tod_questions(limit_count INT)'
      // final response = await supabaseClient.rpc('get_random_tod_questions', params: {'limit_count': limit});

      return response
          .map((item) => TruthOrDareQuestionModel.fromJson(item))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
