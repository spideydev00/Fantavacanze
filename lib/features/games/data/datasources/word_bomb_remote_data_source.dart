import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class WordBombRemoteDataSource {
  Future<List<String>> getWordBombCategories();
}

class WordBombRemoteDataSourceImpl implements WordBombRemoteDataSource {
  final SupabaseClient supabaseClient;

  WordBombRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<String>> getWordBombCategories() async {
    try {
      final response =
          await supabaseClient.from('word_bomb_categories').select('name');
      return response.map((item) => item['name'] as String).toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
