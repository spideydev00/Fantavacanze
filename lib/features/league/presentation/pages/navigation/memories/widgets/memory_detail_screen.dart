import 'package:cached_network_image/cached_network_image.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:fantavacanze_official/features/league/domain/entities/memory.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MemoryDetailScreen extends StatelessWidget {
  final Memory memory;
  final VoidCallback? onDelete;
  final bool isCurrentUserAuthor;

  const MemoryDetailScreen({
    super.key,
    required this.memory,
    this.onDelete,
    this.isCurrentUserAuthor = false,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMMM yyyy, HH:mm');
    final formattedDate = dateFormat.format(memory.createdAt);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          color: Colors.white,
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(
              Colors.black.withValues(alpha: 0.4),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
              ),
            ),
          ),
        ),
        actions: [
          if (isCurrentUserAuthor && onDelete != null)
            Padding(
              padding: const EdgeInsets.only(right: ThemeSizes.sm),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius:
                      BorderRadius.circular(ThemeSizes.borderRadiusMd),
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: Colors.white,
                  onPressed: () {
                    // Show the confirmation dialog
                    showDialog(
                      context: context,
                      builder: (dialogContext) =>
                          ConfirmationDialog.deleteMemory(
                        onDelete: () {
                          // First navigate back from the detail screen
                          Navigator.pop(context); // Close the detail screen

                          // Then call the delete operation
                          onDelete!();
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Image takes most of the screen
          Expanded(
            flex: 3,
            child: Center(
              child: Hero(
                tag: 'memory_image_${memory.id}',
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: CachedNetworkImage(
                    imageUrl: memory.imageUrl,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(context.primaryColor),
                      ),
                    ),
                    errorWidget: (context, url, error) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.broken_image_rounded,
                            color: ColorPalette.error,
                            size: 60,
                          ),
                          const SizedBox(height: ThemeSizes.sm),
                          const Text(
                            "Impossibile caricare l'immagine",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Details panel at the bottom with enhanced design
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(ThemeSizes.lg),
              decoration: BoxDecoration(
                color: context.bgColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(ThemeSizes.borderRadiusXlg),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Author info with enhanced styling
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor:
                                ColorPalette.getGradientFromId(memory.userId)
                                    .colors
                                    .first,
                            child: Text(
                              memory.participantName
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: ThemeSizes.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                memory.participantName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: context.textPrimaryColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 14,
                                    color: context.textSecondaryColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    formattedDate,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: context.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Divider
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: ThemeSizes.md),
                      child: Divider(
                        color: context.borderColor.withValues(alpha: 0.3),
                        height: 1,
                      ),
                    ),

                    // Related event with modern badge styling
                    if (memory.eventName != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: ThemeSizes.md),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: ThemeSizes.md,
                            vertical: ThemeSizes.sm,
                          ),
                          decoration: BoxDecoration(
                            color: context.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                                ThemeSizes.borderRadiusLg),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.event_available_rounded,
                                size: 16,
                                color: context.primaryColor,
                              ),
                              const SizedBox(width: ThemeSizes.sm),
                              Expanded(
                                child: Text(
                                  memory.eventName!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: context.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Memory description with improved typography
                    if (memory.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: ThemeSizes.md),
                        child: Text(
                          memory.text,
                          style: TextStyle(
                            fontSize: 16,
                            color: context.textPrimaryColor,
                            height: 1.4,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
