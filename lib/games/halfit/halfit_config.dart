import '../../models/dart_position.dart';
import '../../models/game_config.dart';
import '../../models/throw.dart';

/// The outcome of evaluating one completed turn (up to 3 darts) against a
/// [HalfItTarget].
class HalfItResult {
  const HalfItResult({required this.hit, required this.points});

  /// True if at least one dart qualified for the target.
  final bool hit;

  /// The total face value (segment x multiplier) of every qualifying
  /// dart. Zero on a miss.
  final int points;

  static const miss = HalfItResult(hit: false, points: 0);
}

/// One round's target in a Half It match.
///
/// A target evaluates a whole completed turn (up to 3 darts) at once,
/// not one dart at a time - some targets (3 Colours, exact scores) only
/// make sense as a judgement on the full set of darts thrown. Extend
/// this to add new target types; [HalfItGame] never needs to know which
/// kind of target it's dealing with.
abstract class HalfItTarget {
  const HalfItTarget();

  /// Human label for the UI, unambiguous about what kind of target it is
  /// - e.g. "Target segment: 20" and "Target score: 41" read very
  /// differently even though both are just a number.
  String get label;

  /// Universal scoring rule: points = the total face value of whichever
  /// darts in [darts] qualify for this target. What "qualifies" means is
  /// entirely up to the target.
  HalfItResult evaluate(List<Throw> darts);

  /// True if [dartsSoFar] (fewer than a full turn) already unambiguously
  /// satisfies this target, so the game can end the turn early instead
  /// of making the player throw darts that can't change the outcome -
  /// e.g. reaching an exact score in 2 darts. Only safe for targets
  /// where more qualifying darts can only ever help, never hurt; most
  /// targets need the full turn to judge, so this defaults to false.
  bool isEarlyHit(List<Throw> dartsSoFar) => false;
}

int _sumFaceValue(List<Throw> darts) =>
    darts.fold(0, (total, d) => total + d.scoredPoints);

/// A specific number (1-20). Darts that hit it qualify, at any multiplier.
class NumberTarget extends HalfItTarget {
  const NumberTarget(this.number)
      : assert(number >= 1 && number <= 20, 'number must be 1-20');

  final int number;

  @override
  String get label => 'Target segment: $number';

  @override
  HalfItResult evaluate(List<Throw> darts) {
    final qualifying = darts.where((d) => d.actualSegment == number);
    return HalfItResult(
      hit: qualifying.isNotEmpty,
      points: _sumFaceValue(qualifying.toList()),
    );
  }
}

/// Any double, on a numbered wedge or the inner/double bull (50) - it's
/// still a double ring, same as any other.
class AnyDoubleTarget extends HalfItTarget {
  const AnyDoubleTarget();

  @override
  String get label => 'Any Double';

  @override
  HalfItResult evaluate(List<Throw> darts) {
    final qualifying = darts.where((d) => d.multiplier == 2);
    return HalfItResult(
      hit: qualifying.isNotEmpty,
      points: _sumFaceValue(qualifying.toList()),
    );
  }
}

/// Any treble on a numbered wedge (there's no treble bull, so this never
/// matches the bull in practice).
class AnyTrebleTarget extends HalfItTarget {
  const AnyTrebleTarget();

  @override
  String get label => 'Any Treble';

  @override
  HalfItResult evaluate(List<Throw> darts) {
    final qualifying = darts.where((d) => d.multiplier == 3);
    return HalfItResult(
      hit: qualifying.isNotEmpty,
      points: _sumFaceValue(qualifying.toList()),
    );
  }
}

/// The bull, inner (50) or outer (25).
class BullseyeTarget extends HalfItTarget {
  const BullseyeTarget();

  @override
  String get label => 'Bull';

  @override
  HalfItResult evaluate(List<Throw> darts) {
    final qualifying = darts.where((d) => d.actualSegment == bullSegment);
    return HalfItResult(
      hit: qualifying.isNotEmpty,
      points: _sumFaceValue(qualifying.toList()),
    );
  }
}

/// The darts thrown must total exactly [total] (e.g. 41, 82, 123).
/// Reaching it in fewer than 3 darts is an immediate hit - see
/// [isEarlyHit] - so a full turn only ever needs evaluating on a miss.
class ExactScoreTarget extends HalfItTarget {
  const ExactScoreTarget(this.total);

  final int total;

  @override
  String get label => 'Target score: $total';

  @override
  HalfItResult evaluate(List<Throw> darts) {
    final hit = _sumFaceValue(darts) == total;
    return HalfItResult(hit: hit, points: hit ? total : 0);
  }

  @override
  bool isEarlyHit(List<Throw> dartsSoFar) =>
      dartsSoFar.isNotEmpty &&
      dartsSoFar.length < 3 &&
      _sumFaceValue(dartsSoFar) == total;
}

/// All 3 darts must total [threshold] or more, or the whole turn misses.
class ScoreAtLeastTarget extends HalfItTarget {
  const ScoreAtLeastTarget(this.threshold);

  final int threshold;

  @override
  String get label => 'Target score: $threshold+';

