import '../../models/dart_position.dart';

/// The kind of bed a bot is aiming at, coarser than a full [SegmentHit] -
/// arms that care about pressure (e.g. "hands shake more on a double for
/// the match") can key off this without caring which number it is.
enum TargetType { triple, double, single, bull, outerBull }

/// Works out the [TargetType] of an aim point by resolving it through
/// [BoardGeometry.segmentAt] - the aim point is always the single source of
/// truth for what's being aimed at, never a separately-tracked value.
TargetType targetTypeFor(DartPosition aimPoint) {
  final hit = BoardGeometry.segmentAt(aimPoint);
  if (hit.segment == bullSegment) {
    return hit.multiplier == 2 ? TargetType.bull : TargetType.outerBull;
  }
  switch (hit.multiplier) {
    case 3:
      return TargetType.triple;
    case 2:
      return TargetType.double;
    default:
      return TargetType.single;
  }
}

/// Everything a [BotArm] might want to know about the dart it's about to
/// throw, besides the aim point itself. A Phase 3 [GaussianArm] ignores all
/// of this - it's here so later arms (pressure on a checkout dart, fatigue
/// over a long match) can react without changing the brain/arm interface.
class ThrowContext {
  const ThrowContext({
    required this.targetType,
    required this.isCheckoutAttempt,
    required this.dartIndexInTurn,
    required this.dartIndexInMatch,
  });

  /// Convenience constructor that derives [targetType] from the aim point,
  /// since it should always agree with what's actually being aimed at.
  factory ThrowContext.forAim(
    DartPosition aimPoint, {
    required bool isCheckoutAttempt,
    required int dartIndexInTurn,
    required int dartIndexInMatch,
  }) =>
      ThrowContext(
        targetType: targetTypeFor(aimPoint),
        isCheckoutAttempt: isCheckoutAttempt,
        dartIndexInTurn: dartIndexInTurn,
        dartIndexInMatch: dartIndexInMatch,
      );

  final TargetType targetType;

  /// True when the brain thinks hitting this aim point would win the leg.
  /// X01Brain sets this; brains for other games always pass false.
  final bool isCheckoutAttempt;

  /// 0, 1, or 2 - which dart of the current turn this is.
  final int dartIndexInTurn;

  /// Cumulative dart count for the whole match, for future pacing/fatigue
  /// arms.
  final int dartIndexInMatch;
}
