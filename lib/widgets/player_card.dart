import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'score_display.dart';

/// One player's panel during a game: name, remaining score, this turn's
/// darts, and legs/sets when relevant. Highlights when it's their turn.
class PlayerCard extends StatelessWidget {
  const PlayerCard({
    super.key,
    required this.name,
    required this.score,
    this.isActive = false,
    this.turnDarts = const [],
    this.detail,
    this.progress,
  });

  final String name;
  final String score;
  final bool isActive;

  /// Labels of the darts thrown so far this turn, e.g. ["T20", "5"].
  final List<String> turnDarts;

  /// Extra line like "Legs 2 · Sets 1". Hidden when null.
  final String? detail;

  /// Fraction (0.0-1.0) for a thin progress bar under the score, e.g. how
  /// far through a Round the Clock sequence this player has got. Hidden
  /// when null - most games don't have a "progress through a sequence"
  /// to show.
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      // The active player's card pops with the primary container colour so
      // whose-turn-is-it is obvious from across the room.
      color: isActive ? scheme.primaryContainer : scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        side: isActive
            ? BorderSide(color: scheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name.toUpperCase(),
              style: AppTypography.label.copyWith(
                color: isActive ? scheme.onPrimaryContainer : scheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            ScoreDisplay(
              value: score,
              huge: isActive,
              color: isActive ? scheme.onPrimaryContainer : scheme.onSurface,
            ),
            if (progress != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: SpacingTokens.xs / 2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(RadiusTokens.sm),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: SpacingTokens.xs,
                    backgroundColor: (isActive
                            ? scheme.onPrimaryContainer
                            : scheme.onSurface)
                        .withValues(alpha: 0.15),
                    color:
                        isActive ? scheme.onPrimaryContainer : scheme.primary,
                  ),
                ),
              ),
            // Reserve the row even when empty so cards don't jump around.
            SizedBox(
              height: SpacingTokens.lg,
              child: Text(
                turnDarts.isEmpty ? ' ' : turnDarts.join('  '),
                style: AppTypography.body.copyWith(
                  color:
                      isActive ? scheme.onPrimaryContainer : scheme.onSurface,
                ),
              ),
            ),
            if (detail != null)
              Text(
                detail!,
                style: AppTypography.label.copyWith(
                  color: (isActive
                          ? scheme.onPrimaryContainer
                          : scheme.onSurface)
                      .withValues(alpha: 0.7),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
