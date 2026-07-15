import '../../models/dart_position.dart';
import '../../services/bot/bot_aim_decision.dart';
import 'cricket_config.dart';
import 'cricket_strategy.dart';

/// Decides where a Cricket bot should aim its next dart, re-evaluated from
/// scratch after every dart (same "no memory of its own" design as
/// X01Brain) - just hand it the live board state each time.
///
/// In a 3+ player match, "behind on points" and "a threatening opponent"
/// are both judged against whichever opponent currently leads - in a
/// 2-player match that's just the one opponent, so the same logic applies
/// unchanged.
class CricketBrain {
  const CricketBrain({this.strategy = const CricketStrategy()});

  final CricketStrategy strategy;

  BotAimDecision nextAim({
    /// The numbers in play, e.g. [20, 19, ..., 15, 25].
    required List<int> numbers,
    /// My marks (0-3) per number.
    required Map<int, int> myMarks,
    /// One marks-per-number map per opponent, same keys as [myMarks].
    required List<Map<int, int>> opponentMarks,
    required int myPoints,
    required List<int> opponentPoints,
    required CricketMode mode,
  }) {
    assert(opponentMarks.length == opponentPoints.length);
    assert(opponentMarks.isNotEmpty);

    // Never aim at a number everyone (me and every opponent) has already
    // closed - there's nothing left to gain from it. If that somehow
    // describes every number (nothing better to do), fall back to the
    // full set rather than aiming at nothing.
    final live = numbers
        .where((n) =>
            !(myMarks[n] == 3 && opponentMarks.every((om) => om[n] == 3)))
        .toList();
    final pool = live.isNotEmpty ? live : numbers;

    final leaderIndex = _leadingOpponentIndex(opponentPoints, mode);
    final leaderMarks = opponentMarks[leaderIndex];
    final leaderPoints = opponentPoints[leaderIndex];

    final threat = _highestThreat(pool, myMarks, leaderMarks);
    if (threat != null) return _aimAt(threat);

    final scoringTargets = _sortedDescending(pool.where(
        (n) => myMarks[n] == 3 && opponentMarks.any((om) => om[n]! < 3)));
    final closingTargets = _closingOrder(
        pool.where((n) => myMarks[n]! < 3).toList());

    int? target;
    if (scoringTargets.isNotEmpty && closingTargets.isNotEmpty) {
      // Both a scoring shot and a closing shot are on the table - use
      // pointPriority to break the tie. At the default 0.5 the allowance
      // is exactly 0, so this reduces to "score only if strictly behind;
      // level or ahead, close" - "lead, then cover". Above 0.5 the
      // allowance grows positive, biasing towards scoring even from
      // ahead; below 0.5 it goes negative, biasing towards closing even
      // from slightly behind.
      final margin = _pointsMargin(myPoints, leaderPoints, mode);
      final allowance = (strategy.pointPriority - 0.5) * 1000;
      target = margin < allowance ? scoringTargets.first : closingTargets.first;
    } else if (scoringTargets.isNotEmpty) {
      target = scoringTargets.first;
    } else if (closingTargets.isNotEmpty) {
      target = closingTargets.first;
    }
    target ??= pool.first;

    return _aimAt(target);
  }

  int _leadingOpponentIndex(List<int> opponentPoints, CricketMode mode) {
    var best = 0;
    for (var i = 1; i < opponentPoints.length; i++) {
      // Standard: higher points lead. Cutthroat: lower points lead.
      final better = mode == CricketMode.standard
          ? opponentPoints[i] > opponentPoints[best]
          : opponentPoints[i] < opponentPoints[best];
      if (better) best = i;
    }
    return best;
  }

  /// Positive means I'm ahead of the leader, negative means behind -
  /// normalised the same way regardless of mode, since cutthroat inverts
  /// which raw direction is "good".
  int _pointsMargin(int myPoints, int leaderPoints, CricketMode mode) =>
      mode == CricketMode.standard
          ? myPoints - leaderPoints
          : leaderPoints - myPoints;

  /// The highest-value number where the leader has enough marks to be a
  /// threat and I haven't closed it yet, or null if there's no threat.
  int? _highestThreat(
      List<int> pool, Map<int, int> myMarks, Map<int, int> leaderMarks) {
    final threats = pool
        .where((n) =>
            myMarks[n]! < 3 &&
            leaderMarks[n]! >= strategy.threatMarkThreshold)
        .toList();
    if (threats.isEmpty) return null;
    threats.sort((a, b) => b.compareTo(a));
    return threats.first;
  }

  List<int> _sortedDescending(Iterable<int> values) =>
      values.toList()..sort((a, b) => b.compareTo(a));

  /// Highest value first, but with the bull moved to the very end when
  /// [CricketStrategy.bullLast] is set - it's the hardest target, so a
  /// sound closer leaves it until nothing else remains to close.
  List<int> _closingOrder(List<int> openNumbers) {
    final sorted = _sortedDescending(openNumbers);
    if (!strategy.bullLast || !sorted.contains(bullSegment)) return sorted;
    sorted
      ..remove(bullSegment)
      ..add(bullSegment);
    return sorted;
  }

  BotAimDecision _aimAt(int number) {
    // Default target within a number is the triple bed; the bull has no
    // triple, so its hardest/only serious target is the inner bull.
    final label = number == bullSegment ? 'Bull' : 'T$number';
    return BotAimDecision(
      aimPoint: BoardGeometry.aimPointFor(label),
      isCheckoutAttempt: false,
      targetLabel: label,
    );
  }
}
