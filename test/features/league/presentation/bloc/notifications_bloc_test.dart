import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/notification_count/notification_count_cubit.dart';
import 'package:fantavacanze_official/core/entities/notification/entity/notification.dart'
    as app_notification;
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/notifications/delete_notification.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/notifications/get_notifications.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/notifications/listen_to_notification.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/notifications_bloc/notifications_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/notifications_bloc/notifications_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/notifications_bloc/notifications_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockGetNotifications extends Mock implements GetNotifications {}

class MockDeleteNotification extends Mock implements DeleteNotification {}

class MockListenToNotification extends Mock implements ListenToNotification {}

class MockAppLeagueCubit extends Mock implements AppLeagueCubit {}

class FakeNoParams extends Fake implements NoParams {}

void main() {
  late MockGetNotifications getNotifications;
  late MockDeleteNotification deleteNotification;
  late MockListenToNotification listenToNotification;
  late NotificationCountCubit notificationCountCubit;
  late MockAppLeagueCubit appLeagueCubit;
  late StreamController<app_notification.Notification> notificationController;

  final notification = app_notification.Notification(
    id: 'notification-1',
    title: 'Nuova richiesta',
    message: 'Hai una nuova richiesta',
    createdAt: DateTime.utc(2026),
    leagueId: 'league-1',
  );

  setUpAll(() {
    registerFallbackValue(FakeNoParams());
  });

  setUp(() {
    getNotifications = MockGetNotifications();
    deleteNotification = MockDeleteNotification();
    listenToNotification = MockListenToNotification();
    notificationCountCubit = NotificationCountCubit();
    appLeagueCubit = MockAppLeagueCubit();
    notificationController =
        StreamController<app_notification.Notification>.broadcast();

    when(() => appLeagueCubit.state).thenReturn(AppLeagueInitial());
    when(() => appLeagueCubit.stream)
        .thenAnswer((_) => const Stream<AppLeagueState>.empty());
    when(() => listenToNotification(any()))
        .thenAnswer((_) async => right(notificationController.stream));
  });

  tearDown(() async {
    await notificationCountCubit.close();
    await notificationController.close();
  });

  NotificationsBloc buildBloc() {
    return NotificationsBloc(
      getNotifications: getNotifications,
      deleteNotification: deleteNotification,
      listenToNotification: listenToNotification,
      notificationCountCubit: notificationCountCubit,
      appLeagueCubit: appLeagueCubit,
    );
  }

  group('NotificationsBloc', () {
    blocTest<NotificationsBloc, NotificationsState>(
      'incrementa una sola volta dopo ListenToNotificationEvent ripetuti',
      build: buildBloc,
      act: (bloc) async {
        bloc
          ..add(ListenToNotificationEvent())
          ..add(ListenToNotificationEvent())
          ..add(ListenToNotificationEvent());

        await Future<void>.delayed(Duration.zero);
        notificationController.add(notification);
      },
      wait: const Duration(milliseconds: 20),
      expect: () => [
        NotificationReceived(notification: notification),
      ],
      verify: (_) {
        expect(notificationCountCubit.state, 1);
        verify(() => listenToNotification(any())).called(1);
      },
    );
  });
}
