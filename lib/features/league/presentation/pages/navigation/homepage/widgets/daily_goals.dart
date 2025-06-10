import 'package:fantavacanze_official/core/constants/lock_type.dart';
import 'package:fantavacanze_official/core/services/ad_helper.dart';
import 'package:fantavacanze_official/core/utils/show_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/premium_access_dialog.dart';
import 'package:fantavacanze_official/features/league/domain/entities/daily_challenge.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/init_dependencies/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/divider.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_state.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:math' show min;

import 'daily_goal_card.dart';

class DailyGoals extends StatefulWidget {
  const DailyGoals({super.key});

  @override
  State<DailyGoals> createState() => _DailyGoalsState();
}

class _DailyGoalsState extends State<DailyGoals> {
  List<DailyChallenge>? _allChallenges;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDailyChallenges();
  }

  void _loadDailyChallenges() {
    if (_isLoading) return;

    final userState = context.read<AppUserCubit>().state;
    final appLeagueState = context.read<AppLeagueCubit>().state;

    if (userState is AppUserIsLoggedIn && appLeagueState is AppLeagueExists) {
      setState(
        () => _isLoading = true,
      );

      context.read<LeagueBloc>().add(
            GetDailyChallengesEvent(
              userId: userState.user.id,
              leagueId: appLeagueState.selectedLeague.id,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppLeagueCubit, AppLeagueState>(
      listenWhen: (previous, current) {
        // Only trigger when the selected league changes
        if (previous is AppLeagueExists && current is AppLeagueExists) {
          return previous.selectedLeague.id != current.selectedLeague.id;
        }
        return false;
      },
      listener: (context, state) {
        if (state is AppLeagueExists) {
          setState(() {
            _allChallenges = null;
          });
          _loadDailyChallenges();
        }
      },
      child: BlocConsumer<LeagueBloc, LeagueState>(
        listener: (context, state) {
          if (state is LeagueError) {
            setState(() => _isLoading = false);

            showSnackBar(
              state.message,
            );
          } else if (state is ChallengeMarkedAsCompleted) {
            setState(() {
              _isLoading = false;

              // Update only the completed challenge
              if (_allChallenges != null) {
                final index = _allChallenges!.indexWhere(
                    (challenge) => challenge.id == state.challenge.id);

                if (index != -1) {
                  _allChallenges![index] = _allChallenges![index].copyWith(
                    isCompleted: true,
                    completedAt: DateTime.now(),
                  );
                }
              }
            });

            showSnackBar(
              "Obiettivo segnato come completato!",
              color: ColorPalette.success,
            );
          } else if (state is ChallengeRefreshed) {
            setState(() {
              _isLoading = false;

              // Update only the refreshed challenge
              if (_allChallenges != null) {
                final index = _allChallenges!.indexWhere(
                    (challenge) => challenge.id == state.challengeId);

                if (index != -1) {
                  // Create a new challenge instance with updated properties
                  final updatedChallenge = _allChallenges![index].copyWith(
                    isRefreshed: true,
                    refreshedAt: DateTime.now(),
                  );

                  // Replace the old challenge in the list
                  _allChallenges![index] = updatedChallenge;
                }
              }
            });
            showSnackBar(
              "Obiettivo aggiornato con successo!",
              color: ColorPalette.success,
            );
          } else if (state is DailyChallengesLoaded) {
            setState(() {
              _allChallenges = state.challenges;
              _isLoading = false;
            });
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.xl),
                child: CustomDivider(text: "Obiettivi giornalieri"),
              ),
              const SizedBox(height: ThemeSizes.md),
              if (_isLoading && _allChallenges == null) ...[
                const SizedBox(height: 80),
                const Loader(color: ColorPalette.success),
                const SizedBox(height: 80),
              ] else if (_allChallenges != null) ...[
                _buildChallengeList(context),
              ] else ...[
                _buildPlaceholderGoals(),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildChallengeList(BuildContext context) {
    // Get app state
    final userState = context.read<AppUserCubit>().state;
    final userId = userState is AppUserIsLoggedIn ? userState.user.id : null;

    // Get league state
    final leagueState = context.read<AppLeagueCubit>().state;
    final selectedLeagueId =
        leagueState is AppLeagueExists ? leagueState.selectedLeague.id : null;
    final selectedLeague =
        leagueState is AppLeagueExists ? leagueState.selectedLeague : null;

    if (userId == null ||
        selectedLeagueId == null ||
        selectedLeague == null ||
        _allChallenges == null ||
        _allChallenges!.isEmpty) {
      return _buildPlaceholderGoals();
    }

    // Sort challenges by position for consistent ordering
    final challengesList = List<DailyChallenge>.from(_allChallenges!)
      ..sort((a, b) => a.position.compareTo(b.position));

    // Get primary challenges (first 3) and substitute challenges (next 3)
    final primaryChallenges = challengesList.take(3).toList();
    final substituteChallenges = challengesList.length > 3
        ? challengesList.sublist(3, min(challengesList.length, 6))
        : <DailyChallenge>[];

    // Process each position to determine what to display
    final displayChallenges = <DailyChallenge>[];

    for (int i = 0; i < primaryChallenges.length; i++) {
      final primary = primaryChallenges[i];

      // If primary is refreshed and we have a substitute available, show the substitute
      if (primary.isRefreshed && i < substituteChallenges.length) {
        displayChallenges.add(substituteChallenges[i]);
      } else {
        // Otherwise show the primary
        displayChallenges.add(primary);
      }
    }

    // Always show all challenges, up to 3 maximum
    final maxToShow = min(displayChallenges.length, 3);
    final challengesToShow = displayChallenges.take(maxToShow).toList();

    return Column(
      children: List.generate(
        challengesToShow.length,
        (index) {
          final challenge = challengesToShow[index];
          final colorIndex = index % 3;
          final colorPair = ColorPalette.getChallengeGradient(colorIndex);

          // Use isUnlocked from the challenge instead of checking isPremium
          LockType lockType = LockType.none;
          bool isLocked = false;

          if (!challenge.isUnlocked) {
            isLocked = true;
            if (index == 1) {
              lockType = LockType.ads;
            } else if (index == 2) {
              lockType = LockType.premium;
            }
          }

          // Determine if this is a substitute (position > 3)
          final bool isSubstitute = substituteChallenges.contains(challenge);

          // Can refresh if:
          // - It's a primary challenge (not a substitute)
          // - It's not already refreshed
          // - It's not completed
          // - Not locked (premium check)
          final bool canRefresh = !isSubstitute &&
              !challenge.isRefreshed &&
              !challenge.isCompleted &&
              !isLocked;

          return Padding(
            padding: const EdgeInsets.only(bottom: ThemeSizes.md),
            child: DailyGoalCard(
              challengeId: challenge.id,
              name: challenge.name,
              score: challenge.points,
              isLocked: isLocked,
              lockType: lockType,
              startColor: colorPair[0],
              endColor: colorPair[1],
              isRefreshed: isSubstitute || challenge.isRefreshed,
              isCompleted: challenge.isCompleted,
              onRefresh: canRefresh
                  ? () => _refreshChallenge(
                        challenge,
                        selectedLeagueId,
                        userId,
                      )
                  : null,
              onComplete: !isLocked && !challenge.isCompleted
                  ? () => _completeChallenge(
                        challenge,
                        selectedLeague,
                        userId,
                      )
                  : null,
              onLockedTap: isLocked
                  ? () => _handleLockedCardTap(
                        lockType,
                        challenge.id,
                        selectedLeagueId,
                      )
                  : null,
            ),
          );
        },
      ),
    );
  }

  // Modified to take the challengeId parameter
  void _handleLockedCardTap(
      LockType lockType, String challengeId, String leagueId) {
    // Show the premium access dialog with appropriate options
    showDialog(
      context: context,
      builder: (context) => PremiumAccessDialog(
        // Only show premium option for the third challenge
        premiumOnly: lockType == LockType.premium,
        description: lockType == LockType.premium
            ? 'Per sbloccare tutte le sfide è necessario un abbonamento premium!'
            : 'Scegli come sbloccare questa sfida giornaliera: ',
        onAdsBtnTapped: () => _handleAdsButton(lockType, challengeId, leagueId),
        onPremiumBtnTapped: () => _handlePremiumButton(),
      ),
    );
  }

// Helper per mostrare un overlay di caricamento pulito
  OverlayEntry _showLoadingOverlay(BuildContext context) {
    final overlay = OverlayEntry(
      builder: (_) => Container(
        color: Colors.black.withOpacity(0.5),
        child: const Center(
          child: Loader(
            color: ColorPalette.success,
          ),
        ),
      ),
    );
    Overlay.of(context).insert(overlay);
    return overlay;
  }

// Funzione principale per gestire il pulsante degli annunci
  Future<void> _handleAdsButton(
      LockType lockType, String challengeId, String leagueId) async {
    if (lockType != LockType.ads) return;

    final pageContext = context;
    final loadingOverlay = _showLoadingOverlay(pageContext);

    try {
      final adHelper = serviceLocator<AdHelper>();
      final bool adsWatched = await adHelper.showSequentialRewardedAds();

      if (loadingOverlay.mounted) {
        loadingOverlay.remove();
      }
      if (!pageContext.mounted) return;

      if (adsWatched) {
        setState(() {
          if (_allChallenges != null) {
            final index =
                _allChallenges!.indexWhere((c) => c.id == challengeId);
            if (index != -1) {
              // Aggiorna l'oggetto challenge nella lista
              _allChallenges![index] = _allChallenges![index].copyWith(
                isUnlocked: true,
              );
              // Forza la ricostruzione della lista per notificare i widget che la usano
              _allChallenges = List.from(_allChallenges!);
            }
          }
        });

        // 2. MOSTRA SUBITO IL SUCCESSO ALL'UTENTE
        showSnackBar(
          "Sfida sbloccata con successo!",
          color: ColorPalette.success,
        );

        // 3. INVIA L'EVENTO AL BLOC IN BACKGROUND
        pageContext.read<LeagueBloc>().add(
              UnlockDailyChallengeEvent(
                challengeId: challengeId,
                leagueId: leagueId,
                isUnlocked: true,
              ),
            );
      } else {
        showSnackBar(
          "Non è stato possibile completare la visione degli annunci. Riprova tra qualche minuto.",
          color: ColorPalette.error,
        );
      }
    } catch (e) {
      debugPrint('Errore in _handleAdsButton per la sfida: $e');
      if (loadingOverlay.mounted) {
        loadingOverlay.remove();
      }
      if (pageContext.mounted) {
        showSnackBar(
          "Si è verificato un errore. Riprova più tardi.",
          color: ColorPalette.error,
        );
      }
    }
  }

  void _handlePremiumButton() {
    // TODO: Implement premium subscription flow
    showSnackBar(
      "Funzionalità premium in arrivo!",
      color: ColorPalette.premiumGradient[1],
    );
  }

  // Update the _completeChallenge method to properly handle notifications and loading state
  void _completeChallenge(
    DailyChallenge challenge,
    League league,
    String userId,
  ) {
    setState(() {
      _isLoading = true; // Show loading state
    });

    // Check if the user is an admin
    final isAdmin = league.admins.contains(userId);

    context.read<LeagueBloc>().add(
          MarkChallengeAsCompletedEvent(
            challenge: challenge,
            userId: userId,
            league: league,
          ),
        );

    // If non-admin, also send a notification
    if (!isAdmin) {
      showSnackBar(
        "Completamento della sfida inviato. Un admin deve approvarlo.",
        color: ColorPalette.warning,
      );
    }
  }

  void _refreshChallenge(
      DailyChallenge challenge, String leagueId, String userId) {
    // 1. Update local state IMMEDIATELY to ensure UI updates
    setState(() {
      if (_allChallenges != null) {
        // Find and update the challenge
        final index = _allChallenges!.indexWhere((c) => c.id == challenge.id);
        if (index != -1) {
          // Create a refreshed version of the challenge
          _allChallenges![index] = _allChallenges![index].copyWith(
            isRefreshed: true,
            refreshedAt: DateTime.now(),
          );
        }

        // Force a rebuild of the UI with the updated challenges
        // This ensures we immediately see the substitute challenge
        _allChallenges = List.from(_allChallenges!);
      }
    });

    // 2. Send event to server
    context.read<LeagueBloc>().add(
          RefreshDailyChallengeEvent(
            challengeId: challenge.id,
            leagueId: leagueId,
            userId: userId,
          ),
        );
  }

  Widget _buildPlaceholderGoals() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        // Randomize gradient colors for placeholder items
        final colorIndex = index % ColorPalette.challengeGradients.length;
        final gradientColors = ColorPalette.challengeGradients[colorIndex];

        return Container(
          margin: const EdgeInsets.only(bottom: ThemeSizes.md),
          child: Stack(
            children: [
              // Card background with gradient
              Container(
                margin: const EdgeInsets.symmetric(horizontal: ThemeSizes.lg),
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                  borderRadius:
                      BorderRadius.circular(ThemeSizes.borderRadiusMd),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[1].withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),

              // Content overlay with shimmer effect
              Positioned.fill(
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(ThemeSizes.borderRadiusMd),
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: ThemeSizes.lg),
                    child: Shimmer.fromColors(
                      baseColor: Colors.white.withValues(alpha: 0.2),
                      highlightColor: Colors.white.withValues(alpha: 0.6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: ThemeSizes.md,
                          vertical: ThemeSizes.sm,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 14,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 50,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
