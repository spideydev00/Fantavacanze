import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/show-snackbar-or-paywall/show_snackbar.dart';
import 'package:fantavacanze_official/features/league/domain/entities/individual_participant.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/note.dart';
import 'package:fantavacanze_official/features/league/domain/entities/participant.dart';
import 'package:fantavacanze_official/features/league/domain/entities/team_participant.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc/league_state.dart';
import 'package:fantavacanze_official/core/widgets/empty_state.dart';
import 'package:fantavacanze_official/core/widgets/divider.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/notes/widgets/note_input.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/notes/widgets/notes_list.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/notes/widgets/participant_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class NotesPage extends StatefulWidget {
  static Route get route =>
      MaterialPageRoute(builder: (context) => const NotesPage());
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _noteFocusNode = FocusNode();
  final Uuid _uuid = const Uuid();

  List<Note> _notes = [];
  Participant? _selectedParticipant;
  String? _selectedUserId;
  String? _currentLeagueId;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    final league = _getCurrentLeague();
    if (league != null) {
      context.read<LeagueBloc>().add(GetNotesEvent(leagueId: league.id));
    }
  }

  League? _getCurrentLeague() {
    final leagueState = context.read<AppLeagueCubit>().state;
    if (leagueState is AppLeagueExists) {
      return leagueState.selectedLeague;
    }
    return null;
  }

  void _cancelEditing() {
    setState(() {
      _noteController.clear();
      _selectedParticipant = null;
      _selectedUserId = null;
    });
    _noteFocusNode.unfocus();
  }

  Future<void> _saveNote() async {
    final String targetId = _getTargetId();

    if (targetId.isEmpty || _noteController.text.trim().isEmpty) {
      showSnackBar('Seleziona un partecipante e inserisci una nota');
      return;
    }

    final league = _getCurrentLeague();
    if (league == null) {
      return;
    }

    final newNote = Note(
      id: _uuid.v4(),
      participantId: targetId,
      participantName: _getParticipantName(),
      content: _noteController.text.trim(),
      createdAt: DateTime.now(),
      leagueId: league.id,
    );

    context.read<LeagueBloc>().add(SaveNoteEvent(
          leagueId: league.id,
          note: newNote,
        ));

    setState(() {
      _noteController.clear();
      _selectedUserId = null;
      _selectedParticipant = null;
    });
    _noteFocusNode.unfocus();
  }

  String _getTargetId() {
    if (_selectedParticipant is IndividualParticipant) {
      return (_selectedParticipant as IndividualParticipant).userId;
    } else if (_selectedParticipant is TeamParticipant &&
        _selectedUserId != null) {
      return _selectedUserId!;
    }
    return "";
  }

  String _getParticipantName() {
    if (_selectedParticipant is TeamParticipant && _selectedUserId != null) {
      final teamName = _selectedParticipant!.name;
      final userName = _getUserNameById(_selectedUserId!) ?? "Membro del team";
      return "$teamName - $userName";
    }
    return _selectedParticipant?.name ?? "";
  }

  String? _getUserNameById(String userId) {
    final league = _getCurrentLeague();
    if (league != null) {
      for (final participant in league.participants) {
        if (participant is TeamParticipant) {
          final member = participant.findMemberById(userId);
          if (member != null) {
            return member.name;
          }
        } else if (participant is IndividualParticipant &&
            participant.userId == userId) {
          return participant.name;
        }
      }
    }

    return null;
  }

  /// Quando l’utente fa swipe, chiamo questa callback
  void _onNoteSwiped(String noteId) {
    // 1) Rimuovo subito la nota dalla lista locale
    setState(() {
      _notes.removeWhere((n) => n.id == noteId);
    });

    // 2) Invio il comando al bloc per cancellarla dal data source
    final league = _getCurrentLeague();
    if (league != null) {
      context.read<LeagueBloc>().add(DeleteNoteEvent(
            leagueId: league.id,
            noteId: noteId,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LeagueBloc, LeagueState>(
      listener: (context, state) {
        if (state is LeagueLoading) {}
        if (state is NoteSuccess) {
          // If notes are provided in the state, update the local list
          if (state.notes != null) {
            setState(() {
              _notes = state.notes!;
            });
          }

          switch (state.operation) {
            case 'get':
              // Notes are already updated by the check above if present.
              // If state.notes was null for a 'get' (should not happen with current bloc logic),
              // _notes would become empty.
              break;
            case 'save':
              // _loadNotes(); // No longer needed, notes are included in the 'save' success state.
              showSnackBar(
                'Nota salvata con successo!',
                color: ColorPalette.success,
              );
              break;
            case 'delete':
              showSnackBar(
                'Nota eliminata con successo!',
                color: ColorPalette.success,
              );
              // _loadNotes(); // No longer needed, notes are included in the 'delete' success state.
              // Optionally, show a snackbar for delete success
              // showSnackBar('Nota eliminata con successo!');
              break;
          }
        } else if (state is LeagueError) {
          showSnackBar(state.message);
        }
      },
      builder: (context, state) {
        return BlocBuilder<AppLeagueCubit, AppLeagueState>(
          builder: (context, leagueState) {
            if (leagueState is AppLeagueExists) {
              final league = leagueState.selectedLeague;
              final participants = league.participants;

              return Scaffold(
                resizeToAvoidBottomInset: true,
                appBar: AppBar(
                  actions: _buildAppBarActions(),
                ),
                body: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: SafeArea(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: ThemeSizes.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const CustomDivider(
                                  text: "Scegli un partecipante",
                                  hasDropdown: true,
                                  dropdownText:
                                      'Non hai voglia o tempo di creare ora un evento? Crea una nota per ricordarti tutto!',
                                ),
                                const SizedBox(height: ThemeSizes.sm),
                                ParticipantSelector<Participant>(
                                  items: participants,
                                  value: _selectedParticipant,
                                  hintText: "Seleziona partecipante",
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedParticipant = value;
                                      _selectedUserId = null;

                                      if (value is IndividualParticipant) {
                                        Future.microtask(() =>
                                            _noteFocusNode.requestFocus());
                                      }
                                    });
                                  },
                                  itemBuilder: (participant) =>
                                      ParticipantSelector
                                          .defaultParticipantItem(
                                              context, participant),
                                ),
                                if (_selectedParticipant
                                    is TeamParticipant) ...[
                                  const SizedBox(height: ThemeSizes.md),
                                  const CustomDivider(
                                    text: "Seleziona membro del team",
                                  ),
                                  const SizedBox(height: ThemeSizes.sm),
                                  _buildTeamMemberSelector(),
                                ],
                                const SizedBox(height: ThemeSizes.md),
                                if (_canShowNoteInput()) ...[
                                  const CustomDivider(text: "Scrivi una nota"),
                                  const SizedBox(height: ThemeSizes.sm),
                                  NoteInput(
                                    controller: _noteController,
                                    focusNode: _noteFocusNode,
                                  ),
                                  const SizedBox(height: ThemeSizes.md),
                                ],
                                if (_notes.isNotEmpty)
                                  const CustomDivider(text: "Note salvate"),
                              ],
                            ),
                          ),
                          NotesList(
                            notes: _notes,
                            onDeleteNote: _onNoteSwiped,
                            isLoading: state is LeagueLoading && _notes.isEmpty,
                            emptyStateWidget: const EmptyState(
                              icon: Icons.edit_note_sharp,
                              title: "Nessuna nota salvata...",
                              subtitle:
                                  "Non hai tempo per assegnare un evento? Crea qui un reminder!",
                            ),
                          ),
                        ],
                      ),
                    ),
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appLeagueState = context.watch<AppLeagueCubit>().state;
    if (appLeagueState is AppLeagueExists) {
      final newLeagueId = appLeagueState.selectedLeague.id;

      final oldLeagueId = _currentLeagueId;
      _currentLeagueId = newLeagueId;

      if (oldLeagueId != newLeagueId) {
        _loadNotes();
      }
    }
  }

  bool _canShowNoteInput() {
    if (_selectedParticipant is IndividualParticipant) {
      return true;
    }
    if (_selectedParticipant is TeamParticipant && _selectedUserId != null) {
      return true;
    }
    return false;
  }

  List<Widget>? _buildAppBarActions() {
    if (_selectedParticipant != null) {
      return [
        IconButton(
          icon: const Icon(
            Icons.close_rounded,
            size: 22,
          ),
          color: ColorPalette.error,
          onPressed: _cancelEditing,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            icon: const Icon(
              Icons.check_rounded,
              size: 22,
            ),
            color: ColorPalette.success,
            onPressed: _saveNote,
          ),
        ),
      ];
    }
    return null;
  }

  Widget _buildTeamMemberSelector() {
    final teamParticipant = _selectedParticipant as TeamParticipant;
    final userIds = teamParticipant.userIds;

    return ParticipantSelector<String>(
      items: userIds,
      value: _selectedUserId,
      hintText: "Seleziona Membro",
      prefixIcon: Icons.person,
      onChanged: (value) {
        setState(() {
          _selectedUserId = value;
          if (value != null) {
            Future.microtask(() => _noteFocusNode.requestFocus());
          }
        });
      },
      itemBuilder: (userId) {
        final userName =
            _getUserNameById(userId) ?? "Membro ${userId.substring(0, 4)}";
        return ParticipantSelector.defaultTeamMemberItem(
          context,
          userId: userId,
          name: userName,
        );
      },
    );
  }
}
