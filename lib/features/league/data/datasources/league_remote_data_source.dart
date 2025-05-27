import 'dart:async';
import 'dart:io';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/features/league/data/models/daily_challenge_model.dart';
import 'package:fantavacanze_official/features/league/data/models/event_model.dart';
import 'package:fantavacanze_official/features/league/data/models/individual_participant_model.dart';
import 'package:fantavacanze_official/features/league/data/models/league_model.dart';
import 'package:fantavacanze_official/features/league/data/models/memory_model.dart';
import 'package:fantavacanze_official/features/league/data/models/participant_model.dart';
import 'package:fantavacanze_official/features/league/data/models/rule_model.dart';
import 'package:fantavacanze_official/features/league/data/models/team_participant_model.dart';
import 'package:fantavacanze_official/features/league/data/models/simple_participant_model.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

abstract class LeagueRemoteDataSource {
  // League operations
  Future<LeagueModel> createLeague({
    required String name,
    required String? description,
    required bool isTeamBased,
    required List<RuleModel> rules,
  });
  Future<LeagueModel> getLeague(String leagueId);
  Future<List<LeagueModel>> getUserLeagues();
  Future<LeagueModel> updateLeagueNameOrDescription({
    required String leagueId,
    String? name,
    String? description,
  });
  Future<void> deleteLeague(String leagueId);
  Future<List<LeagueModel>> searchLeague({required String inviteCode});
  Future<LeagueModel> updateLeagueInfo({
    required LeagueModel league,
    String? name,
    String? description,
  });

  // Participant operations
  Future<LeagueModel> joinLeague({
    required String inviteCode,
    String? teamName,
    List<String>? teamMembers,
    String? specificLeagueId,
  });
  Future<void> exitLeague({
    required LeagueModel league,
    required String userId,
  });
  Future<LeagueModel> removeTeamParticipants({
    required LeagueModel league,
    required String teamName,
    required List<String> userIdsToRemove,
    required String requestingUserId,
  });
  Future<LeagueModel> updateTeamName({
    required LeagueModel league,
    required String userId,
    required String newName,
  });
  Future<LeagueModel> addAdministrators({
    required LeagueModel league,
    required List<String> userIds,
  });
  Future<LeagueModel> removeParticipants({
    required LeagueModel league,
    required List<String> participantIds,
    String? newCaptainId,
  });

  // Event operations
  Future<LeagueModel> addEvent({
    required LeagueModel league,
    required String name,
    required double points,
    required String creatorId,
    required String targetUser,
    required RuleType type,
    required bool isTeamMember,
    String? description,
  });

  // Memory operations
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

  // Rule operations
  Future<List<RuleModel>> getRules({required String mode});
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

