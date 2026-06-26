import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_navigation/app_navigation_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/theme/theme.dart';
import 'package:fantavacanze_official/core/utils/show-snackbar-or-paywall/show_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/ambient_glow.dart';
import 'package:fantavacanze_official/core/widgets/info_container.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:fantavacanze_official/features/league/domain/entities/partner/partner_catalog.dart';
import 'package:fantavacanze_official/features/league/domain/entities/partner/partner_destination.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/partner_bloc/partner_cubit.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/partner/utils/default_league_name.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/rules/widgets/rule_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreatePartnerLeagueFormPage extends StatefulWidget {
  final PartnerCatalog catalog;
  final PartnerDestination destination;

  const CreatePartnerLeagueFormPage({
    super.key,
    required this.catalog,
    required this.destination,
  });

  static Route route(
    PartnerCatalog catalog,
    PartnerDestination destination,
  ) {
    return MaterialPageRoute(
      builder: (_) => CreatePartnerLeagueFormPage(
        catalog: catalog,
        destination: destination,
      ),
    );
  }

  @override
  State<CreatePartnerLeagueFormPage> createState() =>
      _CreatePartnerLeagueFormPageState();
}

class _CreatePartnerLeagueFormPageState
    extends State<CreatePartnerLeagueFormPage> {
  static const String _slug = 'invibe';

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mottoController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final userState = context.read<AppUserCubit>().state;
    final gender = switch (userState) {
      AppUserIsLoggedIn(:final user) => user.gender,
      _ => null,
    };
    _nameController.text = defaultLeagueName(
      gender: gender,
      destination: widget.destination.name,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mottoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.getTheme(context, partnerSlugOverride: _slug),
      child: Builder(
        builder: (context) => Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: context.bgColor,
          appBar: AppBar(
            title: Text(
              'Crea Lega InVibe',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
          floatingActionButton: BlocBuilder<PartnerCubit, PartnerState>(
            builder: (context, state) {
              final isLoading = state is PartnerLoading;

              return ElevatedButton.icon(
                onPressed: isLoading ? null : _submit,
                icon: isLoading
                    ? SizedBox(
                        width: ThemeSizes.iconSm,
                        height: ThemeSizes.iconSm,
                        child: Loader(color: context.textPrimaryColor),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(
                  isLoading ? 'Creazione...' : 'Crea Lega',
                ),
              );
            },
          ),
          body: AmbientGlow(
            child: SafeArea(
              child: BlocConsumer<PartnerCubit, PartnerState>(
                listener: _onPartnerState,
                builder: (context, state) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      ThemeSizes.lg,
                      ThemeSizes.lg,
                      ThemeSizes.lg,
                      ThemeSizes.xxl * 2,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              InfoContainer(
                                title: widget.destination.name,
                                message:
                                    'Personalizza la tua lega: il regolamento InVibe è già pronto.',
                                icon: Icons.travel_explore_rounded,
                                color: context.brandColor,
                              ),
                              const SizedBox(height: ThemeSizes.lg),
                              _LeagueFields(
                                nameController: _nameController,
                                mottoController: _mottoController,
                                passwordController: _passwordController,
                                requiresPassword:
                                    widget.destination.requiresPassword,
                              ),
                              const SizedBox(height: ThemeSizes.lg),
                              _RulesPreview(destination: widget.destination),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onPartnerState(BuildContext context, PartnerState state) {
    if (state is PartnerFailure) {
      showSnackBar(state.message);
      return;
    }

    if (state is PartnerLeagueReady) {
      context.read<AppLeagueCubit>().selectLeague(state.league);
      context.read<AppNavigationCubit>().setIndex(0);
      Navigator.of(context).popUntil((route) => route.isFirst);
      showSnackBar(
        'Lega creata con successo',
        color: ColorPalette.success,
      );
    }
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!_formKey.currentState!.validate()) return;

    final userState = context.read<AppUserCubit>().state;
    if (userState is! AppUserIsLoggedIn) {
      showSnackBar('Devi effettuare l’accesso per creare una lega.');
      return;
    }

    final motto = _mottoController.text.trim();
    context.read<PartnerCubit>().createLeague(
          userName: userState.user.name,
          destinationId: widget.destination.id,
          name: _nameController.text.trim(),
          password: widget.destination.requiresPassword
              ? _passwordController.text.trim()
              : '',
          description: motto.isEmpty ? null : motto,
        );
  }
}

class _LeagueFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController mottoController;
  final TextEditingController passwordController;
  final bool requiresPassword;

  const _LeagueFields({
    required this.nameController,
    required this.mottoController,
    required this.passwordController,
    required this.requiresPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Nome',
            prefixIcon: const Icon(Icons.emoji_events_outlined),
            filled: true,
            fillColor: context.secondaryBgColor,
          ),
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Inserisci il nome della lega';
            }
            return null;
          },
        ),
        const SizedBox(height: ThemeSizes.md),
        TextFormField(
          controller: mottoController,
          decoration: InputDecoration(
            labelText: 'Motto (facoltativo)',
            prefixIcon: const Icon(Icons.notes_outlined),
            filled: true,
            fillColor: context.secondaryBgColor,
          ),
          textInputAction:
              requiresPassword ? TextInputAction.next : TextInputAction.done,
          maxLines: 2,
        ),
        if (requiresPassword) ...[
          const SizedBox(height: ThemeSizes.md),
          TextFormField(
            controller: passwordController,
            decoration: InputDecoration(
              labelText: 'Parola d’ordine InVibe',
              hintText: 'Te la comunica il team InVibe',
              prefixIcon: const Icon(Icons.lock_outline),
              filled: true,
              fillColor: context.secondaryBgColor,
            ),
            obscureText: true,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Inserisci la parola d’ordine InVibe';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }
}

class _RulesPreview extends StatelessWidget {
  final PartnerDestination destination;

  const _RulesPreview({required this.destination});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ThemeSizes.md),
      decoration: BoxDecoration(
        color: context.secondaryBgColor,
        borderRadius: BorderRadius.circular(ThemeSizes.cardRadiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Regolamento',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: ThemeSizes.md),
          if (destination.rules.isEmpty)
            Text(
              'Regolamento non ancora disponibile.',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.textSecondaryColor,
              ),
            )
          else
            for (final rule in destination.rules) RuleItem(rule: rule),
        ],
      ),
    );
  }
}
