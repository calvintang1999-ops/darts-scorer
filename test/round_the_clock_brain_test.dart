import 'package:darts/games/round_the_clock/round_the_clock_brain.dart';
import 'package:darts/games/round_the_clock/round_the_clock_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const brain = RoundTheClockBrain();

  test('aims the treble of a numbered stop when multipliers advance', () {
    final decision = brain.nextAim(
      stop: const RoundTheClockStop(segment: 7, label: '7'),
      multiplierRule: RoundTheClockMultiplierRule.multiplierAdvances,
    );
    expect(decision.targetLabel, 'T7');
  });

  test('aims the plain single of a numbered stop in singles-only mode', () {
    final decision = brain.nextAim(
      stop: const RoundTheClockStop(segment: 7, label: '7'),
      multiplierRule: RoundTheClockMultiplierRule.singlesOnly,
    );
    expect(decision.targetLabel, '7');
  });

  test('aims the outer bull for a required-single-25 stop', () {
    final decision = brain.nextAim(
      stop: const RoundTheClockStop(
          segment: 25, label: 'Bull', requiredMultiplier: 1),
      multiplierRule: RoundTheClockMultiplierRule.multiplierAdvances,
    );
    expect(decision.targetLabel, '25');
  });

  test('aims the inner bull for a required-double-25 (the 50) stop', () {
    final decision = brain.nextAim(
      stop: const RoundTheClockStop(
          segment: 25, label: '50', requiredMultiplier: 2),
      multiplierRule: RoundTheClockMultiplierRule.multiplierAdvances,
    );
    expect(decision.targetLabel, 'Bull');
  });

  test('isCheckoutAttempt is always false - only X01Brain sets it', () {
    final decision = brain.nextAim(
      stop: const RoundTheClockStop(segment: 20, label: '20'),
      multiplierRule: RoundTheClockMultiplierRule.multiplierAdvances,
    );
    expect(decision.isCheckoutAttempt, false);
  });
}
