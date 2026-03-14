import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:re_mem_ui/features/cards/domain/entities/deck.dart';
import 'package:re_mem_ui/features/cards/presentation/providers/deck_providers.dart';
import 'package:re_mem_ui/features/cards/presentation/screens/deck_cards_screen.dart';
import 'package:re_mem_ui/features/cards/presentation/widgets/create_deck_dialog.dart';
import 'package:re_mem_ui/features/cards/presentation/widgets/deck_card.dart';

/// Screen to display and manage user's decks
class DecksScreen extends ConsumerStatefulWidget {
  const DecksScreen({super.key, required this.userId});

  final String userId;

  @override
  ConsumerState<DecksScreen> createState() => _DecksScreenState();
}

class _DecksScreenState extends ConsumerState<DecksScreen> {
  List<Deck> _decks = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDecks();
  }

  Future<void> _loadDecks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final getDecksUseCase = ref.read(getDecksUseCaseProvider);
    final result = await getDecksUseCase(widget.userId);

    result.fold(
      (error) {
        if (mounted) {
          setState(() {
            _errorMessage = error;
            _isLoading = false;
          });
        }
      },
      (decks) {
        if (mounted) {
          setState(() {
            _decks = decks;
            _isLoading = false;
          });
        }
      },
    );
  }

  Future<void> _showCreateDeckDialog() async {
    final result = await showDialog<Deck>(
      context: context,
      builder: (context) => CreateDeckDialog(userId: widget.userId),
    );

    if (result != null) {
      _loadDecks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Decks'),
        elevation: 0,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDeckDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Deck'),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadDecks,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_decks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.style_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No decks yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first deck to organize your cards',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDecks,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _decks.length,
        itemBuilder: (context, index) {
          final deck = _decks[index];
          return DeckCard(
            deck: deck,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DeckCardsScreen(deck: deck),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

