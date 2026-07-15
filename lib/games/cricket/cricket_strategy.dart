/// Tunable "personality" for a [CricketBrain]. The defaults describe
/// standard, sound Cricket tactics ("lead, then cover" - score when
/// behind, close when level or ahead), so every preset bot can use
/// `CricketStrategy()` with no arguments; only their aim dispersion
/// differs. A custom strategy (future career-mode characters) can shift
/// how aggressively it chases points vs. closing, and whether it leaves
/// the bull for last.
class CricketStrategy {
  const CricketStrategy({
    this.pointPriority = 0.5,
    this.bullLast = true,
    this.threatMarkThreshold = 2,
  });

  /// 0.0 = pure closer (always closes when it can, never chases points).
  /// 1.0 = pure pointer (always chases points when it can, even miles
  /// ahead). 0.5 is the balanced default: score when behind, close when
  /// level or ahead.
  final double pointPriority;

  /// Whether the bull is closed last among open numbers, since it's the
  /// hardest target on the board.
  final bool bullLast;

  /// How many marks an opponent needs on a number (that I haven't closed)
  /// before I treat it as a threat worth blocking.
  final int threatMarkThreshold;
}
