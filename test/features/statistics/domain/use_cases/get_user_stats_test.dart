import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:re_mem_ui/features/statistics/domain/entities/user_stats.dart';
import 'package:re_mem_ui/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:re_mem_ui/features/statistics/domain/use_cases/get_user_stats.dart';

class MockStatisticsRepository extends Mock implements StatisticsRepository {}

void main() {
  late GetUserStats useCase;
  late MockStatisticsRepository mockRepository;

  setUp(() {
    mockRepository = MockStatisticsRepository();
    useCase = GetUserStats(mockRepository);
  });

  group('GetUserStats', () {
    const testUserId = 'user-123';

    test('should return UserStats from repository', () async {
      const expectedStats = UserStats(
        userId: testUserId,
        totalReviews: 50,
        correctReviews: 40,
        daysStudied: 7,
        accuracyPercentage: 80.0,
      );

      when(() => mockRepository.getUserStats(testUserId))
          .thenAnswer((_) async => expectedStats);

      final result = await useCase(testUserId);

      expect(result.userId, testUserId);
      expect(result.totalReviews, 50);
      expect(result.correctReviews, 40);
      expect(result.daysStudied, 7);
      expect(result.accuracyPercentage, 80.0);
      verify(() => mockRepository.getUserStats(testUserId)).called(1);
    });

    test('should return stats with zero activity for new user', () async {
      const emptyStats = UserStats(
        userId: testUserId,
        totalReviews: 0,
        correctReviews: 0,
        daysStudied: 0,
        accuracyPercentage: 0.0,
      );

      when(() => mockRepository.getUserStats(testUserId))
          .thenAnswer((_) async => emptyStats);

      final result = await useCase(testUserId);

      expect(result.hasActivity, isFalse);
    });

    test('should propagate exceptions from repository', () async {
      when(() => mockRepository.getUserStats(testUserId))
          .thenThrow(Exception('Network error'));

      expect(() => useCase(testUserId), throwsA(isA<Exception>()));
    });
  });
}
