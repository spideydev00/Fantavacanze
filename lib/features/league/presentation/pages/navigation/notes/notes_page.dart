import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/show_snackbar.dart';
import 'package:fantavacanze_official/features/league/data/models/note_model.dart';
import 'package:fantavacanze_official/features/league/domain/entities/individual_participant.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/participant.dart';
import 'package:fantavacanze_official/features/league/domain/entities/team_participant.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_state.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/core/divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

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

  List<NoteModel> _notes = [];
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
      showSnackBar(context, 'Seleziona un partecipante e inserisci una nota');
      return;
    }

    final league = _getCurrentLeague();
    if (league == null) return;

    final newNote = NoteModel(
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

  Future<void> _deleteNote(String noteId) async {
    final league = _getCurrentLeague();
    if (league == null) return;
    context.read<LeagueBloc>().add(DeleteNoteEvent(
          leagueId: league.id,
          noteId: noteId,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LeagueBloc, LeagueState>(
      listener: (context, state) {
        if (state is NoteSuccess) {
          switch (state.operation) {
            case 'get':
              setState(() {
                _notes = state.notes ?? [];
              });
              break;
            case 'save':
              _loadNotes(); // Reload notes after save
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Nota salvata',
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: ColorPalette.success,
                  duration: Duration(seconds: 1),
                ),
              );
              break;
            case 'delete':
              _loadNotes(); // Reload notes after delete
              break;
          }
        } else if (state is LeagueError) {
          showSnackBar(context, state.message);
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
                  actions: _selectedParticipant != null
                      ? [
                          IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 18,
                            ),
                            color: ColorPalette.error,
                            onPressed: _cancelEditing,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: IconButton(
                              icon: const Icon(
                                Icons.check_rounded,
                                size: 18,
                              ),
                              color: ColorPalette.success,
                              onPressed: _saveNote,
                            ),
                          ),
                        ]
                      : null,
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
                                    text: "Scegli un partecipante"),
                                const SizedBox(
                                  height: ThemeSizes.sm,
                                ),
                                DropdownButtonHideUnderline(
                                  child: DropdownButton2<Participant>(
                                    isExpanded: true,
                                    hint: Row(
                                      children: [
                                        Icon(
                                          Icons.groups_rounded,
                                          size: 22,
                                          color: context.primaryColor,
                                        ),
                                        const SizedBox(width: ThemeSizes.sm),
                                        Expanded(
                                          child: Text(
                                            "Seleziona partecipante",
                                            overflow: TextOverflow.ellipsis,
                                            style: context.textTheme.bodyMedium,
                                          ),
                                        ),
                                      ],
                                    ),
                                    items: participants.map((participant) {
                                      return DropdownMenuItem<Participant>(
                                        value: participant,
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.arrow_right_rounded,
                                              size: 18,
                                              color: context.primaryColor,
                                            ),
                                            const SizedBox(
                                                width: ThemeSizes.xs),
                                            Expanded(
                                              child: Text(
                                                participant.name,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    value: _selectedParticipant,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedParticipant = value;
                                        _selectedUserId =
                                            null; // Reset user selection

                                        if (value is IndividualParticipant) {
                                          // Auto-focus the note field
                                          Future.microtask(() =>
                                              _noteFocusNode.requestFocus());
                                        }
                                      });
                                    },
                                    buttonStyleData: ButtonStyleData(
                                      height: 50,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: ThemeSizes.md,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          ThemeSizes.borderRadiusMd,
                                        ),
                                        border: Border.all(
                                          color: Colors.black26.withValues(
                                            alpha: 0.1,
                                          ),
                                        ),
                                        color: context.secondaryBgColor,
                                      ),
                                      overlayColor: null,
                                    ),
                                    dropdownStyleData: DropdownStyleData(
                                      elevation: 0,
                                      maxHeight:
                                          Constants.getHeight(context) * 0.8,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          ThemeSizes.borderRadiusMd,
                                        ),
                                        color: context.secondaryBgColor,
                                      ),
                                    ),
                                    iconStyleData: IconStyleData(
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        color: context.textPrimaryColor,
                                      ),
                                      iconSize: 24,
                                    ),
                                  ),
                                ),
                                if (_selectedParticipant
                                    is TeamParticipant) ...[
                                  const SizedBox(height: ThemeSizes.md),
                                  const CustomDivider(
                                    text: "Seleziona membro del team",
                                  ),
                                  const SizedBox(height: ThemeSizes.sm),
                                  _buildTeamMemberDropdown(
                                    (_selectedParticipant as TeamParticipant)
                                        .userIds,
                                  ),
                                ],
                                const SizedBox(height: ThemeSizes.md),
                                if (_canShowNoteInput()) ...[
                                  const CustomDivider(text: "Scrivi una nota"),
                                  const SizedBox(height: ThemeSizes.sm),
                                  TextField(
                                    controller: _noteController,
                                    focusNode: _noteFocusNode,
                                    decoration: InputDecoration(
                                      hintText: 'Scrivi la tua nota qui...',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            ThemeSizes.borderRadiusMd),
                                        borderSide: BorderSide(
                                          color: context.borderColor,
                                          width: 0.5,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            ThemeSizes.borderRadiusMd),
                                        borderSide: BorderSide(
                                          color: context.borderColor,
                                          width: 0.5,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            ThemeSizes.borderRadiusMd),
                                        borderSide: BorderSide(
                                          color: ColorPalette.success,
                                          width: 1.0,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.all(ThemeSizes.md),
                                    ),
                                    maxLines: 3,
                                    style: context.textTheme.bodyLarge,
                                  ),
                                  const SizedBox(height: ThemeSizes.md),
                                ],
                                if (_notes.isNotEmpty)
                                  const CustomDivider(text: "Note salvate"),
                              ],
                            ),
                          ),
                          if (state is LeagueLoading && _notes.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(ThemeSizes.lg),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (_notes.isEmpty)
                            _buildEmptyState()
                          else
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: ThemeSizes.md),
                              child: _buildNotesList(),
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

    // Check if the selected league has changed
    final appLeagueState = context.watch<AppLeagueCubit>().state;
    if (appLeagueState is AppLeagueExists) {
      final newLeagueId = appLeagueState.selectedLeague.id;

      // Store the current league ID for comparison
      final oldLeagueId = _currentLeagueId;
      _currentLeagueId = newLeagueId;

      // Only reload notes if the league has changed
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

  Widget _buildTeamMemberDropdown(List<String> userIds) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        key: ValueKey(
          (_selectedParticipant as TeamParticipant).name,
        ),
        isExpanded: true,
        hint: Row(
          children: [
            Icon(
              Icons.person,
              size: 18,
              color: context.primaryColor,
            ),
            const SizedBox(width: ThemeSizes.sm),
            Expanded(
              child: Text(
                "Seleziona Membro",
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        value: _selectedUserId,
        items: userIds.map((userId) {
          final userName = _getUserNameById(userId) ?? "Membro ${userId.substring(0, 4)}";

          return DropdownMenuItem<String>(
            value: userId,
            child: Row(
              children: [
                Icon(
                  Icons.arrow_right_rounded,
                  size: 16,
                  color: context.primaryColor,
                ),
                const SizedBox(width: ThemeSizes.xs),
                Expanded(
                  child: Text(
                    userName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedUserId = value;
            if (value != null) {
              Future.microtask(() => _noteFocusNode.requestFocus());
            }
          });
        },
        buttonStyleData: ButtonStyleData(
          height: 50,
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeSizes.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
            border: Border.all(
              color: Colors.black26.withValues(alpha: 0.1),
            ),
            color: context.secondaryBgColor,
          ),
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: Constants.getHeight(context) * 0.8,
          elevation: 0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
            color: context.secondaryBgColor,
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: ThemeSizes.md),
        ),
        iconStyleData: IconStyleData(
          icon: Icon(
            Icons.arrow_drop_down,
            color: context.textPrimaryColor,
          ),
          iconSize: 24,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_alt_outlined,
              size: 64,
              color: context.textSecondaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: ThemeSizes.md),
            Text(
              'Nessuna nota ancora',
              style: TextStyle(
                fontSize: 18,
                color: context.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(ThemeSizes.md),
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        final note = _notes[index];
        return Dismissible(
          key: Key(note.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: ThemeSizes.md),
            color: Colors.red,
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          onDismissed: (direction) {
            _deleteNote(note.id);
          },
          child: _ModernNoteCard(note: note),
        );
      },
    );
  }
}

class _ModernNoteCard extends StatelessWidget {
  final NoteModel note;

  const _ModernNoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    final gradient = ColorPalette.getGradientFromId(note.id);

    return Container(
      margin: const EdgeInsets.only(bottom: ThemeSizes.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showNoteDetails(context, note),
            splashColor: Colors.white.withOpacity(0.1),
            highlightColor: Colors.white.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(ThemeSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.group,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                note.participantName,
                                style: context.textTheme.labelLarge!.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      offset: const Offset(0, 1),
                                      blurRadius: 3,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ],
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(note.createdAt),
                          style: context.textTheme.labelMedium!.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            shadows: [
                              Shadow(
                                offset: const Offset(0, 1),
                                blurRadius: 2,
                                color: Colors.black.withOpacity(0.4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                      height: 1,
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  Text(
                    note.content,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white,
                      height: 1.4,
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 1),
                          blurRadius: 3,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showNoteDetails(BuildContext context, NoteModel note) {
    final gradient = ColorPalette.getGradientFromId(note.id);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: ThemeSizes.lg),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
          child: Container(
            decoration: BoxDecoration(
              gradient: gradient,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    ThemeSizes.lg,
                    ThemeSizes.lg,
                    ThemeSizes.md,
                    0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          note.participantName,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: const Offset(0, 1),
                                blurRadius: 3,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        color: Colors.white,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: ThemeSizes.lg),
                  child: Text(
                    DateFormat('dd MMMM yyyy - HH:mm').format(note.createdAt),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                          color: Colors.black.withOpacity(0.4),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ThemeSizes.lg,
                    vertical: ThemeSizes.md,
                  ),
                  child: Container(
                    height: 1,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    ThemeSizes.lg,
                    0,
                    ThemeSizes.lg,
                    ThemeSizes.xl,
                  ),
                  child: Text(
                    note.content,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white,
                      height: 1.5,
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 1),
                          blurRadius: 3,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
