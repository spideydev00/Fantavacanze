import 'dart:async';

import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/features/drop/data/models/drop_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class DropRemoteDataSource {
  Future<DropModel?> getActiveDrop();
  Future<String?> getLastSeenDrop();
  Future<void> markSeen(String code);
}

class DropRemoteDataSourceImpl implements DropRemoteDataSource {
  final SupabaseClient supabaseClient;

  DropRemoteDataSourceImpl({required this.supabaseClient});

  String _extractErrorMessage(Object error) {
    if (error is ServerException) return error.message;
    if (error is PostgrestException) return error.message;
    if (error is TimeoutException) return error.message ?? 'Operazione scaduta';
    return error.toString();
  }

  @override
  Future<DropModel?> getActiveDrop() async {
    try {
      final response = await supabaseClient
          .from('drops')
          .select('code, image_url, cta_label, cta_url')
          .limit(1)
          .maybeSingle();
      if (response == null) return null;
      return DropModel.fromJson(response);
    } catch (error) {
      throw ServerException(_extractErrorMessage(error));
    }
  }

  @override
  Future<String?> getLastSeenDrop() async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) return null;
      final response = await supabaseClient
          .from('profiles')
          .select('last_seen_drop')
          .eq('id', userId)
          .maybeSingle();
      return response?['last_seen_drop'] as String?;
    } catch (error) {
      throw ServerException(_extractErrorMessage(error));
    }
  }

  @override
  Future<void> markSeen(String code) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) return;
      await supabaseClient
          .from('profiles')
          .update({'last_seen_drop': code}).eq('id', userId);
    } catch (error) {
      throw ServerException(_extractErrorMessage(error));
    }
  }
}
