import 'dart:async';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

abstract interface class ConnectionChecker {
  Future<bool> get isConnected;
  Stream<bool> get onStatusChange;
  void dispose();
}

class ConnectionCheckerImpl implements ConnectionChecker {
  final InternetConnection internetConnection;
  bool _lastKnownConnected = true;
  late final StreamSubscription<InternetStatus> _subscription;
  final StreamController<bool> _statusController =
      StreamController<bool>.broadcast();

  ConnectionCheckerImpl(this.internetConnection) {
    _subscription = internetConnection.onStatusChange.listen((status) {
      final next = status == InternetStatus.connected;
      if (next != _lastKnownConnected) {
        _lastKnownConnected = next;
        _statusController.add(next);
      }
    });

    internetConnection.hasInternetAccess.then((connected) {
      if (connected != _lastKnownConnected) {
        _lastKnownConnected = connected;
        _statusController.add(connected);
      }
    }).catchError((_) {});
  }

  @override
  Future<bool> get isConnected async => _lastKnownConnected;

  @override
  Stream<bool> get onStatusChange => _statusController.stream;

  @override
  Future<void> dispose() async {
    await _subscription.cancel();
    await _statusController.close();
  }
}
