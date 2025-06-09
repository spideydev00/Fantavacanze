import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_player.dart';
import 'package:fantavacanze_official/features/games/presentation/bloc/lobby/lobby_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditGamePlayerNameDialog extends StatefulWidget {
  final GamePlayer player;
  final String sessionId;

  const EditGamePlayerNameDialog({
    super.key,
    required this.player,
    required this.sessionId,
  });

  static Future<void> show(
    BuildContext context, {
    required GamePlayer player,
    required String sessionId,
  }) async {
    return showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<LobbyBloc>(),
        child: EditGamePlayerNameDialog(
          player: player,
          sessionId: sessionId,
        ),
      ),
    );
  }

  @override
  State<EditGamePlayerNameDialog> createState() =>
      _EditGamePlayerNameDialogState();
}

class _EditGamePlayerNameDialogState extends State<EditGamePlayerNameDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.player.userName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _updatePlayerName() {
    if (_formKey.currentState?.validate() != true) return;

    final newName = _nameController.text.trim();
    if (newName.isNotEmpty && newName != widget.player.userName) {
      context.read<LobbyBloc>().add(
            EditPlayerNameRequested(
                widget.player.id, newName, widget.sessionId),
          );
    }
    // Dialog is popped by ConfirmationDialog's onConfirm
  }

  @override
  Widget build(BuildContext context) {
    return ConfirmationDialog(
      title: 'Modifica Nome Giocatore',
      message: 'Inserisci il nuovo nome per ${widget.player.userName}.',
      confirmText: 'Salva',
      cancelText: 'Annulla',
      icon: Icons.edit_note_rounded,
      iconColor: context.primaryColor,
      onConfirm: _updatePlayerName,
      additionalContent: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                fillColor: context.bgColor,
                labelText: 'Nuovo nome',
                hintText: 'Inserisci il nuovo nome',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Il nome è obbligatorio';
                }
                if (value.trim().length < 2) {
                  return 'Il nome deve avere almeno 2 caratteri';
                }
                if (value.trim().length > 20) {
                  return 'Il nome non può superare i 20 caratteri';
                }
                return null;
              },
            ),
            // We don't need a separate loader here as LobbyBloc will handle UI updates
          ],
        ),
      ),
    );
  }
}
