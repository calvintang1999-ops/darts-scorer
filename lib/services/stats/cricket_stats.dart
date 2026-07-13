import '../../games/cricket/cricket_config.dart';
import '../../models/dart_position.dart';
import '../../models/match_record.dart';
import '../../models/player.dart';

/// Everything computed for one player's Cricket history. "Round" here
/// means one 3-dart visit, matching how MPR (marks per round) is defined
/// everywhere else in darts.
class CricketStats {
  const CricketStats({
    required this.matchesPlayed,
    required this.marksPerRound,
    required this.mostMarksInRound,
    required this.fivePlusRounds,
    required this.sixPlusRounds,
    required this.sevenPlusRounds,
    required this.bullsPerRound,
  });

  final int matchesPlayed;
  final double? marksPerRound;
  final int? mostMarksInRound;
  final int fivePlusRounds;
  final int sixPlusRounds;
  final int sevenPlusRounds;
  final double? bullsPerRound;

  static const empty = CricketStats(
    matchesPlayed: 0,
    marksPerRound: null,
    mostMarksInRound: null,
    fivePlusRounds: 0,
    sixPlusRounds: 0,
    sevenPlusRounds: 0,
    bullsPerRound: null,
  );

  /// [matches] must already be filtered to this player and to Cricket -
  /// see `matchesForPlayer` in stats_filter.dart.
  factory CricketStats.compute(Player player, List<MatchRecord> matches) {
    if (matches.isEmpty) return empty;

    var totalMarks = 0;
    var totalBulls = 0;
    var totalRounds = 0;
    var mostMarksInRound = 0;
    var fivePlus = 0, sixPlus = 0, sevenPlus = 0;

    for (final match in matches) {
      // Which numbers actually counted as marks for this match - needed
      // because a hit outside that set (e.g. a stray dart, or a number
      // excluded by a raised lowNumber) never counts as a mark, no matter
      // how it's scored.
      final numbers = _configFrom(match.config).numbers.toSet();

      for (final turn in match.turnHistory) {
        if (turn.player.id != player.id) continue;
        totalRounds++;
        var marksThisRound = 0;
        var bullsThisRound = 0;
        for (final dart in turn.throws) {
          if (numbers.contains(dart.actualSegment)) {
            marksThisRound += dart.multiplier;
          }
          if (dart.actualSegment == bullSegment) {
            bullsThisRound += dart.multiplier;
          }
        }
        totalMarks += marksThisRound;
        totalBulls += bullsThisRound;
        if (marksThisRound > mostMarksInRound) mostMarksInRound = marksThisRound;
        if (marksThisRound >= 5) fivePlus++;
        if (marksThisRound >= 6) sixPlus++;
        if (marksThisRound >= 7) sevenPlus++;
      }
    }

    return CricketStats(
      matchesPlayed: matches.length,
      marksPerRound: totalRounds == 0 ? null : totalMarks / totalRounds,
      mostMarksInRound: totalRounds == 0 ? null : mostMarksInRound,
      fivePlusRounds: fivePlus,
      sixPlusRounds: sixPlus,
      sevenPlusRounds: sevenPlus,
      bullsPerRound: totalRounds == 0 ? null : totalBulls / totalRounds,
    );
  }

  /// [match.config] as saved by CricketPlayScreen, or this game's own
  /// defaults for matches saved before schema v3 added the config
  /// snapshot.
  static CricketConfig _configFrom(Map<String, Object?>? config) {
    if (config == null) return const CricketConfig();
    return CricketConfig(
      lowNumber: config['lowNumber'] as int? ?? 15,
      includeBull: config['includeBull'] as bool? ?? true,
    );
  }
}
