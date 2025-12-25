import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/di/injection_container.dart';
import 'core/services/navigation_service.dart';
import 'routes/app_router.dart';

// Import all Cubits
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/deck/presentation/cubit/deck_cubit.dart';
import 'features/card/presentation/cubit/card_cubit.dart';
import 'features/study/presentation/cubit/study_cubit.dart';
import 'features/statistics/presentation/cubit/stats_cubit.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await initializeDependencies();

  runApp(const MindSparkApp());
}

class MindSparkApp extends StatelessWidget {
  const MindSparkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => sl<AuthCubit>(),
        ),
        BlocProvider<DeckCubit>(
          create: (context) => sl<DeckCubit>(),
        ),
        BlocProvider<CardCubit>(
          create: (context) => sl<CardCubit>(),
        ),
        BlocProvider<StudyCubit>(
          create: (context) => sl<StudyCubit>(),
        ),
        BlocProvider<StatsCubit>(
          create: (context) => sl<StatsCubit>(),
        ),
      ],
      child: MaterialApp(
        title: 'MindSpark',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        navigatorKey:
            sl<NavigationService>().navigatorKey, // Add global navigator key
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: AppRouter.splash, // Start with splash to check auth
      ),
    );
  }
}
