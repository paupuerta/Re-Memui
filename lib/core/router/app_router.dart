import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:re_mem_ui/core/auth/auth_notifier.dart';
import 'package:re_mem_ui/core/auth/auth_state.dart';
import 'package:re_mem_ui/features/auth/presentation/screens/register_screen.dart';
import 'package:re_mem_ui/features/auth/presentation/screens/login_screen.dart';
import 'package:re_mem_ui/features/cards/presentation/models/review_session_config.dart';
import 'package:re_mem_ui/features/cards/presentation/screens/review_card_screen.dart';
import 'package:re_mem_ui/features/home/presentation/home_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authValue = authState.asData?.value;
      final isAuthenticated = authValue is AuthAuthenticated;
      final isLoading = authState.isLoading || authValue is AuthLoading;
      final onAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (isLoading) return null;
      if (!isAuthenticated && !onAuthRoute) return '/login';
      if (isAuthenticated && onAuthRoute) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/review',
        name: 'review',
        builder: (context, state) {
          return ReviewCardScreen(session: state.extra! as ReviewSessionConfig);
        },
      ),
    ],
  );
});
