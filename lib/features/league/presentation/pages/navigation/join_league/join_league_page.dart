import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_state.dart';

class JoinLeaguePage extends StatefulWidget {
  const JoinLeaguePage({super.key});

  @override
  State<JoinLeaguePage> createState() => _JoinLeaguePageState();
}

class _JoinLeaguePageState extends State<JoinLeaguePage> {
  final _formKey = GlobalKey<FormState>();
  final _inviteCodeController = TextEditingController();
  final _teamNameController = TextEditingController();
  bool _isJoining = false;

  @override
  void dispose() {
    _inviteCodeController.dispose();
    _teamNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unisciti a una Lega'),
        elevation: 0,
      ),
      body: BlocConsumer<LeagueBloc, LeagueState>(
        listener: (context, state) {
          if (state is LeagueError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
            setState(() {
              _isJoining = false;
            });
          } else if (state is LeagueSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ti sei unito alla lega con successo!'),
                backgroundColor: ColorPalette.success,
              ),
            );
            Navigator.pop(context);
          } else if (state is MultiplePossibleLeagues) {
            setState(() {
              _isJoining = false;
            });
            _showLeagueSelectionDialog(
              context,
              state.inviteCode,
              state.possibleLeagues,
            );
          }
        },
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  context.bgColor,
                  context.bgColor.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(ThemeSizes.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header illustration
                    Center(
                      child: Container(
                        height: 180,
                        width: 180,
                        decoration: BoxDecoration(
                          color: context.primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.group_add_rounded,
                          size: 80,
                          color: context.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: ThemeSizes.xl),

                    Text(
                      'Inserisci il codice di invito',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: ThemeSizes.sm),
                    Text(
                      'Chiedi al creatore della lega il codice di invito per unirti alla sua lega.',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: ThemeSizes.lg),

                    // Invite code field with modern design
                    Container(
                      decoration: BoxDecoration(
                        color: context.secondaryBgColor,
                        borderRadius:
                            BorderRadius.circular(ThemeSizes.borderRadiusLg),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _inviteCodeController,
                        decoration: InputDecoration(
                          hintText: 'Inserisci il codice di 10 caratteri',
                          labelText: 'Codice Invito',
                          prefixIcon:
                              Icon(Icons.vpn_key, color: context.primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                ThemeSizes.borderRadiusLg),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: context.secondaryBgColor,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Inserisci un codice di invito';
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.characters,
                        onChanged: (value) {
                          // Auto uppercase
                          if (value != value.toUpperCase()) {
                            _inviteCodeController.value = TextEditingValue(
                              text: value.toUpperCase(),
                              selection: _inviteCodeController.selection,
                            );
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: ThemeSizes.xl),

                    Text(
                      'La tua Squadra (Opzionale)',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: ThemeSizes.sm),
                    Text(
                      'Se questa è una lega a squadre, puoi specificare il nome della tua squadra.',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: ThemeSizes.lg),

                    // Team name field
                    Container(
                      decoration: BoxDecoration(
                        color: context.secondaryBgColor,
                        borderRadius:
                            BorderRadius.circular(ThemeSizes.borderRadiusLg),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _teamNameController,
                        decoration: InputDecoration(
                          hintText: 'Inserisci il nome della tua squadra',
                          labelText: 'Nome Squadra (Opzionale)',
                          prefixIcon:
                              Icon(Icons.people, color: context.primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                ThemeSizes.borderRadiusLg),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: context.secondaryBgColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: ThemeSizes.xxl),

                    // Join button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _isJoining
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    _isJoining = true;
                                  });
                                  final inviteCode =
                                      _inviteCodeController.text.trim();
                                  final teamName =
                                      _teamNameController.text.trim();

                                  context.read<LeagueBloc>().add(
                                        JoinLeagueEvent(
                                          inviteCode: inviteCode,
                                          teamName: teamName.isNotEmpty
                                              ? teamName
                                              : null,
                                        ),
                                      );
                                }
                              },
                        icon: _isJoining
                            ? Container(
                                width: 24,
                                height: 24,
                                padding: const EdgeInsets.all(8),
                                child: const CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.login_rounded),
                        label: Text(
                            _isJoining ? 'Attendere...' : 'Unisciti alla Lega'),
                        style: ElevatedButton.styleFrom(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(ThemeSizes.buttonRadius),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showLeagueSelectionDialog(
      BuildContext context, String inviteCode, List<dynamic> leagues) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Seleziona Lega'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sono state trovate più leghe con questo codice di invito. Seleziona quella a cui vuoi unirti:',
                  style: TextStyle(color: context.textSecondaryColor),
                ),
                const SizedBox(height: ThemeSizes.md),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: leagues.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final league = leagues[index];
                      return ListTile(
                        title: Text(
                          league['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          league['description'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          final teamName = _teamNameController.text.trim();
                          Navigator.pop(context);
                          setState(() {
                            _isJoining = true;
                          });

                          context.read<LeagueBloc>().add(
                                JoinLeagueEvent(
                                  inviteCode: inviteCode,
                                  teamName:
                                      teamName.isNotEmpty ? teamName : null,
                                  specificLeagueId: league['id'],
                                ),
                              );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Annulla'),
            ),
          ],
        );
      },
    );
  }
}
