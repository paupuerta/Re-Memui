/// Result of AI-based card review validation.
class ReviewResult {
  const ReviewResult({
    required this.cardId,
    required this.aiScore,
    required this.fsrsRating,
    required this.validationMethod,
    required this.nextReviewInDays,
  });

  final String cardId;
  final double aiScore;
  final int fsrsRating;
  final String validationMethod;
  final int nextReviewInDays;
}
