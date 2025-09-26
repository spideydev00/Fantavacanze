import 'package:fantavacanze_official/features/fantaserata/data/models/participant/fs_participant_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';

import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/features/fantaserata/data/models/league/fs_league_model.dart';
import 'package:fantavacanze_official/features/fantaserata/data/models/event/fs_event_model.dart';
import 'package:fantavacanze_official/features/fantaserata/data/models/memory/fs_memory_model.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule/fs_rule.dart';
import 'package:uuid/uuid.dart';

abstract interface class FsRemoteDataSource {
  Future<FsLeagueModel> createLeague({
    required String name,
    String? description,
    required String creatorId,
    required String creatorName,
  });

  Future<FsLeagueModel> joinLeague({
    required String inviteCode,
    required String userId,
    required String userName,
  });

  Future<FsLeagueModel> addEvent({
    required String leagueId,
    required String name,
    required double points,
    required String targetParticipantId,
    required String type,
  });

  Future<FsLeagueModel> removeEvent({
    required String leagueId,
    required String eventId,
  });

  Future<FsLeagueModel> addMemory({
    required String leagueId,
    required String imageUrl,
    required String description,
    required String userId,
    required String participantName,
    String? relatedEventId,
    String? eventName,
  });

  Future<FsLeagueModel> deleteMemory({
    required String leagueId,
    required String memoryId,
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

  /// Creates memory data
  FsMemoryModel _createMemoryData({
    required String imageUrl,
    required String description,
    required String userId,
    required String participantName,
    String? relatedEventId,
    String? eventName,
  }) {
    final memoryId = uuid.v4();
    return FsMemoryModel(
      id: memoryId,
      imageUrl: imageUrl,
      description: description,
      createdAt: DateTime.now(),
      userId: userId,
      participantName: participantName,
      relatedEventId: relatedEventId,
      eventName: eventName,
    );
  }

  /// Creates event data
  FsEventModel _createEventData({
    required String name,
    required double points,
    required FsParticipantModel targetParticipant,
    required FsRuleType type,
  }) {
    return FsEventModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      points: points,
      targetParticipant: targetParticipant,
      createdAt: DateTime.now(),
      type: type,
    );
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
                'points': '0',
                'malusTotal': '0',
                'bonusTotal': '0',
              }
            ],
            'events': [],
            'memories': [],
          })
          .select()
          .single();

      final league = FsLeagueModel.fromJson(response);

      // SYNC: Assign dynamic rules immediately after league creation
      await _assignDynamicRulesToUser(
        userId: creatorId,
        leagueId: league.id,
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
          'points': '0',
          'malusTotal': '0',
          'bonusTotal': '0',
        }
      ];

      final response = await supabaseClient
          .from('fs_leagues')
          .update({'participants': updatedParticipants})
          .eq('id', league.id)
          .select()
          .single();

      final updatedLeague = FsLeagueModel.fromJson(response);

      // SYNC: Assign dynamic rules immediately after joining
      await _assignDynamicRulesToUser(
        userId: userId,
        leagueId: updatedLeague.id,
      );

      return updatedLeague;
    });
  }

  @override
  Future<FsLeagueModel> addEvent({
    required String leagueId,
    required String name,
    required double points,
    required String targetParticipantId,
    required String type,
  }) async {
    return _tryDatabaseOperation(() async {
      final leagueResponse = await supabaseClient
          .from('fs_leagues')
          .select()
          .eq('id', leagueId)
          .single();

      final league = FsLeagueModel.fromJson(leagueResponse);
      final targetParticipant = league.participants
          .firstWhere((p) => p.userId == targetParticipantId);

      final newEvent = _createEventData(
        name: name,
        points: points,
        targetParticipant: targetParticipant,
        type: type == 'bonus' ? FsRuleType.bonus : FsRuleType.malus,
      );

      final updatedEvents = [
        ...league.events.map((e) => FsEventModel.fromEntity(e).toJson()),
        newEvent.toJson(),
      ];

      // Update participant points
      final updatedParticipants = league.participants.map((p) {
        if (p.userId == targetParticipantId) {
          final currentPoints = double.parse(p.points);
          final newPoints = currentPoints + points;

          final currentBonus = double.parse(p.bonusTotal);
          final currentMalus = double.parse(p.malusTotal);

          return {
            'userId': p.userId,
            'name': p.name,
            'points': newPoints.toString(),
            'malusTotal': type == 'malus'
                ? (currentMalus + points.abs()).toString()
                : p.malusTotal,
            'bonusTotal': type == 'bonus'
                ? (currentBonus + points).toString()
                : p.bonusTotal,
          };
        }
        return {
          'userId': p.userId,
          'name': p.name,
          'points': p.points,
          'malusTotal': p.malusTotal,
          'bonusTotal': p.bonusTotal,
        };
      }).toList();

      final response = await supabaseClient
          .from('fs_leagues')
          .update({
            'events': updatedEvents,
            'participants': updatedParticipants,
          })
          .eq('id', leagueId)
          .select()
          .single();

      return FsLeagueModel.fromJson(response);
    });
  }

  @override
  Future<FsLeagueModel> removeEvent({
    required String leagueId,
    required String eventId,
  }) async {
    return _tryDatabaseOperation(() async {
      final leagueResponse = await supabaseClient
          .from('fs_leagues')
          .select()
          .eq('id', leagueId)
          .single();

      final league = FsLeagueModel.fromJson(leagueResponse);
      final eventToRemove = league.events.firstWhere((e) => e.id == eventId);

      final updatedEvents = league.events
          .where((e) => e.id != eventId)
          .map((e) => FsEventModel.fromEntity(e).toJson())
          .toList();

      // Update participant points
      final updatedParticipants = league.participants.map((p) {
        if (p.userId == eventToRemove.targetParticipant.userId) {
          final currentPoints = double.parse(p.points);
          final newPoints = currentPoints - eventToRemove.points;

          final currentBonus = double.parse(p.bonusTotal);
          final currentMalus = double.parse(p.malusTotal);

          return {
            'userId': p.userId,
            'name': p.name,
            'points': newPoints.toString(),
            'malusTotal': eventToRemove.type == FsRuleType.malus
                ? (currentMalus - eventToRemove.points.abs()).toString()
                : p.malusTotal,
            'bonusTotal': eventToRemove.type == FsRuleType.bonus
                ? (currentBonus - eventToRemove.points).toString()
                : p.bonusTotal,
          };
        }
        return {
          'userId': p.userId,
          'name': p.name,
          'points': p.points,
          'malusTotal': p.malusTotal,
          'bonusTotal': p.bonusTotal,
        };
      }).toList();

      final response = await supabaseClient
          .from('fs_leagues')
          .update({
            'events': updatedEvents,
            'participants': updatedParticipants,
          })
          .eq('id', leagueId)
          .select()
          .single();

      return FsLeagueModel.fromJson(response);
    });
  }

  @override
  Future<FsLeagueModel> addMemory({
    required String leagueId,
    required String imageUrl,
    required String description,
    required String userId,
    required String participantName,
    String? relatedEventId,
    String? eventName,
  }) async {
    return _tryDatabaseOperation(() async {
      final leagueResponse = await supabaseClient
          .from('fs_leagues')
          .select()
          .eq('id', leagueId)
          .single();

      final league = FsLeagueModel.fromJson(leagueResponse);

      // Get participant name
      final resolvedParticipantName = participantName;

      final newMemory = _createMemoryData(
        imageUrl: imageUrl,
        description: description,
        userId: userId,
        participantName: resolvedParticipantName,
        relatedEventId: relatedEventId,
        eventName: eventName,
      );

      final updatedMemories = [
        ...league.memories.map((m) => FsMemoryModel.fromEntity(m).toJson()),
        newMemory.toJson(),
      ];

      final response = await supabaseClient
          .from('fs_leagues')
          .update({'memories': updatedMemories})
          .eq('id', leagueId)
          .select()
          .single();

      return FsLeagueModel.fromJson(response);
    });
  }

  @override
  Future<FsLeagueModel> deleteMemory({
    required String leagueId,
    required String memoryId,
  }) async {
    return _tryDatabaseOperation(() async {
      final leagueResponse = await supabaseClient
          .from('fs_leagues')
          .select()
          .eq('id', leagueId)
          .single();

      final league = FsLeagueModel.fromJson(leagueResponse);

      final updatedMemories = league.memories
          .where((m) => m.id != memoryId)
          .map((m) => FsMemoryModel.fromEntity(m).toJson())
          .toList();

      final response = await supabaseClient
          .from('fs_leagues')
          .update({'memories': updatedMemories})
          .eq('id', leagueId)
          .select()
          .single();

      return FsLeagueModel.fromJson(response);
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

      if (response.isNotEmpty) {
        return FsLeagueModel.fromJson(response.first);
      }

      return null;
    });
  }

  /// Private method to assign dynamic rules to a user
  Future<void> _assignDynamicRulesToUser({
    required String userId,
    required String leagueId,
  }) async {
    // Call the RPC to assign dynamic rules
    await supabaseClient.rpc('assign_fs_dynamic_rules_to_user', params: {
      'p_user_id': userId,
      'p_league_id': leagueId,
    });
  }
}
