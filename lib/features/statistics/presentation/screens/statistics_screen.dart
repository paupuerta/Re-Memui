import 'package:flutter/material.dart';
import '../../domain/entities/user_stats.dart';
import '../../domain/use_cases/get_user_stats.dart';

/// Screen displaying user statistics
class StatisticsScreen extends StatefulWidget {
  final GetUserStats getUserStats;
  final String userId;

  const StatisticsScreen({
    Key? key,
    required this.getUserStats,
    required this.userId,
  }) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  UserStats? _stats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stats = await widget.getUserStats(widget.userId);
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadStats,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _stats == null
                  ? const Center(child: Text('No statistics available'))
                  : RefreshIndicator(
                      onRefresh: _loadStats,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Overall Stats Card
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Overall Statistics',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildStatRow(
                                      'Total Reviews',
                                      _stats!.totalReviews.toString(),
                                      Icons.quiz,
                                    ),
                                    const Divider(),
                                    _buildStatRow(
                                      'Correct Reviews',
                                      _stats!.correctReviews.toString(),
                                      Icons.check_circle,
                                    ),
                                    const Divider(),
                                    _buildStatRow(
                                      'Days Studied',
                                      _stats!.daysStudied.toString(),
                                      Icons.calendar_today,
                                    ),
                                    const Divider(),
                                    _buildStatRow(
                                      'Accuracy',
                                      _stats!.formattedAccuracy,
                                      Icons.trending_up,
                                      valueColor: _getAccuracyColor(
                                          _stats!.accuracyPercentage),
                                    ),
                                    if (_stats!.lastActiveDate != null) ...[
                                      const Divider(),
                                      _buildStatRow(
                                        'Last Active',
                                        _formatDate(_stats!.lastActiveDate!),
                                        Icons.event,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Motivational Message
                            if (_stats!.hasActivity)
                              Card(
                                color: Colors.blue.shade50,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.emoji_events,
                                        color: Colors.amber.shade700,
                                        size: 32,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          _getMotivationalMessage(),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              Card(
                                color: Colors.green.shade50,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.play_arrow,
                                        color: Colors.green,
                                        size: 32,
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          'Start reviewing cards to see your progress!',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon,
      {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black,
          ),
        ),
      ],
    );
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 80) return Colors.green;
    if (accuracy >= 60) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';

    return '${date.day}/${date.month}/${date.year}';
  }

  String _getMotivationalMessage() {
    final accuracy = _stats!.accuracyPercentage;
    final streak = _stats!.daysStudied;

    if (accuracy >= 90 && streak >= 7) {
      return 'Outstanding! You\'re on fire! 🔥';
    } else if (accuracy >= 80) {
      return 'Great job! Keep up the excellent work!';
    } else if (accuracy >= 70) {
      return 'Good progress! You\'re doing well!';
    } else if (streak >= 3) {
      return 'Nice streak! Consistency is key!';
    } else {
      return 'Keep practicing, you\'re improving!';
    }
  }
}
