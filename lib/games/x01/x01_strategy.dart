import '../../models/segment.dart';

/// Tunable "personality" for an [X01Brain]. The defaults describe how
/// nearly every real player plays, so every preset bot can use
/// `X01Strategy()` with no arguments - a custom strategy (e.g. a character
/// who scores off T19 instead) is what future career-mode bots would tweak.
class X01Strategy {
  const X01Strategy({
    this.preferredScoringBed = Segment.t20,
    this.preferredSetupLeaves = const [40, 32, 36, 24, 16, 8],
  });

  /// What to aim for when just scoring (not yet in checkout range).
  final Segment preferredScoringBed;

  /// Doubles to try to leave when the current score can't be finished with
  /// the darts in hand this turn, in priority order.
  final List<int> preferredSetupLeaves;
}
