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
import 'package:fantavacanze_official/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:fantavacanze_official/core/widgets/info_banner.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:fantavacanze_official/features/league/domain/entities/partner/partner_search_result.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/partner_bloc/partner_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchPartnerLeaguePage extends StatefulWidget {
  static const String _slug = 'invibe';

  final String partnerSlug;

  const SearchPartnerLeaguePage({
    super.key,
    required this.partnerSlug,
  });

  static Route route({String partnerSlug = _slug}) {
    return MaterialPageRoute(
      builder: (_) => SearchPartnerLeaguePage(partnerSlug: partnerSlug),
    );
  }

  @override
  State<SearchPartnerLeaguePage> createState() =>
      _SearchPartnerLeaguePageState();
}

class _SearchPartnerLeaguePageState extends State<SearchPartnerLeaguePage> {
  final _inviteCodeController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _inviteCodeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.getTheme(
        context,
        partnerSlugOverride: SearchPartnerLeaguePage._slug,
      ),
      child: Builder(
        builder: (context) => Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: context.bgColor,
          appBar: AppBar(
            title: Text(
              'Unisciti a una lega',
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
          body: AmbientGlow(
            child: SizedBox.expand(
              child: SafeArea(
                child: BlocConsumer<PartnerCubit, PartnerState>(
                  listener: _onPartnerState,
                  builder: (context, state) {
                    final isLoading = state is PartnerLoading;
                    final expectedPrefix = _prefixFor(widget.partnerSlug);

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
                                    'Inserisci codice invito e parola d’ordine InVibe.',
                                color: context.brandColor,
                                icon: Icons.lock_open_outlined,
                              ),
                              const SizedBox(height: ThemeSizes.md),
                              TextField(
                                controller: _inviteCodeController,
                                decoration: InputDecoration(
                                  labelText: 'Codice Invito',
                                  hintText: 'Esempio: ${expectedPrefix}ABC123',
                                  prefixIcon: const Icon(Icons.code),
                                  filled: true,
                                  fillColor: context.secondaryBgColor,
                                ),
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: ThemeSizes.md),
                              TextField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Parola d’ordine InVibe',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  filled: true,
                                  fillColor: context.secondaryBgColor,
                                ),
                                obscureText: true,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _search(),
                              ),
                              const SizedBox(height: ThemeSizes.lg),
                              ElevatedButton.icon(
                                onPressed: isLoading ? null : _search,
                                icon: isLoading
                                    ? SizedBox(
                                        width: ThemeSizes.iconSm,
                                        height: ThemeSizes.iconSm,
                                        child: Loader(
                                          color: context.textPrimaryColor,
                                        ),
                                      )
                                    : const Icon(Icons.login_rounded),
                                label: Text(
                                  isLoading
                                      ? 'Ricerca in corso...'
                                      : 'Cerca / Unisciti',
                                ),
                              ),
                            ],
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
      ),
    );
  }

  void _onPartnerState(BuildContext context, PartnerState state) {
    if (state is PartnerFailure) {
      showSnackBar(state.message);
      return;
    }

    if (state is PartnerSearchLoaded) {
      switch (state.result.status) {
        case PartnerSearchStatus.notFound:
          showSnackBar('Lega non trovata', color: ColorPalette.warning);
        case PartnerSearchStatus.wrongPassword:
          showSnackBar('Parola d’ordine errata', color: ColorPalette.error);
        case PartnerSearchStatus.found:
          _showFoundConfirmation(state.result);
      }
      return;
    }

    if (state is PartnerLeagueReady) {
      context.read<AppLeagueCubit>().selectLeague(state.league);
      context.read<AppNavigationCubit>().setIndex(0);
      Navigator.of(context).popUntil((route) => route.isFirst);
      showSnackBar(
        'Sei entrato nella lega',
        color: ColorPalette.success,
      );
    }
  }

  void _search() {
    FocusManager.instance.primaryFocus?.unfocus();
    final inviteCode = _inviteCodeController.text.trim();
    final password = _passwordController.text.trim();

    if (inviteCode.isEmpty) {
      showSnackBar('Inserisci il codice invito.', color: ColorPalette.warning);
      return;
    }

    if (password.isEmpty) {
      showSnackBar(
        'Inserisci la parola d’ordine InVibe.',
        color: ColorPalette.warning,
      );
      return;
    }

    context.read<PartnerCubit>().searchLeague(
          inviteCode: inviteCode,
          password: password,
        );
  }

  void _showFoundConfirmation(PartnerSearchResult result) {
    final league = result.league;
    final leagueName = league?.name ?? 'questa lega';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ConfirmationDialog(
        title: 'Lega trovata',
        message: 'Vuoi unirti a "$leagueName"?',
        confirmText: 'Unisciti',
        cancelText: 'Annulla',
        icon: Icons.groups_rounded,
        iconColor: context.brandColor,
        additionalContent: _ResultDetails(result: result),
        onCancel: () => Navigator.of(dialogContext).pop(),
        onConfirm: () {
          Navigator.of(dialogContext).pop();
          _join();
        },
      ),
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

class _ResultDetails extends StatelessWidget {
  final PartnerSearchResult result;

  const _ResultDetails({required this.result});

  @override
  Widget build(BuildContext context) {
    if (result.destinationName == null && result.roundName == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: ThemeSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (result.destinationName != null)
            Text(
              'Destinazione: ${result.destinationName}',
              style: context.textTheme.bodyMedium,
            ),
          if (result.roundName != null) ...[
            const SizedBox(height: ThemeSizes.xs),
            Text(
              'Turno: ${result.roundName}',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
