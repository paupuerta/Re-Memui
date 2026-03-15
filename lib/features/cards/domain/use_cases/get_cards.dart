import 'package:re_mem_ui/core/error/result.dart';

import '../entities/card.dart';
import '../repositories/card_repository.dart';

/// Use case: Get all cards for a user (SRP ? single responsibility).
class GetCardsUseCase {
  const GetCardsUseCase(this._repository);

  final CardRepository _repository;

  AsyncResult<List<Card>> call(
    String userId, {
    String? deckId,
    int? limit,
    int? offset,
  }) {
    if (deckId != null) {
      return _repository.getCardsByDeck(deckId, limit: limit, offset: offset);
    }

    return _repository.getCards(userId, limit: limit, offset: offset);
  }
}