  @override
  HalfItResult evaluate(List<Throw> darts) {
    final sum = _sumFaceValue(darts);
    final hit = darts.length == 3 && sum >= threshold;
    return HalfItResult(hit: hit, points: hit ? sum : 0);
  }
}

/// All 3 darts must land on the board (no misses) and total [max] or
/// less. An off-board dart disqualifies the whole turn even if the
/// on-board darts alone would total low enough.
class ScoreAtMostOnBoardTarget extends HalfItTarget {
  const ScoreAtMostOnBoardTarget(this.max);

  final int max;

  @override
  String get label => 'Target score: ≤$max';

  @override
  HalfItResult evaluate(List<Throw> darts) {
    final allOnBoard =
        darts.length == 3 && darts.every((d) => d.actualSegment > missSegment);
    final sum = _sumFaceValue(darts);
    final hit = allOnBoard && sum <= max;
    return HalfItResult(hit: hit, points: hit ? sum : 0);
  }
}

/// All 3 darts qualify only if, between them, they cover a black single,
/// a white single, and one red-or-green segment. The bull counts towards
/// the red-or-green dart too: the outer bull (25) is green, the inner
/// bull/double bull (50) is red - same colours [dartColour] already
/// assigns them.
class ThreeColoursTarget extends HalfItTarget {
  const ThreeColoursTarget();

  @override
  String get label => '3 Colours';

  @override
  HalfItResult evaluate(List<Throw> darts) {
    if (darts.length != 3) return HalfItResult.miss;
    final colours =
        darts.map((d) => dartColour(d.actualSegment, d.multiplier)).toList();
    final blacks = colours.where((c) => c == DartColour.black).length;
    final whites = colours.where((c) => c == DartColour.white).length;
    final ringHits = colours
        .where((c) => c == DartColour.red || c == DartColour.green)
        .length;
    final hit = blacks == 1 && whites == 1 && ringHits == 1;
    return HalfItResult(hit: hit, points: hit ? _sumFaceValue(darts) : 0);
  }
}

/// All 3 darts qualify only if they all landed in the same number wedge
/// (any mix of single/double/treble on that number).
class ThreeInSameBedTarget extends HalfItTarget {
  const ThreeInSameBedTarget();

  @override
  String get label => '3 in a Bed';

  @override
  HalfItResult evaluate(List<Throw> darts) {
    if (darts.length != 3) return HalfItResult.miss;
    final segment = darts.first.actualSegment;
    final hit = segment != missSegment &&
        darts.every((d) => d.actualSegment == segment);
    return HalfItResult(hit: hit, points: hit ? _sumFaceValue(darts) : 0);
  }
}

/// All 3 darts qualify only if, in throw order, they are black single,
/// white single, black single.
class BlackWhiteBlackTarget extends HalfItTarget {
  const BlackWhiteBlackTarget();

  @override
  String get label => 'Black-White-Black';

  @override
  HalfItResult evaluate(List<Throw> darts) {
    if (darts.length != 3) return HalfItResult.miss;
    final hit = dartColour(darts[0].actualSegment, darts[0].multiplier) ==
            DartColour.black &&
        dartColour(darts[1].actualSegment, darts[1].multiplier) ==
            DartColour.white &&
        dartColour(darts[2].actualSegment, darts[2].multiplier) ==
            DartColour.black;
    return HalfItResult(hit: hit, points: hit ? _sumFaceValue(darts) : 0);
  }
}

/// Every target a randomized match can draw rounds from. The bull is
/// deliberately excluded here - it's always appended as the match's
/// final round instead, never drawn at random into an earlier one.
/// Numbers are limited to 15-20, the standard Half It range.
final List<HalfItTarget> halfItTargetPool = [
  for (var n = 15; n <= 20; n++) NumberTarget(n),
  const AnyDoubleTarget(),
  const AnyTrebleTarget(),
  const ExactScoreTarget(41),
  const ExactScoreTarget(82),
  const ExactScoreTarget(123),
  const ScoreAtLeastTarget(65),
  const ScoreAtMostOnBoardTarget(10),
  const ThreeColoursTarget(),
  const ThreeInSameBedTarget(),
  const BlackWhiteBlackTarget(),
];

/// Whether a match uses a fixed, user-chosen sequence of targets, or a
/// fresh randomized one each game.
enum HalfItSequenceType { fixed, randomized }

/// All the options for a Half It match. The default (randomized, 10
/// rounds, starting score 20) is the standard casual game, so "quick
/// start" needs no configuration at all.
class HalfItConfig extends GameConfig {
  const HalfItConfig({
    this.sequenceType = HalfItSequenceType.randomized,
    this.roundCount = 10,
    this.startingScore = 20,
    this.fixedSequence,
  }) : assert(
          sequenceType != HalfItSequenceType.fixed || fixedSequence != null,
          'fixedSequence is required when sequenceType is fixed',
        );

  final HalfItSequenceType sequenceType;

  /// How many rounds in a randomized match (the bull always fills the
  /// last one). Ignored for a fixed sequence, where the list's own
  /// length decides the round count.
  final int roundCount;

  final int startingScore;

  /// The user-supplied ordered targets, only used when [sequenceType] is
  /// [HalfItSequenceType.fixed].
  final List<HalfItTarget>? fixedSequence;
}
