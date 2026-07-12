import '../../models/dart_position.dart';
import '../../models/game_config.dart';

/// Whether extra marks on an already-closed number score points for
/// yourself (standard) or get piled onto your opponents (cutthroat).
enum CricketMode { standard, cutthroat }

/// All the options for a Cricket match. Defaults are the standard game -
/// 15 to 20 plus the bull, standard scoring - so "quick start" needs no
/// configuration at all.
class CricketConfig extends GameConfig {
  const CricketConfig({
    this.lowNumber = 15,
    this.includeBull = true,
    this.mode = CricketMode.standard,
  }) : assert(lowNumber >= 10 && lowNumber <= 20,
            'lowNumber must be between 10 and 20');

  /// Numbers run from here up to 20. Standard play starts at 15; some
  /// casual variants open it up as low as 10 for beginners.
  final int lowNumber;

  /// Whether the bull (25) is one of the numbers that must be closed.
  final bool includeBull;

  final CricketMode mode;

  /// The numbers in play, highest first (matches how a cricket scoreboard
  /// is usually laid out), with the bull last if included.
  List<int> get numbers => [
        for (var n = 20; n >= lowNumber; n--) n,
        if (includeBull) bullSegment,
      ];
}
