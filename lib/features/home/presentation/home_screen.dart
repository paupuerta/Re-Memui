import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:re_mem_ui/core/auth/auth_notifier.dart';
import 'package:re_mem_ui/core/auth/auth_state.dart';
import 'package:re_mem_ui/features/cards/domain/entities/deck.dart';
import 'package:re_mem_ui/features/cards/presentation/models/review_session_config.dart';
import 'package:re_mem_ui/features/cards/presentation/screens/decks_screen.dart';
import 'package:re_mem_ui/features/cards/presentation/providers/deck_providers.dart';
import 'package:re_mem_ui/features/statistics/presentation/providers/statistics_providers.dart';
import 'package:re_mem_ui/features/statistics/presentation/screens/statistics_screen.dart';

/// Async provider that loads all decks for the current authenticated user.
final _userDecksProvider = FutureProvider.autoDispose
    .family<List<Deck>, String>((ref, userId) async {
      final useCase = ref.watch(getDecksUseCaseProvider);
      final result = await useCase(userId);
      return result.fold((failure) => throw failure, (decks) => decks);
    });

/// Home screen – entry point for the app.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const String _allDecksValue = '';

  String _selectedDeckId = _allDecksValue;

  @override
  Widget build(BuildContext context) {
    final authValue = ref.watch(authStateProvider).asData?.value;
    final userId = authValue is AuthAuthenticated ? authValue.userId : '';
    final decksAsync = ref.watch(_userDecksProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('ReMem'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Statistics',
            onPressed: () {
              final getUserStats = ref.read(getUserStatsUseCaseProvider);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StatisticsScreen(
                    getUserStats: getUserStats,
                    userId: userId,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.style),
            tooltip: 'My Decks',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DecksScreen(userId: userId),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) context.go('/login');
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
            decksAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (err, _) => Column(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load decks',
                    style: TextStyle(color: Colors.red[700]),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => ref.invalidate(_userDecksProvider(userId)),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
              data: (decks) => Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _selectedDeckId,
                    decoration: const InputDecoration(
                      labelText: 'Study deck',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: _allDecksValue,
                        child: Text('All decks'),
                      ),
                      ...decks.map(
                        (deck) => DropdownMenuItem(
                          value: deck.id,
                          child: Text(deck.name),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedDeckId = value ?? _allDecksValue;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _selectedDeckLabel(decks),
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: userId.isEmpty
                        ? null
                        : () {
                            final selectedDeck = _selectedDeck(decks);
                            context.pushNamed(
                              'review',
                              extra: ReviewSessionConfig(
                                userId: userId,
                                deckId: selectedDeck?.id,
                                deckName: selectedDeck?.name,
                              ),
                            );
                          },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Review'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DecksScreen(userId: userId),
                        ),
                      );
                    },
                    icon: const Icon(Icons.style),
                    label: const Text('Manage Decks'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
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

  String _selectedDeckLabel(List<Deck> decks) {
    if (_selectedDeckId == _allDecksValue) {
      return decks.isEmpty
          ? 'Study all available cards. Sessions load cards in batches of 5.'
          : 'Study across all decks. Sessions load cards in batches of 5.';
    }

    final selectedDeck = _selectedDeck(decks);
    if (selectedDeck == null) {
      return 'Study across all decks. Sessions load cards in batches of 5.';
    }

    return 'Study only "${selectedDeck.name}". Sessions load cards in batches of 5.';
  }

  Deck? _selectedDeck(List<Deck> decks) {
    for (final deck in decks) {
      if (deck.id == _selectedDeckId) {
        return deck;
      }
    }
    return null;
  }
}
