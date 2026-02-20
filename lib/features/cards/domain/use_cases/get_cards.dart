import 'package:re_mem_ui/core/error/result.dart';

import '../entities/card.dart';
import '../repositories/card_repository.dart';

/// Use case: Get all cards for a user (SRP ? single responsibility).
class GetCardsUseCase {
  const GetCardsUseCase(this._repository);

  final CardRepository _repository;

  AsyncResult<List<Card>> call(String userId) =>
      _repository.getCards(userId);
}
