import 'package:fantavacanze_official/core/entities/fs_league/fs_night_type.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

class FsFormFields extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final FsNightType nightType;

  const FsFormFields({
    super.key,
    required this.nameController,
    required this.descriptionController,
    this.nightType = FsNightType.def,
  });

  @override
  State<FsFormFields> createState() => _FsFormFieldsState();
}

class _FsFormFieldsState extends State<FsFormFields> {
  @override
  void initState() {
    super.initState();
    // Auto-populate name controller with default league name if empty
    if (widget.nameController.text.isEmpty) {
      widget.nameController.text = _getDefaultLeagueName();
    }
  }

  @override
  Widget build(BuildContext context) {
    final seasonalColor = ColorPalette.getSeasonalGradient(widget.nightType)[1];

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
          controller: widget.nameController,
          decoration: InputDecoration(
            labelText: 'Nome della Lega *',
            labelStyle: TextStyle(color: context.textSecondaryColor),
            hintText: _getSeasonalHintText(),
            prefixIcon: Icon(
              Icons.drive_file_rename_outline_rounded,
              color: seasonalColor,
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
          controller: widget.descriptionController,
          decoration: InputDecoration(
            labelText: _getSeasonalMottoLabel(),
            labelStyle: TextStyle(color: context.textSecondaryColor),
            hintText: _getSeasonalMottoHint(),
            prefixIcon: Icon(
              Icons.format_quote_rounded,
              color: seasonalColor,
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

  /// Get default league name based on night type
  String _getDefaultLeagueName() {
    switch (widget.nightType) {
      case FsNightType.halloween:
        return 'Fanta Halloween';
      case FsNightType.christmas:
        return 'Fanta Vigilia';
      case FsNightType.carnival:
        return 'Fanta Carnevale';
      case FsNightType.newYearsEve:
        return 'Fanta Capodanno';
      case FsNightType.apresSki:
        return 'Fanta Après-Ski';
      default:
        return '';
    }
  }

  /// Get seasonal hint text based on night type
  String _getSeasonalHintText() {
    switch (widget.nightType) {
      case FsNightType.halloween:
        return 'es. Fanta Halloween da Paura';
      case FsNightType.christmas:
        return 'es. Fanta Vigilia Magico';
      case FsNightType.carnival:
        return 'es. Fanta Carnevale Colorato';
      case FsNightType.newYearsEve:
        return 'es. Fanta Capodanno Esplosivo';
      case FsNightType.apresSki:
        return 'es. Fanta Ski Ghiacciato';
      default:
        return 'es. FantaSerata al Line';
    }
  }

  /// Get seasonal motto label based on night type
  String _getSeasonalMottoLabel() {
    switch (widget.nightType) {
      case FsNightType.halloween:
        return 'Motto Terrificante';
      case FsNightType.christmas:
        return 'Motto Natalizio';
      case FsNightType.carnival:
        return 'Motto Carnevalesco';
      case FsNightType.newYearsEve:
        return 'Motto di Capodanno';
      case FsNightType.apresSki:
        return 'Motto Ghiacciato';
      default:
        return 'Motto della Serata';
    }
  }

  /// Get seasonal motto hint based on night type
  String _getSeasonalMottoHint() {
    switch (widget.nightType) {
      case FsNightType.halloween:
        return 'es. Boo! Chi ha paura?';
      case FsNightType.christmas:
        return 'es. Babbo Natale siamo noi!';
      case FsNightType.carnival:
        return 'es. Maschere in alto!';
      case FsNightType.newYearsEve:
        return 'es. 3, 2, 1... Evviva!';
      case FsNightType.apresSki:
        return 'es. Neve, sci e vittoria!';
      default:
        return 'es. Chi osa vince!';
    }
  }
}
