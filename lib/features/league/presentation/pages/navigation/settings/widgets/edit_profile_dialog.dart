import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfileDialog extends StatefulWidget {
  static Future<void> show(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: context.read<AppUserCubit>(),
        child: const EditProfileDialog(),
      ),
    );
  }

  const EditProfileDialog({super.key});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _currentUserName;
  String? _currentUserGender;
  String? _selectedGender;
  bool _isLoading = false;

  final Map<String, String> _genderOptions = {
    'male': 'Uomo',
    'female': 'Donna',
    'undefined': 'Preferisco non dirlo',
  };

  @override
  void initState() {
    super.initState();
    final userState = context.read<AppUserCubit>().state;

    if (userState is AppUserIsLoggedIn) {
      _currentUserName = userState.user.name;
      _currentUserGender = userState.user.gender;
      _nameController.text = _currentUserName ?? '';
      _selectedGender = _currentUserGender;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState?.validate() != true) return;

    final newName = _nameController.text.trim();
    final nameChanged = newName != _currentUserName;
    final genderChanged = _selectedGender != _currentUserGender;

    if (!nameChanged && !genderChanged) return;

    setState(() => _isLoading = true);

    try {
      if (nameChanged) {
        await context.read<AppUserCubit>().updateDisplayName(newName);
      }
      if (genderChanged && _selectedGender != null && mounted) {
        await context.read<AppUserCubit>().updateGender(_selectedGender!);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConfirmationDialog(
      title: 'Modifica Profilo',
      message: 'Aggiorna i dettagli del tuo profilo',
      confirmText: 'Salva',
      cancelText: 'Annulla',
      icon: Icons.person,
      iconColor: context.primaryColor,
      onConfirm: _updateProfile,
      additionalContent: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                fillColor: context.bgColor,
                labelText: 'Nome',
                hintText: 'Inserisci il tuo nome',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Il nome è obbligatorio';
                }
                if (value.trim().length < 2) {
                  return 'Il nome deve avere almeno 2 caratteri';
                }
                return null;
              },
            ),
            const SizedBox(height: ThemeSizes.md),
            Theme(
              data: Theme.of(context).copyWith(
                canvasColor: context.bgColor,
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: InputDecoration(
                  labelText: 'Genere',
                  fillColor: context.bgColor,
                ),
                items: _genderOptions.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
              ),
            ),
            if (_isLoading)
              const Padding(
                  padding: EdgeInsets.only(top: ThemeSizes.md),
                  child: Loader(color: ColorPalette.success)),
          ],
        ),
      ),
    );
  }
}
