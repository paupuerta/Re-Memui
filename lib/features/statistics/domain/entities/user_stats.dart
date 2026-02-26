/// User statistics entity
class UserStats {
  final String userId;
  final int totalReviews;
  final int correctReviews;
  final int daysStudied;
  final double accuracyPercentage;
  final DateTime? lastActiveDate;

  const UserStats({
    required this.userId,
    required this.totalReviews,
    required this.correctReviews,
    required this.daysStudied,
    required this.accuracyPercentage,
    this.lastActiveDate,
  });

  /// Returns true if the user has any review activity
  bool get hasActivity => totalReviews > 0;

  /// Returns a formatted accuracy string (e.g., "85%")
  String get formattedAccuracy => '${accuracyPercentage.toStringAsFixed(0)}%';
}
