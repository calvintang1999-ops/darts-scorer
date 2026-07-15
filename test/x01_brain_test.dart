import 'package:darts/games/x01/checkouts.dart';
import 'package:darts/games/x01/x01_brain.dart';
import 'package:darts/games/x01/x01_strategy.dart';
import 'package:darts/models/dart_position.dart';
import 'package:darts/models/segment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('170 finish attempt', () {
    test('follows T20, T20, Bull, flagging only the winning dart', () {
      final brain = X01Brain();

      final first = brain.nextAim(remainingScore: 170, dartsLeftInTurn: 3);
      expect(first.targetLabel, 'T20');
      expect(first.isCheckoutAttempt, false);

      // Recompute after the first dart lands as intended (170 - 60 = 110).
      final second = brain.nextAim(remainingScore: 110, dartsLeftInTurn: 2);
      expect(second.targetLabel, 'T20');
      expect(second.isCheckoutAttempt, false);

      // Recompute after the second dart lands as intended (110 - 60 = 50).
      final third = brain.nextAim(remainingScore: 50, dartsLeftInTurn: 1);
      expect(third.targetLabel, 'Bull');
      expect(third.isCheckoutAttempt, true); // this dart would win the leg
    });
  });

  group('bogey numbers', () {
    test('169 (a bogey) is treated as scoring, not a checkout attempt', () {
      expect(checkoutRoutes.containsKey(169), false); // sanity on the chart
      final brain = X01Brain();

      final decision = brain.nextAim(remainingScore: 169, dartsLeftInTurn: 3);

      expect(decision.targetLabel, 'T20'); // default preferred scoring bed
      expect(decision.isCheckoutAttempt, false);
    });

    test('every listed bogey number falls back to the scoring bed', () {
      final brain = X01Brain();
      for (final bogey in [169, 168, 166, 165, 163, 162, 159]) {
        final decision =
            brain.nextAim(remainingScore: bogey, dartsLeftInTurn: 3);
        expect(decision.targetLabel, 'T20', reason: 'bogey $bogey');
        expect(decision.isCheckoutAttempt, false, reason: 'bogey $bogey');
      }
    });
  });

  group('setup logic', () {
    test('leaves 32 (a preferred double) when the chart route needs more '
        'darts than are left this turn', () {
      final brain = X01Brain();

      // Chart route for 77 is T19, D10 - two darts. With only one dart
      // left this turn it can't be followed, so the brain should instead
      // aim to leave a preferred double: T15 (45 points) leaves exactly
      // 32, the second-priority leave.
      expect(checkoutRoutes[77], isNotNull);
      expect(checkoutRoutes[77]!.length, greaterThan(1));

      final decision = brain.nextAim(remainingScore: 77, dartsLeftInTurn: 1);

      expect(decision.targetLabel, 'T15');
      expect(decision.isCheckoutAttempt, false);
      const leaveHit = 45; // T15
      expect(77 - leaveHit, 32);
    });

    test('never intentionally busts or leaves an unfinishable 1', () {
      final brain = X01Brain();
      // Score 3 can't be finished in a single dart under double-out (its
      // chart route needs two darts), so with one dart left the brain must
      // not aim anything that leaves exactly 0 (a guaranteed bust) or
      // exactly 1 (unfinishable). It should aim single-1, leaving a safe 2.
      final decision = brain.nextAim(remainingScore: 3, dartsLeftInTurn: 1);
      expect(decision.targetLabel, '1');
      expect(3 - 1, 2); // leaves 2 - not 0 (bust) and not 1 (unfinishable)
    });
  });

  group('reacting to what actually happened', () {
    test('a missed treble mid-checkout is recomputed from the live score',
        () {
      final brain = X01Brain();

      final first = brain.nextAim(remainingScore: 170, dartsLeftInTurn: 3);
      expect(first.targetLabel, 'T20');

      // The bot aimed T20 but actually hit S1 - remaining score is now 169
      // (a bogey), not the 110 a hit would have left, and only 2 darts
      // remain in the turn.
      final reaction = brain.nextAim(remainingScore: 169, dartsLeftInTurn: 2);

      expect(reaction.targetLabel, 'T20'); // back to scoring, not chasing 169
      expect(reaction.isCheckoutAttempt, false);
    });
  });

  group('custom strategy', () {
    test('a custom preferred scoring bed actually changes the aim', () {
      final defaultBrain = X01Brain();
      final customBrain =
          X01Brain(strategy: X01Strategy(preferredScoringBed: Segment.treble(19)));

      final defaultDecision =
          defaultBrain.nextAim(remainingScore: 300, dartsLeftInTurn: 3);
      final customDecision =
          customBrain.nextAim(remainingScore: 300, dartsLeftInTurn: 3);

      expect(defaultDecision.targetLabel, 'T20');
      expect(customDecision.targetLabel, 'T19');
      expect(
        customDecision.aimPoint.angleDegrees,
        isNot(defaultDecision.aimPoint.angleDegrees),
      );
    });

    test('a custom setup-leave priority changes the setup target', () {
      // At 41 with one dart left, the default priority (40 first) picks
      // single-1 (41 - 1 = 40). Putting 32 first should instead pick
      // single-9 (41 - 9 = 32).
      final defaultBrain = X01Brain();
      final swappedBrain = X01Brain(
        strategy:
            const X01Strategy(preferredSetupLeaves: [32, 40, 36, 24, 16, 8]),
      );

      final defaultDecision =
          defaultBrain.nextAim(remainingScore: 41, dartsLeftInTurn: 1);
      final swappedDecision =
          swappedBrain.nextAim(remainingScore: 41, dartsLeftInTurn: 1);

      expect(defaultDecision.targetLabel, '1');
      expect(swappedDecision.targetLabel, '9');
    });
  });

  group('isCheckoutAttempt flag correctness', () {
    test('is true only for the last dart of a multi-dart route', () {
      final brain = X01Brain();

      final twoDartRouteFirstDart =
          brain.nextAim(remainingScore: 100, dartsLeftInTurn: 3); // T20, D20
      expect(twoDartRouteFirstDart.targetLabel, 'T20');
      expect(twoDartRouteFirstDart.isCheckoutAttempt, false);

      final finishingDart =
          brain.nextAim(remainingScore: 40, dartsLeftInTurn: 1); // D20
      expect(finishingDart.targetLabel, 'D20');
      expect(finishingDart.isCheckoutAttempt, true);
    });

    test('is false during ordinary scoring, far above checkout range', () {
      final brain = X01Brain();
      final decision = brain.nextAim(remainingScore: 501, dartsLeftInTurn: 3);
      expect(decision.isCheckoutAttempt, false);
    });
  });

  group('aim points are real board positions', () {
    test('every decision resolves back to its own target label', () {
      final brain = X01Brain();
      for (final score in [501, 170, 100, 77, 41, 3, 2]) {
        final decision = brain.nextAim(remainingScore: score, dartsLeftInTurn: 3);
        final hit = BoardGeometry.segmentAt(decision.aimPoint);
        final relabelled = BoardGeometry.aimPointFor(decision.targetLabel);
        final relabelledHit = BoardGeometry.segmentAt(relabelled);
        expect(hit.segment, relabelledHit.segment);
        expect(hit.multiplier, relabelledHit.multiplier);
      }
    });
  });
}
