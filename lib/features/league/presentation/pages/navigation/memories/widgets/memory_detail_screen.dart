import 'package:cached_network_image/cached_network_image.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
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
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (isCurrentUserAuthor && onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                Navigator.pop(context);
                onDelete!();
              },
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
                child: CachedNetworkImage(
                  imageUrl: memory.imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child:
                        Icon(Icons.error_outline, color: Colors.red, size: 50),
                  ),
                ),
              ),
            ),
          ),

          // Details panel at the bottom
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(ThemeSizes.md),
              decoration: BoxDecoration(
                color: context.bgColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(ThemeSizes.borderRadiusLg),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Author and date
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: context.primaryColor,
                          child: Text(
                            memory.participantName
                                .substring(0, 1)
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: ThemeSizes.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                memory.participantName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                formattedDate,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: context.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Related event (if any)
                    if (memory.eventName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: ThemeSizes.md),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: ThemeSizes.md,
                              vertical: ThemeSizes.sm),
                          decoration: BoxDecoration(
                            color: context.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                                ThemeSizes.borderRadiusMd),
                          ),
                          child: Text(
                            'Evento: ${memory.eventName!}',
                            style: TextStyle(
                              fontSize: 14,
                              color: context.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    // Memory description
                    if (memory.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: ThemeSizes.md),
                        child: Text(
                          memory.text,
                          style: const TextStyle(fontSize: 16),
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
