import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/theme/theme.dart';
import 'package:fantavacanze_official/core/widgets/ambient_glow.dart';
import 'package:fantavacanze_official/core/widgets/info_container.dart';
import 'package:fantavacanze_official/core/widgets/partner_destination_card.dart';
import 'package:fantavacanze_official/features/league/domain/entities/partner/partner_catalog.dart';
import 'package:fantavacanze_official/features/league/domain/entities/partner/partner_destination.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/partner_bloc/partner_cubit.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/partner/create_partner_league_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreatePartnerLeaguePage extends StatelessWidget {
  static const String _slug = 'invibe';

  final PartnerCatalog catalog;

  const CreatePartnerLeaguePage({
    super.key,
    required this.catalog,
  });

  static Route route(PartnerCatalog catalog) {
    return MaterialPageRoute(
      builder: (_) => CreatePartnerLeaguePage(catalog: catalog),
    );
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
              'Crea Lega Partner',
              style: context.textTheme.bodyLarge,
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
          body: AmbientGlow(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(ThemeSizes.lg),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        InfoContainer(
                          title: 'Scegli Destinazione',
                          message:
                              'Scegli la destinazione in cui andrai. Il regolamento lo abbiamo già preparato noi!',
                          icon: Icons.travel_explore_rounded,
                          color: context.brandColor,
                        ),
                        const SizedBox(height: ThemeSizes.lg),
                        for (final destination in catalog.destinations)
                          PartnerDestinationCard(
                            name: destination.name,
                            description: destination.description,
                            imageUrl: destination.imageUrl,
                            accentColor: context.brandColor,
                            tagLabel: _roundDateLabel(destination),
                            selected: null,
                            trailing: Icon(
                              Icons.chevron_right_rounded,
                              color: context.brandColor,
                            ),
                            onTap: () => _openForm(context, destination),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _roundDateLabel(PartnerDestination destination) {
    final round = destination.activeRound;
    if (round == null) return null;
    final start = _formatDate(round.startDate);
    final end = round.endDate == null ? null : _formatDate(round.endDate!);
    return end == null ? 'Turno dal $start' : 'Turno $start - $end';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month';
  }

  void _openForm(BuildContext context, PartnerDestination destination) {
    final cubit = context.read<PartnerCubit>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: CreatePartnerLeagueFormPage(
            catalog: catalog,
            destination: destination,
          ),
        ),
      ),
    );
  }
}
