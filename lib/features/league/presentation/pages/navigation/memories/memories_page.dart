import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/show_snackbar.dart';
import 'package:fantavacanze_official/features/league/domain/entities/event.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/memory.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_state.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/common/empty_state.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/memories/add_memory_bottom_sheet.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/memories/memory_card.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/memories/memory_detail_screen.dart';
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

  // Add these new variables to store form data
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
      backgroundColor: context.bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ThemeSizes.borderRadiusLg),
        ),
      ),
      builder: (context) => AddMemoryBottomSheet(
        league: _currentLeague!,
        events: _currentLeague!.events,
        onSave: _handleSaveMemory,
      ),
    );
  }

  void _handleSaveMemory(
      File imageFile, String text, Event? event, String? eventName) {
    if (_currentLeague == null || _currentUserId == null) return;

    // Store the form values for later use
    _pendingMemoryText = text;
    _pendingEventId = event?.id;
    _pendingEventName = eventName;

    // First upload the image
    context.read<LeagueBloc>().add(UploadImageEvent(
          leagueId: _currentLeague!.id,
          imageFile: imageFile,
        ));

    setState(() {
      _isLoading = true;
    });
  }

  void _deleteMemory(String memoryId) {
    if (_currentLeague == null) return;

    // Confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: const Text('Sei sicuro di voler eliminare questo ricordo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<LeagueBloc>().add(
                    RemoveMemoryEvent(
                      league: _currentLeague!,
                      memoryId: memoryId,
                    ),
                  );
            },
            style: TextButton.styleFrom(
              foregroundColor: ColorPalette.error,
            ),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }

  void _openMemoryDetail(Memory memory) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemoryDetailScreen(
          memory: memory,
          isCurrentUserAuthor: memory.userId == _currentUserId || _isAdmin,
          onDelete: () => _deleteMemory(memory.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocConsumer<LeagueBloc, LeagueState>(
      listener: (context, state) {
        if (state is LeagueError) {
          showSnackBar(context, state.message);
          setState(() {
            _isLoading = false;
          });
        } else if (state is ImageUploadSuccess) {
          // After image upload, add the memory
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
          // Update the current league reference
          _currentLeague = state.league;

          // Clear the pending data
          _pendingMemoryText = '';
          _pendingEventId = null;
          _pendingEventName = null;

          // Close bottom sheet if it's open
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }

          showSnackBar(
            context,
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
                floatingActionButton: FloatingActionButton(
                  onPressed: _isLoading ? null : _showAddMemoryBottomSheet,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Icon(Icons.add_photo_alternate),
                ),
                body: memories.isEmpty
                    ? const EmptyState(
                        icon: Icons.photo_album_outlined,
                        title: 'Nessun ricordo',
                        subtitle: 'Aggiungi dei ricordi della tua vacanza',
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          if (_currentLeague != null) {
                            context.read<LeagueBloc>().add(
                                GetLeagueEvent(leagueId: _currentLeague!.id));
                          }
                        },
                        child: CustomScrollView(
                          slivers: [
                            // Recent memories in horizontal list
                            SliverToBoxAdapter(
                              child: _buildRecentMemories(memories),
                            ),

                            // All memories in staggered grid
                            SliverPadding(
                              padding: const EdgeInsets.all(ThemeSizes.md),
                              sliver: SliverMasonryGrid.count(
                                crossAxisCount: 2,
                                mainAxisSpacing: ThemeSizes.md,
                                crossAxisSpacing: ThemeSizes.md,
                                childCount: memories.length,
                                itemBuilder: (context, index) {
                                  final memory = memories[index];
                                  return MemoryCard(
                                    memory: memory,
                                    isCurrentUserAuthor:
                                        memory.userId == _currentUserId ||
                                            _isAdmin,
                                    onTap: () => _openMemoryDetail(memory),
                                    onDelete: () => _deleteMemory(memory.id),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
              );
            }

            return const Center(child: Text('Nessuna lega selezionata'));
          },
        );
      },
    );
  }

  Widget _buildRecentMemories(List<Memory> memories) {
    if (memories.length <= 3) return const SizedBox.shrink();

    // Take the 5 most recent memories for the horizontal list
    final recentMemories = List<Memory>.from(memories)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final topMemories = recentMemories.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(
            left: ThemeSizes.md,
            right: ThemeSizes.md,
            top: ThemeSizes.md,
          ),
          child: Text(
            'Ricordi recenti',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: ThemeSizes.sm),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.sm),
            itemCount: topMemories.length,
            itemBuilder: (context, index) {
              final memory = topMemories[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.sm),
                child: GestureDetector(
                  onTap: () => _openMemoryDetail(memory),
                  child: Container(
                    width: 140,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(ThemeSizes.borderRadiusMd),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Memory image
                        CachedNetworkImage(
                          imageUrl: memory.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: context.secondaryBgColor,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: context.secondaryBgColor,
                            child: const Icon(Icons.error),
                          ),
                        ),

                        // Gradient overlay for text readability
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.7),
                                ],
                                stops: const [0.6, 1.0],
                              ),
                            ),
                          ),
                        ),

                        // User name at bottom
                        Positioned(
                          bottom: 8,
                          left: 8,
                          right: 8,
                          child: Text(
                            memory.participantName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: ThemeSizes.md),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: ThemeSizes.md),
          child: Text(
            'Tutti i ricordi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
