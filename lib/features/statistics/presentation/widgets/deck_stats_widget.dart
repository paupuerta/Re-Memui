import 'package:flutter/material.dart';
import '../../domain/entities/deck_stats.dart';

/// Widget displaying deck statistics
class DeckStatsWidget extends StatelessWidget {
  final DeckStats stats;
  final bool compact;

  const DeckStatsWidget({
    Key? key,
    required this.stats,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactView(context);
    } else {
      return _buildFullView(context);
    }
  }

  Widget _buildCompactView(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStatChip(
          Icons.style,
          '${stats.totalCards}',
          Colors.blue,
        ),
        const SizedBox(width: 8),
        if (stats.hasActivity)
          _buildStatChip(
            Icons.trending_up,
            stats.formattedAccuracy,
            _getAccuracyColor(stats.accuracyPercentage),
          ),
      ],
    );
  }

  Widget _buildFullView(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stats.deckName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStatChip(Icons.style, '${stats.totalCards} cards', Colors.blue),
                if (stats.hasActivity) ...[
                  _buildStatChip(
                    Icons.quiz,
                    '${stats.totalReviews} reviews',
                    Colors.grey,
                  ),
                  _buildStatChip(
                    Icons.trending_up,
                    stats.formattedAccuracy,
                    _getAccuracyColor(stats.accuracyPercentage),
                  ),
                  _buildStatChip(
                    Icons.calendar_today,
                    '${stats.daysStudied} days',
                    Colors.orange,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label),
      labelStyle: const TextStyle(fontSize: 12),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 80) return Colors.green;
    if (accuracy >= 60) return Colors.orange;
    return Colors.red;
  }
}
