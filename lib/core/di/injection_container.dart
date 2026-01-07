import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

// Core
import '../network/dio_api_client.dart';
import '../network/dio_client_with_interceptor.dart';
import '../storage/token_storage.dart';
import '../api/services/auth_service_dio.dart';
import '../services/navigation_service.dart';

// Auth
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';

// Deck
import '../../features/deck/data/datasources/deck_remote_datasource.dart';
import '../../features/deck/data/repositories/deck_repository_impl.dart';
import '../../features/deck/domain/repositories/deck_repository.dart';
import '../../features/deck/domain/usecases/deck_usecases.dart';
import '../../features/deck/presentation/cubit/deck_cubit.dart';

// Card
import '../../features/card/data/datasources/card_remote_datasource.dart';
import '../../features/card/data/repositories/card_repository_impl.dart';
import '../../features/card/domain/repositories/card_repository.dart';
import '../../features/card/domain/usecases/card_usecases.dart';
import '../../features/card/presentation/cubit/card_cubit.dart';

// Study
import '../../features/study/data/datasources/study_remote_datasource.dart';
import '../../features/study/data/repositories/study_repository_impl.dart';
import '../../features/study/domain/repositories/study_repository.dart';
import '../../features/study/domain/usecases/study_usecases.dart';
import '../../features/study/presentation/cubit/study_cubit.dart';

// Stats
import '../../features/statistics/data/datasources/stats_remote_datasource.dart';
import '../../features/statistics/data/repositories/stats_repository_impl.dart';
import '../../features/statistics/domain/repositories/stats_repository.dart';
import '../../features/statistics/domain/usecases/stats_usecases.dart';
import '../../features/statistics/presentation/cubit/stats_cubit.dart';

// OCR
import '../api/services/ocr_service.dart';
import '../../features/ocr/presentation/cubit/ocr_cubit.dart';

// Services
import '../services/tts_service.dart';

final sl = GetIt.instance; // Service Locator

/// Initialize all dependencies
/// Call this before runApp() in main.dart
Future<void> initializeDependencies() async {
  // ===== Core =====

  // External dependencies
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  sl.registerLazySingleton<Dio>(() => Dio());

  // Navigation service (global navigator key)
  sl.registerLazySingleton<NavigationService>(() => NavigationService());

  // Core services
  // Initialize token storage (await init to ensure web prefs ready)
  final tokenStorage = TokenStorage(sl());
  await tokenStorage.init();
  sl.registerLazySingleton<TokenStorage>(() => tokenStorage);

  // DioClientWithInterceptor - Auto-refresh token on 401
  sl.registerLazySingleton<DioClientWithInterceptor>(
    () => DioClientWithInterceptor(
      sl<TokenStorage>(),
      onUnauthorized: () {
        // Navigate to login when refresh token fails
        sl<NavigationService>().navigateToLogin();
      },
    ),
  );

  // AuthServiceDio - Using Dio with interceptor
  sl.registerLazySingleton<AuthServiceDio>(
    () => AuthServiceDio(sl(), sl()),
  );

  // DioApiClient (legacy, without callback first)
  sl.registerLazySingleton<DioApiClient>(
    () => DioApiClient(sl()),
  );

  // ===== Auth Feature =====

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      tokenStorage: sl(),
    ),
  );

  // Setup refresh token callback after all dependencies are registered
  _setupRefreshTokenCallback();

  // Use cases
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => IsAuthenticatedUseCase(sl()));

  // Cubit
  sl.registerFactory(
    () => AuthCubit(
      registerUseCase: sl(),
      loginUseCase: sl(),
      logoutUseCase: sl(),
      getProfileUseCase: sl(),
      isAuthenticatedUseCase: sl(),
    ),
  );

  // ===== Deck Feature =====

  // Data sources
  sl.registerLazySingleton<DeckRemoteDataSource>(
    () => DeckRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<DeckRepository>(
    () => DeckRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetDecksUseCase(sl()));
  sl.registerLazySingleton(() => CreateDeckUseCase(sl()));
  sl.registerLazySingleton(() => UpdateDeckUseCase(sl()));
  sl.registerLazySingleton(() => DeleteDeckUseCase(sl()));

  // Cubit
  sl.registerFactory(
    () => DeckCubit(
      getDecksUseCase: sl(),
      createDeckUseCase: sl(),
      updateDeckUseCase: sl(),
      deleteDeckUseCase: sl(),
    ),
  );

  // ===== Card Feature =====

  // Data sources
  sl.registerLazySingleton<CardRemoteDataSource>(
    () => CardRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<CardRepository>(
    () => CardRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetCardsUseCase(sl()));
  sl.registerLazySingleton(() => CreateCardUseCase(sl()));
  sl.registerLazySingleton(() => CreateCardsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCardUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCardUseCase(sl()));

  // Cubit
  sl.registerFactory(
    () => CardCubit(
      getCardsUseCase: sl(),
      createCardUseCase: sl(),
      createCardsUseCase: sl(),
      updateCardUseCase: sl(),
      deleteCardUseCase: sl(),
    ),
  );

  // ===== Study Feature =====

  // Data sources
  sl.registerLazySingleton<StudyRemoteDataSource>(
    () => StudyRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<StudyRepository>(
    () => StudyRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetDueCardsUseCase(sl()));
  sl.registerLazySingleton(() => ReviewCardUseCase(sl()));

  // Cubit
  sl.registerFactory(
    () => StudyCubit(
      getDueCardsUseCase: sl(),
      reviewCardUseCase: sl(),
    ),
  );

  // ===== Stats Feature =====

  // Data sources
  sl.registerLazySingleton<StatsRemoteDataSource>(
    () => StatsRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<StatsRepository>(
    () => StatsRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetLeaderboardUseCase(sl()));
  sl.registerLazySingleton(() => GetUserStatsUseCase(sl()));
  sl.registerLazySingleton(() => GetWeeklyProgressUseCase(sl()));
  sl.registerLazySingleton(() => GetActivityHeatmapUseCase(sl()));
  sl.registerLazySingleton(() => GetTopDecksUseCase(sl()));
  sl.registerLazySingleton(() => GetAchievementsUseCase(sl()));

  // Cubit
  sl.registerFactory(
    () => StatsCubit(
      getLeaderboardUseCase: sl(),
      getUserStatsUseCase: sl(),
      getWeeklyProgressUseCase: sl(),
      getActivityHeatmapUseCase: sl(),
      getTopDecksUseCase: sl(),
      getAchievementsUseCase: sl(),
    ),
  );

  // ===== OCR Feature =====

  // Service (no repository needed - direct API call)
  sl.registerLazySingleton<OcrService>(
    () => OcrService(sl()),
  );

  // Cubit
  sl.registerFactory(
    () => OcrCubit(sl()),
  );

  // ===== TTS Service =====
  sl.registerLazySingleton<TtsService>(
    () => TtsService(),
  );
}

/// Setup refresh token callback after all dependencies are registered
void _setupRefreshTokenCallback() {
  final apiClient = sl<DioApiClient>();
  final authRepo = sl<AuthRepository>();

  apiClient.onRefreshToken = () async {
    final result = await authRepo.refreshToken();

    return result.fold(
      (error) {
        if (kDebugMode) {
          print(' Refresh token failed: $error');
        }
        sl<NavigationService>().navigateToLogin();
        return false; // Refresh failed
      },
      (response) => true, // Refresh success
    );
  };
}

/// Reset all dependencies (useful for testing)
Future<void> resetDependencies() async {
  await sl.reset();
}
