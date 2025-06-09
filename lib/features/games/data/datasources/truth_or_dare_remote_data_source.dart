import 'dart:async';
import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/features/games/data/models/truth_or_dare_question_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class TruthOrDareRemoteDataSource {
  Future<List<TruthOrDareQuestionModel>> getTruthOrDareCards({int limit});
}

class TruthOrDareRemoteDataSourceImpl implements TruthOrDareRemoteDataSource {
  final SupabaseClient supabaseClient;

  TruthOrDareRemoteDataSourceImpl({required this.supabaseClient});

  // =====================================================================
  // ERROR HANDLING UTILITIES
  // =====================================================================

  // ------------------ EXTRACT ERROR MESSAGE ------------------ //
  String _extractErrorMessage(Object e) {
    if (e is ServerException) return e.message;
    if (e is PostgrestException) return e.message;
    if (e is TimeoutException) return e.message ?? 'Operazione scaduta';
    return e.toString();
  }

  // ------------------ TRY DATABASE OPERATION ------------------ //
  Future<T> _tryDatabaseOperation<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  // =====================================================================
  // CARD RETRIEVAL
  // =====================================================================

  // ------------------ GET TRUTH OR DARE CARDS ------------------ //
  @override
  Future<List<TruthOrDareQuestionModel>> getTruthOrDareCards(
      {int limit = 100}) async {
    return _tryDatabaseOperation(() async {
      final response = await supabaseClient.rpc(
        'get_random_questions',
        params: {'quantity_per_type': limit},
      );

      final List<TruthOrDareQuestionModel> questions = (response as List)
          .map((item) => TruthOrDareQuestionModel.fromJson(item))
          .toList();

      return questions;
    });
  }
}
