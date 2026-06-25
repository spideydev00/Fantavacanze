import 'package:bloc_test/bloc_test.dart';
import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_theme/app_theme_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/partner_fixtures.dart';

class MockAppThemeCubit extends MockCubit<AppThemeState>
    implements AppThemeCubit {}

class MockAppLeagueCubit extends MockCubit<AppLeagueState>
    implements AppLeagueCubit {}

void main() {
  late MockAppThemeCubit themeCubit;
  late MockAppLeagueCubit leagueCubit;

  setUp(() {
    themeCubit = MockAppThemeCubit();
    leagueCubit = MockAppLeagueCubit();
    when(() => themeCubit.state).thenReturn(AppThemeState(ThemeMode.dark));
  });

  Future<Color> resolvePrimary(
    WidgetTester tester,
    AppLeagueState leagueState,
  ) async {
    when(() => leagueCubit.state).thenReturn(leagueState);
    late Color resolved;

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AppThemeCubit>.value(value: themeCubit),
          BlocProvider<AppLeagueCubit>.value(value: leagueCubit),
        ],
        child: Builder(
          builder: (context) {
            resolved = context.primaryColor;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    return resolved;
  }

  group('ThemeColorsExtension.primaryColor', () {
    testWidgets(
      'usa il brand quando la lega selezionata e InVibe',
      (tester) async {
        final state = AppLeagueExists(
          leagues: [tPartnerLeagueModel],
          selectedLeague: tPartnerLeagueModel,
        );

        final color = await resolvePrimary(tester, state);

        expect(color, const Color(0xFF6AC5E6));
      },
    );

    testWidgets(
      'usa il primary app quando non c e una lega partner',
      (tester) async {
        final color = await resolvePrimary(tester, AppLeagueInitial());

        expect(color, ColorPalette.primary(ThemeMode.dark));
      },
    );
  });
}
