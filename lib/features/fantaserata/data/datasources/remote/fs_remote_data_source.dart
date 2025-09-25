import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/features/fantaserata/data/models/league/fs_league_model.dart';
import 'package:fantavacanze_official/features/fantaserata/data/models/event/fs_event_model.dart';
import 'package:fantavacanze_official/features/fantaserata/data/models/memory/fs_memory_model.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule.dart';
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

  Future<FsEventModel> addEvent({
    required String leagueId,
    required String name,
    required double points,
    required String targetParticipantId,
    required String type,
  });

  Future<void> removeEvent({
    required String leagueId,
    required String eventId,
  });

  Future<FsMemoryModel> addMemory({
    required String leagueId,
    required String imageUrl,
    required String description,
    required String userId,
    required String participantName,
    String? relatedEventId,
    String? eventName,
  });

  Future<void> deleteMemory({
    required String leagueId,
    required String memoryId,
  });

  Future<void> removeParticipant({
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

  Future<void> refreshRule({
    required String userId,
    required String leagueId,
    required String challengeId,
  });

  Future<void> unlockRule({
    required String userId,
    required String leagueId,
    required String challengeId,
  });

  Future<void> setRuleAsCompleted({
    required String userId,
    required String leagueId,
    required String challengeId,
    required String ruleName,
    required double points,
    required String type,
  });

  Future<List<FsLeagueModel>> getFsLeagues();
}

class FsRemoteDataSourceImpl implements FsRemoteDataSource {
  final SupabaseClient supabaseClient;
  final Uuid uuid;

  const FsRemoteDataSourceImpl(
      {required this.supabaseClient, required this.uuid});

  @override
  Future<FsLeagueModel> createLeague({
    required String name,
    String? description,
    required String creatorId,
    required String creatorName,
  }) async {
    try {
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

      return FsLeagueModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<FsLeagueModel> joinLeague({
    required String inviteCode,
    required String userId,
    required String userName,
  }) async {
    try {
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

      return FsLeagueModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<FsEventModel> addEvent({
    required String leagueId,
    required String name,
    required double points,
    required String targetParticipantId,
    required String type,
  }) async {
    try {
      final leagueResponse = await supabaseClient
          .from('fs_leagues')
          .select()
          .eq('id', leagueId)
          .single();

      final league = FsLeagueModel.fromJson(leagueResponse);
      final targetParticipant = league.participants
          .firstWhere((p) => p.userId == targetParticipantId);

      final newEvent = FsEventModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        points: points,
        targetParticipant: targetParticipant,
        createdAt: DateTime.now(),
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

      await supabaseClient.from('fs_leagues').update({
        'events': updatedEvents,
        'participants': updatedParticipants,
      }).eq('id', leagueId);

      return newEvent;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> removeEvent({
    required String leagueId,
    required String eventId,
  }) async {
    try {
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

      await supabaseClient.from('fs_leagues').update({
        'events': updatedEvents,
        'participants': updatedParticipants,
      }).eq('id', leagueId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<FsMemoryModel> addMemory({
    required String leagueId,
    required String imageUrl,
    required String description,
    required String userId,
    required String participantName,
    String? relatedEventId,
    String? eventName,
  }) async {
    try {
      final leagueResponse = await supabaseClient
          .from('fs_leagues')
          .select()
          .eq('id', leagueId)
          .single();

      final league = FsLeagueModel.fromJson(leagueResponse);

      final newMemory = FsMemoryModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imageUrl: imageUrl,
        description: description,
        createdAt: DateTime.now(),
        userId: userId,
        participantName: participantName,
        relatedEventId: relatedEventId,
        eventName: eventName,
      );

      final updatedMemories = [
        ...league.memories.map((m) => FsMemoryModel.fromEntity(m).toJson()),
        newMemory.toJson(),
      ];

      await supabaseClient
          .from('fs_leagues')
          .update({'memories': updatedMemories}).eq('id', leagueId);

      return newMemory;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteMemory({
    required String leagueId,
    required String memoryId,
  }) async {
    try {
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

      await supabaseClient
          .from('fs_leagues')
          .update({'memories': updatedMemories}).eq('id', leagueId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> removeParticipant({
    required String leagueId,
    required String participantId,
  }) async {
    try {
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

      await supabaseClient
          .from('fs_leagues')
          .update({'participants': updatedParticipants}).eq('id', leagueId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> exitLeague({
    required String leagueId,
    required String userId,
  }) async {
    await removeParticipant(leagueId: leagueId, participantId: userId);
  }

  @override
  Future<void> deleteLeague({
    required String leagueId,
  }) async {
    try {
      await supabaseClient.from('fs_leagues').delete().eq('id', leagueId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> refreshRule({
    required String userId,
    required String leagueId,
    required String challengeId,
  }) async {
    try {
      await supabaseClient
          .from('user_fs_dynamic_rules')
          .update({
            'is_refreshed': true,
            'refreshed_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('league_id', leagueId)
          .eq('challenge_id', challengeId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> unlockRule({
    required String userId,
    required String leagueId,
    required String challengeId,
  }) async {
    try {
      await supabaseClient
          .from('user_fs_dynamic_rules')
          .update({'is_unlocked': true})
          .eq('user_id', userId)
          .eq('league_id', leagueId)
          .eq('challenge_id', challengeId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> setRuleAsCompleted({
    required String userId,
    required String leagueId,
    required String challengeId,
    required String ruleName,
    required double points,
    required String type,
  }) async {
    try {
      // Update rule completion
      await supabaseClient
          .from('user_fs_dynamic_rules')
          .update({
            'is_completed': true,
            'completed_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('league_id', leagueId)
          .eq('challenge_id', challengeId);

      // Add event to league
      await addEvent(
        leagueId: leagueId,
        name: ruleName,
        points: points,
        targetParticipantId: userId,
        type: type,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<FsLeagueModel>> getFsLeagues() async {
    try {
      final response = await supabaseClient
          .from('fs_leagues')
          .select()
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((league) =>
              FsLeagueModel.fromJson(league as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
