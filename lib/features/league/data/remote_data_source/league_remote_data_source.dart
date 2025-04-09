import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/errors/server_exception.dart';
import 'package:fantavacanze_official/features/league/data/models/event_model.dart';
import 'package:fantavacanze_official/features/league/data/models/league_model.dart';
import 'package:fantavacanze_official/features/league/data/models/memory_model.dart';
import 'package:fantavacanze_official/features/league/data/models/participant_model.dart';
import 'package:fantavacanze_official/features/league/data/models/rule_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

abstract class LeagueRemoteDataSource {
  Future<LeagueModel> createLeague({
    required String name,
    required String description,
    required bool isTeamBased,
    required List<String> admins,
    required List<Map<String, dynamic>> rules,
  });

  Future<LeagueModel> getLeague(String leagueId);
  Future<List<LeagueModel>> getUserLeagues();
  Future<LeagueModel> updateLeague({
    required String leagueId,
    String? name,
    String? description,
  });
  Future<void> deleteLeague(String leagueId);

  Future<LeagueModel> joinLeague({
    required String inviteCode,
    required String userId,
    String? teamName,
    List<String>? teamMembers,
    String? specificLeagueId,
  });

  Future<LeagueModel> exitLeague({
    required String leagueId,
    required String userId,
  });

  Future<LeagueModel> updateTeamName({
    required String leagueId,
    required String userId,
    required String newName,
  });

  Future<LeagueModel> addEvent({
    required String leagueId,
    required String name,
    required int points,
    required String userId,
    String? description,
  });

  Future<LeagueModel> removeEvent({
    required String leagueId,
    required String eventId,
  });

  Future<LeagueModel> addMemory({
    required String leagueId,
    required String imageUrl,
    required String text,
    required String userId,
    String? relatedEventId,
  });

  Future<LeagueModel> removeMemory({
    required String leagueId,
    required String memoryId,
  });

  /// Fetches rules from Supabase based on mode
  /// [mode] can be either "hard" or "soft"
  /// Returns a list of [RuleModel]
  /// Throws [ServerException] if there's a problem with the server
  Future<List<RuleModel>> getRules({required String mode});
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

  String? _getCurrentUserId() {
    final state = appUserCubit.state;
    if (state is AppUserIsLoggedIn) {
      return state.user.id;
    }
    return null;
  }

  String? _getCurrentUserName() {
    final state = appUserCubit.state;
    if (state is AppUserIsLoggedIn) {
      return state.user.name;
    }
    return null;
  }

  @override
  Future<LeagueModel> createLeague({
    required String name,
    required String description,
    required bool isTeamBased,
    required List<String> admins,
    required List<Map<String, dynamic>> rules,
  }) async {
    try {
      final String leagueId = uuid.v4();

      // Generate a secure 10-character invite code
      final String inviteCode = uuid.v4().substring(0, 10);

      // Get creator info
      final creatorId = _getCurrentUserId();
      final creatorName = _getCurrentUserName();

      if (creatorId == null || creatorName == null) {
        throw ServerException('Utente non autenticato');
      }

      // Create initial participant based on league type
      final Map<String, dynamic> initialParticipant;
      if (isTeamBased) {
        initialParticipant = {
          'type': 'team',
          'userIds': [creatorId],
          'name': '$creatorName Team', // Default team name
          'score': 0,
          'malusTotal': 0,
          'bonusTotal': 0,
        };
      } else {
        initialParticipant = {
          'type': 'individual',
          'userId': creatorId,
          'name': creatorName,
          'score': 0,
          'malusTotal': 0,
          'bonusTotal': 0,
        };
      }

      final leagueData = {
        'id': leagueId,
        'invite_code': inviteCode,
        'admins': admins,
        'name': name,
        'description': description,
        'created_at': DateTime.now().toIso8601String(),
        'rules': rules,
        'participants': [initialParticipant],
        'events': [],
        'memories': [],
        'is_team_based': isTeamBased,
      };

      final response = await supabaseClient
          .from('leagues')
          .insert(leagueData)
          .select()
          .single();

      // Convert to our model format
      final jsonData = {
        ...response,
        'createdAt': response['created_at'],
        'isTeamBased': response['is_team_based'],
        'inviteCode': response['invite_code'],
      };

      return LeagueModel.fromJson(jsonData);
    } on PostgrestException catch (e) {
      throw ServerException('Errore: ${e.message}');
    } catch (e) {
      throw ServerException('Si è verificato un errore: ${e.toString()}');
    }
  }

