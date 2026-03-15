import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:re_mem_ui/features/cards/domain/entities/card.dart';
import 'package:re_mem_ui/features/cards/domain/repositories/card_repository.dart';
import 'package:re_mem_ui/features/cards/domain/use_cases/get_cards.dart';

class MockCardRepository extends Mock implements CardRepository {}

void main() {
  late GetCardsUseCase useCase;
  late MockCardRepository mockRepository;

  setUp(() {
    mockRepository = MockCardRepository();
    useCase = GetCardsUseCase(mockRepository);
  });

  const userId = 'user-123';
  final cards = [
    const Card(
      id: '1',
      userId: userId,
      question: 'Hello in French?',
      answer: 'Bonjour',
    ),
    const Card(
      id: '2',
      userId: userId,
      question: 'Goodbye in French?',
      answer: 'Au revoir',
    ),
  ];

  group('GetCardsUseCase', () {
    test('should return list of cards from repository', () async {
      // Arrange
      when(
        () => mockRepository.getCards(userId),
      ).thenAnswer((_) async => Right(cards));

      // Act
      final result = await useCase(userId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left: $failure'),
        (data) => expect(data, cards),
      );
      verify(() => mockRepository.getCards(userId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
