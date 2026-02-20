import 'package:flutter_test/flutter_test.dart';
import 'package:re_mem_ui/features/cards/domain/entities/card.dart';

void main() {
  group('Card entity', () {
    test('should create a Card with required fields', () {
      const card = Card(
        id: '1',
        userId: 'user-1',
        question: 'What is hello in Spanish?',
        answer: 'Hola',
      );

      expect(card.id, '1');
      expect(card.userId, 'user-1');
      expect(card.question, 'What is hello in Spanish?');
      expect(card.answer, 'Hola');
    });
  });
}
