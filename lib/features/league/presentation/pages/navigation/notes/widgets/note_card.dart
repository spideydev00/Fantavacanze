import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/profile_image_avatar.dart';
import 'package:fantavacanze_official/features/league/domain/entities/note.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final EdgeInsetsGeometry margin;
  final double elevation;
  final bool enableDismiss;

  const NoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.onDelete,
    this.margin = const EdgeInsets.only(bottom: ThemeSizes.md),
    this.elevation = 3.0,
    this.enableDismiss = true,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = ColorPalette.getGradientFromId(note.id);

    if (enableDismiss && onDelete != null) {
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
        confirmDismiss: (_) async {
          onDelete!();
          return true;
        },
        child: _buildNoteContent(context, gradient),
      );
    }

    return _buildNoteContent(context, gradient);
  }

  Widget _buildNoteContent(BuildContext context, Gradient gradient) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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
            onTap: onTap,
            splashColor: Colors.white.withValues(alpha: 0.1),
            highlightColor: Colors.white.withValues(alpha: 0.1),
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
                            _buildNoteAvatar(context, note, 28),
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
                                      color:
                                          Colors.black.withValues(alpha: 0.5),
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
                          color: Colors.white.withValues(alpha: 0.2),
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
                                color: Colors.black.withValues(alpha: 0.4),
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
                      color: Colors.white.withValues(alpha: 0.2),
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
                          color: Colors.black.withValues(alpha: 0.5),
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

  static void showNoteDetails(BuildContext context, Note note) {
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
                      _buildNoteAvatar(context, note, 36),
                      const SizedBox(width: ThemeSizes.sm),
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
                                color: Colors.black.withValues(alpha: 0.5),
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
                      color: Colors.white.withValues(alpha: 0.8),
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                          color: Colors.black.withValues(alpha: 0.4),
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
                    color: Colors.white.withValues(alpha: 0.2),
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
                          color: Colors.black.withValues(alpha: 0.5),
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

  static Widget _buildNoteAvatar(
    BuildContext context,
    Note note,
    double size,
  ) {
    final profileImageUrl =
        context.watch<AppLeagueCubit>().getProfileImageFor(note.participantId);

    return ProfileImageAvatar(
      imageUrl: profileImageUrl,
      size: size,
      loaderColor: Colors.white,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      fallback: _buildNoteFallback(note, size),
    );
  }

  static Widget _buildNoteFallback(Note note, double size) {
    final initial = note.participantName.trim().isNotEmpty
        ? note.participantName.trim()[0].toUpperCase()
        : '?';

    return Center(
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.45,
        ),
      ),
    );
  }
}
