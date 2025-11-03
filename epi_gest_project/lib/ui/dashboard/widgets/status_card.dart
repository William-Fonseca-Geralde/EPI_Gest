import 'package:flutter/material.dart';

enum TrendType { positive, negative, neutral }

class StatusCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final TrendType trend;
  final String trendValue;

  const StatusCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
    required this.trendValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Header com ícone
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                _buildTrendIndicator(),
              ],
            ),
            const Spacer(),
            // Valor principal
            Text(
              value,
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            // Título
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendIndicator() {
    IconData trendIcon;
    Color trendColor;

    switch (trend) {
      case TrendType.positive:
        trendIcon = Icons.trending_up_rounded;
        trendColor = Colors.green;
        break;
      case TrendType.negative:
        trendIcon = Icons.trending_down_rounded;
        trendColor = Colors.red;
        break;
      case TrendType.neutral:
        trendIcon = Icons.trending_flat_rounded;
        trendColor = Colors.grey;
        break;
    }

    return Card.filled(
      color: trendColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          spacing: 4,
          children: [
            Icon(trendIcon, color: trendColor, size: 20),
            Text(trendValue, style: TextStyle(color: trendColor, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
