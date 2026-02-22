import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:re_mem_ui/features/cards/presentation/providers/card_providers.dart';

/// Dialog to create a new card
class CreateCardDialog extends ConsumerStatefulWidget {
  const CreateCardDialog({
    super.key,
    required this.userId,
    this.deckId,
  });

  final String userId;
  final String? deckId;

  @override
  ConsumerState<CreateCardDialog> createState() => _CreateCardDialogState();
}

class _CreateCardDialogState extends ConsumerState<CreateCardDialog> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _createCard() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final createCardUseCase = ref.read(createCardUseCaseProvider);
    final result = await createCardUseCase(
      userId: widget.userId,
      question: _questionController.text.trim(),
      answer: _answerController.text.trim(),
      deckId: widget.deckId,
    );

    if (!mounted) return;

    result.fold(
      (error) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating card: ${error.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      },
      (card) {
        Navigator.of(context).pop(card);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Card created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Card'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(
                  labelText: 'Question',
                  hintText: 'e.g., What is "hello" in Spanish?',
                  prefixIcon: Icon(Icons.help_outline),
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a question';
                  }
                  if (value.trim().length < 3) {
                    return 'Question must be at least 3 characters';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _answerController,
                decoration: const InputDecoration(
                  labelText: 'Answer',
                  hintText: 'e.g., hola',
                  prefixIcon: Icon(Icons.lightbulb_outline),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an answer';
                  }
                  if (value.trim().length < 1) {
                    return 'Answer must be at least 1 character';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
              if (widget.deckId != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Card will be added to the current deck',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _isLoading ? null : _createCard,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.add),
          label: const Text('Create'),
        ),
      ],
    );
  }
}
