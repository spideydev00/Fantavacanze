import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/divider.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/homepage/widgets/daily_goal_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DailyGoals extends StatelessWidget {
  const DailyGoals({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppUserCubit, AppUserState>(
      builder: (context, state) {
        final isPremium = state is AppUserIsLoggedIn && state.user.isPremium;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.xl),
              child: CustomDivider(text: "Obiettivi giornalieri"),
            ),
            const SizedBox(height: ThemeSizes.md),
            _buildObjectivesList(isPremium),
          ],
        );
      },
    );
  }

  Widget _buildObjectivesList(bool isPremium) {
    final List<Map<String, dynamic>> objectives = [
      {
        'name': 'Bevi 3 shot in 10 minuti',
        'score': 5,
        'colors': [
          const Color(0xFF6C72CB), // Purple-ish
          const Color(0xFFCB69C1),
        ]
      },
      {
        'name': 'Fai un selfie con uno sconosciuto',
        'score': 2,
        'colors': [
          const Color.fromARGB(255, 69, 167, 253), // Blue gradient
          const Color.fromARGB(255, 91, 197, 202),
        ]
      },
      {
        'name': 'Canta una canzone in pubblico',
        'score': 10,
        'colors': [
          const Color(0xFFFF8008), // Orange gradient
          const Color.fromARGB(255, 228, 190, 92),
        ]
      },
    ];

    return Column(
      children: [
        DailyGoalCard(
          name: objectives[0]['name'],
          score: objectives[0]['score'],
          startColor: objectives[0]['colors'][0],
          endColor: objectives[0]['colors'][1],
        ),
        const SizedBox(height: ThemeSizes.md),
        DailyGoalCard(
          name: objectives[1]['name'],
          score: objectives[1]['score'],
          isLocked: !isPremium,
          startColor: objectives[1]['colors'][0],
          endColor: objectives[1]['colors'][1],
        ),
        const SizedBox(height: ThemeSizes.md),
        DailyGoalCard(
          name: objectives[2]['name'],
          score: objectives[2]['score'],
          isLocked: !isPremium,
          startColor: objectives[2]['colors'][0],
          endColor: objectives[2]['colors'][1],
        ),
      ],
    );
  }
}
