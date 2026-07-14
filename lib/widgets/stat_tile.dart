import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../theme/typography.dart';

/// One labelled stat, used all over the stats screens. Shows "No data
/// yet" instead of the value whenever there's nothing to report, so a
/// zero-denominator stat never renders as a crash or a raw "NaN%".
class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.label, required this.value});

  final String label;

  /// Pre-formatted display string, or null for "no data yet".
  final String? value;

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
            Text(label.toUpperCase(),
                style: AppTypography.label
                    .copyWith(color: scheme.onSurfaceVariant)),
            const SizedBox(height: SpacingTokens.xs),
            Text(
              value ?? 'No data yet',
              style: AppTypography.statValue.copyWith(
                color:
                    value == null ? scheme.onSurfaceVariant : scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
