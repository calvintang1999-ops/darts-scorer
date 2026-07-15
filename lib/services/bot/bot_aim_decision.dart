import '../../models/dart_position.dart';

/// What a [BotBrain] (one per game type - X01Brain, CricketBrain, etc.)
/// wants to do with its next dart: where to aim, whether hitting it would
/// win the leg, and the board label it chose (kept around mainly so tests
/// can assert on it without re-deriving it from the aim point).
class BotAimDecision {
  const BotAimDecision({
    required this.aimPoint,
    required this.isCheckoutAttempt,
    required this.targetLabel,
  });

  final DartPosition aimPoint;

  /// True when the brain thinks this dart could win the leg/match. Only
  /// X01Brain ever sets this true - every other brain always passes false,
  /// since only X01 has a "the final dart must be a double" checkout
  /// concept for [ThrowContext] to care about.
  final bool isCheckoutAttempt;
  final String targetLabel;
}
