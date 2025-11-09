import 'package:go_router/go_router.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/onboarding/presentation/onboarding_form_screen.dart';
import 'features/routine/presentation/routine_screen.dart';
import 'features/routine/presentation/routine_day_screen.dart';
import 'features/progress/presentation/progress_screen.dart';
import 'features/settings/presentation/profile_screen.dart';
import 'package:flutter/material.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingFormScreen()),
    GoRoute(path: '/', builder: (_, __) => const RoutineScreen()),
    GoRoute(path: '/progress', builder: (_, __) => const ProgressScreen()),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    GoRoute(
      path: '/day',
      builder: (context, state) {
        final extra = state.extra;
        if (extra is Map<String, dynamic>) {
          return RoutineDayScreen(day: extra);
        }
        return const Scaffold(body: Center(child: Text('Día no encontrado')));
      },
    ),
  ],
);
