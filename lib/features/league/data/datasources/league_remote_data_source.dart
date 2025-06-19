import 'dart:async';
import 'dart:io';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/features/league/data/models/daily_challenge_model/daily_challenge_model.dart';
import 'package:fantavacanze_official/features/league/data/models/individual_participant_model/individual_participant_model.dart';
import 'package:fantavacanze_official/features/league/data/models/league_model/league_model.dart';
import 'package:fantavacanze_official/features/league/data/models/memory_model/memory_model.dart';
import 'package:fantavacanze_official/features/league/data/models/notification_model/daily_challenge_notification/daily_challenge_notification_model.dart';
import 'package:fantavacanze_official/features/league/data/models/notification_model/notification/notification_model.dart';
import 'package:fantavacanze_official/features/league/data/models/participant_model/participant_model.dart';
import 'package:fantavacanze_official/features/league/data/models/rule_model/rule_model.dart';
import 'package:fantavacanze_official/features/league/data/models/team_participant_model/team_participant_model.dart';
import 'package:fantavacanze_official/features/league/data/models/simple_participant_model/simple_participant_model.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule/rule.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
    required bool isTeamMember,
    String? description,
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

  // =====================================================================
  // DAILY CHALLENGE OPERATIONS
  // =====================================================================
  Future<List<DailyChallengeModel>> getDailyChallenges({
    required String userId,
    required String leagueId,
  });

  Future<void> unlockDailyChallenge({
    required String challengeId,
    required bool isUnlocked,
    required String leagueId,
    int primaryPosition = 2,
  });

  Future<void> sendChallengeNotification({
    required LeagueModel league,
    required DailyChallengeModel challenge,
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

  // =====================================================================
  // NOTIFICATION OPERATIONS
  // =====================================================================
  Stream<NotificationModel> listenToNotification();

  Future<List<NotificationModel>> getNotifications();

  Future<void> markAsRead(String notificationId);

  Future<void> deleteNotification(String notificationId);

  Future<void> approveDailyChallenge(String notificationId);

  Future<void> rejectDailyChallenge(
    String notificationId,
    String challengeId,
  );
}

class LeagueRemoteDataSourceImpl implements LeagueRemoteDataSource {
  final SupabaseClient supabaseClient;
  final Uuid uuid;
  final AppUserCubit appUserCubit;

  final _notificationModelController =
      StreamController<NotificationModel>.broadcast();

  Stream<NotificationModel> get notificationModelStream =>
      _notificationModelController.stream;

  void initNotificationListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        // Converti direttamente in NotificationModel
        convertRemoteNotificationToModel(message.notification!, message)
            .then((notificationModel) {
          if (notificationModel != null) {
            _notificationModelController.add(notificationModel);
            debugPrint('📨 Notifica convertita: ${notificationModel.title}');
          }
        });
      }
    });
  }

  LeagueRemoteDataSourceImpl({
    required this.supabaseClient,
    required this.uuid,
    required this.appUserCubit,
  }) {
    initNotificationListener();
  }

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
      await supabaseClient.from('leagues').delete().eq(
            'id',
            leagueId,
          );
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
      await supabaseClient.rpc(
        'exit_league',
        params: {
          'p_user_id': userId,
          'p_league_id': league.id,
        },
      );
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
      final response = await supabaseClient.rpc(
        'remove_team_participants',
        params: {
          'p_league_id': league.id,
          'p_team_name': teamName,
          'p_user_ids_to_remove': userIdsToRemove,
          'p_requesting_user_id': requestingUserId,
        },
      );

      return _convertResponseToModel(response);
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
    required bool isTeamMember,
    String? description,
  }) async {
    return _tryDatabaseOperation(() async {
      final response = await supabaseClient.rpc(
        'add_event',
        params: {
          'p_league_id': league.id,
          'p_event_name': name,
          'p_points': points,
          'p_creator_id': creatorId,
          'p_target_user': targetUser,
          'p_rule_type': type.toString().split('.').last,
          'p_is_team_member': isTeamMember,
          'p_description': description,
        },
      );

      return _convertResponseToModel(response);
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
  // RULE OPERATIONS IMPLEMENTATION
  // =====================================================================
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
  // STORAGE OPERATIONS IMPLEMENTATION
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
  // DAILY CHALLENGE OPERATIONS IMPLEMENTATION
  // =====================================================================

  @override
  Future<List<DailyChallengeModel>> getDailyChallenges({
    required String userId,
    required String leagueId,
  }) async {
    return _tryDatabaseOperation(() async {
      // Call the RPC function to get challenges efficiently
      final response = await supabaseClient.rpc(
        'get_user_daily_challenges',
        params: {
          'p_user_id': userId,
          'p_league_id': leagueId,
        },
      );

      if (response == null) {
        throw ServerException('Impossibile recuperare le sfide giornaliere');
      }

      // Convert to models
      final List<dynamic> challengesJson = response as List<dynamic>;

      final result = challengesJson
          .map((json) => DailyChallengeModel.fromJson(json))
          .toList();

      return result;
    });
  }

  @override
  Future<void> unlockDailyChallenge({
    required String challengeId,
    required bool isUnlocked,
    required String leagueId,
    int primaryPosition = 2,
  }) async {
    return _tryDatabaseOperation(() async {
      // Calculate the substitute position (primary position + 3)
      final substitutePosition = primaryPosition + 3;

      // Use a new RPC function to unlock both challenges at once
      await supabaseClient.rpc(
        'unlock_daily_challenges',
        params: {
          'p_league_id': leagueId,
          'p_primary_position': primaryPosition,
          'p_substitute_position': substitutePosition,
          'p_is_unlocked': isUnlocked,
        },
      );
    });
  }

  @override
  Future<void> sendChallengeNotification({
    required LeagueModel league,
    required DailyChallengeModel challenge,
    required String userId,
  }) async {
    return _tryDatabaseOperation(() async {
      final now = DateTime.now();
      final userName = _getCurrentUserName();

      // Create notification data
      final notificationData = {
        'id': const Uuid().v4(),
        'title': 'Nuova sfida completata',
        'message': '$userName ha completato la sfida "${challenge.name}"',
        'created_at': now.toIso8601String(),
        'is_read': false,
        'type': 'daily_challenge',
        'user_id': userId,
        'league_id': league.id,
        'challenge_id': challenge.id,
        'challenge_name': challenge.name,
        'challenge_points': challenge.points,
        'target_user_ids': league.admins,
      };

      // Insert notification
      await supabaseClient
          .from('daily_challenges_notifications')
          .insert(notificationData)
          .select();
    });
  }

  @override
  Future<void> markChallengeAsCompleted({
    required DailyChallengeModel challenge,
    required LeagueModel league,
    required String userId,
  }) async {
    return _tryDatabaseOperation(() async {
      // 1) Check if the user is an admin
      final isAdmin = league.admins.contains(userId);

      if (isAdmin) {
        // Admin completes challenge directly - Add event and update challenge status
        await addEvent(
          league: league,
          name: challenge.name,
          points: challenge.points,
          creatorId: userId,
          targetUser: userId,
          type: RuleType.bonus,
          isTeamMember: league.isTeamBased,
        );

        // Also update the challenge record to mark it as completed
        await supabaseClient.from('user_daily_challenges').update({
          'is_completed': true,
          'completed_at': DateTime.now().toIso8601String(),
        }).eq('id', challenge.id);
      } else {
        // Non-admin - send notification to admins for approval
        await sendChallengeNotification(
          league: league,
          challenge: challenge,
          userId: userId,
        );

        // Update challenge as pending approval
        await supabaseClient.from('user_daily_challenges').update({
          'is_pending_approval': true,
        }).eq('id', challenge.id);
      }
    });
  }

  @override
  Future<void> updateChallengeRefreshStatus({
    required String challengeId,
    required String userId,
    required bool isRefreshed,
  }) async {
    return _tryDatabaseOperation(
      () async {
        // Update the challenge refresh status in the database
        await supabaseClient
            .from('user_daily_challenges')
            .update({
              'is_refreshed': isRefreshed,
              'refreshed_at': DateTime.now().toIso8601String(),
            })
            .eq('id', challengeId)
            .select();
      },
    );
  }

  // =====================================================================
  // NOTIFICATION OPERATIONS IMPLEMENTATION
  // =====================================================================

  @override
  Future<List<NotificationModel>> getNotifications() async {
    return _tryDatabaseOperation(() async {
      final userId = _checkAuthentication();

      // Use the updated RPC function
      final response = await supabaseClient.rpc(
        'get_user_notifications',
        params: {'p_user_id': userId},
      );

      // The response now contains objects with a "notification" field
      final List<dynamic> notificationsWithDate = response as List<dynamic>;

      // Extract just the notification objects
      final notifications = notificationsWithDate.map((item) {
        final json = item['notification'];

        if (json['type'] == 'daily_challenge') {
          return DailyChallengeNotificationModel.fromJson(json);
        } else {
          return NotificationModel.fromJson(json);
        }
      }).toList();

      return notifications;
    });
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    return _tryDatabaseOperation(() async {
      await supabaseClient.rpc(
        'mark_notification_as_read',
        params: {'p_notification_id': notificationId},
      );
    });
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    return _tryDatabaseOperation(
      () async {
        // Delete from standard notifications table
        await supabaseClient
            .from('notifications')
            .delete()
            .eq('id', notificationId);

        // Delete from daily challenge notifications table
        await supabaseClient
            .from('daily_challenges_notifications')
            .delete()
            .eq('id', notificationId);
      },
    );
  }

  @override
  Future<void> approveDailyChallenge(String notificationId) async {
    return _tryDatabaseOperation(() async {
      final eventId = uuid.v4();

      // Call the RPC function with just the notification ID and necessary parameters
      await supabaseClient.rpc(
        'approve_daily_challenge',
        params: {
          'p_notification_id': notificationId,
          'p_created_at': DateTime.now().toIso8601String(),
          'p_event_id': eventId,
        },
      );
    });
  }

  @override
  Future<void> rejectDailyChallenge(
      String notificationId, String challengeId) async {
    return _tryDatabaseOperation(() async {
      // 1. If we have a challenge ID, update its pending status
      await supabaseClient.from('user_daily_challenges').update({
        'is_pending_approval': false,
      }).eq('id', challengeId);

      // 3. Delete the notification
      await deleteNotification(notificationId);
    });
  }

  @override
  Stream<NotificationModel> listenToNotification() {
    try {
      return notificationModelStream;
    } catch (e) {
      throw ServerException(
          'Errore nell\'ascolto delle notifiche: ${_extractErrorMessage(e)}');
    }
  }

  Future<NotificationModel?> convertRemoteNotificationToModel(
    RemoteNotification notification,
    RemoteMessage message,
  ) async {
    try {
      final data = message.data;
      if (data.isEmpty) return null;

      // Ottieni i dati dal payload FCM o usa valori di default
      final id = data['id'] ?? const Uuid().v4();
      final title = data['title'] ?? notification.title ?? 'Nuova notifica';
      final messageText = data['message'] ?? notification.body ?? '';
      final type = data['type'] ?? 'generic';
      final userId = data['user_id'] ?? _getCurrentUserId() ?? '';
      final leagueId = data['league_id'] ?? '';
      final createdAt = data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : DateTime.now();
      final isRead = data['is_read'] == 'true';

      // Parsing di target_user_ids
      List<String> targetUserIds = [];
      if (data['target_user_ids'] != null) {
        final rawIds = data['target_user_ids'].toString();
        targetUserIds = rawIds.split(',').where((id) => id.isNotEmpty).toList();
      }

      // Crea il modello appropriato in base al tipo
      if (type == 'daily_challenge') {
        return DailyChallengeNotificationModel(
          id: id,
          title: title,
          message: messageText,
          createdAt: createdAt,
          isRead: isRead,
          type: type,
          userId: userId,
          leagueId: leagueId,
          challengeId: data['challenge_id'] ?? '',
          challengeName: data['challenge_name'] ?? '',
          challengePoints:
              double.tryParse(data['challenge_points'] ?? '0') ?? 0.0,
          targetUserIds: targetUserIds,
        );
      } else {
        // Notifica generica
        return NotificationModel(
          id: id,
          title: title,
          message: messageText,
          createdAt: createdAt,
          isRead: isRead,
          type: type,
          leagueId: leagueId,
        );
      }
    } catch (e) {
      debugPrint("⚠️ Errore nella conversione della notifica: $e");
      return null;
    }
  }

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
