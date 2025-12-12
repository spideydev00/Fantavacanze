import 'dart:async';

import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/features/app/data/models/app_status_model.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AppRemoteDataSource {
  Future<AppStatusModel> getAppStatus();
}

class AppRemoteDataSourceImpl implements AppRemoteDataSource {
  final SupabaseClient supabaseClient;

  AppRemoteDataSourceImpl({required this.supabaseClient});

  String _extractErrorMessage(Object e) {
    if (e is ServerException) return e.message;
    if (e is PostgrestException) return e.message;
    if (e is TimeoutException) return e.message ?? 'Operazione scaduta';
    return e.toString();
  }

  @override
  Future<AppStatusModel> getAppStatus() async {
    try {
      final response = await supabaseClient
          .from("application_status")
          .select("status")
          .limit(1)
          .single();

      return AppStatusModel.fromJson(response);
    } catch (e) {
      debugPrint("❌ Errore: ${_extractErrorMessage(e)}");
      throw ServerException(e.toString());
    }
  }
}
