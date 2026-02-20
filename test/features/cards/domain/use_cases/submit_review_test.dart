import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:re_mem_ui/core/error/failure.dart';
import 'package:re_mem_ui/features/cards/domain/entities/review_result.dart';
import 'package:re_mem_ui/features/cards/domain/repositories/card_repository.dart';
import 'package:re_mem_ui/features/cards/domain/use_cases/submit_review.dart';

class MockCardRepository extends Mock implements CardRepository {}

void main() {
  late SubmitReviewUseCase useCase;
  late MockCardRepository mockRepository;

  setUp(() {
    mockRepository = MockCardRepository();
    useCase = SubmitReviewUseCase(mockRepository);
  });

  group('SubmitReviewUseCase', () {
    const testCardId = 'card-123';
    const testUserId = 'user-456';
    const testAnswer = 'Test answer';

    test('should return ReviewResult on success', () async {
      // Arrange
      const expectedResult = ReviewResult(
        cardId: testCardId,
        aiScore: 0.95,
        fsrsRating: 4,
        validationMethod: 'exact',
        nextReviewInDays: 7,
      );

      when(() => mockRepository.submitReview(
            cardId: testCardId,
            userId: testUserId,
            userAnswer: testAnswer,
          )).thenAnswer((_) async => const Right(expectedResult));

      // Act
      final result = await useCase(
        cardId: testCardId,
        userId: testUserId,
        userAnswer: testAnswer,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Expected Right, got Left'),
        (r) {
          expect(r.cardId, testCardId);
          expect(r.aiScore, 0.95);
          expect(r.fsrsRating, 4);
          expect(r.validationMethod, 'exact');
          expect(r.nextReviewInDays, 7);
        },
      );

      verify(() => mockRepository.submitReview(
            cardId: testCardId,
            userId: testUserId,
            userAnswer: testAnswer,
          )).called(1);
    });

    test('should return Failure on error', () async {
      // Arrange
      when(() => mockRepository.submitReview(
            cardId: testCardId,
            userId: testUserId,
            userAnswer: testAnswer,
          )).thenAnswer((_) async => const Left(NetworkFailure()));

      // Act
      final result = await useCase(
        cardId: testCardId,
        userId: testUserId,
        userAnswer: testAnswer,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<NetworkFailure>()),
        (r) => fail('Expected Left, got Right'),
      );
    });

    test('should handle different AI scores and ratings', () async {
      // Arrange - Good rating
      const goodResult = ReviewResult(
        cardId: testCardId,
        aiScore: 0.75,
        fsrsRating: 3,
        validationMethod: 'embedding',
        nextReviewInDays: 3,
      );

      when(() => mockRepository.submitReview(
            cardId: any(named: 'cardId'),
            userId: any(named: 'userId'),
            userAnswer: any(named: 'userAnswer'),
          )).thenAnswer((_) async => const Right(goodResult));

      // Act
      final result = await useCase(
        cardId: testCardId,
        userId: testUserId,
        userAnswer: 'Different answer',
      );

      // Assert
      result.fold(
        (l) => fail('Expected Right, got Left'),
        (r) {
          expect(r.aiScore, 0.75);
          expect(r.fsrsRating, 3);
          expect(r.validationMethod, 'embedding');
        },
      );
    });
  });
}
