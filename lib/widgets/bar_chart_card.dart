import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../theme/typography.dart';

/// A small titled bar chart for a labelled distribution (e.g. X01's
/// score-per-visit histogram). Every colour comes from the active
/// ColorScheme, same reasoning as LineChartCard.
class BarChartCard extends StatelessWidget {
  const BarChartCard({super.key, required this.title, required this.buckets});

  final String title;

  /// Bucket label -> count, in display order.
  final Map<String, int> buckets;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final labels = buckets.keys.toList();
    final total = buckets.values.fold(0, (sum, v) => sum + v);
    final maxCount = buckets.values.fold(0, (m, v) => v > m ? v : m);

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
              child: total == 0
                  ? Center(
                      child: Text('No data yet',
                          style: AppTypography.body
                              .copyWith(color: scheme.onSurfaceVariant)),
                    )
                  : BarChart(
                      BarChartData(
                        maxY: maxCount.toDouble(),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= labels.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      top: SpacingTokens.xs),
                                  child: Text(
                                    labels[index],
                                    style: AppTypography.chartAxisLabel
                                        .copyWith(color: scheme.onSurfaceVariant),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        barGroups: [
                          for (var i = 0; i < labels.length; i++)
                            BarChartGroupData(x: i, barRods: [
                              BarChartRodData(
                                toY: buckets[labels[i]]!.toDouble(),
                                color: scheme.primary,
                                width: 14,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ]),
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
