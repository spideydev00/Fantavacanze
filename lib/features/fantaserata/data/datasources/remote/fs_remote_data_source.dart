import 'package:fantavacanze_official/core/entities/fs_league/fs_night_type.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';

import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/features/fantaserata/data/models/league/fs_league_model.dart';
import 'package:uuid/uuid.dart';

abstract interface class FsRemoteDataSource {
  Future<FsLeagueModel> createLeague({
    required String name,
    String? description,
    required String creatorId,
    required String creatorName,
  });

  Future<FsLeagueModel> createNightSpecificLeague({
    required String name,
    String? description,
    required String creatorId,
    required String creatorName,
    required FsNightType nightType,
  });

  Future<FsLeagueModel> joinLeague({
    required String inviteCode,
    required String userId,
    required String userName,
  });

  Future<FsLeagueModel> joinNightSpecificLeague({
    required String inviteCode,
    required String userId,
    required String userName,
  });

  Future<FsLeagueModel> removeParticipant({
    required String leagueId,
    required String participantId,
  });

  Future<void> exitLeague({
    required String leagueId,
    required String userId,
  });

  Future<void> deleteLeague({
    required String leagueId,
  });

  Future<FsLeagueModel?> getFsLeague();

  Future<void> updateParticipantPoints({
    required String leagueId,
    required String userId,
    required double pointsToAdd,
    required double bonusToAdd,
    required double malusToAdd,
  });

  Future<FsLeagueModel> uploadWinnerPhoto({
    required String leagueId,
    required Uint8List imageBytes,
  });

  Future<FsLeagueModel> deleteWinnerPhoto({
    required String leagueId,
  });
}

class FsRemoteDataSourceImpl implements FsRemoteDataSource {
  final SupabaseClient supabaseClient;
  final Uuid uuid;
  final AppUserCubit appUserCubit;

  const FsRemoteDataSourceImpl({
    required this.supabaseClient,
    required this.uuid,
    required this.appUserCubit,
  });

  // =====================================================================
  // HELPER METHODS - USER AUTHENTICATION & ERROR HANDLING
  // =====================================================================

  /// Extracts a clean error message from various exception types
  String _extractErrorMessage(Object e) {
    if (e is ServerException) return e.message;
    if (e is PostgrestException) return e.message;
    return e.toString();
  }

  /// Gets the current user ID from cache or cubit
  String? _getCurrentUserId() {
    final state = appUserCubit.state;
    if (state is AppUserIsLoggedIn) {
      return state.user.id;
    }
    return null;
  }

  /// Checks authentication and returns user ID or throws exception
  String _checkAuthentication() {
    final currentUserId = _getCurrentUserId();
    if (currentUserId == null) {
      throw ServerException('Utente non autenticato');
    }
    return currentUserId;
  }

