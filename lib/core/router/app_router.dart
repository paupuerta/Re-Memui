import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:re_mem_ui/core/auth/auth_notifier.dart';
import 'package:re_mem_ui/core/auth/auth_state.dart';
import 'package:re_mem_ui/features/auth/presentation/screens/login_screen.dart';
import 'package:re_mem_ui/features/auth/presentation/screens/register_screen.dart';
import 'package:re_mem_ui/features/cards/domain/entities/card.dart' as entities;
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
          state.matchedLocation == '/login' || state.matchedLocation == '/register';

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
          final extra = state.extra as Map<String, dynamic>;
          final cards = extra['cards'] as List<entities.Card>? ?? [extra['card'] as entities.Card];
          final index = extra['index'] as int? ?? 0;
          return ReviewCardScreen(
            card: cards[index],
            userId: extra['userId'] as String,
            cards: cards,
            currentIndex: index,
          );
        },
      ),
    ],
  );
});
