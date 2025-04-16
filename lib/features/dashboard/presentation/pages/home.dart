import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/modern_icon_button.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/widgets/helpers/homepage/article_card.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/widgets/helpers/divider.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/widgets/helpers/homepage/daily_goals.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/widgets/helpers/homepage/page_redirection_card.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/add_event.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/create_league_page.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/join_league_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLeagueCubit, AppLeagueState>(
      builder: (context, leagueState) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              if (leagueState is AppLeagueExists &&
                  leagueState.leagues.isNotEmpty)
                _buildParticipantContent(context, leagueState)
              else
                _buildNonParticipantContent(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNonParticipantContent(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.xl),
          child: CustomDivider(text: "Per Iniziare"),
        ),
        const SizedBox(height: 25),
        _buildActionButtons(context),
        const SizedBox(height: 25),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.xl),
          child: CustomDivider(text: 'I Nostri Articoli'),
        ),
        _buildArticles(),
        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildParticipantContent(
      BuildContext context, AppLeagueExists leagueState) {
    if (leagueState.selectedLeague != null) {
      final league = leagueState.selectedLeague!;
      final isAdmin = context.read<AppLeagueCubit>().isAdmin();

      return Column(
        children: [
          DailyGoals(),

          // Admin section for creating events
          if (isAdmin) ...[
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.xl),
              child: CustomDivider(text: 'Nuovo Evento'),
            ),
            const SizedBox(height: 15),
            _buildAdminActions(context),
          ],

          // Latest events section (visible to everyone)
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.xl),
            child: CustomDivider(text: 'Ultimi Eventi'),
          ),
          const SizedBox(height: 15),
          _buildLatestEvents(context, league),
        ],
      );
    }

    return _buildNonParticipantContent(context);
  }

  Widget _buildLatestEvents(BuildContext context, League league) {
    // Get the latest 5 events
    final events = league.events.take(5).toList();

    if (events.isEmpty) {
      // Show a message if there are no events
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: ThemeSizes.xl,
            horizontal: ThemeSizes.xl,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.celebration_outlined,
                size: 64,
                color: context.textSecondaryColor.withValues(alpha: 0.5),
              ),
              const SizedBox(height: ThemeSizes.md),
              Text(
                'Nessun evento ancora aggiunto alla lega. Inizia la sfida!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: context.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Display the events in a list
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.xl),
      child: Column(
        children: events.map((event) => _EventCard(event: event)).toList(),
      ),
    );
  }

  Widget _buildAdminActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.xl),
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          children: [
            // Container with image and text (positioned to allow button overlap)
            Padding(
              padding:
                  const EdgeInsets.only(left: 30.0), // Space for button overlap
              child: GestureDetector(
                onTap: () => _navigateToAddEvent(context),
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        // Background image
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/baddie-bg.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Gradient overlay for better readability
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.black.withValues(alpha: 0.5),
                                  Colors.black.withValues(alpha: 0.4),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Content
                        Padding(
                          padding: const EdgeInsets.all(ThemeSizes.lg),
                          child: Row(
                            children: [
                              const SizedBox(
                                  width:
                                      24), // Space for the overlapping button
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: ThemeSizes.xs),
                                    Text(
                                      'Aggiungi un nuovo evento',
                                      style: context.textTheme.headlineSmall
                                          ?.copyWith(
                                        color: ColorPalette.textPrimary(
                                          ThemeMode.dark,
                                        ),
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: ThemeSizes.xs),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Overlapping modern icon button
            Positioned(
              top: 25, // Center the button vertically with the taller container
              left: 0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ModernIconButton(
                  icon: Icons.add,
                  iconSize: 28,
                  padding: const EdgeInsets.all(18),
                  iconColor: context.primaryColor,
                  backgroundColor:
                      context.secondaryBgColor.withValues(alpha: 0.9),
                  onTap: () => _navigateToAddEvent(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddEvent(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEventPage()),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PageRedirectionCard(
          title: "Crea Lega",
          icon: Icons.add_circle_outline_sharp,
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => CreateLeaguePage()));
          },
        ),
        const SizedBox(width: 20),
        PageRedirectionCard(
          title: "Cerca Lega",
          icon: Icons.search_rounded,
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => JoinLeaguePage()));
          },
        ),
      ],
    );
  }
}

Widget _buildArticles() {
  return Column(
    children: [
      ArticleCard(
        imagePath: 'assets/images/baddie-bg.jpg',
        title: 'Rimorchiare come un pro in vacanza',
        readingTime: '2 min',
        redirectPage: const HomePage(),
      ),
      ArticleCard(
        imagePath: 'assets/images/social-enhance-bg.jpg',
        title: 'Come vivere una vacanza indimenticabile',
        readingTime: '2 min',
        redirectPage: const HomePage(),
      ),
    ],
  );
}

class _EventCard extends StatelessWidget {
  final dynamic event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    // Extract event data
    final String eventName = event.name;
    final int points = event.points;
    final bool isBonus = event.type == RuleType.bonus;
    final DateTime createdAt = event.createdAt;
    final String targetName =
        event.targetUser; // This might need to be fetched from participants
    final formattedDate = DateFormat('dd/MM/yyyy').format(createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: ThemeSizes.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(ThemeSizes.md),
        child: Row(
          children: [
            // Event type icon (bonus or malus)
            Container(
              padding: const EdgeInsets.all(ThemeSizes.sm),
              decoration: BoxDecoration(
                color: isBonus
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isBonus ? Icons.arrow_upward : Icons.arrow_downward,
                color: isBonus ? Colors.green : Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: ThemeSizes.md),
            // Event details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eventName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Assegnato a: $targetName',
                    style: TextStyle(
                      fontSize: 14,
                      color: context.textSecondaryColor,
                    ),
                  ),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            // Points
            Text(
              isBonus ? '+$points' : '$points',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isBonus ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
