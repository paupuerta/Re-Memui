/// Card entity – mirrors the backend domain Card.
class Card {
  const Card({
    required this.id,
    required this.userId,
    this.deckId,
    required this.question,
    required this.answer,
  });

  final String id;
  final String userId;
  final String? deckId;
  final String question;
  final String answer;

  factory Card.fromJson(Map<String, dynamic> json) {
    return Card(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      deckId: json['deck_id'] as String?,
      question: json['question'] as String,
      answer: json['answer'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'deck_id': deckId,
      'question': question,
      'answer': answer,
    };
  }
}
