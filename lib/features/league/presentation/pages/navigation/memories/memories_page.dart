import 'dart:io';
import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/show-snackbar-or-paywall/show_snackbar.dart';
import 'package:fantavacanze_official/core/utils/dates-and-numbers/sort_by_date.dart';
import 'package:fantavacanze_official/core/widgets/buttons/gradient_option_button.dart';
import 'package:fantavacanze_official/features/league/domain/entities/event.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/memory.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc/league_state.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/memories/widgets/add_memory_bottom_sheet.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/memories/widgets/memory_card.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/memories/widgets/memory_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class MemoriesPage extends StatefulWidget {
  static Route get route =>
      MaterialPageRoute(builder: (context) => const MemoriesPage());
  const MemoriesPage({super.key});

  @override
  State<MemoriesPage> createState() => _MemoriesPageState();
}

class _MemoriesPageState extends State<MemoriesPage>
    with AutomaticKeepAliveClientMixin {
  League? _currentLeague;
  String? _currentUserId;

  bool _isAdmin = false;
  bool _isLoading = false;

  // Variabili per memorizzare i dati del form
  String _pendingMemoryText = '';
  String? _pendingEventId;
  String? _pendingEventName;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() {
    final userState = context.read<AppUserCubit>().state;
    if (userState is AppUserIsLoggedIn) {
      _currentUserId = userState.user.id;
    }

    final leagueState = context.read<AppLeagueCubit>().state;
    if (leagueState is AppLeagueExists) {
      _currentLeague = leagueState.selectedLeague;
      _isAdmin = _currentLeague!.admins.contains(_currentUserId);
    }
  }

  void _showAddMemoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddMemoryBottomSheet(
        league: _currentLeague!,
        events: _currentLeague!.events,
        onSave: _handleSaveMemory,
        currentUserId: _currentUserId!, // Add this parameter
      ),
    );
  }

  void _handleSaveMemory(
    File mediaFile,
    String text,
    Event? event,
    String? eventName,
  ) {
    if (_currentLeague == null || _currentUserId == null) return;

    // Store the form values for later use
    _pendingMemoryText = text;
    _pendingEventId = event?.id;
    _pendingEventName = eventName;

    // First upload the image
    context.read<LeagueBloc>().add(
          UploadMediaEvent(
            leagueId: _currentLeague!.id,
            mediaFile: mediaFile,
          ),
        );

    setState(() {
      _isLoading = true;
    });
  }

  /// Elimina subito il ricordo, senza mostrare una seconda conferma
  void _deleteMemoryImmediate(String memoryId) {
    if (_currentLeague == null) return;
    context.read<LeagueBloc>().add(
          RemoveMemoryEvent(
            league: _currentLeague!,
            memoryId: memoryId,
          ),
        );
  }

  /// Rimuove il ricordo mostrando dialog di conferma
  void _deleteMemory(String memoryId) {
    if (_currentLeague == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: const Text('Sei sicuro di voler eliminare questo ricordo?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        ),
        backgroundColor: context.bgColor,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annulla',
              style: TextStyle(
                color: context.textSecondaryColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<LeagueBloc>().add(
                    RemoveMemoryEvent(
                      league: _currentLeague!,
                      memoryId: memoryId,
                    ),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorPalette.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }

  /// Apre lo schermo di dettaglio e passa il callback "immediato"
  void _openMemoryDetail(Memory memory) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemoryDetailScreen(
          memory: memory,
          isCurrentUserAuthor: memory.userId == _currentUserId || _isAdmin,
          onDelete: () => _deleteMemoryImmediate(memory.id),
          league: _currentLeague,
        ),
      ),
    );
  }

  Widget _buildAddMemoryButton() {
    return _isLoading
        ? Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
              color: context.secondaryBgColor,
            ),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(context.primaryColor),
              ),
            ),
          )
        : GradientOptionButton(
            isSelected: true,
            label: 'Aggiungi un ricordo',
            icon: Icons.add_photo_alternate_rounded,
            onTap: _showAddMemoryBottomSheet,
            primaryColor: const Color(0xFF614385),
            secondaryColor: const Color(0xFF516395),
            iconSize: 32,
            labelFontSize: 14,
            description: 'Immortala un momento speciale',
            descriptionFontSize: 12,
          );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocConsumer<LeagueBloc, LeagueState>(
      listener: (context, state) {
        if (state is LeagueError) {
          showSnackBar(state.message);
          setState(() {
            _isLoading = false;
          });
        } else if (state is ImageUploadSuccess) {
          if (_currentLeague != null && _currentUserId != null) {
            context.read<LeagueBloc>().add(AddMemoryEvent(
                  league: _currentLeague!,
                  imageUrl: state.imageUrl,
                  text: _pendingMemoryText,
                  userId: _currentUserId!,
                  relatedEventId: _pendingEventId,
                  eventName: _pendingEventName,
                ));
          }
        } else if (state is LeagueSuccess && state.operation == 'add_memory') {
          setState(() {
            _isLoading = false;
          });
          _currentLeague = state.league;
          _pendingMemoryText = '';
          _pendingEventId = null;
          _pendingEventName = null;
          if (Navigator.canPop(context)) Navigator.pop(context);
          showSnackBar(
            'Ricordo aggiunto con successo!',
            color: ColorPalette.success,
          );
        }
      },
      builder: (context, state) {
        return BlocBuilder<AppLeagueCubit, AppLeagueState>(
          builder: (context, leagueState) {
            if (leagueState is AppLeagueExists) {
              _currentLeague = leagueState.selectedLeague;
              _isAdmin = _currentLeague!.admins.contains(_currentUserId);
              final memories = _currentLeague!.memories;
              return Scaffold(
                body: memories.isEmpty
                    ? _buildEmptyState()
                    : _buildMemoriesGrid(memories),
              );
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sports_score_outlined,
                    size: 60,
                    color: context.textSecondaryColor.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: ThemeSizes.md),
                  Text(
                    'Nessuna lega selezionata',
                    style: TextStyle(
                      fontSize: 18,
                      color: context.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(ThemeSizes.md),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.grid_view_rounded, size: 16),
              const SizedBox(width: 8),
              Text(
                'Porta con te i tuoi ricordi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'Qui puoi caricare foto della vacanza e condividerle con gli altri partecipanti della lega. Puoi collegarle ad un evento della lega, per sbeffeggiare gli altri ancora di più!',
            style: context.textTheme.bodyMedium!.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: 60),
          SizedBox(
            height: Constants.getHeight(context) * 0.25,
            child: _buildAddMemoryButton(),
          ),
        ],
      ),
    );
  }

  // Grid with memories and positioned add button
  Widget _buildMemoriesGrid(List<Memory> memories) {
    // Use the utility function to sort memories by creation date (newest first)
    final sortedMemories = sortMemoriesByDate(memories);

    return RefreshIndicator(
      onRefresh: () async {
        if (_currentLeague != null) {
          context.read<LeagueBloc>().add(
                GetLeagueEvent(leagueId: _currentLeague!.id),
              );
        }
      },
      color: context.primaryColor,
      backgroundColor: context.secondaryBgColor,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                ThemeSizes.md,
                0,
                ThemeSizes.md,
                0,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ThemeSizes.md,
                vertical: ThemeSizes.sm,
              ),
              child: Row(
                children: [
                  Icon(Icons.grid_view_rounded, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Porta con te i tuoi ricordi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(ThemeSizes.md),
            sliver: SliverToBoxAdapter(
              child: MasonryGridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: ThemeSizes.md,
                crossAxisSpacing: ThemeSizes.md,
                itemCount: sortedMemories.length + 1, // Use sortedMemories
                itemBuilder: (context, index) {
                  // Place add button as the second item
                  if (index == 1) {
                    return _buildAddMemoryButton();
                  }

                  // Adjust index for memories
                  final memoryIndex = index > 1 ? index - 1 : index;
                  final memory =
                      sortedMemories[memoryIndex]; // Use sortedMemories

                  return MemoryCard(
                    memory: memory,
                    isCurrentUserAuthor:
                        memory.userId == _currentUserId || _isAdmin,
                    onTap: () => _openMemoryDetail(memory),
                    onDelete: () => _deleteMemory(memory.id),
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}
