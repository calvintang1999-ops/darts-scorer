import 'package:flutter/material.dart';

import '../models/match_record.dart';
import '../models/throw.dart';
import '../services/stats/game_labels.dart';
import '../services/stats/stats_filter.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';

/// One past match, leg by leg, dart by dart - built entirely from the raw
/// throws already in [match]; nothing here is a stored aggregate.
class MatchDetailScreen extends StatelessWidget {
  const MatchDetailScreen({super.key, required this.match});

  final MatchRecord match;

  @override
  Widget build(BuildContext context) {
    final legs = legsOf(match);
    return Scaffold(
      appBar: AppBar(title: Text(gameLabel(match.gameName))),
      body: ListView(
        padding: const EdgeInsets.all(SpacingTokens.md),
        children: [
          Text(
            match.players.map((p) => p.name).join(' vs '),
            style: AppTypography.body,
          ),
          Text(
            formatMatchDate(match.finishedAt),
            style: AppTypography.label.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          for (var legIndex = 0; legIndex < legs.length; legIndex++) ...[
            if (legIndex > 0) const SizedBox(height: SpacingTokens.lg),
            _LegCard(
              turns: legs[legIndex],
              // legNumber/setNumber only vary for X01 - for every other
              // (single-leg) game, a plain "Leg 1" is clearer than
              // "Set 1 · Leg 1".
              label: legs.length > 1
                  ? 'Set ${legs[legIndex].first.setNumber} · '
                      'Leg ${legs[legIndex].first.legNumber}'
                  : 'Leg 1',
            ),
          ],
        ],
      ),
    );
  }

}

class _LegCard extends StatelessWidget {
  const _LegCard({required this.turns, required this.label});

  final List<Turn> turns;
  final String label;

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
          children: [
            Text(label.toUpperCase(), style: AppTypography.label),
            const SizedBox(height: SpacingTokens.sm),
            for (final turn in turns)
              Padding(
                padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(turn.player.name, style: AppTypography.body),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        turn.throws.map((t) => t.label).join('  '),
                        style: AppTypography.body.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
