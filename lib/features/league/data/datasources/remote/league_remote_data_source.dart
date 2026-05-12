import 'dart:async';
import 'dart:io';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/features/league/data/models/individual_participant_model/individual_participant_model.dart';
import 'package:fantavacanze_official/features/league/data/models/event_model/event_model.dart';
import 'package:fantavacanze_official/features/league/data/models/league_model/league_model.dart';
import 'package:fantavacanze_official/features/league/data/models/memory_model/memory_model.dart';
import 'package:fantavacanze_official/features/league/data/models/participant_model/participant_model.dart';
import 'package:fantavacanze_official/features/league/data/models/rule_model/rule_model.dart';
import 'package:fantavacanze_official/features/league/data/models/team_participant_model/team_participant_model.dart';
import 'package:fantavacanze_official/features/league/data/models/simple_participant_model/simple_participant_model.dart';
import 'package:fantavacanze_official/features/league/domain/entities/event/event.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule/rule.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

abstract class LeagueRemoteDataSource {
  // =====================================================================
  // LEAGUE OPERATIONS
  // =====================================================================
  Future<LeagueModel> createLeague({
    required String name,
    required String? description,
    required LeagueType type,
    required List<RuleModel> rules,
  });
  Future<LeagueModel> getLeague(
    String leagueId, {
    LeagueType? type,
  });

  Future<List<LeagueModel>> getUserLeagues();
  Future<Map<String, String?>> getProfileImagesForUsers(List<String> userIds);

  Future<void> deleteLeague(
    String leagueId, {
    LeagueType? type,
  });

  Future<List<LeagueModel>> searchLeague({required String inviteCode});

  Future<LeagueModel> updateLeagueInfo({
    required LeagueModel league,
    String? name,
    String? description,
  });

  // =====================================================================
  // PARTICIPANT OPERATIONS
  // =====================================================================
  Future<LeagueModel> joinLeague({
    required String inviteCode,
    String? teamName,
    List<String>? teamMembers,
    String? specificLeagueId,
  });

  Future<void> exitLeague({
    required LeagueModel league,
  });

  Future<LeagueModel> updateTeamName({
    required LeagueModel league,
    required String oldTeamName,
    required String newName,
  });

  Future<LeagueModel> addAdministrators({
    required LeagueModel league,
    required List<String> userIds,
  });

  Future<LeagueModel> removeParticipants({
    required LeagueModel league,
    required List<String> participantIds,
    String? teamName,
    String? newCaptainId,
  });

  // =====================================================================
  // EVENT OPERATIONS
  // =====================================================================
  Future<LeagueModel> addEvent({
    required LeagueModel league,
    required String name,
    required double points,
    required String creatorId,
    required String targetUser,
    required RuleType type,
    String? targetTeamName,
    String? targetMemberId,
    String? description,
  });

  Future<LeagueModel> removeEvent({
    required LeagueModel league,
    required String eventId,
  });

  // =====================================================================
  // MEMORY OPERATIONS
  // =====================================================================
  Future<LeagueModel> addMemory({
    required LeagueModel league,
    required String imageUrl,
    required String text,
    required String userId,
    String? relatedEventId,
    String? eventName,
  });
  Future<LeagueModel> removeMemory({
    required LeagueModel league,
    required String memoryId,
  });

  // =====================================================================
  // RULE OPERATIONS
  // =====================================================================
  Future<LeagueModel> updateRule({
    required LeagueModel league,
    required RuleModel rule,
    String? originalRuleName,
  });
  Future<LeagueModel> deleteRule({
    required LeagueModel league,
    required String ruleName,
  });
  Future<LeagueModel> addRule({
    required LeagueModel league,
    required RuleModel rule,
  });

  // =====================================================================
  // STORAGE OPERATIONS
  // =====================================================================
  Future<String> uploadMedia({
    required String leagueId,
    required File mediaFile,
  });
  Future<String> uploadTeamLogo({
    required String leagueId,
    required String teamName,
    required File imageFile,
  });
  Future<LeagueModel> updateTeamLogo({
    required LeagueModel league,
    required String teamName,
    required String logoUrl,
  });
}

class LeagueRemoteDataSourceImpl implements LeagueRemoteDataSource {
  final SupabaseClient supabaseClient;
  final Uuid uuid;
  final AppUserCubit appUserCubit;

