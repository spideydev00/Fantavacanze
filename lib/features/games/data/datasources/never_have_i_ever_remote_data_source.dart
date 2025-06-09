import 'dart:async';
import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/features/games/data/models/never_have_i_ever_question_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class NeverHaveIEverRemoteDataSource {
  Future<List<NeverHaveIEverQuestionModel>> getNeverHaveIEverCards({
    required String sessionId, // Add sessionId
    int limit = 200,
  });
}

class NeverHaveIEverRemoteDataSourceImpl
    implements NeverHaveIEverRemoteDataSource {
  final SupabaseClient supabaseClient;

  NeverHaveIEverRemoteDataSourceImpl({required this.supabaseClient});

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

  // ------------------ GET NEVER HAVE I EVER CARDS ------------------ //
  @override
  Future<List<NeverHaveIEverQuestionModel>> getNeverHaveIEverCards({
    required String sessionId,
    int limit = 200,
  }) async {
    return _tryDatabaseOperation(() async {
      final response = await supabaseClient.rpc(
        'get_random_never_have_i_ever_questions',
        params: {
          'cards_limit': limit,
          'p_session_id': sessionId,
        },
      );

      if (response is List) {
        return response
            .map((item) => NeverHaveIEverQuestionModel.fromJson(
                item as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException('Formato risposta inatteso dalla funzione RPC.');
      }
    });
  }
}
