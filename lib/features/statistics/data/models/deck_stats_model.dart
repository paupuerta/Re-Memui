import '../../domain/entities/deck_stats.dart';

/// Deck statistics data model
class DeckStatsModel {
  final String deckId;
  final String deckName;
  final int totalCards;
  final int totalReviews;
  final int correctReviews;
  final int daysStudied;
  final double accuracyPercentage;
  final String? lastActiveDate;

  const DeckStatsModel({
    required this.deckId,
    required this.deckName,
    required this.totalCards,
    required this.totalReviews,
    required this.correctReviews,
    required this.daysStudied,
    required this.accuracyPercentage,
    this.lastActiveDate,
  });

  /// Create from JSON
  factory DeckStatsModel.fromJson(Map<String, dynamic> json) {
    return DeckStatsModel(
      deckId: json['deck_id'] as String,
      deckName: json['deck_name'] as String,
      totalCards: json['total_cards'] as int,
      totalReviews: json['total_reviews'] as int,
      correctReviews: json['correct_reviews'] as int,
      daysStudied: json['days_studied'] as int,
      accuracyPercentage: (json['accuracy_percentage'] as num).toDouble(),
      lastActiveDate: json['last_active_date'] as String?,
    );
  }

  /// Convert to entity
  DeckStats toEntity() {
    return DeckStats(
      deckId: deckId,
      deckName: deckName,
      totalCards: totalCards,
      totalReviews: totalReviews,
      correctReviews: correctReviews,
      daysStudied: daysStudied,
      accuracyPercentage: accuracyPercentage,
      lastActiveDate: lastActiveDate != null 
          ? DateTime.parse(lastActiveDate!) 
          : null,
    );
  }
}
