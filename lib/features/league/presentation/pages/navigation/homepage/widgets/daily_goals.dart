import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/challenge_processor.dart'; // Import the new utility
import 'package:fantavacanze_official/core/utils/show_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/divider.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:fantavacanze_official/features/league/data/models/daily_challenge_model.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_state.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/homepage/widgets/daily_goal_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DailyGoals extends StatefulWidget {
  const DailyGoals({super.key});

  @override
  State<DailyGoals> createState() => _DailyGoalsState();
}

class _DailyGoalsState extends State<DailyGoals> {
  List<DailyChallengeModel>? _allChallenges;
  bool _isLoading = false;
  int? _refreshingIndex;

  @override
  void initState() {
    super.initState();
    _loadDailyChallenges();
  }

  void _loadDailyChallenges() {
    if (_isLoading) return;

    final userState = context.read<AppUserCubit>().state;
    if (userState is AppUserIsLoggedIn) {
      setState(() => _isLoading = true);
      context.read<LeagueBloc>().add(
            GetDailyChallengesEvent(
              userId: userState.user.id,
            ),
          );
    }
  }

  void _updateChallengesAfterCompletion(LeagueState state) {
    _allChallenges
        ?.firstWhere(
          (challenge) =>
              challenge.id ==
              (state as ChallengeMarkedAsCompleted).challenge.id,
        )
        .copyWith(
          isCompleted: true,
          completedAt: DateTime.now(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LeagueBloc, LeagueState>(
      listener: (context, state) {
        if (state is LeagueError) {
          setState(() => _isLoading = false);
          showSnackBar(state.message);
        } else if (state is ChallengeMarkedAsCompleted) {
          setState(() => _isLoading = false);
          showSnackBar(
            "Obiettivo completato! Aspetta l'approvazione dell'admin.",
          );
          _updateChallengesAfterCompletion(state);
        } else if (state is ChallengeRefreshed) {
          setState(
            () {
              _isLoading = false;
              if (_refreshingIndex != null && _allChallenges != null) {
                _allChallenges![_refreshingIndex!] =
                    _allChallenges![_refreshingIndex!].copyWith(
                  isRefreshed: true,
                  refreshedAt: DateTime.now(),
                );

                _refreshingIndex = null;
              }
            },
          );
          showSnackBar(
            "Obiettivo aggiornato con successo!",
            color: ColorPalette.success,
          );
        } else if (state is DailyChallengesLoaded) {
          setState(() {
            _allChallenges = state.challenges as List<DailyChallengeModel>;
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
    );
  }

  Widget _buildChallengeList(BuildContext context) {
    // Get app state
    final userState = context.read<AppUserCubit>().state;
    final isPremium =
        userState is AppUserIsLoggedIn && userState.user.isPremium;
    final userId = userState is AppUserIsLoggedIn ? userState.user.id : null;

    // Get league state
    final leagueState = context.read<AppLeagueCubit>().state;
    final selectedLeagueId =
        leagueState is AppLeagueExists ? leagueState.selectedLeague.id : null;
    final admins = leagueState is AppLeagueExists
        ? leagueState.selectedLeague.admins
        : <String>[];

    // Process challenges using the new utility
    final processedChallenges =
        ChallengeProcessor.processChallenges(_allChallenges ?? []);

    if (processedChallenges.isEmpty) {
      return _buildPlaceholderGoals();
    }

    // For free users, only show the first challenge (in original position)
    final challengesToShow =
        isPremium ? processedChallenges : processedChallenges.take(3).toList();

    // Display the challenges
    return Column(
      children: List.generate(
        challengesToShow.length,
        (index) {
          final processedChallenge = challengesToShow[index];
          final challenge = processedChallenge.challenge;

          // Get gradient colors from ColorPalette
          final colorPair = ColorPalette.getChallengeGradient(
              processedChallenge.originalPrimaryIndex);

          // Determine if challenge is locked (for non-premium users)
          final bool isLocked = !isPremium && index > 0;

          return Padding(
            padding: const EdgeInsets.only(bottom: ThemeSizes.md),
            child: GestureDetector(
              onTap: isLocked || challenge.isCompleted
                  ? null
                  : () => _showChallengeOptions(
                      context, challenge, userId!, selectedLeagueId, admins),
              child: Stack(
                children: [
                  DailyGoalCard(
                    name: challenge.name,
                    score: challenge.points,
                    isLocked: isLocked,
                    startColor: colorPair[0],
                    endColor: colorPair[1],
                    isRefreshed: !processedChallenge.isPrimary,
                    isCompleted: challenge.isCompleted,
                    onRefresh: (isLocked || !processedChallenge.canRefresh)
                        ? null
                        : () => _showRefreshConfirmation(context, challenge,
                            userId!, processedChallenge.originalPrimaryIndex),
                  ),
                  if (challenge.isCompleted) _buildCompletedBadge(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showRefreshConfirmation(BuildContext context,
      DailyChallengeModel mainChallenge, String userId, int index) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Cambia obiettivo',
        message:
            'Vuoi cambiare questo obiettivo con uno nuovo? Questa operazione può essere eseguita una sola volta per ogni obiettivo.',
        confirmText: 'Cambia',
        cancelText: 'Annulla',
        icon: Icons.refresh_rounded,
        iconColor: ColorPalette.info,
        elevatedButtonStyle: ElevatedButton.styleFrom(
          backgroundColor: ColorPalette.info,
          foregroundColor: Colors.white,
        ),
        outlinedButtonStyle: OutlinedButton.styleFrom(
          foregroundColor: ColorPalette.info,
          side: BorderSide(color: ColorPalette.info, width: 1.5),
        ),
        onConfirm: () {
          setState(() {
            _isLoading = true;
            _refreshingIndex = index;
          });
          context.read<LeagueBloc>().add(
                RefreshDailyChallengeEvent(
                  challengeId: mainChallenge.id,
                  userId: userId,
                  primaryIndex: index,
                ),
              );
        },
      ),
    );
  }

  void _showChallengeOptions(
    BuildContext context,
    DailyChallengeModel challenge,
    String userId,
    String? leagueId,
    List<String> admins,
  ) {
    // Get the selected league directly from AppLeagueCubit instead of just the ID
    final leagueState = context.read<AppLeagueCubit>().state;
    if (leagueState is! AppLeagueExists) {
      showSnackBar("Devi prima selezionare una lega");
      return;
    }

    final selectedLeague = leagueState.selectedLeague;

    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Completato?',
        message: challenge.name,
        confirmText: 'Completato',
        cancelText: 'No',
        elevatedButtonStyle: ElevatedButton.styleFrom(
          backgroundColor: ColorPalette.success,
          foregroundColor: Colors.white,
        ),
        outlinedButtonStyle: OutlinedButton.styleFrom(
          foregroundColor: ColorPalette.error,
          side: BorderSide(color: ColorPalette.error, width: 1.5),
        ),
        icon: Icons.check_circle_outline,
        iconColor: ColorPalette.success,
        onConfirm: () {
          context.read<LeagueBloc>().add(
                MarkChallengeAsCompletedEvent(
                    challenge: challenge,
                    userId: userId,
                    league: selectedLeague),
              );
        },
      ),
    );
  }

  Widget _buildCompletedBadge() {
    return Positioned(
      top: 0,
      right: ThemeSizes.lg,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: ThemeSizes.sm, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusSm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check, color: Colors.white, size: 12),
            const SizedBox(width: 2),
            Text(
              "Completato",
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderGoals() {
    return Column(
      children: List.generate(
          3,
          (index) => Padding(
                padding: const EdgeInsets.only(bottom: ThemeSizes.md),
                child: DailyGoalCard(
                  name: 'Caricamento obiettivi...',
                  score: 0,
                  isLocked: index > 0,
                  startColor: Colors.grey[400]!,
                  endColor: Colors.grey[600]!,
                ),
              )),
    );
  }
}
