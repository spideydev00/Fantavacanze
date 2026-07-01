import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/services/ads/ad_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAppUserCubit extends Mock implements AppUserCubit {}

void main() {
  group('AdManager', () {
    late AdManager adManager;
    late MockAppUserCubit appUserCubit;

    setUp(() {
      adManager = AdManager();
      appUserCubit = MockAppUserCubit();
      when(() => appUserCubit.state).thenReturn(AppUserInitial());
      when(() => appUserCubit.stream)
          .thenAnswer((_) => const Stream<AppUserState>.empty());
      adManager.connectToUserCubit(appUserCubit);
    });

    tearDown(() {
      adManager.dispose();
    });

    test('non mostra App Open quando utente non loggato', () async {
      expect(adManager.canShowAds, isFalse);
      await expectLater(adManager.onAppResumed(), completes);
    });
  });
}
