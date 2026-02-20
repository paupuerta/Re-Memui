import 'package:re_mem_ui/core/error/result.dart';
import 'package:re_mem_ui/features/cards/domain/entities/review_result.dart';
import 'package:re_mem_ui/features/cards/domain/repositories/card_repository.dart';

/// Use case for submitting an intelligent card review with AI validation.
class SubmitReviewUseCase {
  const SubmitReviewUseCase(this._repository);

  final CardRepository _repository;

  AsyncResult<ReviewResult> call({
    required String cardId,
    required String userId,
    required String userAnswer,
  }) {
    return _repository.submitReview(
      cardId: cardId,
      userId: userId,
      userAnswer: userAnswer,
    );
  }
}