  @override
  Future<LeagueModel> getLeague(String leagueId) async {
    try {
      final response = await supabaseClient
          .from('leagues')
          .select()
          .eq('id', leagueId)
          .single();

      // Convert to our model format
      final jsonData = {
        ...response,
        'createdAt': response['created_at'],
        'isTeamBased': response['is_team_based']
      };

      return LeagueModel.fromJson(jsonData);
    } on PostgrestException catch (e) {
      throw ServerException('Errore: ${e.message}');
    } catch (e) {
      throw ServerException('Si è verificato un errore: ${e.toString()}');
    }
  }

  @override
  Future<List<LeagueModel>> getUserLeagues() async {
    try {
      final currentUserId = _getCurrentUserId();

      if (currentUserId == null) {
        throw ServerException('Utente non autenticato');
      }

      // Use the RPC function to get all leagues where user is admin or participant
      final leaguesResponse = await supabaseClient.rpc(
        'get_user_leagues',
        params: {'p_user_id': currentUserId},
      );

      final List<LeagueModel> leagues = [];

      // Process response
      for (final league in leaguesResponse) {
        // Convert to our model format
        final jsonData = {
          ...league,
          'createdAt': league['created_at'],
          'isTeamBased': league['is_team_based']
        };

        leagues.add(
          LeagueModel.fromJson(jsonData as Map<String, dynamic>),
        );
      }

      return leagues;
    } on PostgrestException catch (e) {
      throw ServerException('Errore: ${e.message}');
    } catch (e) {
      throw ServerException('Si è verificato un errore: ${e.toString()}');
    }
  }

