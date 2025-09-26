import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/show-snackbar-or-paywall/show_page_specific_snackbar.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/bloc/fs_league_bloc/fs_bloc.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/pages/fs_league_created_page.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/widgets/create_fs_league/fs_create_button.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/widgets/create_fs_league/fs_create_hero_section.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/widgets/create_fs_league/fs_form_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateFsLeaguePage extends StatefulWidget {
  static const String routeName = '/create-fs-league';

  static get route => MaterialPageRoute(
        builder: (context) => const CreateFsLeaguePage(),
        settings: const RouteSettings(name: routeName),
      );

  const CreateFsLeaguePage({super.key});

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
          'Crea FantaSerata',
          style: context.textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocListener<FsBloc, FsState>(
        listener: (context, state) {
          if (state is FsLeagueCreated) {
            Navigator.of(context).pushReplacement(
              FsLeagueCreatedPage.route(state.league),
            );
          } else if (state is FantaserataFailure) {
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
                const FsCreateHeroSection(),

                const SizedBox(height: ThemeSizes.xl),

                // Form fields
                FsFormFields(
                  nameController: _nameController,
                  descriptionController: _descriptionController,
                ),

                const SizedBox(height: ThemeSizes.xl),

                // Create button
                BlocBuilder<FsBloc, FsState>(
                  builder: (context, state) {
                    if (state is FantaserataLoading) {
                      return FsCreateButton(
                        onPressed: () {},
                        isLoading: true,
                      );
                    }
                    return FsCreateButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          _createLeague();
                        }
                      },
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
  }
}
