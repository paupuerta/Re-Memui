import 'package:re_mem_ui/core/error/result.dart';

import '../repositories/card_repository.dart';

/// Use case for deleting a card
class DeleteCard {
  const DeleteCard(this._repository);

  final CardRepository _repository;

  AsyncResult<void> call({
    required String userId,
    required String cardId,
  }) =>
      _repository.deleteCard(userId: userId, cardId: cardId);
}
