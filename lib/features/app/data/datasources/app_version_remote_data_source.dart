import 'dart:async';

import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/features/app/data/models/app_version_config_model.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AppVersionRemoteDataSource {
  Future<AppVersionConfigModel> getAppVersionConfig();
}

class AppVersionRemoteDataSourceImpl implements AppVersionRemoteDataSource {
  final SupabaseClient supabaseClient;

  AppVersionRemoteDataSourceImpl({required this.supabaseClient});

  String _extractErrorMessage(Object e) {
    if (e is ServerException) return e.message;
    if (e is PostgrestException) return e.message;
    if (e is TimeoutException) return e.message ?? 'Operazione scaduta';
    return e.toString();
  }

  @override
  Future<AppVersionConfigModel> getAppVersionConfig() async {
    try {
      final platform =
          defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
      final response = await supabaseClient
          .from('app_version_config')
          .select('min_supported_version, store_url')
          .eq('platform', platform)
          .limit(1)
          .single();

      return AppVersionConfigModel.fromJson(response);
    } catch (e) {
      final message = _extractErrorMessage(e);
      debugPrint('Errore configurazione versione app: $message');
      throw ServerException(message);
    }
  }
}
