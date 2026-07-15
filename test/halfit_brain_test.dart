import 'package:darts/games/halfit/halfit_brain.dart';
import 'package:darts/games/halfit/halfit_config.dart';
import 'package:darts/models/dart_position.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const brain = HalfItBrain();

  test('aims the triple of a number target', () {
    final decision = brain.nextAim(target: const NumberTarget(18));
    expect(decision.targetLabel, 'T18');
    expect(decision.isCheckoutAttempt, false);
  });

  test('aims the inner bull for a bullseye round', () {
    final decision = brain.nextAim(target: const BullseyeTarget());
    expect(decision.targetLabel, 'Bull');
  });

  test('aims a double for an any-double round', () {
    final decision = brain.nextAim(target: const AnyDoubleTarget());
    expect(decision.targetLabel, 'D20');
  });

  test('aims a treble for an any-treble round', () {
    final decision = brain.nextAim(target: const AnyTrebleTarget());
    expect(decision.targetLabel, 'T20');
  });

  test('aims low and on the board for a "score at most" round', () {
    final decision = brain.nextAim(target: const ScoreAtMostOnBoardTarget(10));
    expect(decision.targetLabel, '1');
  });

  test('every decision resolves back to its own target label', () {
    for (final target in [
      const NumberTarget(15),
      const AnyDoubleTarget(),
      const AnyTrebleTarget(),
      const BullseyeTarget(),
      const ExactScoreTarget(41),
      const ScoreAtLeastTarget(65),
      const ScoreAtMostOnBoardTarget(10),
      const ThreeColoursTarget(),
      const ThreeInSameBedTarget(),
      const BlackWhiteBlackTarget(),
    ]) {
      final decision = brain.nextAim(target: target);
      final hit = BoardGeometry.segmentAt(decision.aimPoint);
      final relabelled = BoardGeometry.segmentAt(
          BoardGeometry.aimPointFor(decision.targetLabel));
      expect(hit.segment, relabelled.segment, reason: target.label);
      expect(hit.multiplier, relabelled.multiplier, reason: target.label);
    }
  });
}
