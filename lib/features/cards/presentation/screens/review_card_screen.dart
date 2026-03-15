import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:re_mem_ui/core/services/audio_providers.dart';
import 'package:re_mem_ui/core/services/language_detection.dart';
import 'package:re_mem_ui/features/cards/domain/entities/card.dart' as entities;
import 'package:re_mem_ui/features/cards/presentation/models/review_session_config.dart';
import 'package:re_mem_ui/features/cards/presentation/providers/card_providers.dart';
import 'package:re_mem_ui/features/cards/presentation/widgets/flashcard_widget.dart';

/// Screen for reviewing flashcards with AI-powered answer validation.
class ReviewCardScreen extends ConsumerStatefulWidget {
  const ReviewCardScreen({required this.session, super.key});

  final ReviewSessionConfig session;

  @override
  ConsumerState<ReviewCardScreen> createState() => _ReviewCardScreenState();
}

class _ReviewCardScreenState extends ConsumerState<ReviewCardScreen> {
  final _answerController = TextEditingController();
  final _answerFocusNode = FocusNode(debugLabel: 'review-answer');
  final _reviewFocusNode = FocusNode(debugLabel: 'review-shortcuts');
  final List<entities.Card> _cards = [];

  bool _isSubmitting = false;
  bool _showResult = false;
  bool _isListening = false;
  bool _isInitializing = true;
  bool _isLoadingMore = false;
  bool _canLoadMore = false;
  bool _isAnswerRevealed = false;

  int _currentIndex = 0;

  String? _resultMessage;
  String? _loadError;

  entities.Card get _currentCard => _cards[_currentIndex];

  bool get _hasLoadedCard => _cards.isNotEmpty;

  bool get _hasNextLoadedCard => _currentIndex < _cards.length - 1;

  bool get _hasMoreSessionCards =>
      _hasNextLoadedCard || _canLoadMore || _isLoadingMore;

  @override
  void initState() {
    super.initState();

    _cards.addAll(widget.session.initialCards);
    _canLoadMore =
        widget.session.incrementalLoading &&
        (_cards.isEmpty || _cards.length >= widget.session.batchSize);
    _currentIndex = _cards.isEmpty
        ? 0
        : (widget.session.startIndex < _cards.length
              ? widget.session.startIndex
              : _cards.length - 1);

    unawaited(_initializeSession());
  }

  @override
  void dispose() {
    _answerController.dispose();
    _answerFocusNode.dispose();
    _reviewFocusNode.dispose();
    ref.read(sttServiceProvider).stopListening();
    super.dispose();
  }

