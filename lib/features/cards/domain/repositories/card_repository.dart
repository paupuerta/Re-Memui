import 'package:re_mem_ui/core/error/result.dart';

import '../entities/card.dart';
import '../entities/review_result.dart';

/// Repository contract for card operations (DIP ? depend on abstraction).
abstract interface class CardRepository {
  AsyncResult<List<Card>> getCards(String userId);
  AsyncResult<Card> getCard(String cardId);
  AsyncResult<Card> createCard({
    required String userId,
    required String question,
    required String answer,
  });
  AsyncResult<ReviewResult> submitReview({
    required String cardId,
    required String userId,
    required String userAnswer,
  });
}
