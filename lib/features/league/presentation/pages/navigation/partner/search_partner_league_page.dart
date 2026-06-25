import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/show-snackbar-or-paywall/show_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/info_banner.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:fantavacanze_official/features/league/domain/entities/partner/partner_search_result.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/partner_bloc/partner_cubit.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/partner/partner_league_dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchPartnerLeaguePage extends StatefulWidget {
  final String partnerSlug;

  const SearchPartnerLeaguePage({
    super.key,
    required this.partnerSlug,
  });

  @override
  State<SearchPartnerLeaguePage> createState() =>
      _SearchPartnerLeaguePageState();
}

class _SearchPartnerLeaguePageState extends State<SearchPartnerLeaguePage> {
  final _inviteCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  PartnerSearchResult? _result;

  @override
  void dispose() {
    _inviteCodeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brandColor = context.brandPrimaryColor(widget.partnerSlug);
    final expectedPrefix = _prefixFor(widget.partnerSlug);

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        title: const Text('Cerca Lega Partner'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocConsumer<PartnerCubit, PartnerState>(
          listener: (context, state) {
            if (state is PartnerFailure) {
              showSnackBar(state.message);
            } else if (state is PartnerSearchLoaded) {
              setState(() {
                _result = state.result;
              });
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
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InfoBanner(
                        message:
                            'Inserisci codice invito e parola d’ordine della lega partner.',
                        color: brandColor,
                        icon: Icons.lock_open_outlined,
                      ),
                      const SizedBox(height: ThemeSizes.md),
                      TextField(
                        controller: _inviteCodeController,
                        decoration: InputDecoration(
                          labelText: 'Codice invito',
                          hintText: 'Esempio: ${expectedPrefix}ABC123',
                          prefixIcon: const Icon(Icons.code),
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: ThemeSizes.md),
                      TextField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Parola d’ordine',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        obscureText: true,
                        onSubmitted: (_) => _search(),
                      ),
                      const SizedBox(height: ThemeSizes.lg),
                      ElevatedButton.icon(
                        onPressed: isLoading ? null : _search,
                        icon: isLoading
                            ? SizedBox(
                                width: ThemeSizes.iconSm,
                                height: ThemeSizes.iconSm,
                                child: Loader(color: context.textPrimaryColor),
                              )
                            : const Icon(Icons.search_rounded),
                        label: Text(
                          isLoading ? 'Ricerca in corso...' : 'Cerca Lega',
                        ),
                      ),
                      const SizedBox(height: ThemeSizes.lg),
                      if (_result != null)
                        _SearchResultCard(
                          result: _result!,
                          brandColor: brandColor,
                          isLoading: isLoading,
                          onJoin: _join,
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _search() {
    FocusManager.instance.primaryFocus?.unfocus();
    final inviteCode = _inviteCodeController.text.trim();
    final password = _passwordController.text.trim();

    if (inviteCode.isEmpty || password.isEmpty) {
      showSnackBar(
        'Inserisci codice invito e parola d’ordine.',
        color: ColorPalette.warning,
      );
      return;
    }

    context.read<PartnerCubit>().searchLeague(
          inviteCode: inviteCode,
          password: password,
        );
  }

  void _join() {
    final userState = context.read<AppUserCubit>().state;
    if (userState is! AppUserIsLoggedIn) {
      showSnackBar('Devi effettuare l’accesso per unirti alla lega.');
      return;
    }

    context.read<PartnerCubit>().joinLeague(
          userName: userState.user.name,
          inviteCode: _inviteCodeController.text.trim(),
          password: _passwordController.text.trim(),
        );
  }

  String _prefixFor(String slug) {
    return switch (slug) {
      'invibe' => 'vb',
      'b-eazy' => 'bz',
      _ => 'xx',
    };
  }
}

class _SearchResultCard extends StatelessWidget {
  final PartnerSearchResult result;
  final Color brandColor;
  final bool isLoading;
  final VoidCallback onJoin;

  const _SearchResultCard({
    required this.result,
    required this.brandColor,
    required this.isLoading,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ThemeSizes.lg),
      decoration: BoxDecoration(
        color: context.secondaryBgColor,
        borderRadius: BorderRadius.circular(ThemeSizes.cardRadiusLg),
        border: Border.all(color: brandColor.withValues(alpha: 0.3)),
      ),
      child: switch (result.status) {
        PartnerSearchStatus.found => _FoundLeague(
            result: result,
            brandColor: brandColor,
            isLoading: isLoading,
            onJoin: onJoin,
          ),
        PartnerSearchStatus.notFound => _StatusMessage(
            icon: Icons.search_off,
            title: 'Nessuna lega trovata',
            message: 'Nessuna lega trovata con questo codice.',
            color: ColorPalette.warning,
          ),
        PartnerSearchStatus.wrongPassword => _StatusMessage(
            icon: Icons.lock_outline,
            title: 'Parola d’ordine errata',
            message: 'Controlla la parola d’ordine e riprova.',
            color: ColorPalette.error,
          ),
      },
    );
  }
}

class _FoundLeague extends StatelessWidget {
  final PartnerSearchResult result;
  final Color brandColor;
  final bool isLoading;
  final VoidCallback onJoin;

  const _FoundLeague({
    required this.result,
    required this.brandColor,
    required this.isLoading,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final league = result.league;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatusMessage(
          icon: Icons.check_circle_outline,
          title: 'Lega trovata',
          message: league?.name ?? 'Puoi unirti a questa lega partner.',
          color: brandColor,
        ),
        if (result.destinationName != null) ...[
          const SizedBox(height: ThemeSizes.sm),
          Text(
            'Destinazione: ${result.destinationName}',
            style: context.textTheme.bodyMedium,
          ),
        ],
        if (result.roundName != null) ...[
          const SizedBox(height: ThemeSizes.xs),
          Text(
            'Turno: ${result.roundName}',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
        ],
        const SizedBox(height: ThemeSizes.lg),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : onJoin,
            icon: isLoading
                ? SizedBox(
                    width: ThemeSizes.iconSm,
                    height: ThemeSizes.iconSm,
                    child: Loader(color: context.textPrimaryColor),
                  )
                : const Icon(Icons.login_rounded),
            label: Text(isLoading ? 'Unione in corso...' : 'Unisciti'),
          ),
        ),
      ],
    );
  }
}

class _StatusMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color color;

  const _StatusMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: ThemeSizes.iconMd),
        const SizedBox(width: ThemeSizes.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: ThemeSizes.xs),
              Text(
                message,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
