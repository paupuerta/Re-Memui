import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:re_mem_ui/features/cards/presentation/providers/card_providers.dart';
import 'package:re_mem_ui/features/cards/presentation/screens/decks_screen.dart';

// TODO: replace with authenticated user ID once auth is implemented
const _testUserId = 'ae87b4cc-5a57-471b-9740-837f3440db6c';

/// Async provider that loads all cards for the current user.
final _userCardsProvider = FutureProvider.autoDispose((ref) async {
  final useCase = ref.watch(getCardsUseCaseProvider);
  final result = await useCase(_testUserId);
  return result.fold(
    (failure) => throw failure,
    (cards) => cards,
  );
});

/// Home screen – entry point for the app.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(_userCardsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ReMem'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.style),
            tooltip: 'My Decks',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DecksScreen(userId: _testUserId),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to ReMem',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your language learning companion',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            cardsAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (err, _) => Column(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load cards',
                    style: TextStyle(color: Colors.red[700]),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => ref.invalidate(_userCardsProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
              data: (cards) => Column(
                children: [
                  Text(
                    '${cards.length} card${cards.length == 1 ? '' : 's'} ready',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: cards.isEmpty
                        ? null
                        : () {
                            context.pushNamed(
                              'review',
                              extra: {
                                'cards': cards,
                                'index': 0,
                                'userId': _testUserId,
                              },
                            );
                          },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Review'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const DecksScreen(userId: _testUserId),
                        ),
                      );
                    },
                    icon: const Icon(Icons.style),
                    label: const Text('Manage Decks'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
