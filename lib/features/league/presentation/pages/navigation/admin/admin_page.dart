import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_navigation/app_navigation_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/show_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/divider.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_state.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/admin/sections/admin_section.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/admin/sections/league_info_section.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/admin/sections/participants_section.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/events/add_event.dart';
import 'package:fantavacanze_official/core/widgets/confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminPage extends StatefulWidget {
  static Route get route =>
      MaterialPageRoute(builder: (context) => const AdminPage());

  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _participantsKey = GlobalKey<ParticipantsSectionState>();

  League? _currentLeague;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLeague();
  }

  void _loadLeague() {
    final leagueState = context.read<AppLeagueCubit>().state;
    if (leagueState is AppLeagueExists) {
      setState(() {
        _currentLeague = leagueState.selectedLeague;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LeagueBloc, LeagueState>(
      listener: (context, state) {
        if (state is LeagueLoading) {
          setState(() {
            _isLoading = true;
          });
        } else {
          setState(() {
            _isLoading = false;
          });

          if (state is LeagueError) {
            showSnackBar(context, state.message, color: ColorPalette.error);
          } else if (state is AdminOperationSuccess) {
            _currentLeague = state.league;

            String message = '';
            switch (state.operation) {
              case 'add_administrators':
                message = 'Amministratori aggiunti con successo';
                break;
              case 'remove_administrators':
                message = 'Amministratori rimossi con successo';
                break;
              case 'remove_participants':
                message = 'Partecipanti rimossi con successo';
                break;
              case 'update_league_info':
                message = 'Informazioni lega aggiornate con successo';
                break;
              default:
                message = 'Operazione completata con successo';
            }

            showSnackBar(context, message, color: ColorPalette.success);

            // Update any child state if needed
            if (state.operation == 'remove_participants') {
              _participantsKey.currentState?.clearSelection();
            }
          } else if (state is LeagueSuccess) {
            if (state.operation == 'add_event') {
              showSnackBar(context, 'Evento aggiunto con successo',
                  color: ColorPalette.success);
            }
          } else if (state is DeleteLeagueSuccess) {
            Navigator.pop(context);
            // Navigate to home page
            context.read<AppNavigationCubit>().setIndex(0);
            // Show success message
            showSnackBar(
              context,
              'Lega eliminata con successo',
              color: ColorPalette.success,
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: context.bgColor,
        appBar: AppBar(
          title: const Text('Admin'),
          elevation: 0,
        ),
        body: _isLoading
            ? Center(child: Loader(color: context.primaryColor))
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_currentLeague == null) {
      return const Center(
        child: Text('Nessuna lega selezionata'),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(ThemeSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Introduction Text
          Container(
            padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.sm),
            child: Text(
              'Gestisci le impostazioni sensibili della tua lega utilizzando le sezioni qui sotto.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium!.copyWith(
                color: context.textSecondaryColor,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: ThemeSizes.lg),

          // Section 1: Admin management
          const GradientSectionDivider(
            text: 'AMMINISTRATORI',
            sectionNumber: 1,
          ),
          AdminSection(
            league: _currentLeague!,
          ),

          // Section 2: Participants management
          const GradientSectionDivider(
            text: 'PARTECIPANTI',
            sectionNumber: 2,
          ),
          ParticipantsSection(
            key: _participantsKey,
            league: _currentLeague!,
          ),

          // Section 3: Event management
          const GradientSectionDivider(
            text: 'EVENTI',
            sectionNumber: 3,
          ),
          _buildEventManagementCard(),

          // Section 4: League info management
          const GradientSectionDivider(
            text: 'LEGA',
            sectionNumber: 4,
          ),
          LeagueInfoSection(
            league: _currentLeague!,
          ),

          const SizedBox(height: ThemeSizes.lg),

          // Danger zone
          const CustomDivider(
            text: 'ELIMINA LEGA',
            thickness: 1,
            color: ColorPalette.error,
          ),

          // Delete league button
          _buildDeleteLeagueButton(),

          const SizedBox(height: ThemeSizes.xl),
        ],
      ),
    );
  }

  Widget _buildEventManagementCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: ThemeSizes.lg),
      decoration: BoxDecoration(
        color: context.secondaryBgColor,
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeSizes.md,
              vertical: ThemeSizes.md,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.textPrimaryColor.withValues(alpha: 0.05),
                    borderRadius:
                        BorderRadius.circular(ThemeSizes.borderRadiusMd),
                  ),
                  child: Icon(
                    Icons.event_note_outlined,
                    color: context.textPrimaryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: ThemeSizes.md),
                Text(
                  'Eventi',
                  style: context.textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(ThemeSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: context.textTheme.bodyMedium!.copyWith(
                      height: 1.5,
                      color: context.textSecondaryColor,
                    ),
                    children: [
                      TextSpan(
                        text: 'Crea nuovi eventi ',
                        style: context.textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.textSecondaryColor,
                        ),
                      ),
                      TextSpan(
                        text:
                            'per assegnare punti bonus o malus ai partecipanti. Puoi utilizzare le regole già definite o crearne di nuove.',
                        style: context.textTheme.bodyMedium!.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: ThemeSizes.lg),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        AddEventPage.route,
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Crea Nuovo Evento'),
                    style: ElevatedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: ThemeSizes.md),
                      backgroundColor: context.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: context.primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteLeagueButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: ThemeSizes.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        gradient: LinearGradient(
          colors: [
            ColorPalette.error.withValues(alpha: 0.05),
            ColorPalette.error.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(color: ColorPalette.error.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        child: InkWell(
          onTap: () => _showDeleteLeagueDialog(context),
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
          splashColor: ColorPalette.error.withValues(alpha: 0.1),
          highlightColor: ColorPalette.error.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(ThemeSizes.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorPalette.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_forever,
                    color: ColorPalette.error,
                    size: 22,
                  ),
                ),
                const SizedBox(width: ThemeSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Elimina Lega',
                        style: context.textTheme.bodyLarge!.copyWith(
                          color: ColorPalette.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Questa azione non può essere annullata',
                        maxLines: 2,
                        style: context.textTheme.bodySmall!.copyWith(
                          color: ColorPalette.error.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteLeagueDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog.delete(
        itemType: 'Lega',
        customMessage:
            'Sei sicuro di voler eliminare questa lega? Questa azione non può essere annullata.',
        onDelete: () {
          _deleteLeague();
        },
      ),
    );
  }

  void _deleteLeague() {
    if (_currentLeague != null) {
      context.read<LeagueBloc>().add(
            DeleteLeagueEvent(leagueId: _currentLeague!.id),
          );
    }
  }
}
