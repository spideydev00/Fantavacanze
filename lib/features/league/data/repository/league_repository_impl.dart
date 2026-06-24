import 'dart:io';

import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/network/connection_checker.dart';
import 'package:fantavacanze_official/features/league/data/datasources/local/local_data_source.dart';
import 'package:fantavacanze_official/features/league/data/datasources/remote/league_remote_data_source.dart';
import 'package:fantavacanze_official/features/league/data/models/league_model/league_model.dart';
import 'package:fantavacanze_official/features/league/data/models/note_model/note_model.dart';
import 'package:fantavacanze_official/features/league/data/models/rule_model/rule_model.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/member_profile.dart';
import 'package:fantavacanze_official/features/league/domain/entities/note.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule/rule.dart';
import 'package:fantavacanze_official/features/league/domain/entities/partner/partner_catalog.dart';
import 'package:fantavacanze_official/features/league/domain/entities/partner/partner_search_result.dart';
import 'package:fantavacanze_official/features/league/domain/entities/partner/general_ranking_entry.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';

class LeagueRepositoryImpl implements LeagueRepository {
  final LeagueRemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final ConnectionChecker connectionChecker;

  LeagueRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectionChecker,
  });

  @override
  Future<Either<Failure, League>> createLeague({
    required String name,
    String? description,
    required LeagueType type,
    required List<Rule> rules,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      // Convert Rule objects to RuleModel objects
      final List<RuleModel> ruleModels = rules
          .map((rule) => RuleModel(
                createdAt: rule.createdAt,
                name: rule.name,
                type: rule.type,
                points: rule.points,
              ))
          .toList();

      final league = await remoteDataSource.createLeague(
        name: name,
        description: description ?? "",
        type: type,
        rules: ruleModels,
      );

      await localDataSource.cacheLeague(league);

      return Right(league);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, League>> getLeague(String leagueId) async {
    try {
      if (!await connectionChecker.isConnected) {
        // Try to get league from cache when offline
        final cachedLeague = await localDataSource.getCachedLeague(leagueId);
        if (cachedLeague != null) {
          return Right(cachedLeague);
        }
        return Left(
          Failure("Nessuna connessione e nessun dato nella cache."),
        );
      }

      // Get from remote and cache
      final league = await remoteDataSource.getLeague(leagueId);
      await localDataSource.cacheLeague(league);

      return Right(league);
    } on ServerException catch (e) {
      // If server error, try to get from cache
      try {
        final cachedLeague = await localDataSource.getCachedLeague(leagueId);
        if (cachedLeague != null) {
          return Right(cachedLeague);
        }
      } catch (_) {}
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, List<League>>> getUserLeagues() async {
    try {
      try {
        // Prefer server truth. The first connectivity probe at cold start can
        // be unreliable, so the remote call is the real online check here.
        final leagues = await remoteDataSource.getUserLeagues();
        await localDataSource.cacheLeagues(leagues);

        return Right(leagues);
      } on ServerException {
        // Fall through to cache when the remote source is actually unavailable.
      }

      final cachedLeagues = await localDataSource.getCachedLeagues();
      return Right(cachedLeagues);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, List<MemberProfile>>> getProfileImagesForUsers(
    List<String> userIds,
  ) async {
    try {
      if (userIds.isEmpty) return const Right([]);

      final memberProfiles =
          await remoteDataSource.getProfileImagesForUsers(userIds);

      return Right(memberProfiles);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLeague(
    String leagueId, {
    LeagueType? type,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(Failure(
            "Nessuna connessione ad internet, riprova appena sarai connesso."));
      }

      await remoteDataSource.deleteLeague(leagueId, type: type);

      await localDataSource.clearDailyChallengesForLeague(leagueId);
      await localDataSource.clearNotificationsForLeague(leagueId);
      await localDataSource.clearNotesForLeague(leagueId);
      await localDataSource.removeLeagueFromCache(leagueId);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, List<League>>> searchLeague(
      {required String inviteCode}) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }
      final leagues =
          await remoteDataSource.searchLeague(inviteCode: inviteCode);
      return Right(leagues);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, League>> joinLeague({
    required String inviteCode,
    String? teamName,
    List<String>? teamMembers,
    String? specificLeagueId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      final league = await remoteDataSource.joinLeague(
        inviteCode: inviteCode,
        teamName: teamName,
        teamMembers: teamMembers,
        specificLeagueId: specificLeagueId,
      );

      // Cache the joined league
      await localDataSource.cacheLeague(league);

      // Also update the user leagues cache
      final userLeagues = await remoteDataSource.getUserLeagues();
      await localDataSource.cacheLeagues(userLeagues);

      return Right(league);
    } on ServerException catch (e) {
      return Left(Failure(e.message, data: e.data));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, void>> exitLeague({
    required League league,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      await remoteDataSource.exitLeague(
        league: league as LeagueModel,
      );

      await localDataSource.clearDailyChallengesForLeague(league.id);
      await localDataSource.clearNotificationsForLeague(league.id);
      await localDataSource.clearNotesForLeague(league.id);
      await localDataSource.removeLeagueFromCache(league.id);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, League>> updateTeamName({
    required League league,
    required String oldTeamName,
    required String newName,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      final updatedLeague = await remoteDataSource.updateTeamName(
        league: league as LeagueModel,
        oldTeamName: oldTeamName,
        newName: newName,
      );

      // Update cache
      await localDataSource.cacheLeague(updatedLeague);

      return Right(updatedLeague);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, League>> addEvent({
    required League league,
    required String name,
    required double points,
    required String creatorId,
    required String targetUser,
    required RuleType type,
    String? targetTeamName,
    String? targetMemberId,
    String? description,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      final updatedLeague = await remoteDataSource.addEvent(
        league: league as LeagueModel,
        name: name,
        points: points,
        creatorId: creatorId,
        targetUser: targetUser,
        type: type,
        description: description,
        targetTeamName: targetTeamName,
        targetMemberId: targetMemberId,
      );

      // Update cache
      await localDataSource.cacheLeague(updatedLeague);

      return Right(updatedLeague);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, League>> removeEvent({
    required League league,
    required String eventId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(Failure('Nessuna connessione internet'));
      }

      final updatedLeague = await remoteDataSource.removeEvent(
        league: league as LeagueModel,
        eventId: eventId,
      );

      // Update cache
      await localDataSource.cacheLeague(updatedLeague);

      return Right(updatedLeague);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, League>> addMemory({
    required League league,
    required String imageUrl,
    required String text,
    required String userId,
    String? relatedEventId,
    String? eventName,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      final updatedLeague = await remoteDataSource.addMemory(
        league: league as LeagueModel,
        imageUrl: imageUrl,
        text: text,
        userId: userId,
        relatedEventId: relatedEventId,
        eventName: eventName,
      );

      // Update cache
      await localDataSource.cacheLeague(updatedLeague);

      return Right(updatedLeague);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, League>> removeMemory({
    required League league,
    required String memoryId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      final updatedLeague = await remoteDataSource.removeMemory(
        league: league as LeagueModel,
        memoryId: memoryId,
      );

      // Update cache
      await localDataSource.cacheLeague(updatedLeague);

      return Right(updatedLeague);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, League>> updateRule({
    required League league,
    required Rule rule,
    String? originalRuleName,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      // Properly convert Rule to RuleModel
      final ruleModel = RuleModel(
        createdAt: rule.createdAt,
        name: rule.name,
        type: rule.type,
        points: rule.points,
      );

      final updatedLeague = await remoteDataSource.updateRule(
        league: league as LeagueModel,
        rule: ruleModel,
        originalRuleName: originalRuleName,
      );

      // Update cache
      await localDataSource.cacheLeague(updatedLeague);

      return Right(updatedLeague);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, League>> deleteRule({
    required League league,
    required String ruleName,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      final updatedLeague = await remoteDataSource.deleteRule(
        league: league as LeagueModel,
        ruleName: ruleName,
      );

      // Update cache
      await localDataSource.cacheLeague(updatedLeague);

      return Right(updatedLeague);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, League>> addRule({
    required League league,
    required Rule rule,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      final ruleModel = RuleModel(
        createdAt: rule.createdAt,
        name: rule.name,
        type: rule.type,
        points: rule.points,
      );

      final updatedLeague = await remoteDataSource.addRule(
        league: league as LeagueModel,
        rule: ruleModel,
      );

      // Update cache
      await localDataSource.cacheLeague(updatedLeague);

      return Right(updatedLeague);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, void>> clearLocalCache() async {
    try {
      await localDataSource.clearCache();

      return const Right(null);
    } on CacheException catch (e) {
      return Left(Failure('Errore nella pulizia della cache: ${e.toString()}'));
    }
  }

  // Note operations
  @override
  Future<Either<Failure, List<NoteModel>>> getNotes(String leagueId) async {
    try {
      final notes = await localDataSource.getNotes(leagueId);
      return Right(notes);
    } on CacheException catch (e) {
      final errorMessage = 'Errore nel recuperare le note: ${e.message}';
      return Left(Failure(errorMessage));
    } catch (e) {
      final errorMessage =
          'Errore imprevisto nel recuperare le note: ${e.toString()}';
      return Left(Failure(errorMessage));
    }
  }

  @override
  Future<Either<Failure, void>> saveNote(
    String leagueId, // This leagueId parameter is from the event
    Note note, // This is the Note entity from the event
  ) async {
    try {
      // Explicitly convert the Note entity to NoteModel
      final noteModel = NoteModel(
        id: note.id,
        participantId: note.participantId,
        participantName: note.participantName,
        content: note.content,
        createdAt: note.createdAt,
        leagueId: note.leagueId, // Use leagueId from the note entity itself
      );

      // Pass the created noteModel and its leagueId to the local data source.
      // The localDataSource.saveNote uses the second parameter for its key generation.
      await localDataSource.saveNote(noteModel, noteModel.leagueId);
      return const Right(null);
    } on CacheException catch (e) {
      final errorMessage = 'Errore nel salvare la nota: ${e.message}';
      return Left(Failure(errorMessage));
    } catch (e) {
      // Catch any other potential errors during conversion or saving
      final errorMessage =
          'Errore imprevisto nel salvare la nota: ${e.toString()}';
      return Left(Failure(errorMessage));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNote(
      String leagueId, String noteId) async {
    try {
      await localDataSource.deleteNote(
        noteId,
        leagueId,
      );
      return const Right(null);
    } on CacheException catch (e) {
      return Left(Failure('Errore nel cancellare la nota: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadMedia({
    required String leagueId,
    required File mediaFile,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      final mediaUrl = await remoteDataSource.uploadMedia(
        leagueId: leagueId,
        mediaFile: mediaFile,
      );

      return Right(mediaUrl);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(
          'Errore durante il caricamento dell\'immagine: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadTeamLogo({
    required String leagueId,
    required String teamName,
    required File imageFile,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      final logoUrl = await remoteDataSource.uploadTeamLogo(
        leagueId: leagueId,
        teamName: teamName,
        imageFile: imageFile,
      );

      return Right(logoUrl);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(
          Failure('Errore durante il caricamento del logo: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, League>> updateTeamLogo({
    required League league,
    required String teamName,
    required String logoUrl,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      final updatedLeague = await remoteDataSource.updateTeamLogo(
        league: league as LeagueModel,
        teamName: teamName,
        logoUrl: logoUrl,
      );

      // Update cache
      await localDataSource.cacheLeague(updatedLeague);

      return Right(updatedLeague);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    } catch (e) {
      return Left(
          Failure('Errore durante l\'aggiornamento del logo: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, League>> addAdministrators({
    required League league,
    required List<String> userIds,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      final updatedLeague = await remoteDataSource.addAdministrators(
        league: league as LeagueModel,
        userIds: userIds,
      );

      // Update cache
      await localDataSource.cacheLeague(updatedLeague);

      return Right(updatedLeague);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, League>> removeParticipants({
    required League league,
    required List<String> participantIds,
    String? teamName,
    String? newCaptainId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(Failure(
            "Nessuna connessione ad internet, riprova appena sarai connesso."));
      }

      final updatedLeague = await remoteDataSource.removeParticipants(
        league: league as LeagueModel,
        participantIds: participantIds,
        teamName: teamName,
        newCaptainId: newCaptainId,
      );

      // Update cache
      await localDataSource.cacheLeague(updatedLeague);

      return Right(updatedLeague);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, League>> updateLeagueInfo({
    required League league,
    String? name,
    String? description,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      final updatedLeague = await remoteDataSource.updateLeagueInfo(
        league: league as LeagueModel,
        name: name,
        description: description,
      );

      // Update cache
      await localDataSource.cacheLeague(updatedLeague);

      return Right(updatedLeague);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, PartnerCatalog>> getPartnerDestinations(
    String partnerSlug,
  ) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure("Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }
      final catalog = await remoteDataSource.getPartnerDestinations(partnerSlug);
      return Right(catalog);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, League>> createPartnerLeague({
    required String userName,
    required String destinationId,
    required String name,
    required String password,
    String? description,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure("Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }
      final league = await remoteDataSource.createPartnerLeague(
        destinationId: destinationId,
        name: name,
        password: password,
        description: description,
      );

      await localDataSource.cacheLeague(league);
      return Right(league);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, PartnerSearchResult>> searchPartnerLeague({
    required String inviteCode,
    required String password,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure("Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }
      final result = await remoteDataSource.searchPartnerLeague(
        inviteCode: inviteCode,
        password: password,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, League>> joinPartnerLeague({
    required String userName,
    required String inviteCode,
    required String password,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure("Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }
      final league = await remoteDataSource.joinPartnerLeague(
        inviteCode: inviteCode,
        password: password,
      );

      await localDataSource.cacheLeague(league);
      return Right(league);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, List<GeneralRankingEntry>>> getPartnerGeneralRanking(
    String leagueId,
  ) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure("Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }
      final ranking = await remoteDataSource.getPartnerGeneralRanking(leagueId);
      return Right(ranking);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }
}
