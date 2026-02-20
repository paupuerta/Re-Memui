/// Card entity ? mirrors the backend domain Card.
class Card {
  const Card({
    required this.id,
    required this.userId,
    required this.question,
    required this.answer,
  });

  final String id;
  final String userId;
  final String question;
  final String answer;
}
