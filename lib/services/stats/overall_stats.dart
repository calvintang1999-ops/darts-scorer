import '../../models/dart_position.dart';
import '../../models/match_record.dart';
import '../../models/player.dart';
import 'cricket_stats.dart';
import 'half_it_stats.dart';
import 'round_the_clock_stats.dart';
import 'x01_stats.dart';

/// Cross-game stats: favourite spot, win/loss record, and a per-game-type
/// "headline stat over time" series for the line chart. Reuses each
/// game's own calculator (one match at a time) for the headline value, so
/// the definition of "headline stat" lives in exactly one place per game.
class OverallStats {
  const OverallStats({
    required this.matchesPlayed,
    required this.wins,
    required this.losses,
    required this.winRate,
    required this.favouriteSpot,
    required this.headlineSeries,
  });

  final int matchesPlayed;
  final int wins;
  final int losses;
  final double? winRate;

  /// The segment (1-20, or bullSegment) hit most often. Null if every
  /// dart missed the board or there's no data at all.
  final int? favouriteSpot;

  /// gameName -> chronological (date, headline stat value) points, one per
  /// match. Only game types with at least one computable point appear.
  final Map<String, List<(DateTime, double)>> headlineSeries;

  static const empty = OverallStats(
    matchesPlayed: 0,
    wins: 0,
    losses: 0,
    winRate: null,
    favouriteSpot: null,
    headlineSeries: {},
  );

  /// [matches] must already be filtered to this player - see
  /// `matchesForPlayer` in stats_filter.dart. Abandoned matches
  /// (winnerId null) count toward neither wins nor losses.
  factory OverallStats.compute(Player player, List<MatchRecord> matches) {
    if (matches.isEmpty) return empty;

    var wins = 0;
    var losses = 0;
    final segmentCounts = <int, int>{};

    for (final match in matches) {
      if (match.winnerId != null) {
        if (match.winnerId == player.id) {
          wins++;
        } else {
          losses++;
        }
      }
      for (final turn in match.turnHistory) {
        if (turn.player.id != player.id) continue;
        for (final dart in turn.throws) {
          if (dart.actualSegment == missSegment) continue;
          segmentCounts[dart.actualSegment] =
              (segmentCounts[dart.actualSegment] ?? 0) + 1;
        }
      }
    }

    int? favouriteSpot;
    var favouriteCount = 0;
    segmentCounts.forEach((segment, count) {
      if (count > favouriteCount) {
        favouriteCount = count;
        favouriteSpot = segment;
      }
    });

    final byGame = <String, List<MatchRecord>>{};
    for (final match in matches) {
      byGame.putIfAbsent(match.gameName, () => []).add(match);
    }
    final headlineSeries = <String, List<(DateTime, double)>>{};
    for (final entry in byGame.entries) {
      final sorted = List<MatchRecord>.of(entry.value)
        ..sort((a, b) => a.finishedAt.compareTo(b.finishedAt));
      final points = <(DateTime, double)>[
        for (final match in sorted)
          if (_headlineValue(entry.key, player, match) case final v?)
            (match.finishedAt, v),
      ];
      if (points.isNotEmpty) headlineSeries[entry.key] = points;
    }

    final decided = wins + losses;
    return OverallStats(
      matchesPlayed: matches.length,
      wins: wins,
      losses: losses,
      winRate: decided == 0 ? null : wins / decided * 100,
      favouriteSpot: favouriteSpot,
      headlineSeries: headlineSeries,
    );
  }

  /// The one-number "how did this match go" value for [match], using each
  /// game's own calculator run over just that single match. Null if the
  /// game type is unrecognised or the calculator has nothing to report.
  static double? _headlineValue(
      String gameName, Player player, MatchRecord match) {
    switch (gameName) {
      case 'x01':
        return X01Stats.compute(player, [match]).threeDartAverage;
      case 'cricket':
        return CricketStats.compute(player, [match]).marksPerRound;
      case 'round_the_clock':
        return RoundTheClockStats.compute(player, [match]).overallHitRate;
      case 'halfit':
        return HalfItStats.compute(player, [match]).averageTotalScore;
      default:
        return null;
    }
  }
}
