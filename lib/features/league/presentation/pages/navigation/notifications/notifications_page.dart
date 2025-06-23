import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/cubits/notification_count/notification_count_cubit.dart';
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
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc/league_event.dart'
    hide ApproveDailyChallengeEvent;
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc/league_state.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/notifications/widgets/notification_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  List<app_notification.Notification> _notifications = [];

  // Set to track only regular notifications that need to be marked as read
  final Set<String> _regularNotificationsToMarkAsRead = {};

  // Set to track notifications being processed (approval/rejection in progress)
  final Set<String> _processingNotifications = {};

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Process regular notifications to mark as read after each build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processRegularNotificationsAsRead();
    });
  }

  Future<void> _loadNotifications() async {
    // Load notifications from repository
    context.read<LeagueBloc>().add(GetNotificationsEvent());
  }

  // Only mark regular notifications as read, NOT daily challenge notifications
  void _markRegularNotificationAsRead(String notificationId) {
    // Only send event to backend
    context.read<LeagueBloc>().add(
          MarkNotificationAsReadEvent(
            notificationId: notificationId,
          ),
        );

    // Update local state to mark as read without removing
    setState(() {
      _notifications = _notifications.map((notification) {
        if (notification.id == notificationId) {
          return notification.copyWith(isRead: true);
        }
        return notification;
      }).toList();
    });
  }

  // Process regular notifications to mark as read
  void _processRegularNotificationsAsRead() {
    if (_regularNotificationsToMarkAsRead.isNotEmpty) {
      final notificationsToProcess =
          Set<String>.from(_regularNotificationsToMarkAsRead);

      _regularNotificationsToMarkAsRead.clear();

      // Mark each regular notification as read
      for (final id in notificationsToProcess) {
        _markRegularNotificationAsRead(id);
      }
    }
  }

  // Count unread notifications and update cubit
  void _updateUnreadCount() {
    final unreadCount = _notifications.where((n) => !n.isRead).length;
    context.read<NotificationCountCubit>().setCount(unreadCount);
  }

  // Immediately mark notification as being processed to prevent UI issues
  void _markNotificationAsProcessing(String notificationId) {
    setState(() {
      _processingNotifications.add(notificationId);
      // Also immediately remove from UI to avoid flickering
      _notifications.removeWhere((n) => n.id == notificationId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LeagueBloc, LeagueState>(
      listener: (context, state) {
        if (state is NotificationsLoaded) {
          setState(() {
            // Only keep notifications that aren't being processed
            _notifications = state.notifications
                .where((n) => !_processingNotifications.contains(n.id))
                .toList();
          });

          // Update unread count whenever notifications are loaded
          _updateUnreadCount();
        } else if (state is NotificationActionSuccess) {
          // For approve/reject/delete actions, remove from view
          if (state.action == 'approve' ||
              state.action == 'reject' ||
              state.action == 'delete') {
            // First, clear from processing set
            _processingNotifications.remove(state.notificationId);

            // Remove from the notifications list
            setState(() {
              _notifications.removeWhere((n) => n.id == state.notificationId);
            });

            // Update UI based on action
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

            // Update the notification count after removing a notification
            _updateUnreadCount();
          }
        } else if (state is LeagueError) {
          // On error, clear processing state for all notifications
          _processingNotifications.clear();
          showSnackBar(state.message);

          // Reload notifications to restore proper state
          _loadNotifications();
        } else if (state is NotificationReceived) {
          // Refresh notifications when a new one is received
          _loadNotifications();
        }
      },
      builder: (context, state) {
        final bool isLoading = state is LeagueLoading;

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
          body: isLoading && _notifications.isEmpty
              ? Loader(
                  color: ColorPalette.warning,
                )
              : _notifications.isEmpty
                  ? _buildEmptyState()
                  : _buildNotificationsList(),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const EmptyState(
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

          // IMPORTANT: Only add regular notifications to be marked as read
          // Do NOT mark daily challenge notifications as read
          if (!notification.isRead &&
              (notification is! DailyChallengeNotification)) {
            _regularNotificationsToMarkAsRead.add(notification.id);
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

  // Handle approval - this will add points, mark as completed, and delete notification
  void _handleDailyChallengeApproval(DailyChallengeNotification notification) {
    // Mark as processing immediately to provide instant feedback
    _markNotificationAsProcessing(notification.id);

    context.read<DailyChallengesBloc>().add(
          ApproveDailyChallengeEvent(
            notificationId: notification.id,
          ),
        );
  }

  // Handle rejection - this will NOT add points, mark as not pending, and delete notification
  void _handleDailyChallengeRejection(DailyChallengeNotification notification) {
    // Mark as processing immediately to provide instant feedback
    _markNotificationAsProcessing(notification.id);

    context.read<DailyChallengesBloc>().add(
          RejectDailyChallengeEvent(
            notificationId: notification.id,
            challengeId: notification.challengeId,
          ),
        );
  }
}
