import 'package:flutter/material.dart';
import 'api_client.dart';
import 'services/auth_service.dart';
import 'services/deck_service.dart';
import 'services/card_service.dart';
import 'services/study_service.dart';
import 'services/stats_service.dart';

/// API Service Provider
///
/// Provides access to all API services in the application.
/// Use this to initialize and access services throughout the app.
///
/// Example usage:
/// ```dart
/// final apiProvider = ApiServiceProvider();
/// await apiProvider.initialize();
///
/// // Use services
/// final user = await apiProvider.auth.login(
///   email: 'test@example.com',
///   password: 'password123',
/// );
/// ```
class ApiServiceProvider {
  late final ApiClient _apiClient;
  late final AuthService _authService;
  late final DeckService _deckService;
  late final CardService _cardService;
  late final StudyService _studyService;
  late final StatsService _statsService;

  // Singleton pattern
  static final ApiServiceProvider _instance = ApiServiceProvider._internal();

  factory ApiServiceProvider() {
    return _instance;
  }

  ApiServiceProvider._internal() {
    _apiClient = ApiClient();
    _authService = AuthService(_apiClient);
    _deckService = DeckService(_apiClient);
    _cardService = CardService(_apiClient);
    _studyService = StudyService(_apiClient);
    _statsService = StatsService(_apiClient);
  }

  /// Initialize the API client (load saved tokens, etc.)
  Future<void> initialize() async {
    await _apiClient.initialize();
  }

  // Getters for services
  AuthService get auth => _authService;
  DeckService get decks => _deckService;
  CardService get cards => _cardService;
  StudyService get study => _studyService;
  StatsService get stats => _statsService;

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _authService.isAuthenticated();
  }
}

/// Flutter Provider Widget for API Services
class ApiProvider extends InheritedWidget {
  final ApiServiceProvider apiProvider;

  const ApiProvider({
    Key? key,
    required this.apiProvider,
    required Widget child,
  }) : super(key: key, child: child);

  static ApiServiceProvider of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<ApiProvider>();
    assert(provider != null, 'No ApiProvider found in context');
    return provider!.apiProvider;
  }

  @override
  bool updateShouldNotify(ApiProvider oldWidget) {
    return false;
  }
}
