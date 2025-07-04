import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fantavacanze_official/core/constants/lock_type.dart';
import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/services/ad_helper.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/show_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/divider.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/premium_access_dialog.dart';
import 'package:fantavacanze_official/features/league/domain/entities/daily_challenge.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/daily_challenges_bloc/daily_challenges_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/daily_challenges_bloc/daily_challenges_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/daily_challenges_bloc/daily_challenges_state.dart';
import 'package:shimmer/shimmer.dart';
import 'daily_goal_card.dart';

class DailyGoals extends StatefulWidget {
  const DailyGoals({super.key});

  @override
  State<DailyGoals> createState() => _DailyGoalsState();
}

class _DailyGoalsState extends State<DailyGoals> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDailyChallenges();
  }

  void _loadDailyChallenges() {
    if (_isLoading) return;
    final userState = context.read<AppUserCubit>().state;
    final leagueState = context.read<AppLeagueCubit>().state;

    if (userState is AppUserIsLoggedIn && leagueState is AppLeagueExists) {
      setState(
        () => _isLoading = true,
      );

      context.read<DailyChallengesBloc>().add(
            GetDailyChallengesEvent(
              userId: userState.user.id,
              leagueId: leagueState.selectedLeague.id,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DailyChallengesBloc, DailyChallengesState>(
      listener: _onDailyChallengesStateChange,
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: ThemeSizes.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.xl),
              child: CustomDivider(text: "Obiettivi giornalieri"),
            ),
            const SizedBox(height: ThemeSizes.md),
            if (state is DailyChallengesLoading && _isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 80),
                  child: Loader(color: ColorPalette.success),
                ),
              )
            else if (state is DailyChallengesLoaded)
              _buildChallengeList(context, state.challenges)
            else
              _buildPlaceholderGoals(),
          ],
        );
      },
    );
  }

  void _onDailyChallengesStateChange(
    BuildContext context,
    DailyChallengesState state,
  ) {
    if (state is DailyChallengesLoaded) {
      setState(() {
        _isLoading = false;
      });

      // Gestiamo le notifiche in base alle operazioni completate
      if (state.operation == 'mark_completed') {
        showSnackBar(
          "Obiettivo segnato come completato!",
          color: ColorPalette.success,
        );
      } else if (state.operation == 'refresh_challenge') {
        showSnackBar(
          "Obiettivo aggiornato con successo!",
          color: ColorPalette.success,
        );
      } else if (state.operation == 'unlock_challenge') {
        showSnackBar(
          "Sfida sbloccata con successo!",
          color: ColorPalette.success,
        );
      } else if (state.operation == 'premium_unlocked') {
        // Aggiornamento già gestito attraverso lo stato del bloc
      }
      // else if (state.operation == 'approve_challenge') {
      //   showSnackBar(
      //     "Sfida approvata con successo!",
      //     color: ColorPalette.success,
      //   );
      // } else if (state.operation == 'reject_challenge') {
      //   showSnackBar(
      //     "Sfida rifiutata!",
      //     color: ColorPalette.error,
      //   );
      // }
    } else if (state is DailyChallengesError) {
      setState(() => _isLoading = false);
      showSnackBar(state.message);
    }
  }

  Widget _buildChallengeList(
    BuildContext context,
    List<DailyChallenge> challenges,
  ) {
    challenges = List<DailyChallenge>.from(challenges)
      ..sort((a, b) => a.position.compareTo(b.position));

    final primary = challenges.take(3).toList();

    final subs = challenges.sublist(3, challenges.length);

    final display = <DailyChallenge>[];

    for (var i = 0; i < primary.length; i++) {
      display.add(
        primary[i].isRefreshed && i < subs.length ? subs[i] : primary[i],
      );
    }

    return Column(
      children: List.generate(min(display.length, 3), (i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: ThemeSizes.md),
          child: _buildGoalCard(display[i], i),
        );
      }),
    );
  }

  Widget _buildGoalCard(DailyChallenge c, int index) {
    final colors = ColorPalette.getChallengeGradient(index % 3);
    final locked = !c.isUnlocked;

    final lockType = locked
        ? (index == 1
            ? LockType.ads
            : index == 2
                ? LockType.premium
                : LockType.none)
        : LockType.none;

    // Nascondi refresh per posizioni 4, 5 e 6
    final isSubstitutePosition =
        c.position == 4 || c.position == 5 || c.position == 6;

    final isSub = c.isRefreshed || isSubstitutePosition;
    final canRefresh = !isSub && !c.isCompleted && !locked;
    final canComplete = !locked && !c.isCompleted;

    return DailyGoalCard(
      challengeId: c.id,
      name: c.name,
      score: c.points,
      isLocked: locked,
      lockType: lockType,
      startColor: colors[0],
      endColor: colors[1],
      isRefreshed: c.isRefreshed,
      isCompleted: c.isCompleted,
      onRefresh: canRefresh ? () => _refreshChallenge(c) : null,
      onComplete: canComplete ? () => _completeChallenge(c) : null,
      onLockedTap: locked ? () => _handleLockedTap(lockType, c) : null,
    );
  }

  void _handleLockedTap(LockType lockType, DailyChallenge c) {
    showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => PremiumAccessDialog(
        premiumOnly: lockType == LockType.premium,
        description: lockType == LockType.premium
            ? 'Per sbloccare tutte le sfide è necessario un abbonamento premium!'
            : 'Scegli come sbloccare questa sfida giornaliera:',
        onAdsBtnTapped: lockType == LockType.ads
            ? () => AdHelper().showRewardedAd(context)
            : null,
      ),
    ).then((granted) {
      if (granted == true) {
        // Se è una sfida bloccata da ads
        if (lockType == LockType.ads) {
          _unlockAndNotify(c);
        }
        // Se è una sfida premium e l'utente è diventato premium
        else if (lockType == LockType.premium) {
          _unlockAllPremiumChallenges();
        }
      }
    });
  }

  void _unlockAndNotify(DailyChallenge c) {
    final leagueState = context.read<AppLeagueCubit>().state as AppLeagueExists;
    final userState = context.read<AppUserCubit>().state as AppUserIsLoggedIn;

    context.read<DailyChallengesBloc>().add(
          UnlockDailyChallengeEvent(
            challenge: c,
            leagueId: leagueState.selectedLeague.id,
            userId: userState.user.id,
          ),
        );
  }

  void _refreshChallenge(DailyChallenge c) {
    final leagueState = context.read<AppLeagueCubit>().state as AppLeagueExists;
    final userState = context.read<AppUserCubit>().state as AppUserIsLoggedIn;
    setState(() => _isLoading = true);

    context.read<DailyChallengesBloc>().add(
          RefreshDailyChallengeEvent(
            challenge: c,
            leagueId: leagueState.selectedLeague.id,
            userId: userState.user.id,
          ),
        );
  }

  void _completeChallenge(DailyChallenge c) {
    setState(() => _isLoading = true);
    final leagueState = context.read<AppLeagueCubit>().state as AppLeagueExists;
    final userState = context.read<AppUserCubit>().state as AppUserIsLoggedIn;

    context.read<DailyChallengesBloc>().add(
          MarkChallengeAsCompletedEvent(
            challenge: c,
            userId: userState.user.id,
            leagueId: leagueState.selectedLeague.id,
          ),
        );
  }

  void _unlockAllPremiumChallenges() {
    final bloc = context.read<DailyChallengesBloc>();
    final currentState = bloc.state;

    if (currentState is DailyChallengesLoaded) {
      // Recupera lo stato di utente e lega
      final leagueState =
          context.read<AppLeagueCubit>().state as AppLeagueExists;

      final userState = context.read<AppUserCubit>().state as AppUserIsLoggedIn;

      // Usa l'evento specifico per sbloccare le sfide premium
      bloc.add(
        UnlockPremiumChallengesEvent(
          userId: userState.user.id,
          leagueId: leagueState.selectedLeague.id,
        ),
      );

      // Mostra un messaggio di conferma quando l'utente diventa premium
      showSnackBar(
        "Tutte le sfide giornaliere sbloccate!",
        color: ColorPalette.success,
      );
    }
  }

  Widget _buildPlaceholderGoals() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final gradient = ColorPalette
            .challengeGradients[i % ColorPalette.challengeGradients.length];
        return Container(
          margin: const EdgeInsets.only(bottom: ThemeSizes.md),
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: ThemeSizes.lg),
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius:
                      BorderRadius.circular(ThemeSizes.borderRadiusMd),
                  boxShadow: [
                    BoxShadow(
                      color: gradient[1].withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
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
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: ThemeSizes.md),
                          Container(
                            width: 50,
                            height: 24,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
