import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/cards/domain/entities/card.dart' as entities;
import '../../features/cards/presentation/screens/review_card_screen.dart';
import '../../features/home/presentation/home_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
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
