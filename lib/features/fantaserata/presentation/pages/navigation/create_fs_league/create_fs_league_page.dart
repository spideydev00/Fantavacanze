import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/entities/fs_league/fs_night_type.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/show-snackbar-or-paywall/show_page_specific_snackbar.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/bloc/fs_league_bloc/fs_bloc.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/pages/navigation/create_fs_league/fs_league_created_page.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/widgets/create_fs_league/fs_create_button.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/widgets/create_fs_league/fs_create_hero_section.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/widgets/create_fs_league/fs_form_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateFsLeaguePage extends StatefulWidget {
  static const String routeName = '/create-fs-league';
  final FsNightType nightType;

  static route({FsNightType? nightType}) => MaterialPageRoute(
        builder: (context) =>
            CreateFsLeaguePage(nightType: nightType ?? FsNightType.def),
        settings: const RouteSettings(name: routeName),
      );

  const CreateFsLeaguePage({
    super.key,
    this.nightType = FsNightType.def,
  });

  @override
  State<CreateFsLeaguePage> createState() => _CreateFsLeaguePageState();
}

class _CreateFsLeaguePageState extends State<CreateFsLeaguePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getSeasonalCreateTitle(widget.nightType),
          style: context.textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocListener<FsBloc, FsState>(
        listener: (context, state) {
          if (state is FsLeagueCreated ||
              state is FsNightSpecificLeagueCreated) {
            final league = state is FsLeagueCreated
                ? state.league
                : (state as FsNightSpecificLeagueCreated).league;
            Navigator.of(context).pushReplacement(
              FsLeagueCreatedPage.route(league),
            );
          } else if (state is FsFailure) {
            showSpecificSnackBar(
              context,
              state.message,
              color: ColorPalette.error,
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(ThemeSizes.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero section
                FsCreateHeroSection(nightType: widget.nightType),

                const SizedBox(height: ThemeSizes.xl),

                // Form fields
                FsFormFields(
                  nameController: _nameController,
                  descriptionController: _descriptionController,
                  nightType: widget.nightType,
                ),

                const SizedBox(height: ThemeSizes.xl),

                // Create button
                BlocBuilder<FsBloc, FsState>(
                  builder: (context, state) {
                    if (state is FsLoading) {
                      return FsCreateButton(
                        onPressed: () {},
                        isLoading: true,
                        nightType: widget.nightType,
                      );
                    }
                    return FsCreateButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          _createLeague();
                        }
                      },
                      nightType: widget.nightType,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _createLeague() {
    final userState = context.read<AppUserCubit>().state;

    if (userState is! AppUserIsLoggedIn) {
      showSpecificSnackBar(
        context,
        'Errore: utente non autenticato',
        color: ColorPalette.error,
      );
      return;
    }

    // Check if it's a seasonal league or regular league
    if (widget.nightType == FsNightType.def) {
      // Create regular league
      context.read<FsBloc>().add(
            CreateFsLeagueEvent(
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
              creatorId: userState.user.id,
              creatorName: userState.user.name,
            ),
          );
    } else {
      // Create night-specific league
      context.read<FsBloc>().add(
            CreateNightSpecificFsLeagueEvent(
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
              creatorId: userState.user.id,
              creatorName: userState.user.name,
              nightType: widget.nightType,
            ),
          );
    }
  }

  /// Get seasonal create title
  String _getSeasonalCreateTitle(FsNightType nightType) {
    switch (nightType) {
      case FsNightType.halloween:
        return 'Crea Fanta Halloween';
      case FsNightType.christmas:
        return 'Crea Fanta Vigilia';
      case FsNightType.carnival:
        return 'Crea Fanta Carnevale';
      case FsNightType.newYearsEve:
        return 'Crea Fanta Capodanno';
      case FsNightType.apresSki:
        return 'Crea Fanta Ski';
      default:
        return 'Crea FantaSerata';
    }
  }
}
