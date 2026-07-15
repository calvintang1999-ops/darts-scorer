import '../../models/dart_position.dart';
import '../../services/bot/bot_aim_decision.dart';
import 'round_the_clock_config.dart';

/// Decides where a Round the Clock bot should aim: whatever the current
/// stop requires. A bull stop needs its exact ring, so there's no bonus
/// for aiming bigger. A numbered stop under [RoundTheClockMultiplierRule.
/// multiplierAdvances] is worth aiming the treble of, since any multiplier
/// advances and a treble covers the most ground per dart; under
/// singlesOnly only a plain single counts at all, so that's the only
/// sensible aim.
class RoundTheClockBrain {
  const RoundTheClockBrain();

  BotAimDecision nextAim({
    required RoundTheClockStop stop,
    required RoundTheClockMultiplierRule multiplierRule,
  }) {
    final String label;
    if (stop.requiredMultiplier != null) {
      // Bull stops: 1 = outer bull (25), 2 = inner bull (50).
      label = stop.requiredMultiplier == 2 ? 'Bull' : '25';
    } else if (multiplierRule == RoundTheClockMultiplierRule.multiplierAdvances) {
      label = 'T${stop.segment}';
    } else {
      label = '${stop.segment}';
    }
    return BotAimDecision(
      aimPoint: BoardGeometry.aimPointFor(label),
      isCheckoutAttempt: false,
      targetLabel: label,
    );
  }
}
