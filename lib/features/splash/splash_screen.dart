import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth/presentation/cubit/auth_cubit.dart';
import '../auth/presentation/cubit/auth_state.dart';
import '../../routes/app_router.dart';

/// Splash Screen - Check authentication on app startup
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Check authentication when app starts
    context.read<AuthCubit>().checkAuthentication();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated || state is ProfileLoaded) {
          // User is authenticated - go to dashboard
          Navigator.pushReplacementNamed(context, AppRouter.dashboard);
        } else if (state is AuthUnauthenticated) {
          // User is not authenticated - go to onboarding
          Navigator.pushReplacementNamed(context, AppRouter.onboarding);
        }
        // AuthLoading and AuthError stay on splash screen
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo
              Icon(
                Icons.bolt,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 24),
              const Text(
                'MindSpark',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              // Loading indicator
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
