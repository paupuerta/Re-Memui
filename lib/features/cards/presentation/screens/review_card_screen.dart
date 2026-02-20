import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:re_mem_ui/features/cards/domain/entities/card.dart'
    as entities;
import 'package:re_mem_ui/features/cards/presentation/providers/card_providers.dart';
import 'package:re_mem_ui/features/cards/presentation/widgets/flashcard_widget.dart';

/// Screen for reviewing a flashcard with AI-powered answer validation.
class ReviewCardScreen extends ConsumerStatefulWidget {
  const ReviewCardScreen({
    required this.card,
    required this.userId,
    super.key,
  });

  final entities.Card card;
  final String userId;

  @override
  ConsumerState<ReviewCardScreen> createState() => _ReviewCardScreenState();
}

class _ReviewCardScreenState extends ConsumerState<ReviewCardScreen> {
  final _answerController = TextEditingController();
  bool _isSubmitting = false;
  String? _resultMessage;
  bool _showResult = false;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _submitAnswer() async {
    if (_answerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your answer')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _resultMessage = null;
    });

    final useCase = ref.read(submitReviewUseCaseProvider);
    final result = await useCase(
      cardId: widget.card.id,
      userId: widget.userId,
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
          SnackBar(
            content: Text(_resultMessage!),
            backgroundColor: Colors.red,
          ),
        );
      },
      (reviewResult) {
        final scorePercent = (reviewResult.aiScore * 100).toStringAsFixed(0);
        final ratingText = _getRatingText(reviewResult.fsrsRating);
        
        setState(() {
          _isSubmitting = false;
          _showResult = true;
          _resultMessage = '''
AI Score: $scorePercent%
Rating: $ratingText
Method: ${reviewResult.validationMethod}
Next review in: ${reviewResult.nextReviewInDays} days
''';
        });
      },
    );
  }

  String _getRatingText(int rating) {
    return switch (rating) {
      4 => 'Easy ✨',
      3 => 'Good ✓',
      2 => 'Hard 💪',
      1 => 'Again 🔄',
      _ => 'Unknown',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Card'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Flashcard with flip animation
            FlashcardWidget(
              question: widget.card.question,
              answer: widget.card.answer,
            ),
            const SizedBox(height: 32),

            // Answer input section
            if (!_showResult) ...[
              const Text(
                'Your Answer:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _answerController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Type your answer here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 24),

              // Submit button
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
                label: Text(_isSubmitting ? 'Validating...' : 'Submit Answer'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],

            // Result display
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
                        Icon(Icons.check_circle, color: Colors.green.shade700),
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
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Actions after review
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
                      label: const Text('Try Again'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
