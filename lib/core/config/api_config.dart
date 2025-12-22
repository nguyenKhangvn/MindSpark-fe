/// API Configuration for MindSpark
/// Manages base URLs and endpoints for different environments
class ApiConfig {
  // Environment detection
  static const String _environment =
      String.fromEnvironment('ENV', defaultValue: 'dev');

  // Base URLs per environment
  static const Map<String, String> _baseUrls = {
    'dev': 'http://localhost:3000',
    'staging': 'https://staging-api.mindspark.com',
    'production': 'https://api.mindspark.com',
  };

  // Get current base URL
  static String get baseUrl => _baseUrls[_environment] ?? _baseUrls['dev']!;

  // API Version
  static const String apiVersion = '/api/v1';

  // Full base URL with version
  static String get fullBaseUrl => '$baseUrl$apiVersion';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // API Endpoints
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';

  static const String decks = '/decks';
  static String deckById(String id) => '/decks/$id';
  static String deckCards(String deckId) => '/decks/$deckId/cards';

  static const String cards = '/cards';
  static String cardById(String id) => '/cards/$id';

  static const String studySessions = '/study/sessions';
  static String studySessionById(String id) => '/study/sessions/$id';
  static const String studyReview = '/study/review';

  static const String stats = '/stats';
  static const String statsLeaderboard = '/stats/leaderboard';
  static String statsUser(String userId) => '/stats/user/$userId';

  // Health check endpoints
  static const String healthGateway = '/health';
  static const String healthAuth = '/auth/health';
  static const String healthDecks = '/decks/health';
  static const String healthStats = '/stats/health';

  // Environment info
  static bool get isDevelopment => _environment == 'dev';
  static bool get isStaging => _environment == 'staging';
  static bool get isProduction => _environment == 'production';

  // Debug logging
  static bool get enableLogging => !isProduction;
}
