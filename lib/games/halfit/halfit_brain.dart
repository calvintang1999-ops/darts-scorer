import '../../models/dart_position.dart';
import '../../services/bot/bot_aim_decision.dart';
import 'halfit_config.dart';

/// Decides where a Half It bot should aim: whatever the current round's
/// target itself says is the sensible aim (see [HalfItTarget.botAimLabel])
/// - there's no checkout-style planning here, dispersion just does the
/// rest.
class HalfItBrain {
  const HalfItBrain();

  BotAimDecision nextAim({required HalfItTarget target}) {
    final label = target.botAimLabel;
    return BotAimDecision(
      aimPoint: BoardGeometry.aimPointFor(label),
      isCheckoutAttempt: false,
      targetLabel: label,
    );
  }
}
