import '../../models/dart_position.dart';
import '../../models/game_config.dart';

/// What comes after 1-20 in the sequence every player has to complete.
enum RoundTheClockSequence {
  /// Just the numbers 1-20 - the match ends the moment 20 is hit.
  numbersOnly,

  /// Numbers 1-20, then a single "outer bull" stop to finish on.
  plusOuterBull,

  /// Numbers 1-20, then outer bull, then inner bull (the 50) to finish on.
  plusBothBulls,
}

/// How a hit on the current target advances a player through the
/// *numbered* part of the sequence. Never affects the bull - hitting a
/// bull stop always needs its exact ring (see [RoundTheClockStop]) and is
/// always worth exactly one stop, no bonus, no shortcuts.
enum RoundTheClockMultiplierRule {
  /// A single advances 1 stop, a double 2, a treble 3 - enough bonus can
  /// carry you past numbers you weren't even aiming at, right up to the
  /// bull, but never through it.
  multiplierAdvances,

  /// Only a single of the target counts at all, and it's always worth
  /// exactly 1 stop - hitting a double or treble of your target does
  /// nothing, same as a miss.
  singlesOnly,
}

/// One stop in the sequence every player works through.
class RoundTheClockStop {
  const RoundTheClockStop({
    required this.segment,
    required this.label,
    this.requiredMultiplier,
  });

  /// 1-20 for a numbered stop, or [bullSegment] (25) for a bull stop.
  final int segment;

  /// Human label for the UI, e.g. "7", "Bull", "50".
  final String label;

  /// Null for a numbered stop - any ring counts, and the multiplier
  /// decides how many stops it's worth (see [RoundTheClockMultiplierRule]).
  /// Set for a bull stop, where the exact ring is mandatory and never
  /// gives a bonus: 1 for outer bull, 2 for inner bull (the 50). This is
  /// what stops a big multiplier elsewhere from skipping the bull - you
  /// always have to hit it for real.
  final int? requiredMultiplier;
}

/// All the options for a Round the Clock match. The default (1-20 plus
/// both bulls, doubles/trebles advance, starting at 1) is the standard
/// casual game, so "quick start" needs no configuration at all.
class RoundTheClockConfig extends GameConfig {
  const RoundTheClockConfig({
    this.sequence = RoundTheClockSequence.plusBothBulls,
    this.multiplierRule = RoundTheClockMultiplierRule.multiplierAdvances,
    this.startingTarget = 1,
  }) : assert(startingTarget >= 1 && startingTarget <= 20,
            'startingTarget must be between 1 and 20');

  final RoundTheClockSequence sequence;
  final RoundTheClockMultiplierRule multiplierRule;

  /// The first target of the match. Defaults to 1 (the full clock); set it
  /// higher to skip the easy early numbers for a shorter game. The bull
  /// stop(s), if any, always come after 20 regardless of this value.
  final int startingTarget;

  /// The full stop-by-stop sequence every player must complete, in order.
  List<RoundTheClockStop> get stops {
    final stops = [
      for (var n = startingTarget; n <= 20; n++)
        RoundTheClockStop(segment: n, label: '$n'),
    ];
    switch (sequence) {
      case RoundTheClockSequence.numbersOnly:
        break;
      case RoundTheClockSequence.plusOuterBull:
        stops.add(const RoundTheClockStop(
            segment: bullSegment, label: 'Bull', requiredMultiplier: 1));
      case RoundTheClockSequence.plusBothBulls:
        stops.add(const RoundTheClockStop(
            segment: bullSegment, label: 'Bull', requiredMultiplier: 1));
        stops.add(const RoundTheClockStop(
            segment: bullSegment, label: '50', requiredMultiplier: 2));
    }
    return stops;
  }
}
