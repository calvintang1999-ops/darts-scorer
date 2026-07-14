import 'player.dart';
import 'throw.dart';

/// A finished match, ready to be stored. The full turn history is kept
/// because the stats phase (averages, checkout %, heatmaps) needs every
/// individual throw, not just the result.
class MatchRecord {
  MatchRecord({
    required this.gameId,
    required this.gameName,
    required this.players,
    required this.turnHistory,
    required this.winnerId,
    this.config,
    DateTime? finishedAt,
  }) : finishedAt = finishedAt ?? DateTime.now();

  final String gameId;

  /// Registry id of the game mode, e.g. "x01".
  final String gameName;

  final List<Player> players;
  final List<Turn> turnHistory;

  /// Null if the match was abandoned rather than won.
  final String? winnerId;

  final DateTime finishedAt;

  /// A snapshot of the handful of config values (e.g. X01's
  /// startingScore/outRule) needed to correctly interpret this match's
  /// throws for stats - see lib/services/stats/. Not a computed aggregate,
  /// just provenance data, same category as gameName. Null for matches
  /// saved before this existed; stats calculators fall back to that
  /// game's own config defaults in that case.
  final Map<String, Object?>? config;

  Map<String, Object?> toJson() => {
        'gameId': gameId,
        'gameName': gameName,
        'players': [for (final p in players) p.toJson()],
        'turnHistory': [for (final t in turnHistory) t.toJson()],
        'winnerId': winnerId,
        'finishedAt': finishedAt.toIso8601String(),
        'config': config,
      };
}
