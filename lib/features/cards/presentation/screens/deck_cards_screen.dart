import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
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

  Future<void> _importTsv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['tsv', 'txt'],
      withData: true,
    );
    if (result == null) return;

    final file = result.files.single;
    final filePath = kIsWeb ? null : file.path;
    if (filePath == null && file.bytes == null) {
      if (!mounted) return;
      _showErrorSnackBar('Could not read the selected file');
      return;
    }

    if (!mounted) return;

    _showLoadingDialog('Importing TSV…');

    final useCase = ref.read(importTsvUseCaseProvider);
    final importResult = await useCase(
      deckId: widget.deck.id,
      filePath: filePath,
      fileBytes: file.bytes,
      fileName: file.name,
    );

    if (!mounted) return;
    Navigator.of(context).pop(); // close loading dialog

    importResult.fold(
      (failure) => _showErrorSnackBar('Import failed: $failure'),
      (res) {
        _loadCards();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${res.cardsImported} cards imported'
              '${res.cardsSkipped > 0 ? ', ${res.cardsSkipped} skipped' : ''}',
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }

  Future<void> _importAnki() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['apkg'],
      withData: true,
    );
    if (result == null) return;

    final file = result.files.single;
    final filePath = kIsWeb ? null : file.path;
    if (filePath == null && file.bytes == null) {
      if (!mounted) return;
      _showErrorSnackBar('Could not read the selected file');
      return;
    }

    if (!mounted) return;

    _showLoadingDialog('Importing Anki deck…');

    final useCase = ref.read(importAnkiUseCaseProvider);
    final importResult = await useCase(
      filePath: filePath,
      fileBytes: file.bytes,
      fileName: file.name,
    );

    if (!mounted) return;
    Navigator.of(context).pop(); // close loading dialog

    importResult.fold(
      (failure) => _showErrorSnackBar('Import failed: $failure'),
      (res) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '"${res.deckName}": ${res.cardsImported} cards imported'
              '${res.cardsSkipped > 0 ? ', ${res.cardsSkipped} skipped' : ''}',
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }

  void _showLoadingDialog(String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
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
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Import cards',
            icon: const Icon(Icons.upload_file),
            onSelected: (value) {
              if (value == 'tsv') _importTsv();
              if (value == 'anki') _importAnki();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'tsv',
                child: ListTile(
                  leading: Icon(Icons.table_rows),
                  title: Text('Import TSV'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'anki',
                child: ListTile(
                  leading: Icon(Icons.archive),
                  title: Text('Import Anki (.apkg)'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
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
            onDeleted: _loadCards,
          );
        },
      ),
    );
  }
}

class _CardListItem extends ConsumerWidget {
  const _CardListItem({required this.card, required this.onTap, required this.onDeleted});

  final domain.Card card;
  final VoidCallback onTap;
  final VoidCallback onDeleted;

  Future<void> _deleteCard(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Card'),
        content: Text('Are you sure you want to delete this card?\n\n"${card.question}"'),
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

    final deleteCard = ref.read(deleteCardUseCaseProvider);

    final result = await deleteCard(userId: card.userId, cardId: card.id);

    result.fold(
      (failure) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete card: $failure'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      (_) {
        onDeleted();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Card deleted'),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(card.id),
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
      confirmDismiss: (direction) => _deleteCard(context, ref).then((_) => true),
      child: Card(
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
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      onPressed: () => _deleteCard(context, ref),
                      tooltip: 'Delete card',
                      iconSize: 20,
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
    ),
    );
  }
}
