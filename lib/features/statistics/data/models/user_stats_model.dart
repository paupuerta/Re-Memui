import '../../domain/entities/user_stats.dart';

/// User statistics data model
class UserStatsModel {
  final String userId;
  final int totalReviews;
  final int correctReviews;
  final int daysStudied;
  final double accuracyPercentage;
  final String? lastActiveDate;

  const UserStatsModel({
    required this.userId,
    required this.totalReviews,
    required this.correctReviews,
    required this.daysStudied,
    required this.accuracyPercentage,
    this.lastActiveDate,
  });

  /// Create from JSON
  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      userId: json['user_id'] as String,
      totalReviews: json['total_reviews'] as int,
      correctReviews: json['correct_reviews'] as int,
      daysStudied: json['days_studied'] as int,
      accuracyPercentage: (json['accuracy_percentage'] as num).toDouble(),
      lastActiveDate: json['last_active_date'] as String?,
    );
  }

  /// Convert to entity
  UserStats toEntity() {
    return UserStats(
      userId: userId,
      totalReviews: totalReviews,
      correctReviews: correctReviews,
      daysStudied: daysStudied,
      accuracyPercentage: accuracyPercentage,
      lastActiveDate: lastActiveDate != null 
          ? DateTime.parse(lastActiveDate!) 
          : null,
    );
  }
}