  Future<void> _initializeSession() async {
    if (_cards.isEmpty) {
      await _loadMoreCards(initialLoad: true);
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isInitializing = false;
    });
    _requestAnswerFocus();
    _maybePrefetchCards();
  }

  Future<void> _loadMoreCards({bool initialLoad = false}) async {
    if (_isLoadingMore || (!_canLoadMore && !initialLoad)) {
      return;
    }

    if (mounted) {
      setState(() {
        if (initialLoad) {
          _isInitializing = true;
          _loadError = null;
        }
        _isLoadingMore = true;
      });
    }

    final useCase = ref.read(getCardsUseCaseProvider);
    final result = await useCase(
      widget.session.userId,
      deckId: widget.session.deckId,
      limit: widget.session.batchSize,
      excludeCardIds: _cards.map((card) => card.id).toList(),
    );

    if (!mounted) {
      return;
    }

    result.fold(
      (failure) {
        setState(() {
          _isInitializing = false;
          _isLoadingMore = false;
          if (_cards.isEmpty) {
            _loadError = failure.message;
          }
        });

        if (_cards.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load more cards: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      (cards) {
        setState(() {
          _cards.addAll(cards);
          _canLoadMore = cards.length == widget.session.batchSize;
          _isInitializing = false;
          _isLoadingMore = false;
          _loadError = null;
        });
        if (initialLoad && !_showResult) {
          _requestAnswerFocus();
        }
      },
    );
  }

  void _maybePrefetchCards() {
    if (!_canLoadMore || _isLoadingMore || !_hasLoadedCard) {
      return;
    }

    final remainingCards = _cards.length - (_currentIndex + 1);
    if (remainingCards <= widget.session.prefetchThreshold) {
      unawaited(_loadMoreCards());
    }
  }

  Future<void> _advanceToNextCard() async {
    if (_hasNextLoadedCard) {
      _moveToCard(_currentIndex + 1);
      return;
    }

    if (_canLoadMore) {
      await _loadMoreCards();
      if (!mounted) {
        return;
      }

      if (_hasNextLoadedCard) {
        _moveToCard(_currentIndex + 1);
        return;
      }
    }

    if (mounted) {
      context.pop();
    }
  }

  void _moveToCard(int index) {
    ref.read(sttServiceProvider).stopListening();

    setState(() {
      _currentIndex = index;
      _isListening = false;
      _showResult = false;
      _resultMessage = null;
      _isAnswerRevealed = false;
      _answerController.clear();
    });

    _requestAnswerFocus();
    _maybePrefetchCards();
  }

  void _requestReviewFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _reviewFocusNode.requestFocus();
      }
    });
  }

  void _requestAnswerFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_showResult) {
        _answerFocusNode.requestFocus();
      }
    });
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    if (_showResult) {
      if (event.logicalKey == LogicalKeyboardKey.keyN &&
          !(_isLoadingMore && !_hasNextLoadedCard)) {
        unawaited(_advanceToNextCard());
        return KeyEventResult.handled;
      }

      if (event.logicalKey == LogicalKeyboardKey.keyR) {
        setState(() {
          _showResult = false;
          _isAnswerRevealed = false;
          _answerController.clear();
        });
        _requestAnswerFocus();
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  Future<void> _toggleListening() async {
    final stt = ref.read(sttServiceProvider);

    if (_isListening) {
      await stt.stopListening();
      setState(() => _isListening = false);
      return;
    }

    if (!kIsWeb) {
      final micStatus = await Permission.microphone.request();
      if (micStatus.isPermanentlyDenied) {
        if (!mounted) return;
        await showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Microphone Access Required'),
            content: const Text(
              'Please enable microphone access in your device Settings to use voice dictation.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  openAppSettings();
                  Navigator.of(context).pop();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
        return;
      }
      if (!micStatus.isGranted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is required')),
        );
        return;
      }
    }

    final initialized = await stt.initialize();
    if (!initialized) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speech recognition not available on this device'),
        ),
      );
      return;
    }

    setState(() => _isListening = true);
    final answerLocale = detectLanguageFromText(_currentCard.answer);
    await stt.startListening(
      localeId: answerLocale,
      onResult: (text) {
        _answerController.text = text;
        _answerController.selection = TextSelection.fromPosition(
          TextPosition(offset: text.length),
        );
      },
      onDone: () {
        if (mounted) setState(() => _isListening = false);
      },
      onError: (errorMsg) {
        if (!mounted) return;
        setState(() => _isListening = false);
        final hint = errorMsg == 'not-allowed'
            ? 'Microphone access denied — please allow it in your browser.'
            : 'Speech recognition error: $errorMsg';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(hint)));
      },
    );
  }

  Future<void> _submitAnswer() async {
    if (_answerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your answer')));
      return;
    }

    setState(() {
      _isSubmitting = true;
      _resultMessage = null;
    });

    final useCase = ref.read(submitReviewUseCaseProvider);
    final result = await useCase(
      cardId: _currentCard.id,
      userId: widget.session.userId,
      userAnswer: _answerController.text.trim(),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isSubmitting = false;
          _resultMessage = 'Error: ${failure.message}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_resultMessage!), backgroundColor: Colors.red),
        );
      },
      (reviewResult) {
        final scorePercent = (reviewResult.aiScore * 100).toStringAsFixed(0);
        final ratingText = _getRatingText(reviewResult.fsrsRating);

        setState(() {
          _isSubmitting = false;
          _showResult = true;
          _isAnswerRevealed = true;
          _resultMessage =
              '''
AI Score: $scorePercent%
Rating: $ratingText
Method: ${reviewResult.validationMethod}
Next review in: ${reviewResult.nextReviewInDays} days
''';
        });
        _requestReviewFocus();
        _maybePrefetchCards();
      },
    );
  }

  String _getRatingText(int rating) {
    return switch (rating) {
      4 => 'Easy',
      3 => 'Good',
      2 => 'Hard',
      1 => 'Again',
      _ => 'Unknown',
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.session.deckName ?? 'Review Cards'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null && !_hasLoadedCard) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.session.deckName ?? 'Review Cards'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(_loadError!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => _loadMoreCards(initialLoad: true),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_hasLoadedCard) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.session.deckName ?? 'Review Cards'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inbox_outlined, size: 48),
                const SizedBox(height: 16),
                Text(
                  widget.session.deckName == null
                      ? 'No cards are ready for review right now.'
                      : 'No cards are ready in "${widget.session.deckName}".',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final nextButtonLabel = _hasNextLoadedCard
        ? 'Next Card'
        : _canLoadMore
        ? 'Load Next Card'
        : 'Finish';

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter, shift: true): () {
          if (!_isSubmitting && !_showResult) {
            unawaited(_submitAnswer());
          }
        },
      },
      child: Focus(
        focusNode: _reviewFocusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.session.deckName ?? 'Review Cards'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _canLoadMore
                      ? 'Card ${_currentIndex + 1}+'
                      : 'Card ${_currentIndex + 1} of ${_cards.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FlashcardWidget(
                  question: _currentCard.question,
                  answer: _currentCard.answer,
                  revealed: _isAnswerRevealed,
                ),
                const SizedBox(height: 32),
                if (!_showResult) ...[
                  const Text(
                    'Your Answer:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _answerController,
                    focusNode: _answerFocusNode,
                    maxLines: 4,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: 'Type your answer here...',
                      helperText: 'Press Shift+Enter to submit your answer.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(bottom: 72),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: IconButton(
                            key: ValueKey(_isListening),
                            onPressed: _toggleListening,
                            icon: Icon(
                              _isListening ? Icons.mic : Icons.mic_none,
                              color: _isListening ? Colors.red : null,
                            ),
                            tooltip: _isListening
                                ? 'Stop listening'
                                : 'Dictate answer',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _isSubmitting ? null : _submitAnswer,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send),
                    label: Text(
                      _isSubmitting ? 'Validating...' : 'Submit Answer',
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
                if (_showResult && _resultMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green.shade700,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Review Complete!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _resultMessage!,
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _showResult = false;
                              _answerController.clear();
                            });
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again (R)'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _isLoadingMore && !_hasNextLoadedCard
                              ? null
                              : _advanceToNextCard,
                          icon: Icon(
                            _hasMoreSessionCards
                                ? Icons.arrow_forward
                                : Icons.check,
                          ),
                          label: Text('$nextButtonLabel (N)'),
                        ),
                      ),
                    ],
                  ),
                ],
                if (_isLoadingMore) ...[
                  const SizedBox(height: 16),
                  const LinearProgressIndicator(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