  // Storage operations
  Future<String> uploadImage({
    required String leagueId,
    required File imageFile,
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

  // Daily challenge operations
  Future<List<DailyChallengeModel>> getDailyChallenges({
    required String userId,
  });
  Future<void> markChallengeAsCompleted({
    required DailyChallengeModel challenge,
    required LeagueModel league,
    required String userId,
  });
  Future<void> updateChallengeRefreshStatus({
    required String challengeId,
    required String userId,
    required bool isRefreshed,
  });
}

class LeagueRemoteDataSourceImpl implements LeagueRemoteDataSource {
  final SupabaseClient supabaseClient;
  final Uuid uuid;
  final AppUserCubit appUserCubit;

  // Cache for current user data to avoid repeated AppUserCubit access
  String? _cachedUserId;
  String? _cachedUserName;

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
    if (_cachedUserId != null) return _cachedUserId;

    final state = appUserCubit.state;
    if (state is AppUserIsLoggedIn) {
      _cachedUserId = state.user.id;
      return _cachedUserId;
    }
    return null;
  }

  /// Gets the current user name from cache or cubit, never returns null
  String _getCurrentUserName() {
    // Return cached username if available
    if (_cachedUserName != null) return _cachedUserName!;

    // Try to get username from AppUserCubit
    final state = appUserCubit.state;
    if (state is AppUserIsLoggedIn) {
      _cachedUserName = state.user.name;
      return _cachedUserName ?? "Utente";
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
      throw ServerException(_extractErrorMessage(e));
    }
  }

  // =====================================================================
  // LEAGUE OPERATIONS
  // =====================================================================

  @override
  Future<LeagueModel> createLeague({
    required String name,
    required String? description,
    required bool isTeamBased,
    required List<RuleModel> rules,
  }) async {
    return _tryDatabaseOperation(() async {
      final String leagueId = uuid.v4();
      final String inviteCode = uuid.v4().substring(0, 10);

      // Get creator info
      final creatorId = _checkAuthentication();
      final creatorName = _getCurrentUserName();

      // Create initial participant
      final initialParticipant = _createInitialParticipant(
        isTeamBased: isTeamBased,
        creatorId: creatorId,
        creatorName: creatorName,
      );

      // Create league data using models directly
      final leagueData = {
        'id': leagueId,
        'invite_code': inviteCode,
        'admins': [creatorId],
        'name': name,
        'description': description,
        'created_at': DateTime.now().toIso8601String(),
        'rules': rules.map((rule) => rule.toJson()).toList(),
        'participants': [initialParticipant.toJson()],
        'events': [],
        'memories': [],
        'is_team_based': isTeamBased,
      };

      await supabaseClient.from('leagues').insert(leagueData);

      // Get the created league
      final response = await supabaseClient
          .from('leagues')
          .select()
          .eq('id', leagueId)
          .single();

      return _convertResponseToModel(response);
    });
  }

  @override
  Future<LeagueModel> getLeague(String leagueId) async {
    return _getLeagueData(leagueId);
  }

  @override
  Future<List<LeagueModel>> getUserLeagues() async {
    return _tryDatabaseOperation(() async {
      final currentUserId = _checkAuthentication();

      // Use the RPC function to efficiently get all user leagues in a single call
      List<Map<String, dynamic>> leaguesResponse = await supabaseClient.rpc(
        'get_user_leagues',
        params: {'p_user_id': currentUserId},
      );

      // Convert to models directly
      return leaguesResponse
          .map((league) => _convertResponseToModel(league))
          .toList();
    });
  }

  @override
  Future<LeagueModel> updateLeagueNameOrDescription({
    required String leagueId,
    String? name,
    String? description,
  }) async {
    return _tryDatabaseOperation(() async {
      final Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;

      if (updateData.isEmpty) {
        // Nothing to update, return current league
        return await _getLeagueData(leagueId);
      }

      return await _updateLeagueInDb(
        leagueId: leagueId,
        updateData: updateData,
      );
    });
  }

  @override
  Future<void> deleteLeague(String leagueId) async {
    return _tryDatabaseOperation(() async {
      await supabaseClient.from('leagues').delete().eq('id', leagueId);
    });
  }

  @override
  Future<List<LeagueModel>> searchLeague({required String inviteCode}) async {
    return _tryDatabaseOperation(() async {
      // Use RPC function to efficiently search leagues
      final response = await supabaseClient.rpc(
        'search_league_by_invite_code',
        params: {'p_invite_code': inviteCode},
      );

      final result = response as Map<String, dynamic>;
      final leaguesJson = result['leagues'] as List<dynamic>? ?? [];

      // Convert to models
      final leagues = leaguesJson
          .map((json) =>
              _convertResponseToModel(Map<String, dynamic>.from(json)))
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
        updateData: updateData,
      );
    });
  }

  // =====================================================================
  // PARTICIPANT OPERATIONS
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

      // Create a SimpleParticipantModel for the current user
      final currentUserParticipant = SimpleParticipantModel(
          userId: currentUserId, name: currentUserName, points: 0);

      // Use RPC function for joining league
      final response = await supabaseClient.rpc(
        'join_league',
        params: {
          'p_user_id': currentUserId,
          'p_user_name': currentUserName,
          'p_invite_code': inviteCode,
          'p_team_name': teamName,
          'p_specific_league_id': specificLeagueId,
          'p_member_details': currentUserParticipant.toJson(),
        },
      );

      final result = response as Map<String, dynamic>;
      final status = result['status'] as String;

