import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

class FsFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;

  const FsFormFields({
    super.key,
    required this.nameController,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Dettagli della Lega',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.textPrimaryColor,
          ),
        ),
        const SizedBox(height: ThemeSizes.lg),

        // Nome lega
        TextFormField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Nome della Lega *',
            labelStyle: TextStyle(color: context.textSecondaryColor),
            hintText: 'es. FantaSerata al Line',
            prefixIcon: Icon(
              Icons.drive_file_rename_outline_rounded,
              color: context.primaryColor,
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: ColorPalette.error,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Il nome della lega è obbligatorio';
            }
            if (value.trim().length < 3) {
              return 'Il nome deve essere di almeno 3 caratteri';
            }
            if (value.trim().length > 30) {
              return 'Il nome non può superare i 30 caratteri';
            }
            return null;
          },
          textCapitalization: TextCapitalization.words,
          maxLength: 30,
        ),

        const SizedBox(height: ThemeSizes.lg),

        // Motto/Descrizione
        TextFormField(
          controller: descriptionController,
          decoration: InputDecoration(
            labelText: 'Motto della Serata',
            labelStyle: TextStyle(color: context.textSecondaryColor),
            hintText: 'es. Chi osa vince!',
            prefixIcon: Icon(
              Icons.format_quote_rounded,
              color: context.primaryColor,
            ),
            helperText: 'Opzionale - Aggiungi un motto!',
            helperStyle: TextStyle(
              color: context.textSecondaryColor,
              fontSize: 12,
            ),
          ),
          maxLines: 2,
          maxLength: 100,
          textCapitalization: TextCapitalization.sentences,
          keyboardType: TextInputType.text,
        ),
      ],
    );
  }
}
