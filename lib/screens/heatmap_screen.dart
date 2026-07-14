import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../theme/typography.dart';

/// A placeholder for the board-position heatmap. Scoring never records
/// where a dart landed on the board for manual entry (see
/// Throw.landingPosition in CLAUDE.md) - that only arrives with camera
/// scoring (phase 4), so there's genuinely nothing to plot yet.
class HeatmapScreen extends StatelessWidget {
  const HeatmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Heatmap')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.grid_on, size: 64, color: scheme.onSurfaceVariant),
              const SizedBox(height: SpacingTokens.md),
              Text(
                'No position data yet',
                style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                'Manual entry only records which segment you hit, not where '
                'on the board. Heatmaps arrive once camera scoring can track '
                'exact landing positions.',
                style:
                    AppTypography.label.copyWith(color: scheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
