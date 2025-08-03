import 'dart:io';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/in-game/participant_name_resolver.dart';
import 'package:fantavacanze_official/core/utils/show-snackbar-or-paywall/show_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/events/event_card.dart';
import 'package:fantavacanze_official/core/widgets/events/event_with_resolved_name.dart';
import 'package:fantavacanze_official/core/widgets/media/video_thumbnail.dart';
import 'package:fantavacanze_official/features/league/domain/entities/event.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule/rule.dart';
import 'package:fantavacanze_official/features/league/domain/entities/team_participant.dart';
import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/utils/media/image_picker_util.dart';
import 'package:image_picker/image_picker.dart' as image_picker;

class AddMemoryBottomSheet extends StatefulWidget {
  final League league;
  final List<Event> events;
  final Function(File, String, Event?, String?) onSave;
  final String currentUserId;

  const AddMemoryBottomSheet({
    super.key,
    required this.league,
    required this.events,
    required this.onSave,
    required this.currentUserId,
  });

  @override
  State<AddMemoryBottomSheet> createState() => _AddMemoryBottomSheetState();
}

class _AddMemoryBottomSheetState extends State<AddMemoryBottomSheet> {
  final TextEditingController _textController = TextEditingController();
  File? _selectedMedia;
  bool _isVideo = false;
  Event? _selectedEvent;
  bool _isLoading = false;
  bool _showEventSelection = false;

  late List<Event> _userEvents;

  @override
  void initState() {
    super.initState();
    _filterUserEvents();
  }

