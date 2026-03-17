import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:re_mem_ui/core/services/audio_providers.dart';

/// A flashcard widget with flip animation and TTS speaker buttons.
/// Displays front (question) and back (answer) with smooth 3D flip effect.
class FlashcardWidget extends ConsumerStatefulWidget {
  const FlashcardWidget({
    required this.question,
    required this.answer,
    this.questionLocale,
    this.answerLocale,
    this.revealed = false,
    super.key,
  });

  final String question;
  final String answer;

  /// BCP-47 locale for TTS (e.g. 'es-ES'). Auto-detected from text when null.
  final String? questionLocale;

  /// BCP-47 locale for TTS (e.g. 'en-US'). Auto-detected from text when null.
  final String? answerLocale;
  final bool revealed;

  @override
  ConsumerState<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends ConsumerState<FlashcardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;
  bool _showingFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _flipAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_showingFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _showingFront = !_showingFront;
    });
  }

  void _syncRevealState(bool revealed) {
    if (revealed == _showingFront) {
      if (revealed) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      setState(() {
        _showingFront = !revealed;
      });
    }
  }

  @override
  void didUpdateWidget(covariant FlashcardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.revealed != widget.revealed) {
      _syncRevealState(widget.revealed);
      return;
    }

    if (oldWidget.question != widget.question ||
        oldWidget.answer != widget.answer) {
      _controller.value = 0;
      _showingFront = true;
      if (widget.revealed) {
        _syncRevealState(true);
      }
    }
  }

  Future<void> _speak(String text, String? locale) async {
    final tts = ref.read(ttsServiceProvider);
    try {
      await tts.speak(text, languageCode: locale);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Voice not available on this device')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final angle = _flipAnimation.value * math.pi;
          final isFront = angle < math.pi / 2;

          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            alignment: Alignment.center,
            child: isFront
                ? _buildCardFace(
                    widget.question,
                    'Question',
                    Colors.blue.shade700,
                    false,
                    () => _speak(widget.question, widget.questionLocale),
                  )
                : Transform(
                    transform: Matrix4.identity()..rotateY(math.pi),
                    alignment: Alignment.center,
                    child: _buildCardFace(
                      widget.answer,
                      'Answer',
                      Colors.green.shade700,
                      true,
                      () => _speak(widget.answer, widget.answerLocale),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildCardFace(
    String text,
    String label,
    Color color,
    bool isBack,
    VoidCallback onSpeak,
  ) {
    return Container(
      width: double.infinity,
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color, width: 2),
      ),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              if (!isBack)
                const Text(
                  'Tap to reveal answer',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              onPressed: onSpeak,
              icon: Icon(Icons.volume_up_rounded, color: color),
              tooltip: 'Listen to pronunciation',
            ),
          ),
        ],
      ),
    );
  }
}