  @override
  Future<LeagueModel> joinLeague({
    required String inviteCode,
    required String userId,
    String? teamName,
    List<String>? teamMembers,
    String? specificLeagueId,
  }) async {
    try {
      // Find all leagues with this invite code
      final leagueResponse = await supabaseClient
          .from('leagues')
          .select()
          .eq('invite_code', inviteCode);

      if (leagueResponse.isEmpty) {
        throw ServerException(
            'Nessuna lega trovata con questo codice di invito');
      }

      // If there are multiple leagues with the same code, let user choose based on name
      Map<String, dynamic> leagueData;
      String leagueId;

      if (specificLeagueId != null) {
        // If user has selected a specific league from multiple options
        final leagueIndex =
            leagueResponse.indexWhere((l) => l['id'] == specificLeagueId);
        if (leagueIndex == -1) {
          throw ServerException('Lega selezionata non trovata');
        }
        leagueData = leagueResponse[leagueIndex];
        leagueId = specificLeagueId;
      } else if (leagueResponse.length > 1) {
        // Present multiple leagues to the user to choose from
        throw ServerException(
          'Più leghe trovate con questo codice. Selezionane una:',
          data: leagueResponse
              .map((league) => {
                    'id': league['id'],
                    'name': league['name'],
                    'description': league['description'],
                  })
              .toList(),
        );
      } else {
        // Only one league found with this code
        leagueData = leagueResponse[0];
        leagueId = leagueData['id'];
      }

      // Convert to our model format
      final jsonData = {
        ...leagueData,
        'createdAt': leagueData['created_at'],
        'isTeamBased': leagueData['is_team_based']
      };

      final league = LeagueModel.fromJson(jsonData);

      // Check if user is already a participant
      final isAlreadyParticipant = league.participants.any((p) =>
          (p is ParticipantModel &&
              p.toJson()['type'] == 'individual' &&
              p.toJson()['userId'] == userId) ||
          (p is ParticipantModel &&
              p.toJson()['type'] == 'team' &&
              (p.toJson()['userIds'] as List<dynamic>).contains(userId)));

      if (isAlreadyParticipant) {
        throw ServerException('L\'utente è già un partecipante di questa lega');
      }

      // Rest of the method remains the same
      final Map<String, dynamic> participantData;

      if (league.isTeamBased) {
        if (teamName == null) {
          throw ServerException(
              'Il nome del team è obbligatorio per le leghe basate su squadre');
        }

        participantData = {
          'type': 'team',
          'userIds': teamMembers ?? [userId],
          'name': teamName,
          'score': 0,
          'malusTotal': 0,
          'bonusTotal': 0,
        };
      } else {
        final currentUserName = _getCurrentUserName();

        if (currentUserName == null) {
          throw ServerException('Utente non autenticato');
        }

        participantData = {
          'type': 'individual',
          'userId': userId,
          'name': currentUserName,
          'score': 0,
          'malusTotal': 0,
          'bonusTotal': 0,
        };
      }

      // Update the league with the new participant
      final List<dynamic> updatedParticipants = [
        ...league.participants.map((p) => (p as ParticipantModel).toJson()),
        participantData,
      ];

      // Update in Supabase
      final updatedResponse = await supabaseClient
          .from('leagues')
          .update({
            'participants': updatedParticipants,
          })
          .eq('id', leagueId)
          .select()
          .single();

      // Convert to our model format
      final updatedJsonData = {
        ...updatedResponse,
        'createdAt': updatedResponse['created_at'],
        'isTeamBased': updatedResponse['is_team_based']
      };

      return LeagueModel.fromJson(updatedJsonData);
    } on PostgrestException catch (e) {
      throw ServerException('Errore: ${e.message}');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<LeagueModel> addEvent({
    required String leagueId,
    required String name,
    required int points,
    required String userId,
    String? description,
  }) async {
    try {
      // Get the current league data
      final leagueResponse = await supabaseClient
          .from('leagues')
          .select()
          .eq('id', leagueId)
          .single();

      // Convert to our model format
      final jsonData = {
        ...leagueResponse,
        'createdAt': leagueResponse['created_at'],
        'isTeamBased': leagueResponse['is_team_based']
      };

      final league = LeagueModel.fromJson(jsonData);

      // Check if user is admin or participant
      final bool isAdmin = league.admins.contains(userId);
      final bool isParticipant = league.participants.any((p) =>
          (p is ParticipantModel &&
              p.toJson()['type'] == 'individual' &&
              p.toJson()['userId'] == userId) ||
          (p is ParticipantModel &&
              p.toJson()['type'] == 'team' &&
              (p.toJson()['userIds'] as List<dynamic>).contains(userId)));

      if (!isAdmin && !isParticipant) {
        throw ServerException(
            'L\'utente non è autorizzato ad aggiungere eventi a questa lega');
      }

      final eventId = uuid.v4();
      final eventData = {
        'id': eventId,
        'name': name,
        'points': points,
        'userId': userId,
        'createdAt': DateTime.now().toIso8601String(),
        'description': description,
      };

      // Check if we have 10 events already, and remove the oldest one if so
      List<dynamic> updatedEvents = [
        ...league.events.map((e) => (e as EventModel).toJson()),
        eventData,
      ];

      if (updatedEvents.length > 10) {
        // Sort by created date (oldest first)
        updatedEvents.sort((a, b) => DateTime.parse(a['createdAt'])
            .compareTo(DateTime.parse(b['createdAt'])));

        // Remove the oldest event
        updatedEvents.removeAt(0);
      }

      // Also update the participant's score
      final updatedParticipants = league.participants.map((p) {
        final participantJson = (p as ParticipantModel).toJson();

        if ((participantJson['type'] == 'individual' &&
                participantJson['userId'] == userId) ||
            (participantJson['type'] == 'team' &&
                (participantJson['userIds'] as List<dynamic>)
                    .contains(userId))) {
          final updatedScore = p.points + points;

          // Update bonus or malus totals
          int updatedBonusTotal = participantJson['bonusTotal'] ?? 0;
          int updatedMalusTotal = participantJson['malusTotal'] ?? 0;

          if (points > 0) {
            updatedBonusTotal += points;
          } else if (points < 0) {
            updatedMalusTotal += points.abs();
          }

          if (participantJson['type'] == 'individual') {
            return {
              ...participantJson,
              'score': updatedScore,
              'bonusTotal': updatedBonusTotal,
              'malusTotal': updatedMalusTotal,
            };
          } else {
            return {
              ...participantJson,
              'score': updatedScore,
              'bonusTotal': updatedBonusTotal,
              'malusTotal': updatedMalusTotal,
            };
          }
        }
        return participantJson;
      }).toList();

      // Update in Supabase
      final updatedResponse = await supabaseClient
          .from('leagues')
          .update({
            'events': updatedEvents,
            'participants': updatedParticipants,
          })
          .eq('id', leagueId)
          .select()
          .single();

      // Convert to our model format
      final updatedJsonData = {
        ...updatedResponse,
        'createdAt': updatedResponse['created_at'],
        'isTeamBased': updatedResponse['is_team_based']
      };

      return LeagueModel.fromJson(updatedJsonData);
    } on PostgrestException catch (e) {
      throw ServerException('Errore: ${e.message}');
    } catch (e) {
      throw ServerException('Si è verificato un errore: ${e.toString()}');
    }
  }

  @override
  Future<LeagueModel> addMemory({
    required String leagueId,
    required String imageUrl,
    required String text,
    required String userId,
    String? relatedEventId,
  }) async {
    try {
      // Get the current league data
      final leagueResponse = await supabaseClient
          .from('leagues')
          .select()
          .eq('id', leagueId)
          .single();

      // Convert to our model format
      final jsonData = {
        ...leagueResponse,
        'createdAt': leagueResponse['created_at'],
        'isTeamBased': leagueResponse['is_team_based']
      };

      final league = LeagueModel.fromJson(jsonData);

      // Check if user is admin or participant
      final bool isAdmin = league.admins.contains(userId);
      final bool isParticipant = league.participants.any((p) =>
          (p is ParticipantModel &&
              p.toJson()['type'] == 'individual' &&
              p.toJson()['userId'] == userId) ||
          (p is ParticipantModel &&
              p.toJson()['type'] == 'team' &&
              (p.toJson()['userIds'] as List<dynamic>).contains(userId)));

      if (!isAdmin && !isParticipant) {
        throw ServerException(
            'L\'utente non è autorizzato ad aggiungere ricordi a questa lega');
      }

      final memoryId = uuid.v4();
      final memoryData = {
        'id': memoryId,
        'imageUrl': imageUrl,
        'text': text,
        'createdAt': DateTime.now().toIso8601String(),
        'userId': userId,
        'relatedEventId': relatedEventId,
      };

      final updatedMemories = [
        ...league.memories.map((m) => (m as MemoryModel).toJson()),
        memoryData,
      ];

      // Update in Supabase
      final updatedResponse = await supabaseClient
          .from('leagues')
          .update({
            'memories': updatedMemories,
          })
          .eq('id', leagueId)
          .select()
          .single();

      // Convert to our model format
      final updatedJsonData = {
        ...updatedResponse,
        'createdAt': updatedResponse['created_at'],
        'isTeamBased': updatedResponse['is_team_based']
      };

      return LeagueModel.fromJson(updatedJsonData);
    } on PostgrestException catch (e) {
      throw ServerException('Errore: ${e.message}');
    } catch (e) {
      throw ServerException('Si è verificato un errore: ${e.toString()}');
    }
  }

  @override
  Future<LeagueModel> updateLeague({
    required String leagueId,
    String? name,
    String? description,
  }) async {
    try {
      final currentUserId = _getCurrentUserId();

      if (currentUserId == null) {
        throw ServerException('Utente non autenticato');
      }

      // Get current league to check if user is admin
      final leagueResponse = await supabaseClient
          .from('leagues')
          .select()
          .eq('id', leagueId)
          .single();

      final admins = List<String>.from(leagueResponse['admins']);

      if (!admins.contains(currentUserId)) {
        throw ServerException(
            'Solo gli amministratori possono aggiornare i dettagli della lega');
      }

      // Prepare update data
      final Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;

      if (updateData.isEmpty) {
        // Nothing to update, return current league
        // Convert to our model format
        final jsonData = {
          ...leagueResponse,
          'createdAt': leagueResponse['created_at'],
          'isTeamBased': leagueResponse['is_team_based']
        };

        return LeagueModel.fromJson(jsonData);
      }

      // Update the league
      final updatedResponse = await supabaseClient
          .from('leagues')
          .update(updateData)
          .eq('id', leagueId)
          .select()
          .single();

      // Convert to our model format
      final updatedJsonData = {
        ...updatedResponse,
        'createdAt': updatedResponse['created_at'],
        'isTeamBased': updatedResponse['is_team_based']
      };

      return LeagueModel.fromJson(updatedJsonData);
    } on PostgrestException catch (e) {
      throw ServerException('Errore: ${e.message}');
    } catch (e) {
      throw ServerException('Si è verificato un errore: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteLeague(String leagueId) async {
    try {
      final currentUserId = _getCurrentUserId();

      if (currentUserId == null) {
        throw ServerException('Utente non autenticato');
      }

      // Get current league to check if user is admin
      final leagueResponse = await supabaseClient
          .from('leagues')
          .select('admins')
          .eq('id', leagueId)
          .single();

      final admins = List<String>.from(leagueResponse['admins']);

      if (!admins.contains(currentUserId)) {
        throw ServerException(
            'Solo gli amministratori possono eliminare una lega');
      }

      // Delete the league
      await supabaseClient.from('leagues').delete().eq('id', leagueId);
    } on PostgrestException catch (e) {
      throw ServerException('Errore: ${e.message}');
    } catch (e) {
      throw ServerException('Si è verificato un errore: ${e.toString()}');
    }
  }

  @override
  Future<LeagueModel> exitLeague({
    required String leagueId,
    required String userId,
  }) async {
    try {
      // Get the current league data
      final leagueResponse = await supabaseClient
          .from('leagues')
          .select()
          .eq('id', leagueId)
          .single();

      // Convert to our model format
      final jsonData = {
        ...leagueResponse,
        'createdAt': leagueResponse['created_at'],
        'isTeamBased': leagueResponse['is_team_based']
      };

      final league = LeagueModel.fromJson(jsonData);

      // Check if user is an admin
      if (league.admins.contains(userId)) {
        // If this is the only admin, don't allow exit
        if (league.admins.length == 1) {
          throw ServerException(
              'Impossibile uscire dalla lega: sei l\'unico amministratore. Trasferisci i diritti di amministratore o elimina la lega');
        }

        // Update admins list
        final updatedAdmins = [...league.admins];
        updatedAdmins.remove(userId);

        await supabaseClient.from('leagues').update({
          'admins': updatedAdmins,
        }).eq('id', leagueId);
      }

      // Remove user from participants
      final updatedParticipants = league.participants
          .where((p) {
            final participantJson = (p as ParticipantModel).toJson();
            if (participantJson['type'] == 'individual') {
              return participantJson['userId'] != userId;
            } else {
              // For teams, we need to check if user is in the team
              final userIds = List<String>.from(participantJson['userIds']);
              // If user is in team:
              if (userIds.contains(userId)) {
                // If they're the only member, remove the whole team
                if (userIds.length == 1) {
                  return false;
                }
                // Otherwise, keep the team but remove the user below
                userIds.remove(userId);
                participantJson['userIds'] = userIds;
              }
              return true;
            }
          })
          .map((p) => (p as ParticipantModel).toJson())
          .toList();

      // Update in Supabase
      final updatedResponse = await supabaseClient
          .from('leagues')
          .update({
            'participants': updatedParticipants,
          })
          .eq('id', leagueId)
          .select()
          .single();

      // Convert to our model format
      final updatedJsonData = {
        ...updatedResponse,
        'createdAt': updatedResponse['created_at'],
        'isTeamBased': updatedResponse['is_team_based']
      };

      return LeagueModel.fromJson(updatedJsonData);
    } on PostgrestException catch (e) {
      throw ServerException('Errore: ${e.message}');
    } catch (e) {
      throw ServerException('Si è verificato un errore: ${e.toString()}');
    }
  }

  @override
  Future<LeagueModel> removeEvent({
    required String leagueId,
    required String eventId,
  }) async {
    try {
      final currentUserId = _getCurrentUserId();

      if (currentUserId == null) {
        throw ServerException('Utente non autenticato');
      }

      // Get the current league data
      final leagueResponse = await supabaseClient
          .from('leagues')
          .select()
          .eq('id', leagueId)
          .single();

      // Convert to our model format
      final jsonData = {
        ...leagueResponse,
        'createdAt': leagueResponse['created_at'],
        'isTeamBased': leagueResponse['is_team_based']
      };

      final league = LeagueModel.fromJson(jsonData);

      // Check if user is admin
      if (!league.admins.contains(currentUserId)) {
        throw ServerException(
            'Solo gli amministratori possono rimuovere eventi');
      }

      // Find the event
      final eventIndex =
          league.events.indexWhere((e) => (e as EventModel).id == eventId);

      if (eventIndex == -1) {
        throw ServerException('Evento non trovato');
      }

      final EventModel eventToRemove = league.events[eventIndex] as EventModel;

      // Remove the event
      final updatedEvents = league.events
          .where((e) => (e as EventModel).id != eventId)
          .map((e) => (e as EventModel).toJson())
          .toList();

      // Update participant score
      final updatedParticipants = league.participants.map((p) {
        final participantJson = (p as ParticipantModel).toJson();

        if ((participantJson['type'] == 'individual' &&
                participantJson['userId'] == eventToRemove.userId) ||
            (participantJson['type'] == 'team' &&
                (participantJson['userIds'] as List<dynamic>)
                    .contains(eventToRemove.userId))) {
          final updatedScore = p.points - eventToRemove.points;

          // Update bonus or malus totals
          int updatedBonusTotal = participantJson['bonusTotal'] ?? 0;
          int updatedMalusTotal = participantJson['malusTotal'] ?? 0;

          if (eventToRemove.points > 0) {
            updatedBonusTotal -= eventToRemove.points;
          } else if (eventToRemove.points < 0) {
            updatedMalusTotal -= eventToRemove.points.abs();
          }

          return {
            ...participantJson,
            'score': updatedScore,
            'bonusTotal': updatedBonusTotal,
            'malusTotal': updatedMalusTotal,
          };
        }
        return participantJson;
      }).toList();

      // Update in Supabase
      final updatedResponse = await supabaseClient
          .from('leagues')
          .update({
            'events': updatedEvents,
            'participants': updatedParticipants,
          })
          .eq('id', leagueId)
          .select()
          .single();

      // Convert to our model format
      final updatedJsonData = {
        ...updatedResponse,
        'createdAt': updatedResponse['created_at'],
        'isTeamBased': updatedResponse['is_team_based']
      };

      return LeagueModel.fromJson(updatedJsonData);
    } on PostgrestException catch (e) {
      throw ServerException('Errore: ${e.message}');
    } catch (e) {
      throw ServerException('Si è verificato un errore: ${e.toString()}');
    }
  }

  @override
  Future<LeagueModel> removeMemory({
    required String leagueId,
    required String memoryId,
  }) async {
    try {
      final currentUserId = _getCurrentUserId();

      if (currentUserId == null) {
        throw ServerException('Utente non autenticato');
      }

      // Get the current league data
      final leagueResponse = await supabaseClient
          .from('leagues')
          .select()
          .eq('id', leagueId)
          .single();

      // Convert to our model format
      final jsonData = {
        ...leagueResponse,
        'createdAt': leagueResponse['created_at'],
        'isTeamBased': leagueResponse['is_team_based']
      };

      final league = LeagueModel.fromJson(jsonData);

      // Find the memory
      final memoryIndex =
          league.memories.indexWhere((m) => (m as MemoryModel).id == memoryId);

      if (memoryIndex == -1) {
        throw ServerException('Ricordo non trovato');
      }

      final memoryToRemove = league.memories[memoryIndex] as MemoryModel;

      // Check if user is admin or the owner of the memory
      if (!league.admins.contains(currentUserId) &&
          memoryToRemove.userId != currentUserId) {
        throw ServerException(
            'Puoi rimuovere solo i tuoi ricordi a meno che tu non sia un amministratore');
      }

      // Remove the memory
      final updatedMemories = league.memories
          .where((m) => (m as MemoryModel).id != memoryId)
          .map((m) => (m as MemoryModel).toJson())
          .toList();

      // Update in Supabase
      final updatedResponse = await supabaseClient
          .from('leagues')
          .update({
            'memories': updatedMemories,
          })
          .eq('id', leagueId)
          .select()
          .single();

      // Convert to our model format
      final updatedJsonData = {
        ...updatedResponse,
        'createdAt': updatedResponse['created_at'],
        'isTeamBased': updatedResponse['is_team_based']
      };

      return LeagueModel.fromJson(updatedJsonData);
    } on PostgrestException catch (e) {
      throw ServerException('Errore: ${e.message}');
    } catch (e) {
      throw ServerException('Si è verificato un errore: ${e.toString()}');
    }
  }

  @override
  Future<LeagueModel> updateTeamName({
    required String leagueId,
    required String userId,
    required String newName,
  }) async {
    try {
      // Get the current league data
      final leagueResponse = await supabaseClient
          .from('leagues')
          .select()
          .eq('id', leagueId)
          .single();

      // Convert to our model format
      final jsonData = {
        ...leagueResponse,
        'createdAt': leagueResponse['created_at'],
        'isTeamBased': leagueResponse['is_team_based']
      };

      final league = LeagueModel.fromJson(jsonData);

      if (!league.isTeamBased) {
        throw ServerException('Questa non è una lega basata su squadre');
      }

      // Find user's team
      int teamIndex = -1;
      for (int i = 0; i < league.participants.length; i++) {
        final participant = league.participants[i] as ParticipantModel;
        final participantJson = participant.toJson();

        if (participantJson['type'] == 'team' &&
            (participantJson['userIds'] as List<dynamic>).contains(userId)) {
          teamIndex = i;
          break;
        }
      }

      if (teamIndex == -1) {
        throw ServerException('L\'utente non fa parte di nessuna squadra');
      }

      // Update team name
      final updatedParticipants = league.participants.map((p) {
        final participantJson = (p as ParticipantModel).toJson();

        if (participantJson['type'] == 'team' &&
            (participantJson['userIds'] as List<dynamic>).contains(userId)) {
          return {
            ...participantJson,
            'name': newName,
          };
        }
        return participantJson;
      }).toList();

      // Update in Supabase
      final updatedResponse = await supabaseClient
          .from('leagues')
          .update({
            'participants': updatedParticipants,
          })
          .eq('id', leagueId)
          .select()
          .single();

      // Convert to our model format
      final updatedJsonData = {
        ...updatedResponse,
        'createdAt': updatedResponse['created_at'],
        'isTeamBased': updatedResponse['is_team_based']
      };

      return LeagueModel.fromJson(updatedJsonData);
    } on PostgrestException catch (e) {
      throw ServerException('Errore: ${e.message}');
    } catch (e) {
      throw ServerException('Si è verificato un errore: ${e.toString()}');
    }
  }

  @override
  Future<List<RuleModel>> getRules({required String mode}) async {
    try {
      // Determine which table to query based on mode
      final tableName = mode == "hard" ? "hard_rules" : "soft_rules";

      // Execute the query
      final response = await supabaseClient
          .from(tableName)
          .select()
          .order('id', ascending: true);

      // Parse the response into a list of RuleModel objects
      return (response as List)
          .map((ruleJson) => RuleModel.fromJson(ruleJson))
          .toList();
    } catch (e) {
      throw ServerException('Failed to fetch rules: ${e.toString()}');
    }
  }
}
