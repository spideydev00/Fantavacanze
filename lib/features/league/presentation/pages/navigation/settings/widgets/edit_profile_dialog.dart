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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final userState = context.read<AppUserCubit>().state;
    if (userState is AppUserIsLoggedIn) {
      _currentUserName = userState.user.name;
      _nameController.text = _currentUserName ?? '';
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
    if (newName == _currentUserName) return;

    setState(() => _isLoading = true);

    try {
      await context.read<AppUserCubit>().updateDisplayName(newName);
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
            if (_isLoading)
              Padding(
                  padding: EdgeInsets.only(top: ThemeSizes.md),
                  child: Loader(color: ColorPalette.success)),
          ],
        ),
      ),
    );
  }
}
