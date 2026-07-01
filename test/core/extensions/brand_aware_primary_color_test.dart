import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_theme/app_theme_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/partner_fixtures.dart';

class MockAppThemeCubit extends MockCubit<AppThemeState>
    implements AppThemeCubit {}

class MockAppLeagueCubit extends MockCubit<AppLeagueState>
    implements AppLeagueCubit {}

class _FakeBuildContext extends Fake implements BuildContext {}

void main() {
  late MockAppThemeCubit theme;
  late MockAppLeagueCubit league;

  setUpAll(() {
    registerFallbackValue(_FakeBuildContext());
  });

  setUp(() {
    theme = MockAppThemeCubit();
    league = MockAppLeagueCubit();

    when(() => theme.state).thenReturn(AppThemeState(ThemeMode.dark));
    when(() => theme.isDarkMode(any())).thenReturn(true);
    when(() => league.state).thenReturn(AppLeagueInitial());
  });

  group('ThemeColorsExtension.primaryColor', () {
    testWidgets('proviene dal tema', (tester) async {
      const sentinel = Color(0xFF123456);
      late Color resolved;

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AppThemeCubit>.value(value: theme),
            BlocProvider<AppLeagueCubit>.value(value: league),
          ],
          child: MaterialApp(
            theme: ThemeData(
              colorScheme: const ColorScheme.light(primary: sentinel),
            ),
            home: Builder(
              builder: (context) {
                resolved = context.primaryColor;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(resolved, sentinel);
    });

    Future<Color> themePrimary(
      WidgetTester tester,
      AppLeagueState state,
    ) async {
      when(() => league.state).thenReturn(state);
      late Color resolved;

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AppThemeCubit>.value(value: theme),
            BlocProvider<AppLeagueCubit>.value(value: league),
          ],
          child: Builder(
            builder: (context) {
              resolved = AppTheme.getTheme(context).colorScheme.primary;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      return resolved;
    }

    testWidgets('il tema usa il brand-primary InVibe', (tester) async {
      final state = AppLeagueExists(
        leagues: const [],
        selectedLeague: makePartnerLeague(partner: 'invibe'),
      );

      expect(await themePrimary(tester, state), const Color(0xFF6AC5E6));
    });

    testWidgets('il tema usa il default senza lega partner', (tester) async {
      expect(
        await themePrimary(tester, AppLeagueInitial()),
        ColorPalette.primary(ThemeMode.dark),
      );
    });

    testWidgets(
      'lo scope sotto MaterialApp aggiorna il brand senza ricreare il child',
      (tester) async {
        final leagueStates = StreamController<AppLeagueState>.broadcast();
        addTearDown(leagueStates.close);
        final colors = <Color>[];
        var initCount = 0;

        when(() => league.state).thenReturn(AppLeagueInitial());
        when(() => league.stream).thenAnswer((_) => leagueStates.stream);

        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<AppThemeCubit>.value(value: theme),
              BlocProvider<AppLeagueCubit>.value(value: league),
            ],
            child: MaterialApp(
              builder: (context, child) {
                return BlocSelector<AppLeagueCubit, AppLeagueState, String?>(
                  selector: (state) => state is AppLeagueExists
                      ? state.selectedLeague.partner
                      : null,
                  builder: (context, partnerSlug) {
                    return Theme(
                      data: AppTheme.getTheme(
                        context,
                        partnerSlugOverride: partnerSlug,
                      ),
                      child: child ?? const SizedBox.shrink(),
                    );
                  },
                );
              },
              home: _ThemeProbe(
                onInit: () => initCount++,
                onBuild: (context) => colors.add(context.primaryColor),
              ),
            ),
          ),
        );

        expect(colors.last, ColorPalette.primary(ThemeMode.dark));
        expect(initCount, 1);

        leagueStates.add(
          AppLeagueExists(
            leagues: const [],
            selectedLeague: makePartnerLeague(partner: 'invibe'),
          ),
        );
        await tester.pump();

        expect(colors.last, const Color(0xFF6AC5E6));
        expect(initCount, 1);
      },
    );
  });
}

class _ThemeProbe extends StatefulWidget {
  final VoidCallback onInit;
  final ValueChanged<BuildContext> onBuild;

  const _ThemeProbe({
    required this.onInit,
    required this.onBuild,
  });

  @override
  State<_ThemeProbe> createState() => _ThemeProbeState();
}

class _ThemeProbeState extends State<_ThemeProbe> {
  @override
  void initState() {
    super.initState();
    widget.onInit();
  }

  @override
  Widget build(BuildContext context) {
    widget.onBuild(context);
    return const SizedBox.shrink();
  }
}
