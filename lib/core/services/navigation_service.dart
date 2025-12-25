import 'package:flutter/material.dart';

/// Global navigation service for navigating without BuildContext
/// Useful for navigation from non-widget code (interceptors, services, etc.)
class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Navigate to a named route
  Future<dynamic>? navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState?.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate and remove all previous routes
  Future<dynamic>? navigateAndRemoveUntil(
    String routeName, {
    Object? arguments,
  }) {
    return navigatorKey.currentState?.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Replace current route with new route
  Future<dynamic>? navigateReplace(String routeName, {Object? arguments}) {
    return navigatorKey.currentState?.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }

  /// Go back to previous route
  void goBack([dynamic result]) {
    return navigatorKey.currentState?.pop(result);
  }

  /// Navigate to login screen and clear all routes
  void navigateToLogin() {
    navigateAndRemoveUntil('/login');
  }

  /// Check if navigator is ready
  bool get isReady => navigatorKey.currentState != null;
}
