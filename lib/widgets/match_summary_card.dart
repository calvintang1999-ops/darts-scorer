import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'stat_tile.dart';

/// One player's stat tiles for a just-finished match, shown under their
/// name - see [MatchSummaryCard].
class PlayerMatchSummary {
  const PlayerMatchSummary({required this.playerName, required this.tiles});

  final String playerName;
  final List<StatTile> tiles;
}

/// A few headline stats per player, shown on the winner panel right after
/// a match ends - so there's something to look at besides "so-and-so
/// wins!" without a trip to the Stats tab. Every game computes its own
/// tiles from its own stats calculator; this widget only lays them out.
class MatchSummaryCard extends StatelessWidget {
  const MatchSummaryCard({super.key, required this.sections});

  final List<PlayerMatchSummary> sections;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final section in sections) ...[
          Text(section.playerName.toUpperCase(), style: AppTypography.label),
          const SizedBox(height: SpacingTokens.xs),
          Wrap(
            spacing: SpacingTokens.sm,
            runSpacing: SpacingTokens.sm,
            alignment: WrapAlignment.center,
            children: [
              for (final tile in section.tiles)
                SizedBox(width: SizeTokens.statTileWidth, child: tile),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
        ],
      ],
    );
  }
}
