import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindspark/core/di/injection_container.dart';
import 'package:mindspark/features/card/presentation/cubit/card_cubit.dart';
import 'package:mindspark/features/deck/presentation/cubit/deck_cubit.dart';
import 'package:mindspark/features/ocr/presentation/cubit/ocr_cubit.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/profile_screen.dart';
import '../features/auth/presentation/screens/settings_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/deck/presentation/screens/deck_detail_screen.dart';
import '../features/card/presentation/screens/create_card_screen.dart';
import '../features/card/presentation/screens/ocr_result_screen.dart';
import '../features/study/presentation/screens/study_screen.dart';
import '../features/statistics/presentation/statistics_screen.dart';
import '../features/splash/splash_screen.dart';

class AppRouter {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/';
  static const String deckDetail = '/deck-detail';
  static const String createCard = '/create-card';
  static const String study = '/study';
  static const String ocrResult = '/ocr-result';
  static const String statistics = '/statistics';
  static const String profile = '/profile';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case deckDetail:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: sl<DeckCubit>(),
            child: const DeckDetailScreen(),
          ),
          settings: settings,
        );
      case createCard:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: sl<CardCubit>(),
            child: const CreateCardScreen(),
          ),
          settings: settings, // CRITICAL: Truyền settings để nhận arguments
        );
      case study:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: sl<CardCubit>(),
            child: const StudyScreen(),
          ),
          settings: settings,
        );
      case ocrResult:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              // Cung cấp OcrCubit để xử lý ảnh OCR
              BlocProvider(create: (_) => sl<OcrCubit>()),
              // Cung cấp CardCubit để thực hiện lưu thẻ (CreateCards)
              BlocProvider.value(value: sl<CardCubit>()),
              // Cung cấp DeckCubit để lấy danh sách bộ thẻ hiện có cho Dropdown
              BlocProvider.value(value: sl<DeckCubit>()),
            ],
            child: const OcrResultScreen(),
          ),
          settings: settings, // Rất quan trọng để nhận arguments
        );
      case AppRouter.statistics:
        return MaterialPageRoute(builder: (_) => const StatisticsScreen());
      case AppRouter.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case AppRouter.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
