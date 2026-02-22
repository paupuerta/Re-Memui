import 'package:re_mem_ui/core/error/result.dart';

import '../entities/card.dart';
import '../repositories/card_repository.dart';

/// Use case: Create a new card.
class CreateCardUseCase {
  const CreateCardUseCase(this._repository);

  final CardRepository _repository;

  AsyncResult<Card> call({
    required String userId,
    required String question,
    required String answer,
    String? deckId,
  }) =>
      _repository.createCard(
        userId: userId,
        question: question,
        answer: answer,
        deckId: deckId,
      );
}
