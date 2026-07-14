import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../theme/typography.dart';

/// A small titled line chart, one point per match, oldest to newest -
/// used for "headline stat over time". The only place fl_chart's own
/// styling API gets touched; every colour it uses comes from the active
/// ColorScheme so the chart matches the rest of the app in light and dark.
class LineChartCard extends StatelessWidget {
  const LineChartCard({super.key, required this.title, required this.points});

  final String title;

  /// Chronological (date, value) pairs. Fewer than 2 points can't show a
  /// trend, so those cases just show a short message instead of a chart.
  final List<(DateTime, double)> points;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title.toUpperCase(),
                style: AppTypography.label
                    .copyWith(color: scheme.onSurfaceVariant)),
            const SizedBox(height: SpacingTokens.sm),
            SizedBox(
              height: SizeTokens.chartHeight,
              child: points.length < 2
                  ? Center(
                      child: Text(
                        points.isEmpty
                            ? 'No data yet'
                            : 'Play another match to see a trend',
                        style: AppTypography.body
                            .copyWith(color: scheme.onSurfaceVariant),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineTouchData: const LineTouchData(enabled: false),
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            color: scheme.primary,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: scheme.primary.withValues(alpha: 0.12),
                            ),
                            spots: [
                              for (var i = 0; i < points.length; i++)
                                FlSpot(i.toDouble(), points[i].$2),
                            ],
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
