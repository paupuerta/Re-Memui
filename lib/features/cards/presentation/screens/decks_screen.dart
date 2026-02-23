import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:re_mem_ui/features/cards/domain/entities/deck.dart';
import 'package:re_mem_ui/features/cards/presentation/providers/deck_providers.dart';
import 'package:re_mem_ui/features/cards/presentation/widgets/create_deck_dialog.dart';
import 'package:re_mem_ui/features/cards/presentation/screens/deck_cards_screen.dart';
import 'package:re_mem_ui/features/statistics/presentation/providers/statistics_providers.dart';
import 'package:re_mem_ui/features/statistics/domain/entities/deck_stats.dart';

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
          return _DeckCard(
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

class _DeckCard extends ConsumerStatefulWidget {
  const _DeckCard({required this.deck, required this.onTap});

  final Deck deck;
  final VoidCallback onTap;

  @override
  ConsumerState<_DeckCard> createState() => _DeckCardState();
}

class _DeckCardState extends ConsumerState<_DeckCard> {
  DeckStats? _stats;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final getDeckStats = ref.read(getDeckStatsUseCaseProvider);
      final stats = await getDeckStats(widget.deck.id);
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
    }
  }

  Future<void> _deleteDeck(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Deck'),
        content: Text(
          'Are you sure you want to delete "${widget.deck.name}"?\n\nCards in this deck will not be deleted, they will be moved to "No Deck".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final userId = 'ae87b4cc-5a57-471b-9740-837f3440db6c';
    final deleteDeck = ref.read(deleteDeckUseCaseProvider);

    final result = await deleteDeck(userId: userId, deckId: widget.deck.id);

    result.fold(
      (failure) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete deck: $failure'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Deck "${widget.deck.name}" deleted'),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.deck.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.delete,
          color: Theme.of(context).colorScheme.onError,
        ),
      ),
      confirmDismiss: (direction) => _deleteDeck(context, ref).then((_) => true),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.style,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.deck.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      onPressed: () => _deleteDeck(context, ref),
                      tooltip: 'Delete deck',
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                    ),
                  ],
                ),
                if (widget.deck.description != null && widget.deck.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.deck.description!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                  ),
                ],
                const SizedBox(height: 12),
                if (_isLoadingStats)
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (_stats != null)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildStatChip(
                        Icons.style,
                        '${_stats!.totalCards} cards',
                        Colors.blue,
                        context,
                      ),
                      if (_stats!.hasActivity) ...[
                        _buildStatChip(
                          Icons.quiz,
                          '${_stats!.totalReviews} reviews',
                          Colors.grey,
                          context,
                        ),
                        _buildStatChip(
                          Icons.trending_up,
                          _stats!.formattedAccuracy,
                          _getAccuracyColor(_stats!.accuracyPercentage),
                          context,
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color, BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label),
      labelStyle: const TextStyle(fontSize: 12),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 80) return Colors.green;
    if (accuracy >= 60) return Colors.orange;
    return Colors.red;
  }
}

