import '../../games/halfit/halfit_config.dart';
import '../../models/match_record.dart';
import '../../models/player.dart';

/// Everything computed for one player's Half It history.
class HalfItStats {
  const HalfItStats({
    required this.matchesPlayed,
    required this.averageTotalScore,
    required this.bestGameScore,
    required this.mostSurvivedRounds,
  });

  final int matchesPlayed;
  final double? averageTotalScore;
  final int? bestGameScore;

  /// The most rounds survived (not halved) in a single game - a
  /// personal-best, not a lifetime total.
  final int? mostSurvivedRounds;

  static const empty = HalfItStats(
    matchesPlayed: 0,
    averageTotalScore: null,
    bestGameScore: null,
    mostSurvivedRounds: null,
  );

  /// [matches] must already be filtered to this player and to Half It -
  /// see `matchesForPlayer` in stats_filter.dart.
  factory HalfItStats.compute(Player player, List<MatchRecord> matches) {
    if (matches.isEmpty) return empty;

    var totalFinalScore = 0;
    int? bestGameScore;
    int? mostSurvivedRounds;

    for (final match in matches) {
      final config = _configFrom(match.config);
      // The real final score, not just the net change - startingScore
      // plus every round's delta (only the round-deciding dart carries a
      // nonzero delta, see HalfItGame._evaluateTurn).
      var finalScore = config.startingScore;
      var survivedRounds = 0;
      for (final turn in match.turnHistory) {
        if (turn.player.id != player.id) continue;
        final delta =
            turn.throws.fold<int>(0, (sum, d) => sum + d.resultingScoreDelta);
        finalScore += delta;
        // A round that didn't lose points was a hit, not a halving. This
        // is a proxy (Throw doesn't store hit/miss directly), and it's
        // only ambiguous in the rare case a hit scores exactly 0 points
        // while already at 0 - not worth a dedicated field for.
        if (delta >= 0) survivedRounds++;
      }
      totalFinalScore += finalScore;
      bestGameScore = bestGameScore == null
          ? finalScore
          : (finalScore > bestGameScore ? finalScore : bestGameScore);
      mostSurvivedRounds = mostSurvivedRounds == null
          ? survivedRounds
          : (survivedRounds > mostSurvivedRounds
              ? survivedRounds
              : mostSurvivedRounds);
    }

    return HalfItStats(
      matchesPlayed: matches.length,
      averageTotalScore: totalFinalScore / matches.length,
      bestGameScore: bestGameScore,
      mostSurvivedRounds: mostSurvivedRounds,
    );
  }

  /// [match.config] as saved by HalfItPlayScreen, or this game's own
  /// default for matches saved before schema v3 added the config
  /// snapshot.
  static HalfItConfig _configFrom(Map<String, Object?>? config) {
    if (config == null) return const HalfItConfig();
    return HalfItConfig(startingScore: config['startingScore'] as int? ?? 20);
  }
}
