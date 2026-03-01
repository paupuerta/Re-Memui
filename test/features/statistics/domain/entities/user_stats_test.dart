import 'package:flutter_test/flutter_test.dart';
import 'package:re_mem_ui/features/statistics/domain/entities/user_stats.dart';

void main() {
  group('UserStats entity', () {
    test('should create a UserStats with required fields', () {
      const stats = UserStats(
        userId: 'user-1',
        totalReviews: 100,
        correctReviews: 80,
        daysStudied: 15,
        accuracyPercentage: 80.0,
      );

      expect(stats.userId, 'user-1');
      expect(stats.totalReviews, 100);
      expect(stats.correctReviews, 80);
      expect(stats.daysStudied, 15);
      expect(stats.accuracyPercentage, 80.0);
      expect(stats.lastActiveDate, isNull);
    });

    test('hasActivity returns true when totalReviews > 0', () {
      const stats = UserStats(
        userId: 'user-1',
        totalReviews: 5,
        correctReviews: 3,
        daysStudied: 1,
        accuracyPercentage: 60.0,
      );
      expect(stats.hasActivity, isTrue);
    });

    test('hasActivity returns false when totalReviews == 0', () {
      const stats = UserStats(
        userId: 'user-1',
        totalReviews: 0,
        correctReviews: 0,
        daysStudied: 0,
        accuracyPercentage: 0.0,
      );
      expect(stats.hasActivity, isFalse);
    });

    test('formattedAccuracy returns percentage string', () {
      const stats = UserStats(
        userId: 'user-1',
        totalReviews: 100,
        correctReviews: 85,
        daysStudied: 10,
        accuracyPercentage: 85.4,
      );
      expect(stats.formattedAccuracy, '85%');
    });

    test('should accept optional lastActiveDate', () {
      final date = DateTime(2024, 6, 15);
      final stats = UserStats(
        userId: 'user-1',
        totalReviews: 10,
        correctReviews: 8,
        daysStudied: 3,
        accuracyPercentage: 80.0,
        lastActiveDate: date,
      );
      expect(stats.lastActiveDate, date);
    });
  });
}
