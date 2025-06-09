import 'dart:async';

import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class WordBombRemoteDataSource {
  Future<bool> setWordBombTrialStatus(
      {required bool isActive, required String userId});
}

class WordBombRemoteDataSourceImpl implements WordBombRemoteDataSource {
  final SupabaseClient supabaseClient;

  WordBombRemoteDataSourceImpl({required this.supabaseClient});

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
  // TRIAL MANAGEMENT
  // =====================================================================

  // ------------------ SET WORD BOMB TRIAL STATUS ------------------ //
  @override
  Future<bool> setWordBombTrialStatus(
      {required bool isActive, required String userId}) async {
    return _tryDatabaseOperation(
      () async {
        await supabaseClient.from('profiles').update(
            {'is_word_bomb_trial_available': isActive}).eq('id', userId);

        return isActive;
      },
    );
  }
}
