/// Deck statistics entity
class DeckStats {
  final String deckId;
  final String deckName;
  final int totalCards;
  final int totalReviews;
  final int correctReviews;
  final int daysStudied;
  final double accuracyPercentage;
  final DateTime? lastActiveDate;

  const DeckStats({
    required this.deckId,
    required this.deckName,
    required this.totalCards,
    required this.totalReviews,
    required this.correctReviews,
    required this.daysStudied,
    required this.accuracyPercentage,
    this.lastActiveDate,
  });

  /// Returns true if the deck has any review activity
  bool get hasActivity => totalReviews > 0;

  /// Returns a formatted accuracy string (e.g., "85%")
  String get formattedAccuracy => '${accuracyPercentage.toStringAsFixed(0)}%';
}
