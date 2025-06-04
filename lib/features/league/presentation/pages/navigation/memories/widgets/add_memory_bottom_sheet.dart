import 'dart:io';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/show_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/events/events_list_widget.dart';
import 'package:fantavacanze_official/features/league/domain/entities/event.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule/rule.dart';
import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/utils/image_picker_util.dart';
import 'package:image_picker/image_picker.dart' as image_picker;

class AddMemoryBottomSheet extends StatefulWidget {
  final League league;
  final List<Event> events;
  final Function(File, String, Event?, String?) onSave;

  const AddMemoryBottomSheet({
    super.key,
    required this.league,
    required this.events,
    required this.onSave,
  });

  @override
  State<AddMemoryBottomSheet> createState() => _AddMemoryBottomSheetState();
}

class _AddMemoryBottomSheetState extends State<AddMemoryBottomSheet> {
  final TextEditingController _textController = TextEditingController();
  File? _selectedImage;
  Event? _selectedEvent;
  bool _isLoading = false;
  bool _showEventSelection = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSourceType source) async {
    final imageFile = await ImagePickerUtil.pickImage(
      context: context,
      enableCropping: true,
      source: source == ImageSourceType.camera
          ? image_picker.ImageSource.camera
          : image_picker.ImageSource.gallery,
    );

    if (imageFile != null) {
      setState(() {
        _selectedImage = imageFile;
      });
    }
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
              'Scegli la fonte',
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
                _buildImageSourceOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Fotocamera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSourceType.camera);
                  },
                ),

                // Gallery option
                _buildImageSourceOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Galleria',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSourceType.gallery);
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

  Widget _buildImageSourceOption({
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

  void _save() {
    if (_selectedImage == null) {
      showSnackBar(
        'Seleziona un\'immagine',
        color: ColorPalette.success,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String? eventName = _selectedEvent?.name;
    widget.onSave(
        _selectedImage!, _textController.text, _selectedEvent, eventName);
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
      // Wrap the Column with SingleChildScrollView to make it scrollable when keyboard appears
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

            // Image selection area with camera/gallery options
            GestureDetector(
              onTap: _showImageSourceOptions,
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
                  image: _selectedImage != null
                      ? DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _selectedImage == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt_rounded,
                                  size: 28,
                                  color: context.textSecondaryColor,
                                ),
                                const SizedBox(width: ThemeSizes.sm),
                                Icon(
                                  Icons.photo_library_rounded,
                                  size: 28,
                                  color: context.textSecondaryColor,
                                ),
                              ],
                            ),
                            const SizedBox(height: ThemeSizes.sm),
                            Text(
                              'Aggiungi foto',
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
                                color: ColorPalette.info.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Scatta o scegli dalla galleria',
                                style: context.textTheme.labelSmall!.copyWith(
                                  color: ColorPalette.info,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Material(
                            color: Colors.black54,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () {
                                setState(() {
                                  _selectedImage = null;
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
                    color: ColorPalette.info,
                    width: 1,
                  ),
                ),
                hintText: 'Descrivi questo ricordo...',
              ),
            ),
            const SizedBox(height: ThemeSizes.md),

            // Event selection button and display
            if (widget.events.isNotEmpty) ...[
              if (_selectedEvent == null)
                // Button to show event selection
                OutlinedButton.icon(
                  onPressed: _toggleEventSelection,
                  icon: Icon(
                    _showEventSelection ? Icons.expand_less : Icons.expand_more,
                    color: ColorPalette.info,
                  ),
                  label: Text(
                    'Collega ad un evento',
                    style: TextStyle(
                      color: ColorPalette.info,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: ColorPalette.info,
                      width: 2,
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
                    color: ColorPalette.info.withValues(alpha: 0.05),
                    borderRadius:
                        BorderRadius.circular(ThemeSizes.borderRadiusLg),
                  ),
                  child: SingleChildScrollView(
                    child: EventsListWidget(
                      league: widget.league,
                      showAllEvents: true,
                      onEventTap: _selectEvent,
                      padding: const EdgeInsets.all(ThemeSizes.sm),
                    ),
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
}

// Rename our enum to avoid conflict with image_picker's ImageSource
enum ImageSourceType {
  camera,
  gallery,
}

// Extension to be used with our custom enum
extension ImageSourceTypeExtension on ImageSourceType {
  bool get isCamera => this == ImageSourceType.camera;
  bool get isGallery => this == ImageSourceType.gallery;
}
