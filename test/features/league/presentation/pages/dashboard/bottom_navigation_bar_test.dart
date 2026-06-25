import 'package:bloc_test/bloc_test.dart';
import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_navigation/app_navigation_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_theme/app_theme_cubit.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/dashboard/sections/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAppThemeCubit extends MockCubit<AppThemeState>
    implements AppThemeCubit {}

class MockAppNavigationCubit extends MockCubit<int>
    implements AppNavigationCubit {}

class MockAppLeagueCubit extends MockCubit<AppLeagueState>
    implements AppLeagueCubit {}

class _FakeBuildContext extends Fake implements BuildContext {}

void main() {
  late MockAppThemeCubit theme;
  late MockAppNavigationCubit nav;
  late MockAppLeagueCubit league;

  setUpAll(() {
    registerFallbackValue(_FakeBuildContext());
  });

  setUp(() {
    theme = MockAppThemeCubit();
    nav = MockAppNavigationCubit();
    league = MockAppLeagueCubit();

    when(() => theme.state).thenReturn(AppThemeState(ThemeMode.dark));
    when(() => theme.isDarkMode(any())).thenReturn(true);
    when(() => nav.state).thenReturn(0);
    when(() => league.state).thenReturn(AppLeagueInitial());
  });

  group('CustomBottomNavigationBar', () {
    testWidgets('non va in overflow nello stato senza leghe', (tester) async {
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AppThemeCubit>.value(value: theme),
            BlocProvider<AppNavigationCubit>.value(value: nav),
            BlocProvider<AppLeagueCubit>.value(value: league),
          ],
          child: const MaterialApp(
            home: Scaffold(
              bottomNavigationBar: CustomBottomNavigationBar(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
