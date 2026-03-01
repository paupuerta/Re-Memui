import 'package:flutter_test/flutter_test.dart';
import 'package:re_mem_ui/features/statistics/domain/entities/deck_stats.dart';

void main() {
  group('DeckStats entity', () {
    test('should create a DeckStats with required fields', () {
      const stats = DeckStats(
        deckId: 'deck-1',
        deckName: 'Spanish Vocabulary',
        totalCards: 50,
        totalReviews: 200,
        correctReviews: 160,
        daysStudied: 10,
        accuracyPercentage: 80.0,
      );

      expect(stats.deckId, 'deck-1');
      expect(stats.deckName, 'Spanish Vocabulary');
      expect(stats.totalCards, 50);
      expect(stats.totalReviews, 200);
      expect(stats.correctReviews, 160);
      expect(stats.daysStudied, 10);
      expect(stats.accuracyPercentage, 80.0);
      expect(stats.lastActiveDate, isNull);
    });

    test('hasActivity returns true when totalReviews > 0', () {
      const stats = DeckStats(
        deckId: 'deck-1',
        deckName: 'Math',
        totalCards: 10,
        totalReviews: 3,
        correctReviews: 2,
        daysStudied: 1,
        accuracyPercentage: 66.0,
      );
      expect(stats.hasActivity, isTrue);
    });

    test('hasActivity returns false when totalReviews == 0', () {
      const stats = DeckStats(
        deckId: 'deck-1',
        deckName: 'Empty Deck',
        totalCards: 0,
        totalReviews: 0,
        correctReviews: 0,
        daysStudied: 0,
        accuracyPercentage: 0.0,
      );
      expect(stats.hasActivity, isFalse);
    });

    test('formattedAccuracy returns percentage string', () {
      const stats = DeckStats(
        deckId: 'deck-1',
        deckName: 'Deck',
        totalCards: 20,
        totalReviews: 100,
        correctReviews: 92,
        daysStudied: 5,
        accuracyPercentage: 92.7,
      );
      expect(stats.formattedAccuracy, '93%');
    });

    test('should accept optional lastActiveDate', () {
      final date = DateTime(2024, 8, 1);
      final stats = DeckStats(
        deckId: 'deck-1',
        deckName: 'Science',
        totalCards: 30,
        totalReviews: 50,
        correctReviews: 40,
        daysStudied: 7,
        accuracyPercentage: 80.0,
        lastActiveDate: date,
      );
      expect(stats.lastActiveDate, date);
    });
  });
}
