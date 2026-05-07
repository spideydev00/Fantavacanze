import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/entities/notification/entity/notification.dart'
    as app_notification;
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/network/connection_checker.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/show-snackbar-or-paywall/show_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/empty_state.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:fantavacanze_official/features/league/domain/entities/daily_challenge_notification.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/daily_challenges_bloc/daily_challenges_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/daily_challenges_bloc/daily_challenges_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/daily_challenges_bloc/daily_challenges_state.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/notifications_bloc/notifications_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/notifications_bloc/notifications_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/notifications_bloc/notifications_state.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/notifications/widgets/notification_card.dart';
import 'package:fantavacanze_official/init_dependencies/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsPage extends StatefulWidget {
  static const String routeName = '/notifications';

  static MaterialPageRoute<dynamic> get route => MaterialPageRoute(
        builder: (context) => const NotificationsPage(),
        settings: const RouteSettings(name: routeName),
      );

  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  static const String _dailyChallengeOfflineMessage =
      'Per approvare o rifiutare le sfide quotidiane è necessaria una connessione internet. Riprova quando sarai online.';

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

          return DailyChallengeNotificationCard(
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

  void _handleDailyChallengeApproval(
      DailyChallengeNotification notification) async {
    final dailyChallengesBloc = context.read<DailyChallengesBloc>();
    final notificationsBloc = context.read<NotificationsBloc>();

    if (!await _ensureOnlineForDailyChallengeAction()) return;

    dailyChallengesBloc.add(
      ApproveDailyChallengeEvent(notificationId: notification.id),
    );

    // Attende il completamento dell'operazione direttamente sullo stream
    // del bloc, bypassando il distinct-skip di Equatable quando si compiono
    // due approve/reject consecutivi sulla stessa pagina.
    await dailyChallengesBloc.stream.firstWhere(
      (s) =>
          (s is DailyChallengesLoaded && s.operation == 'approve_challenge') ||
          s is DailyChallengesError,
    );

    if (!mounted) return;
    notificationsBloc.add(GetNotificationsEvent());
  }

  void _handleDailyChallengeRejection(
      DailyChallengeNotification notification) async {
    final dailyChallengesBloc = context.read<DailyChallengesBloc>();
    final notificationsBloc = context.read<NotificationsBloc>();

    if (!await _ensureOnlineForDailyChallengeAction()) return;

    dailyChallengesBloc.add(
      RejectDailyChallengeEvent(
        notificationId: notification.id,
      ),
    );

    await dailyChallengesBloc.stream.firstWhere(
      (s) =>
          (s is DailyChallengesLoaded && s.operation == 'reject_challenge') ||
          s is DailyChallengesError,
    );

    if (!mounted) return;
    notificationsBloc.add(GetNotificationsEvent());
  }

  Future<bool> _ensureOnlineForDailyChallengeAction() async {
    final isConnected = await serviceLocator<ConnectionChecker>().isConnected;
    if (isConnected) return true;

    if (!mounted) return false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Connessione assente'),
        content: const Text(_dailyChallengeOfflineMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Ho capito'),
          ),
        ],
      ),
    );

    return false;
  }
}