  void _filterUserEvents() {
    _userEvents = widget.events.where((event) {
      // Use the utility to check if this event belongs to the current user
      if (widget.league.isTeamBased) {
        if (event.isTeamMember) {
          // For team member events, check if the targetUser is the current user
          return event.targetUser == widget.currentUserId;
        } else {
          // For team events, find the user's team and check if it matches
          for (final participant in widget.league.participants) {
            if (participant is TeamParticipant) {
              if (participant.userIds.contains(widget.currentUserId)) {
                return event.targetUser == participant.name;
              }
            }
          }
          return false;
        }
      } else {
        // For individual leagues, check if the event is for this user
        return event.targetUser == widget.currentUserId;
      }
    }).toList();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(MediaSourceType source) async {
    final imageFile = await ImagePickerUtil.pickImage(
      context: context,
      enableCropping: true,
      source: source == MediaSourceType.camera
          ? image_picker.ImageSource.camera
          : image_picker.ImageSource.gallery,
    );

    if (imageFile != null) {
      setState(() {
        _selectedMedia = imageFile;
        _isVideo = false;
      });
    }
  }

  Future<void> _pickVideo(MediaSourceType source) async {
    final videoFile = await ImagePickerUtil.pickVideo(
      context: context,
      source: source == MediaSourceType.camera
          ? image_picker.ImageSource.camera
          : image_picker.ImageSource.gallery,
    );

    if (videoFile != null) {
      setState(() {
        _selectedMedia = videoFile;
        _isVideo = true;
      });
    }
  }

  void _showMediaSourceOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ThemeSizes.borderRadiusLg),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(ThemeSizes.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: ThemeSizes.md),
              decoration: BoxDecoration(
                color: context.textSecondaryColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const Text(
              'Scegli il tipo di contenuto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ThemeSizes.md),

            // Media type options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Photo option
                _buildMediaTypeOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Foto',
                  onTap: () {
                    Navigator.pop(context);
                    _showImageSourceOptions();
                  },
                ),

                // Video option
                _buildMediaTypeOption(
                  icon: Icons.videocam_rounded,
                  label: 'Video',
                  onTap: () {
                    Navigator.pop(context);
                    _showVideoSourceOptions();
                  },
                ),
              ],
            ),

            const SizedBox(height: ThemeSizes.md),
          ],
        ),
      ),
    );
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ThemeSizes.borderRadiusLg),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(ThemeSizes.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: ThemeSizes.md),
              decoration: BoxDecoration(
                color: context.textSecondaryColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const Text(
              'Scegli la fonte per la foto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ThemeSizes.md),

            // Options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Camera option
                _buildSourceOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Fotocamera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(MediaSourceType.camera);
                  },
                ),

                // Gallery option
                _buildSourceOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Galleria',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(MediaSourceType.gallery);
                  },
                ),
              ],
            ),

            const SizedBox(height: ThemeSizes.md),
          ],
        ),
      ),
    );
  }

  void _showVideoSourceOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ThemeSizes.borderRadiusLg),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(ThemeSizes.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: ThemeSizes.md),
              decoration: BoxDecoration(
                color: context.textSecondaryColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const Text(
              'Scegli la fonte per il video',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ThemeSizes.md),

            // Options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Camera option
                _buildSourceOption(
                  icon: Icons.videocam_rounded,
                  label: 'Registra',
                  onTap: () {
                    Navigator.pop(context);
                    _pickVideo(MediaSourceType.camera);
                  },
                ),

                // Gallery option
                _buildSourceOption(
                  icon: Icons.video_library_rounded,
                  label: 'Galleria',
                  onTap: () {
                    Navigator.pop(context);
                    _pickVideo(MediaSourceType.gallery);
                  },
                ),
              ],
            ),

            const SizedBox(height: ThemeSizes.md),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaTypeOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(ThemeSizes.md),
        decoration: BoxDecoration(
          color: context.secondaryBgColor,
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 25,
            ),
            const SizedBox(height: ThemeSizes.sm),
            Text(
              label,
              style: TextStyle(
                color: context.textPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(ThemeSizes.md),
        decoration: BoxDecoration(
          color: context.secondaryBgColor,
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 25,
            ),
            const SizedBox(height: ThemeSizes.sm),
            Text(
              label,
              style: TextStyle(
                color: context.textPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (_selectedMedia == null) {
      showSnackBar(
        _isVideo ? 'Seleziona un video' : 'Seleziona un\'immagine',
        color: ColorPalette.success,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String? eventName = _selectedEvent?.name;
    widget.onSave(
      _selectedMedia!,
      _textController.text,
      _selectedEvent,
      eventName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: ThemeSizes.md,
        left: ThemeSizes.md,
        right: ThemeSizes.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + ThemeSizes.md,
      ),
      decoration: BoxDecoration(
        color: context.bgColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(ThemeSizes.borderRadiusLg),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar at top
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: ThemeSizes.md),
                decoration: BoxDecoration(
                  color: context.textSecondaryColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            Text(
              'Aggiungi un ricordo',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: context.textPrimaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ThemeSizes.md),

            // Media selection area
            GestureDetector(
              onTap: _showMediaSourceOptions,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 180,
                decoration: BoxDecoration(
                  color: context.secondaryBgColor,
                  borderRadius:
                      BorderRadius.circular(ThemeSizes.borderRadiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  image: _selectedMedia != null && !_isVideo
                      ? DecorationImage(
                          image: FileImage(_selectedMedia!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _selectedMedia == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.photo_library_rounded,
                                  size: 28,
                                  color: context.textSecondaryColor,
                                ),
                                const SizedBox(width: ThemeSizes.sm),
                                Icon(
                                  Icons.videocam_rounded,
                                  size: 28,
                                  color: context.textSecondaryColor,
                                ),
                              ],
                            ),
                            const SizedBox(height: ThemeSizes.sm),
                            Text(
                              'Aggiungi foto o video',
                              style: TextStyle(
                                color: context.textSecondaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: ThemeSizes.md),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: ThemeSizes.sm,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    ColorPalette.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Scatta, registra o scegli dalla galleria',
                                style: context.textTheme.labelSmall!.copyWith(
                                  color: ColorPalette.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _isVideo
                        ? Stack(
                            children: [
                              // Video thumbnail
                              Positioned.fill(
                                child: VideoThumbnailWidget(
                                  videoUrl: _selectedMedia!.path,
                                  fit: BoxFit.cover,
                                  placeholder: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                          color: context.primaryColor,
                                        ),
                                        const SizedBox(height: ThemeSizes.sm),
                                        Text(
                                          'Generazione anteprima...',
                                          style: TextStyle(
                                            color: context.textPrimaryColor,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  errorWidget: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.videocam_rounded,
                                          size: 60,
                                          color: context.primaryColor,
                                        ),
                                        const SizedBox(height: ThemeSizes.sm),
                                        Text(
                                          'Video selezionato',
                                          style: TextStyle(
                                            color: context.textPrimaryColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Video indicator overlay
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(
                                        ThemeSizes.borderRadiusLg),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: ColorPalette.info,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.play_arrow_rounded,
                                        size: 30,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Close button
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Material(
                                  color: Colors.black54,
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: () {
                                      setState(() {
                                        _selectedMedia = null;
                                        _isVideo = false;
                                      });
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : // Image preview with proper handling
                        Stack(
                            children: [
                              // Image preview
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      ThemeSizes.borderRadiusLg),
                                  child: Image.file(
                                    _selectedMedia!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.error_outline,
                                              size: 60,
                                              color: ColorPalette.error,
                                            ),
                                            const SizedBox(
                                                height: ThemeSizes.sm),
                                            Text(
                                              'Errore nel caricamento immagine',
                                              style: TextStyle(
                                                color: context.textPrimaryColor,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),

                              // Close button
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Material(
                                  color: Colors.black54,
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: () {
                                      setState(() {
                                        _selectedMedia = null;
                                        _isVideo = false;
                                      });
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: ThemeSizes.md),

            // Description text field with improved styling
            TextField(
              keyboardType: TextInputType.text,
              controller: _textController,
              maxLines: 3,
              style: TextStyle(color: context.textPrimaryColor),
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: ColorPalette.success,
                    width: 1,
                  ),
                ),
                hintText: 'Descrivi questo ricordo...',
              ),
            ),
            const SizedBox(height: ThemeSizes.md),

            // Event selection button and display
            if (_userEvents.isNotEmpty) ...[
              if (_selectedEvent == null)
                // Button to show event selection
                OutlinedButton.icon(
                  onPressed: _toggleEventSelection,
                  icon: Icon(
                    _showEventSelection ? Icons.expand_less : Icons.expand_more,
                    color: ColorPalette.darkGrey,
                  ),
                  label: Text(
                    'Collega Un Evento',
                    style: TextStyle(
                      color: ColorPalette.darkGrey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: ColorPalette.darkGrey,
                      width: 1,
                    ),
                  ),
                )
              else
                // Selected event display
                Container(
                  padding: const EdgeInsets.all(ThemeSizes.sm),
                  decoration: BoxDecoration(
                    color: context.secondaryBgColor,
                    borderRadius:
                        BorderRadius.circular(ThemeSizes.borderRadiusLg),
                    border: Border.all(
                      color: _selectedEvent?.type == RuleType.malus
                          ? ColorPalette.error.withValues(alpha: 0.3)
                          : ColorPalette.success.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _selectedEvent?.type == RuleType.malus
                                    ? ColorPalette.error.withValues(alpha: 0.1)
                                    : ColorPalette.success
                                        .withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.event_available_rounded,
                                color: _selectedEvent?.type == RuleType.malus
                                    ? ColorPalette.error
                                    : ColorPalette.success,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: ThemeSizes.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Evento collegato:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.textSecondaryColor,
                                    ),
                                  ),
                                  Text(
                                    _selectedEvent!.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          _selectedEvent?.type == RuleType.malus
                                              ? ColorPalette.error
                                              : ColorPalette.success,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        color: context.textSecondaryColor,
                        onPressed: _clearSelectedEvent,
                      ),
                    ],
                  ),
                ),

              // Event selection list (expandable)
              if (_showEventSelection)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 200,
                  margin: const EdgeInsets.only(top: ThemeSizes.sm),
                  decoration: BoxDecoration(
                    color: context.secondaryColor.withValues(alpha: 0.05),
                    borderRadius:
                        BorderRadius.circular(ThemeSizes.borderRadiusLg),
                  ),
                  child: _userEvents.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(ThemeSizes.md),
                            child: Text(
                              'Non hai eventi da poter collegare a questo ricordo',
                              style: TextStyle(
                                color: context.textSecondaryColor,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(ThemeSizes.sm),
                          itemCount: _userEvents.length,
                          itemBuilder: (context, index) {
                            final event = _userEvents[index];

                            String resolvedName =
                                ParticipantNameResolver.resolveParticipantName(
                                    event, widget.league);

                            // Create a modified event with the resolved name
                            final displayEvent = EventWithResolvedName(
                              originalEvent: event,
                              resolvedName: resolvedName,
                            );

                            return EventCard(
                              event: displayEvent,
                              onTap: () => _selectEvent(event),
                            );
                          },
                        ),
                ),
            ],

            const SizedBox(height: ThemeSizes.lg),

            // Save button with enhanced styling
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  shadowColor: context.primaryColor.withValues(alpha: 0.5),
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.save_alt_rounded, size: 20),
                          const SizedBox(width: ThemeSizes.sm),
                          const Text(
                            'Salva ricordo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: ThemeSizes.sm),
          ],
        ),
      ),
    );
  }

  void _toggleEventSelection() {
    setState(() {
      _showEventSelection = !_showEventSelection;
    });
  }

  void _selectEvent(Event event) {
    setState(() {
      _selectedEvent = event;
      _showEventSelection = false;
    });
  }

  void _clearSelectedEvent() {
    setState(() {
      _selectedEvent = null;
    });
  }
}

// Update the enum to be more generic for media types
enum MediaSourceType {
  camera,
  gallery,
}

// Extension for the updated enum
extension MediaSourceTypeExtension on MediaSourceType {
  bool get isCamera => this == MediaSourceType.camera;
  bool get isGallery => this == MediaSourceType.gallery;
}
