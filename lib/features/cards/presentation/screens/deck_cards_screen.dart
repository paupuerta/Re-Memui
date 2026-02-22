import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:re_mem_ui/features/cards/domain/entities/card.dart' as domain;
import 'package:re_mem_ui/features/cards/domain/entities/deck.dart';
import 'package:re_mem_ui/features/cards/presentation/providers/card_providers.dart';
import 'package:re_mem_ui/features/cards/presentation/widgets/create_card_dialog.dart';
import 'package:re_mem_ui/features/cards/presentation/screens/review_card_screen.dart';

/// Screen to display cards in a specific deck
class DeckCardsScreen extends ConsumerStatefulWidget {
  const DeckCardsScreen({super.key, required this.deck});

  final Deck deck;

  @override
  ConsumerState<DeckCardsScreen> createState() => _DeckCardsScreenState();
}

class _DeckCardsScreenState extends ConsumerState<DeckCardsScreen> {
  List<domain.Card> _cards = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final getCardsUseCase = ref.read(getCardsUseCaseProvider);
    final result = await getCardsUseCase(widget.deck.userId);

    result.fold(
      (error) {
        if (mounted) {
          setState(() {
            _errorMessage = error.toString();
            _isLoading = false;
          });
        }
      },
      (allCards) {
        // Filter cards for this deck
        final deckCards =
            allCards.where((card) => card.deckId == widget.deck.id).toList();
        if (mounted) {
          setState(() {
            _cards = deckCards;
            _isLoading = false;
          });
        }
      },
    );
  }

  Future<void> _showCreateCardDialog() async {
    final result = await showDialog<domain.Card>(
      context: context,
      builder: (context) => CreateCardDialog(
        userId: widget.deck.userId,
        deckId: widget.deck.id,
      ),
    );

    if (result != null) {
      _loadCards();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.deck.name),
            if (widget.deck.description != null)
              Text(
                widget.deck.description!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
              ),
          ],
        ),
        elevation: 0,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateCardDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Card'),
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
              onPressed: _loadCards,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_cards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_add_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No cards in this deck',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first card to start learning',
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
      onRefresh: _loadCards,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _cards.length,
        itemBuilder: (context, index) {
          final card = _cards[index];
          return _CardListItem(
            card: card,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReviewCardScreen(
                    card: card,
                    userId: card.userId,
                    cards: _cards,
                    currentIndex: index,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CardListItem extends StatelessWidget {
  const _CardListItem({required this.card, required this.onTap});

  final domain.Card card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.question_answer,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      card.question,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      card.answer,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
