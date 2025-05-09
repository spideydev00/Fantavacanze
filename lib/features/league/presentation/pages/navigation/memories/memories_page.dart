import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/memory.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/core/confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class MemoriesPage extends StatelessWidget {
  static Route get route =>
      MaterialPageRoute(builder: (context) => const MemoriesPage());
  const MemoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLeagueCubit, AppLeagueState>(
      builder: (context, state) {
        if (state is AppLeagueExists) {
          final league = state.selectedLeague;
          final memories = league.memories;
          final isAdmin = context.read<LeagueBloc>().isAdmin();

          final userId =
              (context.read<AppUserCubit>().state as AppUserIsLoggedIn).user.id;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Ricordi'),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                // Navigate to add memory page or show dialog
                _showAddMemoryDialog(context, league.id, userId);
              },
              child: const Icon(Icons.add_photo_alternate),
            ),
            body: memories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_album_outlined,
                          size: 64,
                          color:
                              context.textSecondaryColor.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: ThemeSizes.md),
                        Text(
                          'Nessun ricordo ancora',
                          style: TextStyle(
                            fontSize: 18,
                            color: context.textSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: ThemeSizes.lg),
                        ElevatedButton.icon(
                          onPressed: () {
                            _showAddMemoryDialog(context, league.id, userId);
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Aggiungi un ricordo'),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(ThemeSizes.md),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: ThemeSizes.md,
                      mainAxisSpacing: ThemeSizes.md,
                    ),
                    itemCount: memories.length,
                    itemBuilder: (context, index) {
                      final memory = memories[index];
                      final canDelete = isAdmin || memory.userId == userId;

                      return _MemoryCard(
                        memory: memory,
                        onTap: () => _showMemoryDetails(context, memory),
                        onDelete: canDelete
                            ? () =>
                                _confirmDeleteMemory(context, league, memory.id)
                            : null,
                      );
                    },
                  ),
          );
        }

        return const Center(child: Text('Nessuna lega selezionata'));
      },
    );
  }

  void _showMemoryDetails(BuildContext context, Memory memory) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(ThemeSizes.borderRadiusLg),
              ),
              child: Image.network(
                memory.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 250,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 250,
                  color: Colors.grey.shade300,
                  child: Icon(
                    Icons.broken_image,
                    size: 64,
                    color: Colors.grey.shade600,
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 250,
                    color: Colors.grey.shade200,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(ThemeSizes.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    memory.text,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: ThemeSizes.md),
                  Text(
                    'Aggiunto il ${DateFormat('dd/MM/yyyy').format(memory.createdAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: ThemeSizes.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Chiudi'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMemoryDialog(
      BuildContext context, String leagueId, String userId) {
    final textController = TextEditingController();
    final imageUrlController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? selectedEventId;

    // Get current league to access events
    final state = context.read<AppLeagueCubit>().state;
    final league = (state as AppLeagueExists).selectedLeague;

    final recentEvents = league.events.take(5).toList();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
          ),
          child: Padding(
            padding: const EdgeInsets.all(ThemeSizes.lg),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aggiungi un ricordo',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: context.primaryColor,
                    ),
                  ),
                  const SizedBox(height: ThemeSizes.lg),
                  TextFormField(
                    controller: imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'URL Immagine',
                      hintText: 'Inserisci l\'URL dell\'immagine',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Inserisci un URL';
                      }
                      if (!Uri.tryParse(value)!.isAbsolute) {
                        return 'Inserisci un URL valido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: ThemeSizes.md),
                  TextFormField(
                    controller: textController,
                    decoration: const InputDecoration(
                      labelText: 'Descrizione',
                      hintText: 'Descrivi questo ricordo',
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Inserisci una descrizione';
                      }
                      return null;
                    },
                  ),

                  // Add dropdown for related events if available
                  if (recentEvents.isNotEmpty) ...[
                    const SizedBox(height: ThemeSizes.md),
                    DropdownButtonFormField<String?>(
                      decoration: const InputDecoration(
                        labelText: 'Collega a un evento (opzionale)',
                        hintText: 'Seleziona un evento recente',
                      ),
                      value: selectedEventId,
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Nessun evento'),
                        ),
                        ...recentEvents.map(
                          (event) => DropdownMenuItem<String?>(
                            value: event.id,
                            child: Text(event.name),
                          ),
                        )
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedEventId = value;
                        });
                      },
                    ),
                  ],

                  const SizedBox(height: ThemeSizes.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annulla'),
                      ),
                      const SizedBox(width: ThemeSizes.md),
                      ElevatedButton(
                        onPressed: () {
                          context.read<LeagueBloc>().add(
                                AddMemoryEvent(
                                  league: league,
                                  imageUrl: imageUrlController.text.trim(),
                                  text: textController.text.trim(),
                                  userId: userId,
                                  relatedEventId: selectedEventId,
                                ),
                              );
                          Navigator.pop(context);
                        },
                        child: const Text('Salva'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDeleteMemory(
      BuildContext context, League league, String memoryId) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog.deleteMemory(
        onDelete: () {
          context.read<LeagueBloc>().add(
                RemoveMemoryEvent(
                  league: league,
                  memoryId: memoryId,
                ),
              );
        },
      ),
    );
  }
}

class _MemoryCard extends StatelessWidget {
  final Memory memory;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _MemoryCard({
    required this.memory,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
        ),
        elevation: 3,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Image.network(
                    memory.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade300,
                      child: Icon(
                        Icons.broken_image,
                        size: 48,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey.shade200,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(ThemeSizes.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          memory.text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          DateFormat('dd/MM/yyyy').format(memory.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: context.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (onDelete != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: onDelete,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