      if (status == 'joined') {
        final leagueData = result['league'] as Map<String, dynamic>;
        return _convertResponseToModel(leagueData);
      } else {
        throw ServerException('Risposta inattesa dal server');
      }
    });
  }

  @override
  Future<void> exitLeague({
    required LeagueModel league,
    required String userId,
  }) async {
    return _tryDatabaseOperation(() async {
      // Handle different league types efficiently
      if (league.isTeamBased) {
        await _exitTeamLeague(league, userId);
      } else {
        await _exitIndividualLeague(league, userId);
      }
    });
  }

  @override
  Future<LeagueModel> removeTeamParticipants({
    required LeagueModel league,
    required String teamName,
    required List<String> userIdsToRemove,
    required String requestingUserId,
  }) async {
    return _tryDatabaseOperation(() async {
      // Find the team
      final teamResult = _findTeamByName(league, teamName);
      if (!teamResult.found) {
        throw ServerException('Team non trovato');
      }

      final teamIndex = teamResult.index;
      final teamParticipant =
          league.participants[teamIndex] as TeamParticipantModel;

      // Verify permissions
      _verifyTeamRemovalPermissions(
        league: league,
        teamParticipant: teamParticipant,
        requestingUserId: requestingUserId,
        userIdsToRemove: userIdsToRemove,
      );

      // Filter members
      final updatedMembers = teamParticipant.members
          .where((member) => !userIdsToRemove.contains(member.userId))
          .toList();

      // Verify at least one member remains
      if (updatedMembers.isEmpty) {
        throw ServerException(
            'Non puoi rimuovere tutti i membri del team. Il team deve avere almeno un membro.');
      }

      // Create updated team
      final updatedTeam = TeamParticipantModel(
        members: updatedMembers,
        captainId: teamParticipant.captainId,
        name: teamParticipant.name,
        points: teamParticipant.points,
        malusTotal: teamParticipant.malusTotal,
        bonusTotal: teamParticipant.bonusTotal,
        teamLogoUrl: teamParticipant.teamLogoUrl,
      );

      // Update the participants list
      final List<dynamic> updatedParticipants = [...league.participants];
      updatedParticipants[teamIndex] = updatedTeam;

      // Update in database
      return await _updateLeagueInDb(
        leagueId: league.id,
        updateData: {
          'participants': updatedParticipants
              .map((p) => (p as ParticipantModel).toJson())
              .toList(),
        },
      );
    });
  }

  @override
  Future<LeagueModel> updateTeamName({
    required LeagueModel league,
    required String userId,
    required String newName,
  }) async {
    return _tryDatabaseOperation(() async {
      if (!league.isTeamBased) {
        throw ServerException('Questa non è una lega basata su squadre');
      }

      // Find user's team
      final teamIndex = _findUserTeamIndex(league, userId);
      if (teamIndex == -1) {
        throw ServerException('L\'utente non fa parte di nessuna squadra');
      }

      // Update team name efficiently
      final updatedParticipants = league.participants.map((p) {
        final participant = p as ParticipantModel;
        if (participant is TeamParticipantModel &&
            participant.members.any((member) => member.userId == userId)) {
          return participant.copyWith(name: newName).toJson();
        }
        return participant.toJson();
      }).toList();

      // Update in Supabase
      return await _updateLeagueInDb(
        leagueId: league.id,
        updateData: {'participants': updatedParticipants},
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
        updateData: {'admins': uniqueAdmins.toList()},
      );
    });
  }

  @override
  Future<LeagueModel> removeParticipants({
    required LeagueModel league,
    required List<String> participantIds,
    String? newCaptainId,
  }) async {
    return _tryDatabaseOperation(() async {
      _checkAuthentication();

      // Check if any participants to remove are admins
      _checkForAdminsInParticipants(league, participantIds);

      // Process all participants in a single pass
      List<dynamic> updatedParticipants = [];

      for (final participant in league.participants) {
        if (participant is IndividualParticipantModel) {
          // Keep individual participants not in the remove list
          if (!participantIds.contains(participant.userId)) {
            updatedParticipants.add(participant);
          }
        } else if (participant is TeamParticipantModel) {
          // Process team participants
          final updatedTeam = _processTeamParticipantRemoval(
            team: participant,
            participantIds: participantIds,
            newCaptainId: newCaptainId,
          );

          if (updatedTeam != null) {
            updatedParticipants.add(updatedTeam);
          }
        }
      }

      // Update in Supabase
      return await _updateLeagueInDb(
        leagueId: league.id,
        updateData: {
          'participants': updatedParticipants
              .map((p) => (p as ParticipantModel).toJson())
              .toList(),
        },
      );
    });
  }

  // =====================================================================
  // EVENT OPERATIONS
  // =====================================================================

  @override
  Future<LeagueModel> addEvent({
    required LeagueModel league,
    required String name,
    required double points,
    required String creatorId,
    required String targetUser,
    required RuleType type,
    required bool isTeamMember,
    String? description,
  }) async {
    return _tryDatabaseOperation(() async {
      // Find the target participant
      final targetResult = _findTargetParticipantData(
        league: league,
        targetUser: targetUser,
        isTeamMember: isTeamMember,
      );

      if (targetResult.participant == null) {
        throw ServerException('Destinatario non trovato nella lega');
      }

      // Create event
      final eventData = _createEventData(
        name: name,
        points: points,
        creatorId: creatorId,
        targetUser: targetResult.actualTargetUser,
        type: type,
        description: description,
        isTeamMember: isTeamMember,
      );

      // Update events list
      final updatedEvents = _getUpdatedEventsList(league.events, eventData);

      // Update participant score
      final updatedParticipants = _updateParticipantScore(
        league: league,
        targetParticipant: targetResult.participant!,
        targetUser: targetResult.actualTargetUser,
        points: points,
        isTeamMember: isTeamMember,
      );

      // Update in Supabase in a single operation
      return await _updateLeagueInDb(
        leagueId: league.id,
        updateData: {
          'participants': updatedParticipants,
          'events': updatedEvents.map((e) => e.toJson()).toList(),
        },
      );
    });
  }

  // =====================================================================
  // MEMORY OPERATIONS
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
        url: memoryToRemove.imageUrl,
      );

      // Remove the memory efficiently
      final updatedMemories = league.memories
          .where((m) => (m as MemoryModel).id != memoryId)
          .map((m) => (m as MemoryModel).toJson())
          .toList();

      // Update in Supabase
      return await _updateLeagueInDb(
        leagueId: league.id,
        updateData: {'memories': updatedMemories},
      );
    });
  }

  // =====================================================================
  // RULE OPERATIONS
  // =====================================================================

  @override
  Future<List<RuleModel>> getRules({required String mode}) async {
    return _tryDatabaseOperation(() async {
      // Query the appropriate table
      final tableName = mode == "hard" ? "hard_rules" : "soft_rules";

      // Execute the query
      final response = await supabaseClient.from(tableName).select();

      // Parse the response directly into models
      return (response as List)
          .map((ruleJson) => RuleModel.fromJson(ruleJson))
          .toList();
    });
  }

  @override
  Future<LeagueModel> updateRule({
    required LeagueModel league,
    required RuleModel rule,
    String? originalRuleName,
  }) async {
    return _tryDatabaseOperation(() async {
      // Find the rule to update
      final nameToFind = originalRuleName ?? rule.name;

      // Efficiently map the rules
      final updatedRulesList = league.rules.map((currentRule) {
        if (currentRule.name == nameToFind) {
          return rule;
        }
        return currentRule;
      }).toList();

      // Prepare for database update
      final List<Map<String, dynamic>> rulesJson =
          updatedRulesList.map((rule) => (rule as RuleModel).toJson()).toList();

      // Update in Supabase
      return await _updateLeagueInDb(
        leagueId: league.id,
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
      // Filter out the rule to delete efficiently
      final remainingRules = league.rules
          .where((r) => r.name != ruleName && !r.name.contains(ruleName))
          .map((r) => (r as RuleModel).toJson())
          .toList();

      // Update in Supabase
      return await _updateLeagueInDb(
        leagueId: league.id,
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
      // Get existing rules
      final List<RuleModel> existingRules =
          league.rules.map((r) => r as RuleModel).toList();

      // Insert the new rule
      final List<RuleModel> updatedRules = _insertRule(
        existingRules: existingRules,
        newRule: rule,
        ruleType: rule.type,
      );

      // Update in Supabase
      return await _updateLeagueInDb(
        leagueId: league.id,
        updateData: {
          'rules': updatedRules.map((r) => r.toJson()).toList(),
        },
      );
    });
  }

  // =====================================================================
  // STORAGE OPERATIONS
  // =====================================================================

  @override
  Future<String> uploadImage({
    required String leagueId,
    required File imageFile,
  }) async {
    return _tryDatabaseOperation(() async {
      final path = leagueId;
      return await _uploadImageToStorage(
        bucket: 'memories',
        path: path,
        imageFile: imageFile,
        expiresIn: 60 * 60 * 24 * 365, // 1 year
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
      final path = '$leagueId/$teamName';
      return await _uploadImageToStorage(
        bucket: 'team-logos',
        path: path,
        imageFile: imageFile,
        expiresIn: 60 * 60 * 24 * 365, // 1 year
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
      // Find the team efficiently
      final teamResult = _findTeamByName(league, teamName);
      if (!teamResult.found) {
        throw ServerException('Team non trovato');
      }

      final teamIndex = teamResult.index;
      final teamParticipant =
          league.participants[teamIndex] as TeamParticipantModel;

      // Delete old logo if exists
      if (teamParticipant.teamLogoUrl != null &&
          teamParticipant.teamLogoUrl!.isNotEmpty) {
        await _deleteFileFromStorage(
          bucket: 'team-logos',
          url: teamParticipant.teamLogoUrl!,
        );
      }

      // Update team with new logo
      final updatedTeam = teamParticipant.copyWith(teamLogoUrl: logoUrl);
      final updatedParticipants = List<dynamic>.from(league.participants);
      updatedParticipants[teamIndex] = updatedTeam;

      // Update in Supabase
      return await _updateLeagueInDb(
        leagueId: league.id,
        updateData: {
          'participants': updatedParticipants
              .map((p) => (p as ParticipantModel).toJson())
              .toList()
        },
      );
    });
  }

  // =====================================================================
  // DAILY CHALLENGE OPERATIONS
  // =====================================================================

  @override
  Future<List<DailyChallengeModel>> getDailyChallenges({
    required String userId,
  }) async {
    return _tryDatabaseOperation(() async {
      // Call the RPC function to get challenges efficiently
      final response = await supabaseClient.rpc(
        'get_daily_challenges',
        params: {'p_user_id': userId},
      );

      if (response == null) {
        throw ServerException('Impossibile recuperare le sfide giornaliere');
      }

      // Convert to models
      final List<dynamic> challengesJson = response as List<dynamic>;
      return challengesJson
          .map((json) => DailyChallengeModel.fromJson(json))
          .toList();
    });
  }

  @override
  Future<void> markChallengeAsCompleted({
    required DailyChallengeModel challenge,
    required LeagueModel league,
    required String userId,
  }) async {
    return _tryDatabaseOperation(() async {
      // 1) Update the challenge as completed in the database
      await supabaseClient.from('user_daily_challenges').update({
        'is_completed': true,
        'completed_at': DateTime.now().toIso8601String(),
      }).eq('id', challenge.id);

      // 2) Check if user is an admin of this league
      final isAdmin = league.admins.contains(userId);

      if (isAdmin) {
        // Reuse the existing addEvent method to avoid code duplication
        await addEvent(
          league: league,
          name: challenge.name,
          points: challenge.points,
          creatorId: userId,
          targetUser: userId,
          type: challenge.points >= 0 ? RuleType.bonus : RuleType.malus,
          isTeamMember: league.isTeamBased,
          description: 'Obiettivo giornaliero completato',
        );
      } else {
        // 3) If not admin, create notifications for all admins
        final now = DateTime.now().toIso8601String();
        final userName = _getCurrentUserName();

        final notifications = league.admins
            .map((adminId) => {
                  'id': uuid.v4(),
                  'title': 'Obiettivo Completato',
                  'message':
                      '$userName ha completato l\'obiettivo: ${challenge.name}',
                  'created_at': now,
                  'is_read': false,
                  'type': 'challengeCompletion',
                  'league_id': league.id,
                  'challenge_id': challenge.id,
                  'challenge_name': challenge.name,
                  'challenge_points': challenge.points,
                  'user_id': userId,
                  'target_user_id': adminId,
                })
            .toList();

        // Insert notifications in batch if any exist
        if (notifications.isNotEmpty) {
          await supabaseClient.from('notifications').insert(notifications);
        }
      }
    });
  }

  @override
  Future<void> updateChallengeRefreshStatus({
    required String challengeId,
    required String userId,
    required bool isRefreshed,
  }) async {
    return _tryDatabaseOperation(() async {
      // Update the challenge refresh status in the database
      await supabaseClient.from('user_daily_challenges').update({
        'is_refreshed': isRefreshed,
        'refreshed_at': DateTime.now().toIso8601String(),
      }).eq('id', challengeId);

      // No need to fetch the updated data - the app will reload challenges when needed
    });
  }

  // =====================================================================
  // NOTIFICATION OPERATIONS
  // =====================================================================

  // =====================================================================
  // PRIVATE HELPER METHODS
  // =====================================================================

  /// Uploads an image to storage
  Future<String> _uploadImageToStorage({
    required String bucket,
    required String path,
    required File imageFile,
    required int expiresIn,
  }) async {
    try {
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final fileName = '$currentTime.jpg';
      final fullPath =
          path.endsWith('/') ? '$path$fileName' : '$path/$fileName';

      await supabaseClient.storage.from(bucket).upload(
            fullPath,
            imageFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
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
  Future<LeagueModel> _getLeagueData(String leagueId) async {
    try {
      final response = await supabaseClient
          .from('leagues')
          .select()
          .eq('id', leagueId)
          .single();

      return _convertResponseToModel(response);
    } catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  /// Converts a DB response to a LeagueModel
  LeagueModel _convertResponseToModel(Map<String, dynamic> response) {
    final jsonData = {
      ...response,
      'createdAt': response['created_at'],
      'isTeamBased': response['is_team_based'],
      if (response['invite_code'] != null)
        'inviteCode': response['invite_code'],
    };

    return LeagueModel.fromJson(jsonData);
  }

  /// Updates a league in the database
  Future<LeagueModel> _updateLeagueInDb({
    required String leagueId,
    required Map<String, dynamic> updateData,
  }) async {
    try {
      final updatedResponse = await supabaseClient
          .from('leagues')
          .update(updateData)
          .eq('id', leagueId)
          .select()
          .single();

      return _convertResponseToModel(updatedResponse);
    } catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  /// Creates an initial participant when creating a league
  ParticipantModel _createInitialParticipant({
    required bool isTeamBased,
    required String creatorId,
    required String creatorName,
  }) {
    if (isTeamBased) {
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

  /// Verifies permissions for team member removal
  void _verifyTeamRemovalPermissions({
    required LeagueModel league,
    required TeamParticipantModel teamParticipant,
    required String requestingUserId,
    required List<String> userIdsToRemove,
  }) {
    // Check if user has permission (admin or captain)
    final bool isAdmin = league.admins.contains(requestingUserId);
    final bool isCaptain = teamParticipant.captainId == requestingUserId;

    if (!isAdmin && !isCaptain) {
      throw ServerException(
          'Solo gli amministratori o il capitano del team possono rimuovere membri');
    }

    // Check if trying to remove admins
    for (final userId in userIdsToRemove) {
      if (league.admins.contains(userId)) {
        throw ServerException(
            'Non puoi rimuovere un amministratore. Gli amministratori possono solo uscire autonomamente dalla lega.');
      }
    }

    // Check if trying to remove captain
    if (userIdsToRemove.contains(teamParticipant.captainId)) {
      throw ServerException(
          'Il capitano non può essere rimosso dal team. Trasferisci prima il ruolo di capitano a un altro membro.');
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

  /// Process team participant removal with captain handling
  TeamParticipantModel? _processTeamParticipantRemoval({
    required TeamParticipantModel team,
    required List<String> participantIds,
    String? newCaptainId,
  }) {
    // Check if captain is being removed
    final isCaptainBeingRemoved = participantIds.contains(team.captainId);

    // Filter out members to remove
    final updatedMembers = team.members
        .where((member) => !participantIds.contains(member.userId))
        .toList();

    // Check if team will be empty
    if (updatedMembers.isEmpty) {
      throw ServerException(
          'Non puoi rimuovere tutti i membri del team. Il team deve avere almeno un membro.');
    }

    // If captain is being removed, validate new captain
    String captainId = team.captainId;
    if (isCaptainBeingRemoved) {
      if (newCaptainId == null ||
          !updatedMembers.any((member) => member.userId == newCaptainId)) {
        throw ServerException(
            'Il nuovo capitano specificato non è un membro valido del team.');
      }
      captainId = newCaptainId;
    }

    // Return updated team
    return TeamParticipantModel(
      members: updatedMembers,
      name: team.name,
      points: team.points,
      malusTotal: team.malusTotal,
      bonusTotal: team.bonusTotal,
      captainId: captainId,
      teamLogoUrl: team.teamLogoUrl,
    );
  }

  /// Check if any participants to remove are admins
  void _checkForAdminsInParticipants(
      LeagueModel league, List<String> participantIds) {
    for (final userId in participantIds) {
      if (league.admins.contains(userId)) {
        throw ServerException(
            'Non puoi rimuovere un amministratore. Gli amministratori possono solo uscire autonomamente dalla lega.');
      }
    }
  }

  /// Handles exit from a team-based league
  Future<void> _exitTeamLeague(LeagueModel league, String userId) async {
    // Find user's team
    int teamIndex = -1;
    TeamParticipantModel? team;

    for (int i = 0; i < league.participants.length; i++) {
      final participant = league.participants[i];
      if (participant is TeamParticipantModel &&
          participant.members.any((member) => member.userId == userId)) {
        teamIndex = i;
        team = participant;
        break;
      }
    }

    if (teamIndex == -1 || team == null) {
      throw ServerException('Utente non trovato in nessun team della lega');
    }

    // If last member, handle team removal
    if (team.members.length == 1) {
      if (league.participants.length == 1) {
        // If last team in league, delete league
        await deleteLeague(league.id);
        return;
      }

      // Remove the team
      final updatedParticipants = List<dynamic>.from(league.participants)
        ..removeAt(teamIndex);

      await _updateLeagueInDb(
        leagueId: league.id,
        updateData: {
          'participants': updatedParticipants
              .map((p) => (p as ParticipantModel).toJson())
              .toList(),
        },
      );
      return;
    }

    // Remove user from team
    final updatedMembers =
        team.members.where((member) => member.userId != userId).toList();

    // Create updated team
    final updatedTeam = TeamParticipantModel(
      members: updatedMembers,
      captainId: team.captainId == userId
          ? updatedMembers.first.userId
          : team.captainId,
      name: team.name,
      points: team.points,
      malusTotal: team.malusTotal,
      bonusTotal: team.bonusTotal,
      teamLogoUrl: team.teamLogoUrl,
    );

    // Update participants list
    final updatedParticipants = List<dynamic>.from(league.participants);
    updatedParticipants[teamIndex] = updatedTeam;

    await _updateLeagueInDb(
      leagueId: league.id,
      updateData: {
        'participants': updatedParticipants
            .map((p) => (p as ParticipantModel).toJson())
            .toList(),
      },
    );
  }

  /// Handles exit from an individual league
  Future<void> _exitIndividualLeague(LeagueModel league, String userId) async {
    // Find participant index
    int participantIndex = -1;

    for (int i = 0; i < league.participants.length; i++) {
      final participant = league.participants[i];
      if (participant is IndividualParticipantModel &&
          participant.userId == userId) {
        participantIndex = i;
        break;
      }
    }

    if (participantIndex == -1) {
      throw ServerException('Utente non trovato nei partecipanti della lega');
    }

    // If last participant, delete league
    if (league.participants.length == 1) {
      await deleteLeague(league.id);
      return;
    }

    // Remove participant
    final updatedParticipants = List<dynamic>.from(league.participants)
      ..removeAt(participantIndex);

    await _updateLeagueInDb(
      leagueId: league.id,
      updateData: {
        'participants': updatedParticipants
            .map((p) => (p as ParticipantModel).toJson())
            .toList(),
      },
    );
  }

  /// Finds user's team index
  int _findUserTeamIndex(LeagueModel league, String userId) {
    for (int i = 0; i < league.participants.length; i++) {
      final participant = league.participants[i];
      if (participant is TeamParticipantModel &&
          participant.members.any((member) => member.userId == userId)) {
        return i;
      }
    }
    return -1;
  }

  /// Creates event data
  EventModel _createEventData({
    required String name,
    required double points,
    required String creatorId,
    required String targetUser,
    required RuleType type,
    String? description,
    bool isTeamMember = false,
  }) {
    final eventId = uuid.v4();
    return EventModel(
      id: eventId,
      name: name,
      points: points,
      creatorId: creatorId,
      targetUser: targetUser,
      createdAt: DateTime.now(),
      type: type,
      description: description,
      isTeamMember: isTeamMember,
    );
  }

  /// Updates events list with new event
  List<EventModel> _getUpdatedEventsList(
      List<dynamic> currentEvents, EventModel newEvent) {
    // Add new event
    List<EventModel> updatedEvents = [
      ...currentEvents.map((e) => e as EventModel),
      newEvent,
    ];

    // If more than 10 events, remove oldest
    if (updatedEvents.length > 10) {
      updatedEvents.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      updatedEvents = updatedEvents.sublist(1); // Remove oldest
    }

    return updatedEvents;
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

  /// Finds target participant with additional information
  ({ParticipantModel? participant, String actualTargetUser})
      _findTargetParticipantData({
    required LeagueModel league,
    required String targetUser,
    bool isTeamMember = false,
  }) {
    if (league.isTeamBased && isTeamMember) {
      // Find team containing the member
      for (final p in league.participants) {
        if (p is TeamParticipantModel) {
          for (final member in p.members) {
            if (member.userId == targetUser) {
              return (participant: p, actualTargetUser: targetUser);
            }
          }
        }
      }
    } else {
      // Standard participant lookup
      for (final p in league.participants) {
        if (p is ParticipantModel) {
          if (league.isTeamBased) {
            if (p is TeamParticipantModel && p.name == targetUser) {
              return (participant: p, actualTargetUser: targetUser);
            }
          } else if (p is IndividualParticipantModel &&
              p.userId == targetUser) {
            return (participant: p, actualTargetUser: targetUser);
          }
        }
      }
    }
    return (participant: null, actualTargetUser: targetUser);
  }

  /// Updates participant score and returns updated participants
  List<dynamic> _updateParticipantScore({
    required LeagueModel league,
    required ParticipantModel targetParticipant,
    required String targetUser,
    required double points,
    bool isTeamMember = false,
  }) {
    final participantJson = targetParticipant.toJson();

    // Ensure all values are doubles
    double currentPoints = participantJson['points'] is int
        ? (participantJson['points'] as int).toDouble()
        : (participantJson['points'] as double);

    double updatedScore = currentPoints + points;

    // Update bonus/malus totals
    double updatedBonusTotal = participantJson['bonusTotal'] is int
        ? (participantJson['bonusTotal'] as int).toDouble()
        : (participantJson['bonusTotal'] as double? ?? 0.0);

    double updatedMalusTotal = participantJson['malusTotal'] is int
        ? (participantJson['malusTotal'] as int).toDouble()
        : (participantJson['malusTotal'] as double? ?? 0.0);

    if (points > 0) {
      updatedBonusTotal += points;
    } else if (points < 0) {
      updatedMalusTotal += points.abs();
    }

    // Create updated participant data
    final updatedParticipantData = {
      ...participantJson,
      'points': updatedScore,
      'bonusTotal': updatedBonusTotal,
      'malusTotal': updatedMalusTotal,
    };

    // Handle team member scoring
    if (league.isTeamBased && targetParticipant is TeamParticipantModel) {
      if (isTeamMember) {
        // Update specific member
        final updatedMembers = targetParticipant.members.map((member) {
          if (member.userId == targetUser) {
            double memberPoints = member.points is int
                ? (member.points as int).toDouble()
                : member.points;
            return {
              ...(member as SimpleParticipantModel).toJson(),
              'points': memberPoints + points,
            };
          }
          return (member as SimpleParticipantModel).toJson();
        }).toList();
        updatedParticipantData['members'] = updatedMembers;
      } else {
        // Distribute points to all members
        final int memberCount = targetParticipant.members.length;
        final double pointsPerMember =
            memberCount > 0 ? points / memberCount : 0;

        final updatedMembers = targetParticipant.members.map((member) {
          double memberPoints = member.points is int
              ? (member.points as int).toDouble()
              : member.points;
          return {
            ...(member as SimpleParticipantModel).toJson(),
            'points': memberPoints + pointsPerMember,
          };
        }).toList();
        updatedParticipantData['members'] = updatedMembers;
      }
    }

    // Update participant in list
    return league.participants.map((p) {
      if (p is ParticipantModel) {
        if (p == targetParticipant) {
          return updatedParticipantData;
        }
      }
      return p is ParticipantModel ? p.toJson() : p;
    }).toList();
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
      List<LeagueModel> leagues, String userId) {
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
