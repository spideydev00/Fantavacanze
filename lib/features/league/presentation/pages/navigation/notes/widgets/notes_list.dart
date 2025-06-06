import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/domain/entities/note.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/notes/widgets/note_card.dart';
import 'package:flutter/material.dart';

class NotesList extends StatelessWidget {
  final List<Note> notes;
  final Function(String) onDeleteNote;
  final bool showEmptyState;
  final Widget? emptyStateWidget;
  final bool isLoading;
  final Widget? loadingWidget;
  final EdgeInsetsGeometry padding;
  final ScrollPhysics physics;

  const NotesList({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    this.showEmptyState = true,
    this.emptyStateWidget,
    this.isLoading = false,
    this.loadingWidget,
    this.padding = const EdgeInsets.all(ThemeSizes.md),
    this.physics = const NeverScrollableScrollPhysics(),
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingWidget ??
          const Center(
            child: Padding(
              padding: EdgeInsets.all(ThemeSizes.lg),
              child: CircularProgressIndicator(),
            ),
          );
    }

    if (notes.isEmpty && showEmptyState) {
      return emptyStateWidget!;
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: physics,
      padding: padding,
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return NoteCard(
          note: note,
          onTap: () => NoteCard.showNoteDetails(context, note),
          onDelete: () => onDeleteNote(note.id),
        );
      },
    );
  }
}
