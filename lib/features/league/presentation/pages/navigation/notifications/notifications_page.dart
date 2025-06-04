import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/show_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/empty_state.dart';
import 'package:fantavacanze_official/features/league/domain/entities/daily_challenge_notification.dart';
import 'package:fantavacanze_official/features/league/domain/entities/notification.dart'
    as app_notification;
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_state.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/notifications/widgets/notification_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsPage extends StatefulWidget {
  static get route => MaterialPageRoute(
        builder: (context) => const NotificationsPage(),
      );

  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<app_notification.Notification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    // Load notifications from repository
    context.read<LeagueBloc>().add(GetNotificationsEvent());
  }

  // Auto-mark notifications as read when loaded
  void _markAllNotificationsAsRead() {
    // Only process unread notifications
    final unreadNotifications = _notifications.where((n) => !n.isRead).toList();

    // Mark each unread notification as read
    for (final notification in unreadNotifications) {
      context.read<LeagueBloc>().add(
            MarkNotificationAsReadEvent(
              notificationId: notification.id,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LeagueBloc, LeagueState>(
      listener: (context, state) {
        if (state is NotificationsLoaded) {
          setState(() {
            _notifications = state.notifications;
          });

          // Auto-mark notifications as read when they're loaded
          if (_notifications.isNotEmpty) {
            _markAllNotificationsAsRead();
          }
        } else if (state is NotificationActionSuccess) {
          // After a notification action succeeds, reload the notifications
          _loadNotifications();

          if (state.action == 'approve') {
            showSnackBar(
              "Sfida approvata con successo!",
              color: ColorPalette.success,
            );
          } else if (state.action == 'reject') {
            showSnackBar(
              "Sfida rifiutata",
              color: ColorPalette.warning,
            );
          } else if (state.action == 'delete') {
            showSnackBar(
              "Notifica eliminata",
              color: ColorPalette.error,
            );
          }
        } else if (state is LeagueError) {
          showSnackBar(state.message);
        } else if (state is NotificationReceived) {
          // Refresh notifications when a new one is received
          _loadNotifications();
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Notifiche',
              style: context.textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: _notifications.isEmpty
              ? _buildEmptyState()
              : _buildNotificationsList(),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return EmptyState(
        icon: Icons.notifications_none_rounded,
        title: "Nessuna Notifica",
        subtitle:
            "Le tue notifiche appariranno qui quando saranno disponibili.");
  }

  Widget _buildNotificationsList() {
    return RefreshIndicator(
      onRefresh: _loadNotifications,
      color: context.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(ThemeSizes.md),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          final bool isAdmin = _isUserAdmin();

          return NotificationCard(
            notification: notification,
            isAdmin: isAdmin,
            onTap: () {
              if (!notification.isRead) {
                _markNotificationAsRead(notification.id);
              }
            },
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
    context.read<LeagueBloc>().add(
          ApproveDailyChallengeEvent(
            notificationId: notification.id,
          ),
        );
  }

  void _handleDailyChallengeRejection(DailyChallengeNotification notification) {
    context.read<LeagueBloc>().add(
          RejectDailyChallengeEvent(
            notificationId: notification.id,
          ),
        );
  }

  void _markNotificationAsRead(String notificationId) {
    context.read<LeagueBloc>().add(
          MarkNotificationAsReadEvent(
            notificationId: notificationId,
          ),
        );
  }
}
