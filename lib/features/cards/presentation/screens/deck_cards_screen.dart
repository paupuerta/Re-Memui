import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:re_mem_ui/features/cards/domain/entities/card.dart' as domain;
import 'package:re_mem_ui/features/cards/domain/entities/deck.dart';
import 'package:re_mem_ui/features/cards/presentation/models/review_session_config.dart';
import 'package:re_mem_ui/features/cards/presentation/providers/card_providers.dart';
import 'package:re_mem_ui/features/cards/presentation/screens/review_card_screen.dart';
import 'package:re_mem_ui/features/cards/presentation/widgets/card_list_item.dart';
import 'package:re_mem_ui/features/cards/presentation/widgets/create_card_dialog.dart';

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
    final result = await getCardsUseCase(
      widget.deck.userId,
      deckId: widget.deck.id,
    );

    result.fold(
      (error) {
        if (mounted) {
          setState(() {
            _errorMessage = error.toString();
            _isLoading = false;
          });
        }
      },
      (deckCards) {
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
      builder: (context) =>
          CreateCardDialog(userId: widget.deck.userId, deckId: widget.deck.id),
    );

    if (result != null) {
      await _loadCards();
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
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
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
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.5),
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
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
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
          return CardListItem(
            card: card,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReviewCardScreen(
                    session: ReviewSessionConfig(
                      userId: card.userId,
                      deckId: widget.deck.id,
                      deckName: widget.deck.name,
                      initialCards: _cards,
                      startIndex: index,
                      incrementalLoading: false,
                    ),
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
