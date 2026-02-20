import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:re_mem_ui/features/cards/domain/entities/card.dart';
import 'package:re_mem_ui/features/cards/domain/repositories/card_repository.dart';
import 'package:re_mem_ui/features/cards/domain/use_cases/create_card.dart';

class MockCardRepository extends Mock implements CardRepository {}

void main() {
  late CreateCardUseCase useCase;
  late MockCardRepository mockRepository;

  setUp(() {
    mockRepository = MockCardRepository();
    useCase = CreateCardUseCase(mockRepository);
  });

  const userId = 'user-123';
  const question = 'Hello in German?';
  const answer = 'Hallo';
  const card = Card(
    id: 'card-1',
    userId: userId,
    question: question,
    answer: answer,
  );

  group('CreateCardUseCase', () {
    test('should create a card via repository', () async {
      // Arrange
      when(() => mockRepository.createCard(
            userId: userId,
            question: question,
            answer: answer,
          )).thenAnswer((_) async => const Right(card));

      // Act
      final result = await useCase(
        userId: userId,
        question: question,
        answer: answer,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left: $failure'),
        (data) {
          expect(data.id, 'card-1');
          expect(data.question, question);
          expect(data.answer, answer);
        },
      );
      verify(() => mockRepository.createCard(
            userId: userId,
            question: question,
            answer: answer,
          )).called(1);
    });
  });
}