  /// Wraps database operations to handle exceptions uniformly
  Future<T> _tryDatabaseOperation<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (e) {
      debugPrint('❌ Errore nella comunicazione col database FS: $e');
      throw ServerException(_extractErrorMessage(e));
    }
  }

  // =====================================================================
  // EXISTING METHODS WITH _tryDatabaseOperation
  // =====================================================================

  @override
  Future<FsLeagueModel> createLeague({
    required String name,
    String? description,
    required String creatorId,
    required String creatorName,
  }) async {
    return _tryDatabaseOperation(() async {
      final String inviteCode = uuid.v4().substring(0, 10);

      final response = await supabaseClient
          .from('fs_leagues')
          .insert({
            'name': name,
            'description': description,
            'invite_code': inviteCode,
            'participants': [
              {
                'userId': creatorId,
                'name': creatorName,
                'points': 0,
                'malusTotal': 0,
                'bonusTotal': 0,
              }
            ],
          })
          .select()
          .single();

      final league = FsLeagueModel.fromJson(response);

      // SYNC: Assign dynamic rules immediately after league creation
      await _assignRulesToUser(
        userId: creatorId,
        leagueId: league.id,
        nightType: FsNightType.def,
      );

      return league;
    });
  }

  @override
  Future<FsLeagueModel> createNightSpecificLeague({
    required String name,
    String? description,
    required String creatorId,
    required String creatorName,
    required FsNightType nightType,
  }) async {
    return _tryDatabaseOperation(() async {
      final String inviteCode = uuid.v4().substring(0, 10);

      final response = await supabaseClient
          .from('fs_leagues')
          .insert({
            'name': name,
            'description': description,
            'invite_code': inviteCode,
            'participants': [
              {
                'userId': creatorId,
                'name': creatorName,
                'points': 0,
                'malusTotal': 0,
                'bonusTotal': 0,
              }
            ],
            'night_type': nightType.value,
          })
          .select()
          .single();

      final league = FsLeagueModel.fromJson(response);

      await _assignRulesToUser(
        userId: creatorId,
        leagueId: league.id,
        nightType: nightType,
      );

      return league;
    });
  }

  @override
  Future<FsLeagueModel> joinLeague({
    required String inviteCode,
    required String userId,
    required String userName,
  }) async {
    return _tryDatabaseOperation(() async {
      // First get the league
      final leagueResponse = await supabaseClient
          .from('fs_leagues')
          .select()
          .eq('invite_code', inviteCode)
          .single();

      final league = FsLeagueModel.fromJson(leagueResponse);

      // Check if user already participant
      final isAlreadyParticipant =
          league.participants.any((p) => p.userId == userId);

      if (isAlreadyParticipant) {
        return league;
      }

      // Add participant
      final updatedParticipants = [
        ...league.participants.map((p) => {
              'userId': p.userId,
              'name': p.name,
              'points': p.points,
              'malusTotal': p.malusTotal,
              'bonusTotal': p.bonusTotal,
            }),
        {
          'userId': userId,
          'name': userName,
          'points': 0,
          'malusTotal': 0,
          'bonusTotal': 0,
        }
      ];

      final response = await supabaseClient
          .from('fs_leagues')
          .update({'participants': updatedParticipants})
          .eq('id', league.id)
          .select()
          .single();

      final updatedLeague = FsLeagueModel.fromJson(response);

      // SYNC: Assign rules immediately after joining
      await _assignRulesToUser(
        userId: userId,
        leagueId: updatedLeague.id,
        nightType: league.nightType,
      );

      return updatedLeague;
    });
  }

  @override
  Future<FsLeagueModel> joinNightSpecificLeague({
    required String inviteCode,
    required String userId,
    required String userName,
  }) async {
    return _tryDatabaseOperation(() async {
      // First get the league
      final leagueResponse = await supabaseClient
          .from('fs_leagues')
          .select()
          .eq('invite_code', inviteCode)
          .single();

      final league = FsLeagueModel.fromJson(leagueResponse);

      // Check if user already participant
      final isAlreadyParticipant =
          league.participants.any((p) => p.userId == userId);

      if (isAlreadyParticipant) {
        return league;
      }

      // Add participant
      final updatedParticipants = [
        ...league.participants.map((p) => {
              'userId': p.userId,
              'name': p.name,
              'points': p.points,
              'malusTotal': p.malusTotal,
              'bonusTotal': p.bonusTotal,
            }),
        {
          'userId': userId,
          'name': userName,
          'points': 0,
          'malusTotal': 0,
          'bonusTotal': 0,
        }
      ];

      final response = await supabaseClient
          .from('fs_leagues')
          .update({'participants': updatedParticipants})
          .eq('id', league.id)
          .select()
          .single();

      final updatedLeague = FsLeagueModel.fromJson(response);

      // SYNC: Assign rules immediately after joining
      await _assignRulesToUser(
        userId: userId,
        leagueId: updatedLeague.id,
        nightType: updatedLeague.nightType,
      );

      return updatedLeague;
    });
  }

  @override
  Future<FsLeagueModel> removeParticipant({
    required String leagueId,
    required String participantId,
  }) async {
    return _tryDatabaseOperation(() async {
      final leagueResponse = await supabaseClient
          .from('fs_leagues')
          .select()
          .eq('id', leagueId)
          .single();

      final league = FsLeagueModel.fromJson(leagueResponse);

      final updatedParticipants = league.participants
          .where((p) => p.userId != participantId)
          .map((p) => {
                'userId': p.userId,
                'name': p.name,
                'points': p.points,
                'malusTotal': p.malusTotal,
                'bonusTotal': p.bonusTotal,
              })
          .toList();

      final response = await supabaseClient
          .from('fs_leagues')
          .update({'participants': updatedParticipants})
          .eq('id', leagueId)
          .select()
          .single();

      return FsLeagueModel.fromJson(response);
    });
  }

  @override
  Future<void> exitLeague({
    required String leagueId,
    required String userId,
  }) async {
    return _tryDatabaseOperation(() async {
      final leagueResponse = await supabaseClient
          .from('fs_leagues')
          .select()
          .eq('id', leagueId)
          .single();

      final league = FsLeagueModel.fromJson(leagueResponse);

      final updatedParticipants = league.participants
          .where((p) => p.userId != userId)
          .map((p) => {
                'userId': p.userId,
                'name': p.name,
                'points': p.points,
                'malusTotal': p.malusTotal,
                'bonusTotal': p.bonusTotal,
              })
          .toList();

      await supabaseClient
          .from('fs_leagues')
          .update({'participants': updatedParticipants})
          .eq('id', leagueId)
          .select()
          .single();

      return;
    });
  }

  @override
  Future<void> deleteLeague({
    required String leagueId,
  }) async {
    return _tryDatabaseOperation(() async {
      await supabaseClient.from('fs_leagues').delete().eq('id', leagueId);
    });
  }

  @override
  Future<FsLeagueModel?> getFsLeague() async {
    return _tryDatabaseOperation(() async {
      final currentUserId = _checkAuthentication();

      // Primary approach: Use RPC function for safe JSONB querying
      final response =
          await supabaseClient.rpc('get_fs_league_for_user', params: {
        'user_id': currentUserId,
      });

      // Controlla se la response è null o una lista vuota
      if (response == null || (response is List && response.isEmpty)) {
        return null;
      }

      // Se response è una lista, prendi il primo elemento
      if (response is List) {
        return FsLeagueModel.fromJson(response.first);
      }

      return FsLeagueModel.fromJson(response);
    });
  }

  /// Private method to assign rules to a user
  Future<void> _assignRulesToUser({
    required String userId,
    required String leagueId,
    required FsNightType nightType,
  }) async {
    // Call the RPC to assign dynamic rules
    await supabaseClient.rpc('assign_fs_rules_to_user', params: {
      'p_user_id': userId,
      'p_league_id': leagueId,
      'p_night_type': nightType.value,
    });
  }

  @override
  Future<void> updateParticipantPoints({
    required String leagueId,
    required String userId,
    required double pointsToAdd,
    required double bonusToAdd,
    required double malusToAdd,
  }) async {
    return _tryDatabaseOperation(() async {
      // Get current league
      final leagueResponse = await supabaseClient
          .from('fs_leagues')
          .select()
          .eq('id', leagueId)
          .single();

      final league = FsLeagueModel.fromJson(leagueResponse);

      // Find and update the participant
      final updatedParticipants = league.participants.map((participant) {
        if (participant.userId == userId) {
          // Calculate new totals
          final newPoints = participant.points + pointsToAdd;
          final newBonusTotal = participant.bonusTotal + bonusToAdd;
          final newMalusTotal = participant.malusTotal + malusToAdd;

          return {
            'userId': participant.userId,
            'name': participant.name,
            'points': newPoints,
            'bonusTotal': newBonusTotal,
            'malusTotal': newMalusTotal,
          };
        }
        return {
          'userId': participant.userId,
          'name': participant.name,
          'points': participant.points,
          'bonusTotal': participant.bonusTotal,
          'malusTotal': participant.malusTotal,
        };
      }).toList();

      // Update the league with new participant data
      await supabaseClient
          .from('fs_leagues')
          .update({'participants': updatedParticipants}).eq('id', leagueId);
    });
  }

  @override
  Future<FsLeagueModel> uploadWinnerPhoto({
    required String leagueId,
    required Uint8List imageBytes,
  }) async {
    return _tryDatabaseOperation(() async {
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String path = '$leagueId/winner_$timestamp.jpg';

      // Upload image to Supabase storage
      await supabaseClient.storage.from('fs-memories').uploadBinary(
            path,
            imageBytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
            ),
          );

      // Create a signed URL
      final signedUrl =
          await supabaseClient.storage.from('fs-memories').createSignedUrl(
                path,
                60 * 60 * 24 * 365,
              );

      // Update the league's winner_photo_url
      final response = await supabaseClient
          .from('fs_leagues')
          .update({'winner_photo_url': signedUrl})
          .eq('id', leagueId)
          .select()
          .maybeSingle();

      return FsLeagueModel.fromJson(response!);
    });
  }

  @override
  Future<FsLeagueModel> deleteWinnerPhoto({
    required String leagueId,
  }) async {
    return _tryDatabaseOperation(() async {
      // Update the league's winner_photo_url
      final response = await supabaseClient
          .from('fs_leagues')
          .update({'winner_photo_url': null})
          .eq('id', leagueId)
          .select()
          .maybeSingle();

      try {
        // List all files in the league folder
        final List<FileObject> files = await supabaseClient.storage
            .from('fs-memories')
            .list(path: leagueId);

        if (files.isNotEmpty) {
          // Extract file paths and delete them
          final List<String> filePaths =
              files.map((file) => '$leagueId/${file.name}').toList();

          await supabaseClient.storage.from('fs-memories').remove(filePaths);
        }
      } catch (e) {
        debugPrint('❌ Error deleting files from storage: $e');
      }

      return FsLeagueModel.fromJson(response!);
    });
  }
}