  LeagueRemoteDataSourceImpl({
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
    if (e is TimeoutException) return e.message ?? 'Operazione scaduta';
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

  /// Gets the current user name from cache or cubit, never returns null
  String _getCurrentUserName() {
    // Try to get username from AppUserCubit
    final state = appUserCubit.state;
    if (state is AppUserIsLoggedIn) {
      return state.user.name;
    }

    return "Utente";
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
      debugPrint('❌ Errore nella comunicazione col database: $e');
      if (e is ServerException) rethrow;
      if (e is PostgrestException) {
        throw ServerException(e.message);
      }
      if (e is TimeoutException) {
        throw ServerException(e.message ?? 'Operazione scaduta');
      }
      throw ServerException(_extractErrorMessage(e));
    }
  }

  // =====================================================================
  // LEAGUE OPERATIONS IMPLEMENTATION
  // =====================================================================

  @override
  Future<LeagueModel> createLeague({
    required String name,
    required String? description,
    required LeagueType type,
    required List<RuleModel> rules,
  }) async {
    return _tryDatabaseOperation(() async {
      final String leagueId = uuid.v4();
      final String inviteCode = uuid.v4().substring(0, 10);

      final table = _tableForType(type);

      // Get creator info
      final creatorId = _checkAuthentication();
      final creatorName = _getCurrentUserName();

      // Create initial participant
      final initialParticipant = _createInitialParticipant(
        type: type,
        creatorId: creatorId,
        creatorName: creatorName,
      );

      // Normalize rule points to ensure malus values are negative
      final normalizedRules =
          rules.map((rule) => _normalizeRulePoints(rule)).toList();

      // Create league data using models directly
      final leagueData = {
        'id': leagueId,
        'invite_code': inviteCode,
        'admins': [creatorId],
        'name': name,
        'description': description,
        'created_at': DateTime.now().toIso8601String(),
        'rules': normalizedRules.map((rule) => rule.toJson()).toList(),
        'participants': [initialParticipant.toJson()],
        'events': [],
        'memories': [],
      };

      await supabaseClient.from(table).insert(leagueData);

      // Get the created league
      final response =
          await supabaseClient.from(table).select().eq('id', leagueId).single();

      return _convertResponseToModel(response, fallbackType: type);
    });
  }

  @override
  Future<LeagueModel> getLeague(
    String leagueId, {
    LeagueType? type,
  }) async {
    _checkAuthentication();
    return _getLeagueData(leagueId, type: type);
  }

  @override
  Future<List<LeagueModel>> getUserLeagues() async {
    return _tryDatabaseOperation(() async {
      _checkAuthentication();

      // Use the RPC function to efficiently get all user leagues in a single call
      List<Map<String, dynamic>> leaguesResponse = await supabaseClient.rpc(
        'get_user_leagues',
      );

      // Convert to models directly
      return leaguesResponse
          .map((league) => _convertResponseToModel(
                league,
                fallbackType: _inferLeagueTypeFromResponse(league),
              ))
          .toList();
    });
  }

  @override
  Future<Map<String, String?>> getProfileImagesForUsers(
    List<String> userIds,
  ) async {
    return _tryDatabaseOperation(() async {
      if (userIds.isEmpty) return {};

      final uniqueUserIds = userIds.toSet().toList();
      final response = await supabaseClient
          .from('profiles')
          .select('id, profile_image_url')
          .inFilter('id', uniqueUserIds);

      final profileImages = <String, String?>{
        for (final userId in uniqueUserIds) userId: null,
      };

      for (final row in response) {
        final id = row['id'] as String?;
        if (id == null) continue;

        final profileImageUrl = row['profile_image_url'] as String?;
        profileImages[id] =
            profileImageUrl != null && profileImageUrl.isNotEmpty
                ? profileImageUrl
                : null;
      }

      return profileImages;
    });
  }

  @override
  Future<void> deleteLeague(
    String leagueId, {
    LeagueType? type,
  }) async {
    return _tryDatabaseOperation(() async {
      _checkAuthentication();

      if (type != null) {
        await supabaseClient.from(_tableForType(type)).delete().eq(
              'id',
              leagueId,
            );
        return;
      }

      // Attempt deletion on both tables to ensure cleanup (Just for safety)
      await supabaseClient.from('individual_leagues').delete().eq(
            'id',
            leagueId,
          );

      await supabaseClient.from('team_leagues').delete().eq(
            'id',
            leagueId,
          );
    });
  }

  @override
  Future<List<LeagueModel>> searchLeague({required String inviteCode}) async {
    return _tryDatabaseOperation(() async {
      _checkAuthentication();

      // Use RPC function to efficiently search leagues
      final response = await supabaseClient.rpc(
        'search_league_by_invite_code',
        params: {'p_invite_code': inviteCode},
      );

      final result = Map<String, dynamic>.from(response as Map);
      final leaguesJson = result['leagues'] as List<dynamic>? ?? [];

      // Convert to models
      final leagues = leaguesJson
          .map((json) => _convertResponseToModel(
                Map<String, dynamic>.from(json),
                fallbackType: _inferLeagueTypeFromResponse(
                  Map<String, dynamic>.from(json),
                ),
              ))
          .toList();

      // Check if user is already a participant in any found leagues
      final currentUserId = _getCurrentUserId();

      if (currentUserId != null) {
        _checkUserParticipationInLeagues(leagues, currentUserId);
      }

      return leagues;
    });
  }

  @override
  Future<LeagueModel> updateLeagueInfo({
    required LeagueModel league,
    String? name,
    String? description,
  }) async {
    return _tryDatabaseOperation(() async {
      _checkAuthentication();

      final Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;

      if (updateData.isEmpty) {
        // Nothing to update, return current league
        return league;
      }

      // Update in Supabase
      return await _updateLeagueInDb(
        leagueId: league.id,
        type: league.type,
        updateData: updateData,
      );
    });
  }

  // =====================================================================
  // PARTICIPANT OPERATIONS IMPLEMENTATION
  // =====================================================================

  @override
  Future<LeagueModel> joinLeague({
    required String inviteCode,
    String? teamName,
    List<String>? teamMembers,
    String? specificLeagueId,
  }) async {
    return _tryDatabaseOperation(() async {
      final currentUserId = _checkAuthentication();
      final currentUserName = _getCurrentUserName();

      // Create a SimpleParticipantModel for the current user, ensuring auth
      final currentUserParticipant = SimpleParticipantModel(
        userId: currentUserId,
        name: currentUserName,
        points: 0,
      );

      // Use RPC function for joining league
      final response = await supabaseClient.rpc(
        'join_league',
        params: {
          'p_user_name': currentUserName,
          'p_invite_code': specificLeagueId == null ? inviteCode : null,
          'p_team_name': teamName,
          'p_specific_league_id': specificLeagueId,
          'p_member_details': currentUserParticipant.toJson(),
        },
      );

      final result = Map<String, dynamic>.from(response as Map);
      final status = result['status'] as String;

      if (status == 'joined') {
        final leagueData = Map<String, dynamic>.from(
          result['league'] as Map,
        );

        return _convertResponseToModel(
          leagueData,
          fallbackType: _inferLeagueTypeFromResponse(leagueData),
        );
      } else {
        throw ServerException('Risposta inattesa dal server');
      }
    });
  }

  @override
  Future<void> exitLeague({
    required LeagueModel league,
  }) async {
    return _tryDatabaseOperation(() async {
      _checkAuthentication();

      await supabaseClient.rpc(
        'exit_league',
        params: {
          'p_league_id': league.id,
        },
      );
    });
  }

  @override
  Future<LeagueModel> updateTeamName({
    required LeagueModel league,
    required String oldTeamName,
    required String newName,
  }) async {
    return _tryDatabaseOperation(() async {
      _checkAuthentication();

      if (league.type != LeagueType.team) {
        throw ServerException('Questa non è una lega basata su squadre');
      }

      final teamResult = _findTeamByName(league, oldTeamName);
      if (!teamResult.found) {
        throw ServerException('Team non trovato');
      }

      final response = await supabaseClient.rpc(
        'update_team_name',
        params: {
          'p_league_id': league.id,
          'p_old_team_name': oldTeamName,
          'p_new_team_name': newName,
        },
      );

      if (response == null) {
        throw ServerException('Errore nell\'aggiornamento del nome team');
      }

      final normalized = Map<String, dynamic>.from(response as Map);

      return _convertResponseToModel(
        normalized,
        fallbackType: LeagueType.team,
      );
    });
  }

  @override
  Future<LeagueModel> addAdministrators({
    required LeagueModel league,
    required List<String> userIds,
  }) async {
    return _tryDatabaseOperation(() async {
      _checkAuthentication();

      // Efficiently add new admins without duplicates
      final Set<String> uniqueAdmins = {...league.admins, ...userIds};

      // Update in Supabase
      return await _updateLeagueInDb(
        leagueId: league.id,
        type: league.type,
        updateData: {'admins': uniqueAdmins.toList()},
      );
    });
  }

  @override
  Future<LeagueModel> removeParticipants({
    required LeagueModel league,
    required List<String> participantIds,
    String? teamName,
    String? newCaptainId,
  }) async {
    return _tryDatabaseOperation(() async {
      _checkAuthentication();

      // Check if any participants to remove are admins
      _checkForAdminsInParticipants(league, participantIds);

      // TEAM LEAGUE: delegate to RPC for atomic update
      if (league.type == LeagueType.team) {
        final inferredTeamName =
            teamName ?? _inferTeamNameForRemoval(league, participantIds);

        if (inferredTeamName == null || inferredTeamName.isEmpty) {
          throw ServerException(
              'Specificare un team valido per rimuovere i partecipanti');
        }

        // Remove related events first to keep points in sync
        final leagueWithoutEvents = await _removeEventsForUserIds(
          league: league,
          userIds: participantIds,
        );

        final response = await supabaseClient.rpc(
          'remove_team_participants',
          params: {
            'p_league_id': leagueWithoutEvents.id,
            'p_team_name': inferredTeamName,
            'p_user_ids_to_remove': participantIds,
            'p_new_captain_id': newCaptainId,
          },
        );

        if (response == null) {
          throw ServerException('Errore nella rimozione dei partecipanti');
        }

        final normalized = Map<String, dynamic>.from(response as Map);

        final updatedLeague = _convertResponseToModel(
          normalized,
          fallbackType: LeagueType.team,
        );

        return _withRecalculatedTotals(updatedLeague);
      }

      // INDIVIDUAL LEAGUE: remove events then participants
      final leagueWithoutEvents = await _removeEventsForUserIds(
        league: league,
        userIds: participantIds,
      );

      final updatedParticipants = leagueWithoutEvents.participants
          .where((participant) =>
              participant is IndividualParticipantModel &&
              !participantIds.contains(participant.userId))
          .map((p) => (p as ParticipantModel).toJson())
          .toList();

      return await _updateLeagueInDb(
        leagueId: leagueWithoutEvents.id,
        type: leagueWithoutEvents.type,
        updateData: {
          'participants': updatedParticipants,
          'events': leagueWithoutEvents.events
              .map((e) => (e as EventModel).toJson())
              .toList(),
        },
      ).then(_withRecalculatedTotals);
    });
  }

  // =====================================================================
  // EVENT OPERATIONS IMPLEMENTATION
  // =====================================================================

  @override
  Future<LeagueModel> addEvent({
    required LeagueModel league,
    required String name,
    required double points,
    required String creatorId,
    required String targetUser,
    required RuleType type,
    String? targetTeamName,
    String? targetMemberId,
    String? description,
  }) async {
    _checkAuthentication();

    if (league.type == LeagueType.individual) {
      if (targetUser.isEmpty) {
        throw ServerException('Seleziona un partecipante valido per l\'evento');
      }

      return addIndividualLeagueEvent(
        leagueId: league.id,
        name: name,
        points: points,
        creatorId: creatorId,
        targetUserId: targetUser,
        type: type,
        description: description,
      );
    }

    final resolvedTeamName =
        targetTeamName ?? (targetMemberId == null ? targetUser : null);

    if (resolvedTeamName == null || resolvedTeamName.isEmpty) {
      throw ServerException(
          'Specificare un nome squadra per aggiungere un evento in lega a squadre');
    }

    return addTeamLeagueEvent(
      leagueId: league.id,
      name: name,
      points: points,
      creatorId: creatorId,
      targetTeamName: resolvedTeamName,
      targetMemberId: targetMemberId,
      type: type,
      description: description,
    );
  }

  Future<LeagueModel> addIndividualLeagueEvent({
    required String leagueId,
    required String name,
    required double points,
    required String creatorId,
    required String targetUserId,
    required RuleType type,
    String? description,
  }) async {
    return _tryDatabaseOperation(() async {
      _checkAuthentication();

      final response = await supabaseClient.rpc(
        'add_individual_league_event',
        params: {
          'p_league_id': leagueId,
          'p_event_name': name,
          'p_points': points,
          'p_creator_id': creatorId,
          'p_target_user_id': targetUserId,
          'p_rule_type': type.toString().split('.').last,
          'p_description': description,
        },
      );

      if (response == null) {
        throw ServerException('Errore nell\'aggiunta dell\'evento');
      }

      final normalized = Map<String, dynamic>.from(response as Map);

      return _convertResponseToModel(
        normalized,
        fallbackType: LeagueType.individual,
      );
    });
  }

  Future<LeagueModel> addTeamLeagueEvent({
    required String leagueId,
    required String name,
    required double points,
    required String creatorId,
    required String targetTeamName,
    required RuleType type,
    String? description,
    String? targetMemberId,
  }) async {
    return _tryDatabaseOperation(() async {
      _checkAuthentication();

      if (targetTeamName.isEmpty) {
        throw ServerException('Specificare un nome squadra valido');
      }

      if (targetMemberId != null && targetMemberId.isEmpty) {
        throw ServerException('Specificare un membro valido della squadra');
      }

      final response = await supabaseClient.rpc(
        'add_team_league_event',
        params: {
          'p_league_id': leagueId,
          'p_event_name': name,
          'p_points': points,
          'p_creator_id': creatorId,
          'p_target_team_name': targetTeamName,
          'p_rule_type': type.toString().split('.').last,
          'p_description': description,
          'p_target_member_id': targetMemberId,
        },
      );

      if (response == null) {
        throw ServerException('Errore nell\'aggiunta dell\'evento');
      }

      final normalized = Map<String, dynamic>.from(response as Map);

      return _convertResponseToModel(
        normalized,
        fallbackType: LeagueType.team,
      );
    });
  }

  @override
  Future<LeagueModel> removeEvent({
    required LeagueModel league,
    required String eventId,
  }) async {
    return _tryDatabaseOperation(() async {
      _checkAuthentication();

      final response = await supabaseClient.rpc(
        'remove_event_from_league',
        params: {
          'p_league_id': league.id,
          'p_event_id': eventId,
        },
      );

      if (response == null) {
        throw ServerException('Errore nella rimozione dell\'evento');
      }

      final normalized = Map<String, dynamic>.from(response as Map);

      return _convertResponseToModel(
        normalized,
        fallbackType: league.type,
      );
    });
  }

  // =====================================================================
  // MEMORY OPERATIONS IMPLEMENTATION
  // =====================================================================

  @override
  Future<LeagueModel> addMemory({
    required LeagueModel league,
    required String imageUrl,
    required String text,
    required String userId,
    String? relatedEventId,
    String? eventName,
  }) async {
    return _tryDatabaseOperation(() async {
      _checkAuthentication();

      // Get the participant name
      final participantName = _getParticipantNameByUserId(league, userId);

      // Create new memory with participant name
      final memoryData = _createMemoryData(
        imageUrl: imageUrl,
        text: text,
        userId: userId,
        participantName: participantName,
        relatedEventId: relatedEventId,
        eventName: eventName,
      );

      // Efficiently add the new memory
      final updatedMemories = [
        ...league.memories.map((m) => m as MemoryModel),
        memoryData,
      ];

      // Update in Supabase
      return await _updateLeagueInDb(
        leagueId: league.id,
        type: league.type,
        updateData: {
          'memories': updatedMemories.map((m) => m.toJson()).toList()
        },
      );
    });
  }

  @override
  Future<LeagueModel> removeMemory({
    required LeagueModel league,
    required String memoryId,
  }) async {
    return _tryDatabaseOperation(() async {
      final currentUserId = _checkAuthentication();

      // Find the memory
      final memoryIndex =
          league.memories.indexWhere((m) => (m as MemoryModel).id == memoryId);

      if (memoryIndex == -1) {
        throw ServerException('Ricordo non trovato');
      }

      final memoryToRemove = league.memories[memoryIndex] as MemoryModel;

      // Check if user is the owner of the memory
      if (memoryToRemove.userId != currentUserId &&
          !league.admins.contains(currentUserId)) {
        throw ServerException(
            'Puoi rimuovere solo i tuoi ricordi a meno che tu non sia un amministratore');
      }

      // Delete the image from storage
      await _deleteFileFromStorage(
        bucket: 'memories',
        url: memoryToRemove.mediaUrl,
      );

      // Remove the memory efficiently
      final updatedMemories = league.memories
          .where((m) => (m as MemoryModel).id != memoryId)
          .map((m) => (m as MemoryModel).toJson())
          .toList();

      // Update in Supabase
      return await _updateLeagueInDb(
        leagueId: league.id,
        type: league.type,
        updateData: {'memories': updatedMemories},
      );
    });
  }

  // =====================================================================
  // RULE OPERATIONS IMPLEMENTATION
  // =====================================================================
  @override
  Future<LeagueModel> updateRule({
    required LeagueModel league,
    required RuleModel rule,
    String? originalRuleName,
  }) async {
    return _tryDatabaseOperation(() async {
      _checkAuthentication();

      final normalizedRule = _normalizeRulePoints(rule);

      // Find the rule to update
      final nameToFind = originalRuleName ?? rule.name;

      // Efficiently map the rules
      final updatedRulesList = league.rules.map((currentRule) {
        if (currentRule.name == nameToFind) {
          return normalizedRule;
        }
        return currentRule;
      }).toList();

      // Prepare for database update
      final List<Map<String, dynamic>> rulesJson =
          updatedRulesList.map((rule) => (rule as RuleModel).toJson()).toList();

      // Update in Supabase
      return await _updateLeagueInDb(
        leagueId: league.id,
        type: league.type,
        updateData: {'rules': rulesJson},
      );
    });
  }

  @override
  Future<LeagueModel> deleteRule({
    required LeagueModel league,
    required String ruleName,
  }) async {
    return _tryDatabaseOperation(() async {
      _checkAuthentication();

      // Filter out the rule to delete efficiently
      final remainingRules = league.rules
          .where((r) => r.name != ruleName && !r.name.contains(ruleName))
          .map((r) => (r as RuleModel).toJson())
          .toList();

      // Update in Supabase
      return await _updateLeagueInDb(
        leagueId: league.id,
        type: league.type,
        updateData: {'rules': remainingRules},
      );
    });
  }

  @override
  Future<LeagueModel> addRule({
    required LeagueModel league,
    required RuleModel rule,
  }) async {
    return _tryDatabaseOperation(() async {
      _checkAuthentication();

      final normalizedRule = _normalizeRulePoints(rule);

      // Get existing rules
      final List<RuleModel> existingRules =
          league.rules.map((r) => r as RuleModel).toList();

      // Insert the new rule
      final List<RuleModel> updatedRules = _insertRule(
        existingRules: existingRules,
        newRule: normalizedRule,
        ruleType: normalizedRule.type,
      );

      // Update in Supabase
      return await _updateLeagueInDb(
        leagueId: league.id,
        type: league.type,
        updateData: {
          'rules': updatedRules.map((r) => r.toJson()).toList(),
        },
      );
    });
  }

  // =====================================================================
  // STORAGE OPERATIONS IMPLEMENTATION
  // =====================================================================

  @override
  Future<String> uploadMedia({
    required String leagueId,
    required File mediaFile,
  }) async {
    return _tryDatabaseOperation(() async {
      _checkAuthentication();

      final path = leagueId;
      return await _uploadMediaToStorage(
        bucket: 'memories',
        path: path,
        mediaFile: mediaFile,
        expiresIn: 60 * 60 * 24 * 365,
      );
    });
  }

  @override
  Future<String> uploadTeamLogo({
    required String leagueId,
    required String teamName,
    required File imageFile,
  }) async {
    return _tryDatabaseOperation(() async {
      _checkAuthentication();

      final existingFiles = await supabaseClient.storage
          .from('team-logos')
          .list(path: '$leagueId/$teamName');

      if (existingFiles.isNotEmpty) {
        final filesToRemove = existingFiles
            .map((file) => '$leagueId/$teamName/${file.name}')
            .toList();

        await supabaseClient.storage.from('team-logos').remove(filesToRemove);
      }

      final path = '$leagueId/$teamName';
      return await _uploadMediaToStorage(
        bucket: 'team-logos',
        path: path,
        mediaFile: imageFile,
        expiresIn: 60 * 60 * 24 * 365,
      );
    });
  }

  @override
  Future<LeagueModel> updateTeamLogo({
    required LeagueModel league,
    required String teamName,
    required String logoUrl,
  }) async {
    return _tryDatabaseOperation(() async {
      _checkAuthentication();

      // Find the team efficiently
      final teamResult = _findTeamByName(league, teamName);
      if (!teamResult.found) {
        throw ServerException('Team non trovato');
      }

      final teamIndex = teamResult.index;
      final teamParticipant =
          league.participants[teamIndex] as TeamParticipantModel;

      // Update team with new logo
      final updatedTeam = teamParticipant.copyWith(teamLogoUrl: logoUrl);
      final updatedParticipants = List<dynamic>.from(league.participants);
      updatedParticipants[teamIndex] = updatedTeam;

      // Update in Supabase
      return await _updateLeagueInDb(
        leagueId: league.id,
        type: league.type,
        updateData: {
          'participants': updatedParticipants
              .map((p) => (p as ParticipantModel).toJson())
              .toList()
        },
      );
    });
  }

  // =====================================================================
  // PRIVATE HELPER METHODS
  // =====================================================================

  /// Uploads a media file (image or video) to storage
  Future<String> _uploadMediaToStorage({
    required String bucket,
    required String path,
    required File mediaFile,
    required int expiresIn,
  }) async {
    try {
      final currentTime = DateTime.now().millisecondsSinceEpoch;

      // Determine file extension and content type from the file name.
      final fileExtension = _getFileExtension(mediaFile);
      final contentType = _getContentTypeForExtension(fileExtension);

      final fullFileName = '$currentTime$fileExtension';
      final fullPath =
          path.endsWith('/') ? '$path$fullFileName' : '$path/$fullFileName';

      await supabaseClient.storage.from(bucket).upload(
        fullPath,
        mediaFile,
        fileOptions: FileOptions(
          cacheControl: '3600',
          upsert: true,
          contentType: contentType,
        ),
      );

      // Create a signed URL
      final signedUrl = await supabaseClient.storage
          .from(bucket)
          .createSignedUrl(fullPath, expiresIn);

      return signedUrl;
    } catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  /// Determines file extension from file path or content
  String _getFileExtension(File file) {
    final fileName = file.path.toLowerCase();

    // Check for video extensions
    if (fileName.endsWith('.mp4') || fileName.contains('video')) {
      return '.mp4';
    } else if (fileName.endsWith('.mov')) {
      return '.mov';
    } else if (fileName.endsWith('.avi')) {
      return '.avi';
    } else if (fileName.endsWith('.mkv')) {
      return '.mkv';
    }
    // Check for image extensions
    else if (fileName.endsWith('.png')) {
      return '.png';
    } else if (fileName.endsWith('.gif')) {
      return '.gif';
    } else if (fileName.endsWith('.jpeg')) {
      return '.jpeg';
    }
    // Default to jpg
    else {
      return '.jpg';
    }
  }

  /// Resolves the content-type to satisfy storage bucket MIME constraints.
  String _getContentTypeForExtension(String extension) {
    switch (extension) {
      case '.mp4':
        return 'video/mp4';
      case '.mov':
        return 'video/quicktime';
      case '.avi':
        return 'video/x-msvideo';
      case '.mkv':
        return 'video/x-matroska';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.jpeg':
      case '.jpg':
        return 'image/jpeg';
      default:
        return 'application/octet-stream';
    }
  }

  /// Deletes a file from storage
  Future<void> _deleteFileFromStorage({
    required String bucket,
    required String url,
  }) async {
    try {
      // Extract file path from URL
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;

      // Find bucket in path
      final bucketIndex = pathSegments.indexOf(bucket);
      if (bucketIndex == -1 || bucketIndex + 1 >= pathSegments.length) {
        return;
      }

      // Get file path after bucket
      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

      // Delete file
      await supabaseClient.storage.from(bucket).remove([filePath]);
    } catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  /// Gets league data by ID
  Future<LeagueModel> _getLeagueData(
    String leagueId, {
    LeagueType? type,
  }) async {
    try {
      if (type != null) {
        final response = await supabaseClient
            .from(_tableForType(type))
            .select()
            .eq('id', leagueId)
            .single();

        return _convertResponseToModel(
          response,
          fallbackType: type,
        );
      }

      // Try individual leagues first, then team leagues
      try {
        final individualResponse = await supabaseClient
            .from('individual_leagues')
            .select()
            .eq('id', leagueId)
            .single();

        return _convertResponseToModel(
          individualResponse,
          fallbackType: LeagueType.individual,
        );
      } catch (_) {
        final teamResponse = await supabaseClient
            .from('team_leagues')
            .select()
            .eq('id', leagueId)
            .single();

        return _convertResponseToModel(
          teamResponse,
          fallbackType: LeagueType.team,
        );
      }
    } catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  /// Converts a DB response to a LeagueModel
  LeagueModel _convertResponseToModel(
    Map<String, dynamic> response, {
    LeagueType? fallbackType,
  }) {
    // Normalize supabase response to a mutable Map<String, dynamic>
    final normalizedResponse = Map<String, dynamic>.from(response);

    final inferredType = _inferLeagueTypeFromResponse(
      normalizedResponse,
      fallbackType: fallbackType,
    );

    final jsonData = {
      ...normalizedResponse,
      if (normalizedResponse['created_at'] != null)
        'createdAt': normalizedResponse['created_at'],
      if (normalizedResponse['invite_code'] != null)
        'inviteCode': normalizedResponse['invite_code'],
      'type': inferredType.name,
    };

    return LeagueModel.fromJson(jsonData);
  }

  /// Updates a league in the database
  Future<LeagueModel> _updateLeagueInDb({
    required String leagueId,
    required LeagueType type,
    required Map<String, dynamic> updateData,
  }) async {
    try {
      final table = _tableForType(type);

      final updatedResponse = await supabaseClient
          .from(table)
          .update(updateData)
          .eq('id', leagueId)
          .select()
          .single();

      return _convertResponseToModel(updatedResponse, fallbackType: type);
    } catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  /// Removes every event that targets one of the provided user IDs
  /// and returns the latest league snapshot from the database.
  Future<LeagueModel> _removeEventsForUserIds({
    required LeagueModel league,
    required List<String> userIds,
  }) async {
    if (userIds.isEmpty || league.events.isEmpty) return league;

    LeagueModel updatedLeague = league;
    final Set<String> idsToRemove = userIds.toSet();

    // Iterate over a snapshot of the events because the RPC returns an updated league each time
    for (final event in List<Event>.from(updatedLeague.events)) {
      if (!_isEventTargetingUser(event, idsToRemove)) continue;

      final response = await supabaseClient.rpc(
        'remove_event_from_league',
        params: {
          'p_league_id': updatedLeague.id,
          'p_event_id': event.id,
        },
      );

      if (response == null) {
        throw ServerException('Errore nella rimozione dell\'evento');
      }

      final normalized = Map<String, dynamic>.from(response as Map);

      updatedLeague = _convertResponseToModel(
        normalized,
        fallbackType: updatedLeague.type,
      );
    }

    return updatedLeague;
  }

  bool _isEventTargetingUser(Event event, Set<String> userIds) {
    final target = event.target;

    switch (target.kind) {
      case EventTargetKind.teamMember:
        final memberId = target.memberId ?? target.userId;
        return memberId != null &&
            memberId.isNotEmpty &&
            userIds.contains(memberId);
      case EventTargetKind.individual:
        final userId = target.userId;
        return userId != null && userId.isNotEmpty && userIds.contains(userId);
      case EventTargetKind.team:
        return false;
    }
  }

  LeagueType _inferLeagueTypeFromResponse(
    Map<String, dynamic> response, {
    LeagueType? fallbackType,
  }) {
    final rawType = response['league_type'];

    if (rawType is String) {
      return rawType.toLowerCase() == 'team'
          ? LeagueType.team
          : LeagueType.individual;
    }

    final participants = response['participants'];

    if (participants is List && participants.isNotEmpty) {
      final first = participants.first;

      if (first is Map<String, dynamic>) {
        final participantType = first['type'] as String?;
        if (participantType == 'team') return LeagueType.team;
        if (participantType == 'individual') return LeagueType.individual;
      }
    }

    return fallbackType ?? LeagueType.individual;
  }

  String _tableForType(LeagueType type) {
    return type == LeagueType.team ? 'team_leagues' : 'individual_leagues';
  }

  /// Creates an initial participant when creating a league
  ParticipantModel _createInitialParticipant({
    required LeagueType type,
    required String creatorId,
    required String creatorName,
  }) {
    if (type == LeagueType.team) {
      return TeamParticipantModel(
        members: [
          SimpleParticipantModel(
              userId: creatorId, name: creatorName, points: 0),
        ],
        captainId: creatorId,
        name: 'Team di $creatorName',
        points: 0,
        malusTotal: 0,
        bonusTotal: 0,
        teamLogoUrl: null,
      );
    } else {
      return IndividualParticipantModel(
        userId: creatorId,
        name: creatorName,
        points: 0,
        malusTotal: 0,
        bonusTotal: 0,
      );
    }
  }

  /// Finds team index by name with result object
  ({bool found, int index}) _findTeamByName(
      LeagueModel league, String teamName) {
    for (int i = 0; i < league.participants.length; i++) {
      final participant = league.participants[i];
      if (participant is TeamParticipantModel && participant.name == teamName) {
        return (found: true, index: i);
      }
    }
    return (found: false, index: -1);
  }

  /// Check if any participants to remove are admins
  void _checkForAdminsInParticipants(
    LeagueModel league,
    List<String> participantIds,
  ) {
    for (final userId in participantIds) {
      if (league.admins.contains(userId)) {
        throw ServerException(
            'Non puoi rimuovere un amministratore. Gli amministratori possono solo uscire autonomamente dalla lega.');
      }
    }
  }

  /// Creates memory data
  MemoryModel _createMemoryData({
    required String imageUrl,
    required String text,
    required String userId,
    required String participantName,
    String? relatedEventId,
    String? eventName,
  }) {
    final memoryId = uuid.v4();
    return MemoryModel(
      id: memoryId,
      imageUrl: imageUrl,
      text: text,
      createdAt: DateTime.now(),
      userId: userId,
      participantName: participantName,
      relatedEventId: relatedEventId,
      eventName: eventName,
    );
  }

  /// Gets participant name by user ID
  String _getParticipantNameByUserId(LeagueModel league, String userId) {
    for (final participant in league.participants) {
      if (participant is IndividualParticipantModel &&
          participant.userId == userId) {
        return participant.name;
      } else if (participant is TeamParticipantModel) {
        for (final member in participant.members) {
          if (member.userId == userId) {
            return "${participant.name} - ${member.name}";
          }
        }
      }
    }
    return "Utente";
  }

  /// Finds the team name associated with the provided participant IDs
  String? _inferTeamNameForRemoval(
    LeagueModel league,
    List<String> participantIds,
  ) {
    for (final participant in league.participants) {
      if (participant is TeamParticipantModel &&
          participant.members
              .any((member) => participantIds.contains(member.userId))) {
        return participant.name;
      }
    }
    return null;
  }

  /// Ensures rule points follow type semantics (malus always negative, bonus positive)
  RuleModel _normalizeRulePoints(RuleModel rule) {
    final normalizedPoints =
        rule.type == RuleType.malus ? -rule.points.abs() : rule.points.abs();

    if (normalizedPoints == rule.points) return rule;

    return RuleModel(
      createdAt: rule.createdAt,
      name: rule.name,
      type: rule.type,
      points: normalizedPoints,
    );
  }

  /// Recomputes bonusTotal and malusTotal for participants based on existing events
  LeagueModel _withRecalculatedTotals(LeagueModel league) {
    final bonusByKey = <String, double>{};
    final malusByKey = <String, double>{};

    void addTotals(String key, double points) {
      if (points > 0) {
        bonusByKey[key] = (bonusByKey[key] ?? 0) + points;
      } else if (points < 0) {
        malusByKey[key] = (malusByKey[key] ?? 0) + points.abs();
      }
    }

    if (league.type == LeagueType.team) {
      for (final event in league.events) {
        final teamName = event.target.teamName;
        if (teamName == null || teamName.isEmpty) continue;

        addTotals(teamName, event.points);
      }

      final updatedParticipants = league.participants.map((participant) {
        if (participant is TeamParticipantModel) {
          final bonus = bonusByKey[participant.name] ?? 0;
          final malus = malusByKey[participant.name] ?? 0;
          return participant.copyWith(
            bonusTotal: bonus,
            malusTotal: malus,
          );
        }
        return participant;
      }).toList();

      return league.copyWith(participants: updatedParticipants);
    }

    // Individual league
    for (final event in league.events) {
      final userId = event.target.userId;
      if (userId == null || userId.isEmpty) continue;
      addTotals(userId, event.points);
    }

    final updatedParticipants = league.participants.map((participant) {
      if (participant is IndividualParticipantModel) {
        final bonus = bonusByKey[participant.userId] ?? 0;
        final malus = malusByKey[participant.userId] ?? 0;
        return participant.copyWith(
          bonusTotal: bonus,
          malusTotal: malus,
        );
      }
      return participant;
    }).toList();

    return league.copyWith(participants: updatedParticipants);
  }

  /// Inserts a rule in the correct position based on type
  List<RuleModel> _insertRule({
    required List<RuleModel> existingRules,
    required RuleModel newRule,
    required RuleType ruleType,
  }) {
    // Separate by type
    final List<RuleModel> bonusRules =
        existingRules.where((r) => r.type == RuleType.bonus).toList();

    final List<RuleModel> malusRules =
        existingRules.where((r) => r.type == RuleType.malus).toList();

    // Add to appropriate list
    if (ruleType == RuleType.bonus) {
      bonusRules.add(newRule);
    } else {
      malusRules.add(newRule);
    }

    // Combine in order
    return [...bonusRules, ...malusRules];
  }

  /// Checks if user is already a participant in any of the leagues
  void _checkUserParticipationInLeagues(
    List<LeagueModel> leagues,
    String userId,
  ) {
    for (final league in leagues) {
      for (final participant in league.participants) {
        if (participant is IndividualParticipantModel) {
          if (participant.userId == userId) {
            throw ServerException(
                "Sei già iscritto a questa lega: ${league.name}");
          }
        } else if (participant is TeamParticipantModel) {
          if (participant.members.any((member) => member.userId == userId)) {
            throw ServerException(
                "Sei già iscritto a questa lega: ${league.name}");
          }
        }
      }
    }
  }
}
