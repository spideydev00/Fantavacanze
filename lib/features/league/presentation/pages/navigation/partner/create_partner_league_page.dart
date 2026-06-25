import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/show-snackbar-or-paywall/show_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:fantavacanze_official/features/league/domain/entities/partner/partner_catalog.dart';
import 'package:fantavacanze_official/features/league/domain/entities/partner/partner_destination.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule/rule.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/partner_bloc/partner_cubit.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/partner/partner_league_dashboard_page.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/partner/widgets/destination_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreatePartnerLeaguePage extends StatefulWidget {
  final PartnerCatalog catalog;

  const CreatePartnerLeaguePage({
    super.key,
    required this.catalog,
  });

  @override
  State<CreatePartnerLeaguePage> createState() =>
      _CreatePartnerLeaguePageState();
}

class _CreatePartnerLeaguePageState extends State<CreatePartnerLeaguePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _passwordController = TextEditingController();
  PartnerDestination? _selectedDestination;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brandColor = context.brandPrimaryColor(widget.catalog.partner.slug);

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        title: const Text('Crea Lega Partner'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocConsumer<PartnerCubit, PartnerState>(
          listener: (context, state) {
            if (state is PartnerFailure) {
              showSnackBar(state.message);
            } else if (state is PartnerLeagueReady) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => PartnerLeagueDashboardPage(
                    league: state.league,
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is PartnerLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(ThemeSizes.lg),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Header(
                          title: 'Scegli destinazione',
                          subtitle:
                              'Ogni destinazione ha il proprio regolamento partner.',
                          color: brandColor,
                        ),
                        const SizedBox(height: ThemeSizes.lg),
                        for (final destination in widget.catalog.destinations)
                          DestinationCard(
                            destination: destination,
                            selected: destination == _selectedDestination,
                            partnerSlug: widget.catalog.partner.slug,
                            onTap: () {
                              setState(() {
                                _selectedDestination = destination;
                                if (!destination.requiresPassword) {
                                  _passwordController.clear();
                                }
                              });
                            },
                          ),
                        if (_selectedDestination != null) ...[
                          const SizedBox(height: ThemeSizes.md),
                          _SelectedRules(
                            destination: _selectedDestination!,
                            color: brandColor,
                          ),
                          const SizedBox(height: ThemeSizes.lg),
                          _LeagueForm(
                            nameController: _nameController,
                            descriptionController: _descriptionController,
                            passwordController: _passwordController,
                            requiresPassword:
                                _selectedDestination!.requiresPassword,
                          ),
                          const SizedBox(height: ThemeSizes.lg),
                          ElevatedButton.icon(
                            onPressed: isLoading ? null : _submit,
                            icon: isLoading
                                ? SizedBox(
                                    width: ThemeSizes.iconSm,
                                    height: ThemeSizes.iconSm,
                                    child:
                                        Loader(color: context.textPrimaryColor),
                                  )
                                : const Icon(Icons.check_circle_outline),
                            label: Text(
                              isLoading ? 'Creazione in corso...' : 'Crea Lega',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    final destination = _selectedDestination;
    if (destination == null) {
      showSnackBar(
        'Seleziona una destinazione.',
        color: ColorPalette.warning,
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final userState = context.read<AppUserCubit>().state;
    if (userState is! AppUserIsLoggedIn) {
      showSnackBar('Devi effettuare l’accesso per creare una lega.');
      return;
    }

    final description = _descriptionController.text.trim();
    context.read<PartnerCubit>().createLeague(
          userName: userState.user.name,
          destinationId: destination.id,
          name: _nameController.text.trim(),
          password: destination.requiresPassword
              ? _passwordController.text.trim()
              : '',
          description: description.isEmpty ? null : description,
        );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;

  const _Header({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ThemeSizes.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(ThemeSizes.cardRadiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.textPrimaryColor,
            ),
          ),
          const SizedBox(height: ThemeSizes.sm),
          Text(
            subtitle,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedRules extends StatelessWidget {
  final PartnerDestination destination;
  final Color color;

  const _SelectedRules({
    required this.destination,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ThemeSizes.md),
      decoration: BoxDecoration(
        color: context.secondaryBgColor,
        borderRadius: BorderRadius.circular(ThemeSizes.cardRadiusLg),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Regolamento di ${destination.name}',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: ThemeSizes.md),
          if (destination.rules.isEmpty)
            Text(
              'Nessuna regola disponibile.',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.textSecondaryColor,
              ),
            )
          else
            for (final rule in destination.rules) _RulePreviewRow(rule: rule),
        ],
      ),
    );
  }
}

class _RulePreviewRow extends StatelessWidget {
  final Rule rule;

  const _RulePreviewRow({required this.rule});

  @override
  Widget build(BuildContext context) {
    final isBonus = rule.type == RuleType.bonus;
    final color = isBonus ? ColorPalette.success : ColorPalette.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: ThemeSizes.sm),
      child: Row(
        children: [
          Icon(
            isBonus ? Icons.add_circle_outline : Icons.remove_circle_outline,
            color: color,
            size: ThemeSizes.iconSm,
          ),
          const SizedBox(width: ThemeSizes.sm),
          Expanded(
            child: Text(
              rule.name,
              style: context.textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${isBonus ? '+' : '-'}${rule.points.abs().toStringAsFixed(0)} pt',
            style: context.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeagueForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController passwordController;
  final bool requiresPassword;

  const _LeagueForm({
    required this.nameController,
    required this.descriptionController,
    required this.passwordController,
    required this.requiresPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nome lega',
            prefixIcon: Icon(Icons.emoji_events_outlined),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Inserisci il nome della lega';
            }
            return null;
          },
        ),
        const SizedBox(height: ThemeSizes.md),
        TextFormField(
          controller: descriptionController,
          decoration: const InputDecoration(
            labelText: 'Descrizione',
            prefixIcon: Icon(Icons.notes_outlined),
          ),
          maxLines: 2,
        ),
        if (requiresPassword) ...[
          const SizedBox(height: ThemeSizes.md),
          TextFormField(
            controller: passwordController,
            decoration: const InputDecoration(
              labelText: 'Parola d’ordine',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Inserisci la parola d’ordine';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }
}
