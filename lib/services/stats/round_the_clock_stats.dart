import '../../models/match_record.dart';
import '../../models/player.dart';

/// Everything computed for one player's Round the Clock history. Fully
/// derivable from raw throws with no config needed - `intendedTarget` is
/// already recorded on every dart (see RoundTheClockGame.applyThrow).
class RoundTheClockStats {
  const RoundTheClockStats({
    required this.matchesPlayed,
    required this.overallHitRate,
    required this.favouriteNumber,
    required this.worstNumber,
    required this.hitRateByTarget,
  });

  final int matchesPlayed;
  final double? overallHitRate;

  /// The target hit most/least often relative to how often it was aimed
  /// at, requiring a minimum number of attempts so a single lucky/unlucky
  /// dart on a rarely-seen target doesn't dominate.
  final int? favouriteNumber;
  final int? worstNumber;

  /// Target segment -> (hits, attempts), for anyone who wants the full
  /// breakdown rather than just favourite/worst.
  final Map<int, (int hits, int attempts)> hitRateByTarget;

  static const empty = RoundTheClockStats(
    matchesPlayed: 0,
    overallHitRate: null,
    favouriteNumber: null,
    worstNumber: null,
    hitRateByTarget: {},
  );

  /// A target needs at least this many attempts before it's eligible to
  /// be called a favourite/worst number - otherwise one dart at a target
  /// thrown only once would always look like either 0% or 100%.
  static const _minAttemptsForRanking = 3;

  /// [matches] must already be filtered to this player and to Round the
  /// Clock - see `matchesForPlayer` in stats_filter.dart.
  factory RoundTheClockStats.compute(Player player, List<MatchRecord> matches) {
    if (matches.isEmpty) return empty;

    var totalHits = 0;
    var totalAttempts = 0;
    final hitsByTarget = <int, int>{};
    final attemptsByTarget = <int, int>{};

    for (final match in matches) {
      for (final turn in match.turnHistory) {
        if (turn.player.id != player.id) continue;
        for (final dart in turn.throws) {
          final target = dart.intendedTarget;
          if (target == null) continue;
          totalAttempts++;
          attemptsByTarget[target] = (attemptsByTarget[target] ?? 0) + 1;
          // RoundTheClockGame records the steps advanced as
          // resultingScoreDelta - a hit is any dart that advanced them.
          if (dart.resultingScoreDelta > 0) {
            totalHits++;
            hitsByTarget[target] = (hitsByTarget[target] ?? 0) + 1;
          }
        }
      }
    }

    final hitRateByTarget = <int, (int, int)>{
      for (final target in attemptsByTarget.keys)
        target: (hitsByTarget[target] ?? 0, attemptsByTarget[target]!),
    };

    int? favourite;
    int? worst;
    double? favouriteRate;
    double? worstRate;
    for (final entry in hitRateByTarget.entries) {
      final (hits, attempts) = entry.value;
      if (attempts < _minAttemptsForRanking) continue;
      final rate = hits / attempts;
      if (favouriteRate == null || rate > favouriteRate) {
        favouriteRate = rate;
        favourite = entry.key;
      }
      if (worstRate == null || rate < worstRate) {
        worstRate = rate;
        worst = entry.key;
      }
    }

    return RoundTheClockStats(
      matchesPlayed: matches.length,
      overallHitRate: totalAttempts == 0 ? null : totalHits / totalAttempts * 100,
      favouriteNumber: favourite,
      worstNumber: worst,
      hitRateByTarget: hitRateByTarget,
    );
  }
}
