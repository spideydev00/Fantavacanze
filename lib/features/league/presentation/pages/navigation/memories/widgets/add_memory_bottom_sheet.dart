import 'dart:io';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/domain/entities/event.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/utils/image_picker_util.dart';

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

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final imageFile = await ImagePickerUtil.pickImage(
      context: context,
      enableCropping: true,
    );

    if (imageFile != null) {
      setState(() {
        _selectedImage = imageFile;
      });
    }
  }

  void _save() {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleziona un\'immagine')),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Aggiungi un ricordo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ThemeSizes.md),

          // Image selection area
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: context.secondaryBgColor,
                borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
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
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 40,
                            color: context.textSecondaryColor,
                          ),
                          const SizedBox(height: ThemeSizes.sm),
                          Text(
                            'Aggiungi foto',
                            style: TextStyle(
                              color: context.textSecondaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Scatta o scegli dalla galleria',
                            style: TextStyle(
                              color: context.textSecondaryColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const CircleAvatar(
                          backgroundColor: Colors.black54,
                          radius: 16,
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedImage = null;
                          });
                        },
                      ),
                    ),
            ),
          ),
          const SizedBox(height: ThemeSizes.md),

          // Description text field
          TextField(
            controller: _textController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Descrivi questo ricordo...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
              ),
            ),
          ),
          const SizedBox(height: ThemeSizes.md),

          // Related event dropdown (if events exist)
          if (widget.events.isNotEmpty)
            DropdownButtonFormField<Event>(
              value: _selectedEvent,
              decoration: InputDecoration(
                hintText: 'Collega a un evento (opzionale)',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(ThemeSizes.borderRadiusMd),
                ),
              ),
              items: widget.events.map((event) {
                return DropdownMenuItem<Event>(
                  value: event,
                  child: Text(
                    event.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (Event? value) {
                setState(() {
                  _selectedEvent = value;
                });
              },
            ),
          const SizedBox(height: ThemeSizes.lg),

          // Save button
          ElevatedButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Salva ricordo'),
          ),
        ],
      ),
    );
  }
}
