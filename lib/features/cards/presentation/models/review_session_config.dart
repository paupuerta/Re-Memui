import 'package:re_mem_ui/features/cards/domain/entities/card.dart' as entities;

/// Configures how a review session should be started.
class ReviewSessionConfig {
  const ReviewSessionConfig({
    required this.userId,
    this.deckId,
    this.deckName,
    this.initialCards = const [],
    this.startIndex = 0,
    this.batchSize = 5,
    this.prefetchThreshold = 2,
    this.incrementalLoading = true,
  });

  final String userId;
  final String? deckId;
  final String? deckName;
  final List<entities.Card> initialCards;
  final int startIndex;
  final int batchSize;
  final int prefetchThreshold;
  final bool incrementalLoading;
}
