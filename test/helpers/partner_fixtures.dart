import 'package:fantavacanze_official/features/league/data/models/league_model/league_model.dart';
import 'package:fantavacanze_official/features/league/data/models/partner/general_ranking_entry_model.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/partner/general_ranking_entry.dart';
import 'package:fantavacanze_official/features/league/domain/entities/partner/partner.dart';
import 'package:fantavacanze_official/features/league/domain/entities/partner/partner_catalog.dart';
import 'package:fantavacanze_official/features/league/domain/entities/partner/partner_destination.dart';
import 'package:fantavacanze_official/features/league/domain/entities/partner/partner_round.dart';
import 'package:fantavacanze_official/features/league/domain/entities/partner/partner_search_result.dart';

/// Shared test fixtures for the partner-collaborations feature.

final tPartnerLeagueModel = LeagueModel(
  id: 'league-1',
  name: 'InVibe Gallipoli',
  description: 'Lega partner di test',
  createdAt: DateTime(2026, 6, 24),
  participants: const [],
  events: const [],
  memories: const [],
  rules: const [],
  admins: const ['user-1'],
  inviteCode: 'vb12345678',
  type: LeagueType.individual,
  partner: 'invibe',
  partnerDestinationId: 'dest-1',
  partnerRoundId: 'round-1',
);

final tPartnerRound = PartnerRound(
  id: 'round-1',
  name: 'Turno 1 · Luglio',
  startDate: DateTime(2026, 7, 1),
  endDate: DateTime(2026, 7, 7),
);

final tPartnerDestination = PartnerDestination(
  id: 'dest-1',
  name: 'Gallipoli',
  description: 'Salento',
  rules: const [],
  imageUrl: null,
  activeRound: tPartnerRound,
);

const tPartner = Partner(slug: 'invibe', name: 'InVibe', kind: 'travel');

final tPartnerCatalog = PartnerCatalog(
  partner: tPartner,
  destinations: [tPartnerDestination],
);

final tPartnerSearchResultFound = PartnerSearchResult(
  status: PartnerSearchStatus.found,
  league: tPartnerLeagueModel,
  destinationName: 'Gallipoli',
  roundName: 'Turno 1 · Luglio',
);

const tGeneralRanking = <GeneralRankingEntry>[
  GeneralRankingEntry(
    userId: 'user-1',
    name: 'Mario',
    points: 42,
    leagueName: 'InVibe Gallipoli',
  ),
  GeneralRankingEntry(
    userId: 'user-2',
    name: 'Luigi',
    points: 30,
    leagueName: 'InVibe Pag',
  ),
];

/// Datasource-typed variant (the remote datasource returns models).
const tGeneralRankingModels = <GeneralRankingEntryModel>[
  GeneralRankingEntryModel(
    userId: 'user-1',
    name: 'Mario',
    points: 42,
    leagueName: 'InVibe Gallipoli',
  ),
  GeneralRankingEntryModel(
    userId: 'user-2',
    name: 'Luigi',
    points: 30,
    leagueName: 'InVibe Pag',
  ),
];
