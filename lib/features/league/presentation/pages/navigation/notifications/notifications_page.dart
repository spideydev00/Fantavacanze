import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/show_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/empty_state.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';

import 'package:fantavacanze_official/features/league/domain/entities/daily_challenge_notification.dart';
import 'package:fantavacanze_official/features/league/domain/entities/notification.dart'
    as app_notification;
import 'package:fantavacanze_official/features/league/presentation/bloc/daily_challenges_bloc/daily_challenges_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/daily_challenges_bloc/daily_challenges_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/notifications_bloc/notifications_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/notifications_bloc/notifications_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/notifications_bloc/notifications_state.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/notifications/widgets/notification_card.dart';

class NotificationsPage extends StatefulWidget {
  static const String routeName = '/notifications';

  static get route => MaterialPageRoute(
        builder: (context) => const NotificationsPage(),
        settings: const RouteSettings(name: routeName),
      );

  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    // Carico le notifiche all’apertura della pagina
    context.read<NotificationsBloc>().add(GetNotificationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificationsBloc, NotificationsState>(
      listener: (context, state) {
        if (state is NotificationActionSuccess && state.action == 'delete') {
          showSnackBar("Scelta Salvata", color: ColorPalette.success);
        } else if (state is NotificationsError) {
          showSnackBar(state.message);
        }
      },
      builder: (context, state) {
        final isLoading =
            state is NotificationsLoading && state is! NotificationsLoaded;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Notifiche',
              style: context.textTheme.titleMedium!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: isLoading
              ? const Loader(color: ColorPalette.warning)
              : _buildContent(state),
        );
      },
    );
  }

  Widget _buildContent(NotificationsState state) {
    if (state is NotificationsLoaded) {
      if (state.notifications.isEmpty) {
        return _buildEmptyState();
      }
      return _buildNotificationsList(state.notifications);
    }
    return _buildEmptyState();
  }

  Widget _buildEmptyState() {
    return const EmptyState(
      icon: Icons.notifications_none_rounded,
      title: "Nessuna Notifica",
      subtitle: "Le tue notifiche appariranno qui quando saranno disponibili.",
    );
  }

  Widget _buildNotificationsList(
      List<app_notification.Notification> notifications) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<NotificationsBloc>().add(GetNotificationsEvent());
      },
      color: context.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(ThemeSizes.md),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          final isAdmin = _isUserAdmin();

          // Segna come lette le notifiche “normali” quando appaiono
          if (!notification.isRead &&
              notification is! DailyChallengeNotification) {
            context.read<NotificationsBloc>().add(
                  MarkNotificationAsReadEvent(
                    notificationId: notification.id,
                  ),
                );
          }

          return NotificationCard(
            notification: notification,
            isAdmin: isAdmin,
            onApprove: notification is DailyChallengeNotification && isAdmin
                ? () => _handleDailyChallengeApproval(notification)
                : null,
            onReject: notification is DailyChallengeNotification && isAdmin
                ? () => _handleDailyChallengeRejection(notification)
                : null,
          );
        },
      ),
    );
  }

  bool _isUserAdmin() {
    final userState = context.read<AppUserCubit>().state;
    final leagueState = context.read<AppLeagueCubit>().state;

    if (userState is AppUserIsLoggedIn && leagueState is AppLeagueExists) {
      return leagueState.selectedLeague.admins.contains(userState.user.id);
    }
    return false;
  }

  void _handleDailyChallengeApproval(DailyChallengeNotification notification) {
    context.read<DailyChallengesBloc>().add(
          ApproveDailyChallengeEvent(notificationId: notification.id),
        );
    context.read<NotificationsBloc>().add(
          DeleteNotificationEvent(notificationId: notification.id),
        );
  }

  void _handleDailyChallengeRejection(DailyChallengeNotification notification) {
    context.read<DailyChallengesBloc>().add(
          RejectDailyChallengeEvent(
            notificationId: notification.id,
            challengeId: notification.challengeId,
          ),
        );
    context.read<NotificationsBloc>().add(
          DeleteNotificationEvent(notificationId: notification.id),
        );
  }
}
