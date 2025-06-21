import 'dart:async';
import 'dart:math' show min;

import 'package:fantavacanze_official/core/services/review_service.dart';
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
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc/league_state.dart';
import 'package:get_it/get_it.dart';
import 'package:shimmer/shimmer.dart';
import 'daily_goal_card.dart';

class DailyGoals extends StatefulWidget {
  const DailyGoals({super.key});

  @override
  State<DailyGoals> createState() => _DailyGoalsState();
}

class _DailyGoalsState extends State<DailyGoals> {
  List<DailyChallenge>? _allChallenges;
  bool _isLoading = false;
  StreamSubscription? _userSubscription;
  final _reviewService = GetIt.instance<ReviewService>();

  @override
  void initState() {
    super.initState();
    _loadDailyChallenges();

    // Listen to premium status changes
    _userSubscription = context.read<AppUserCubit>().stream.listen((state) {
      if (state is AppUserIsLoggedIn && mounted) {
        final prevState = context.read<AppUserCubit>().state;
        // If premium status changed, reload challenges
        if (prevState is AppUserIsLoggedIn &&
            prevState.user.isPremium != state.user.isPremium) {
          _loadDailyChallenges();
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<AppLeagueCubit>().stream.listen((state) {
      if (state is AppLeagueExists) {
        setState(() {
          _allChallenges = null;
          _isLoading = false;
        });
        _loadDailyChallenges();
      }
    });
  }

  void _loadDailyChallenges() {
    if (_isLoading) return;
    final userState = context.read<AppUserCubit>().state;
    final leagueState = context.read<AppLeagueCubit>().state;
    if (userState is AppUserIsLoggedIn && leagueState is AppLeagueExists) {
      setState(() => _isLoading = true);
      context.read<LeagueBloc>().add(
            GetDailyChallengesEvent(
              userId: userState.user.id,
              leagueId: leagueState.selectedLeague.id,
            ),
          );
    }
  }

  void _checkAndRequestReview() {
    // Add a small delay so the snackbar for challenge refresh can be seen first
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _reviewService.checkAndRequestReview(
          context,
          context.read<AppUserCubit>(),
        );
      }
    });
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LeagueBloc, LeagueState>(
      listener: _onLeagueStateChange,
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
            if (_isLoading && _allChallenges == null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 80),
                  child: Loader(color: ColorPalette.success),
                ),
              )
            else if (_allChallenges != null)
              _buildChallengeList(context)
            else
              _buildPlaceholderGoals(),
          ],
        );
      },
    );
  }

  void _onLeagueStateChange(BuildContext context, LeagueState state) {
    if (state is DailyChallengesLoaded) {
      setState(() {
        _allChallenges = state.challenges;
        _isLoading = false;
      });
    } else if (state is LeagueError) {
      setState(() => _isLoading = false);
      showSnackBar(state.message);
    } else if (state is ChallengeMarkedAsCompleted) {
      _updateSingleChallenge(
        state.challenge.id,
        isCompleted: true,
      );
      setState(() => _isLoading = false);
      showSnackBar(
        "Obiettivo segnato come completato!",
        color: ColorPalette.success,
      );
    } else if (state is ChallengeRefreshed) {
      _updateSingleChallenge(
        state.challengeId,
        isRefreshed: true,
      );
      setState(() => _isLoading = false);
      showSnackBar(
        "Obiettivo aggiornato con successo!",
        color: ColorPalette.success,
      );

      _checkAndRequestReview();
    }
  }

  void _updateSingleChallenge(
    String id, {
    bool isCompleted = false,
    bool isRefreshed = false,
    bool isUnlocked = false,
  }) {
    if (_allChallenges == null) return;

    final list = List<DailyChallenge>.from(_allChallenges!);
    final idx = list.indexWhere((c) => c.id == id);

    if (idx == -1) return;

    final primary = list[idx];

    list[idx] = primary.copyWith(
      isCompleted: isCompleted ? true : primary.isCompleted,
      isRefreshed: isRefreshed ? true : primary.isRefreshed,
      isUnlocked: isUnlocked ? true : primary.isUnlocked,
      completedAt: isCompleted ? DateTime.now() : primary.completedAt,
      refreshedAt: isRefreshed ? DateTime.now() : primary.refreshedAt,
    );

    if (isRefreshed && idx + 3 < list.length) {
      final sub = list[idx + 3];
      list[idx + 3] = sub.copyWith(isRefreshed: true);
    }

    if (isUnlocked && idx + 3 < list.length) {
      final sub = list[idx + 3];
      list[idx + 3] = sub.copyWith(isUnlocked: true);
    }

    setState(() => _allChallenges = list);
  }

  Widget _buildChallengeList(BuildContext context) {
    final challenges = List<DailyChallenge>.from(_allChallenges!)
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
      if (granted == true && lockType == LockType.ads) {
        _unlockAndNotify(c);
      }
    });
  }

  void _unlockAndNotify(DailyChallenge c) {
    final leagueState = context.read<AppLeagueCubit>().state as AppLeagueExists;

    context.read<LeagueBloc>().add(
          UnlockDailyChallengeEvent(
            challengeId: c.id,
            leagueId: leagueState.selectedLeague.id,
            isUnlocked: true,
          ),
        );

    _updateSingleChallenge(
      c.id,
      isUnlocked: true,
    );

    showSnackBar(
      "Sfida sbloccata con successo!",
      color: ColorPalette.success,
    );
  }

  void _refreshChallenge(DailyChallenge c) {
    final leagueState = context.read<AppLeagueCubit>().state as AppLeagueExists;
    final userState = context.read<AppUserCubit>().state as AppUserIsLoggedIn;
    setState(() => _isLoading = true);

    context.read<LeagueBloc>().add(
          RefreshDailyChallengeEvent(
            challengeId: c.id,
            leagueId: leagueState.selectedLeague.id,
            userId: userState.user.id,
          ),
        );
  }

  void _completeChallenge(DailyChallenge c) {
    setState(() => _isLoading = true);
    final leagueState = context.read<AppLeagueCubit>().state as AppLeagueExists;
    final userState = context.read<AppUserCubit>().state as AppUserIsLoggedIn;

    context.read<LeagueBloc>().add(
          MarkChallengeAsCompletedEvent(
            challenge: c,
            userId: userState.user.id,
            league: leagueState.selectedLeague,
          ),
        );
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
