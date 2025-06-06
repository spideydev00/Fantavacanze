import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/utils/ad_helper.dart';
import 'package:fantavacanze_official/init_dependencies/init_dependencies.dart';

/// A route observer that safely updates the AdHelper with the current route name
/// and manages starting/stopping the ad timer based on route changes
class SafeRouteObserver extends NavigatorObserver {
  final AdHelper _adHelper = serviceLocator<AdHelper>();
  BuildContext? _lastContext;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _handleRouteChange(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _handleRouteChange(newRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _handleRouteChange(previousRoute);
    } else {
      // If there's no previous route, stop the ad timer
      _adHelper.stopAdTimer();
    }
  }

  /// Handle route change by updating the current route and managing the ad timer
  void _handleRouteChange(Route<dynamic> route) {
    // Get the route name
    final String? routeName = route.settings.name;

    // Update the current route in AdHelper
    _adHelper.updateCurrentRoute(routeName);

    // If we have a context and the route is not excluded, start the ad timer
    if (route is PageRoute && route.navigator?.context != null) {
      _lastContext = route.navigator!.context;

      // Check if ads should be shown on this route
      if (!_adHelper.isCurrentRouteExcluded) {
        // Start or restart the ad timer with the new context
        _adHelper.stopAdTimer(); // Stop any existing timer
        _adHelper.startAdTimer(_lastContext!);
      } else {
        // Stop the timer if we're on an excluded route
        _adHelper.stopAdTimer();
      }
    }
  }
}
