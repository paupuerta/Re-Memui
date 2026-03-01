import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:re_mem_ui/features/statistics/domain/entities/deck_stats.dart';
import 'package:re_mem_ui/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:re_mem_ui/features/statistics/domain/use_cases/get_deck_stats.dart';

class MockStatisticsRepository extends Mock implements StatisticsRepository {}

void main() {
  late GetDeckStats useCase;
  late MockStatisticsRepository mockRepository;

  setUp(() {
    mockRepository = MockStatisticsRepository();
    useCase = GetDeckStats(mockRepository);
  });

  group('GetDeckStats', () {
    const testDeckId = 'deck-456';

    test('should return DeckStats from repository', () async {
      const expectedStats = DeckStats(
        deckId: testDeckId,
        deckName: 'Spanish Vocabulary',
        totalCards: 100,
        totalReviews: 300,
        correctReviews: 240,
        daysStudied: 20,
        accuracyPercentage: 80.0,
      );

      when(() => mockRepository.getDeckStats(testDeckId))
          .thenAnswer((_) async => expectedStats);

      final result = await useCase(testDeckId);

      expect(result.deckId, testDeckId);
      expect(result.deckName, 'Spanish Vocabulary');
      expect(result.totalCards, 100);
      expect(result.totalReviews, 300);
      expect(result.correctReviews, 240);
      expect(result.accuracyPercentage, 80.0);
      verify(() => mockRepository.getDeckStats(testDeckId)).called(1);
    });

    test('should return stats with zero activity for empty deck', () async {
      const emptyStats = DeckStats(
        deckId: testDeckId,
        deckName: 'New Deck',
        totalCards: 0,
        totalReviews: 0,
        correctReviews: 0,
        daysStudied: 0,
        accuracyPercentage: 0.0,
      );

      when(() => mockRepository.getDeckStats(testDeckId))
          .thenAnswer((_) async => emptyStats);

      final result = await useCase(testDeckId);

      expect(result.hasActivity, isFalse);
      expect(result.formattedAccuracy, '0%');
    });

    test('should propagate exceptions from repository', () async {
      when(() => mockRepository.getDeckStats(testDeckId))
          .thenThrow(Exception('Server error'));

      expect(() => useCase(testDeckId), throwsA(isA<Exception>()));
    });
  });
}
