import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/divider.dart';
import 'package:fantavacanze_official/core/widgets/events/events_list_widget.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/create_league/create_league_page.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/events/add_event.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/homepage/widgets/action_buttons_row.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/homepage/widgets/admin_action_card.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/homepage/widgets/articles_list.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/homepage/widgets/daily_goals.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/join_league/search_league_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLeagueCubit, AppLeagueState>(
      builder: (context, state) {
        // User has leagues and a selected league
        if (state is AppLeagueExists) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: _buildParticipantContent(context, state.selectedLeague),
          );
        }

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: _buildNonParticipantContent(context),
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

  Widget _buildParticipantContent(BuildContext context, League league) {
    final isAdmin = context.read<LeagueBloc>().isAdmin();

    return Column(
      children: [
        const DailyGoals(),

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

        // Use our new reusable component
        EventsListWidget(
          league: league,
          limit: 5,
          showAllEvents: true,
          onEventTap: (event) {
            // Handle event tap if needed
          },
        ),

        const SizedBox(height: 25),
      ],
    );
  }

  Widget _buildAdminActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.xl),
      child: AdminActionCard(
        title: 'Aggiungi un nuovo evento',
        imagePath: 'assets/images/add-event-bg.jpg',
        iconData: Icons.add,
        onTap: () => _navigateToAddEvent(context),
      ),
    );
  }

  void _navigateToAddEvent(BuildContext context) {
    Navigator.push(
      context,
      AddEventPage.route,
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return ActionButtonsRow(
      buttons: [
        ActionButtonData(
          title: "Crea Lega",
          icon: Icons.add_circle_outline_sharp,
          onPressed: () {
            Navigator.push(
              context,
              CreateLeaguePage.route,
            );
          },
        ),
        ActionButtonData(
          title: "Cerca Lega",
          icon: Icons.search_rounded,
          onPressed: () {
            Navigator.push(
              context,
              SearchLeaguePage.route,
            );
          },
        ),
      ],
    );
  }

  Widget _buildArticles() {
    return ArticlesList(
      articles: [
        ArticleData(
          imagePath: 'assets/images/baddie-bg.jpg',
          title: 'Rimorchiare come un pro in vacanza',
          readingTime: '2 min',
          redirectPage: const HomePage(),
        ),
        ArticleData(
          imagePath: 'assets/images/social-enhance-bg.jpg',
          title: 'Come vivere una vacanza indimenticabile',
          readingTime: '2 min',
          redirectPage: const HomePage(),
        ),
      ],
    );
  }
}
