import 'package:darts/games/cricket/cricket_brain.dart';
import 'package:darts/games/cricket/cricket_config.dart';
import 'package:darts/games/cricket/cricket_strategy.dart';
import 'package:darts/models/dart_position.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('threat response', () {
    test('blocks a threatened 18 ahead of anything else', () {
      const brain = CricketBrain();
      final decision = brain.nextAim(
        numbers: const [20, 19, 18, 17],
        myMarks: const {20: 1, 19: 0, 18: 1, 17: 0},
        // The opponent has 2+ marks (the default threshold) on 18, which I
        // haven't closed - that's a threat, even though 20 is technically
        // "my" highest-value open number.
        opponentMarks: const [
          {20: 0, 19: 0, 18: 2, 17: 0}
        ],
        myPoints: 0,
        opponentPoints: const [0],
        mode: CricketMode.standard,
      );
      expect(decision.targetLabel, 'T18');
      expect(decision.isCheckoutAttempt, false);
    });
  });

  group('points decision - lead then cover', () {
    test('points on a number I have closed when behind', () {
      const brain = CricketBrain();
      final decision = brain.nextAim(
        numbers: const [20, 19, 18],
        myMarks: const {20: 3, 19: 0, 18: 0},
        opponentMarks: const [
          {20: 1, 19: 0, 18: 0}
        ],
        myPoints: 0,
        opponentPoints: const [50], // I'm behind
        mode: CricketMode.standard,
      );
      expect(decision.targetLabel, 'T20');
    });

    test('switches from pointing to closing once ahead', () {
      const brain = CricketBrain();
      final decision = brain.nextAim(
        numbers: const [20, 19, 18],
        myMarks: const {20: 3, 19: 0, 18: 0},
        opponentMarks: const [
          {20: 1, 19: 0, 18: 0}
        ],
        myPoints: 100,
        opponentPoints: const [50], // now ahead
        mode: CricketMode.standard,
      );
      // 20 is closed by me (a live scoring option, opponent hasn't closed
      // it) but I'm ahead, so the default strategy should close instead -
      // the next-highest open number, 19.
      expect(decision.targetLabel, 'T19');
    });

    test('a level score also means close, not score (strict cutoff)', () {
      const brain = CricketBrain();
      final decision = brain.nextAim(
        numbers: const [20, 19],
        myMarks: const {20: 3, 19: 0},
        opponentMarks: const [
          {20: 1, 19: 0}
        ],
        myPoints: 50,
        opponentPoints: const [50], // exactly level
        mode: CricketMode.standard,
      );
      expect(decision.targetLabel, 'T19');
    });
  });

  group('dead numbers', () {
    test('never aims at a number closed by every player', () {
      const brain = CricketBrain();
      final decision = brain.nextAim(
        numbers: const [20, 19, 18],
        // 20 is closed by me AND the opponent - dead, nothing to gain.
        myMarks: const {20: 3, 19: 0, 18: 0},
        opponentMarks: const [
          {20: 3, 19: 0, 18: 0}
        ],
        myPoints: 0,
        opponentPoints: const [0],
        mode: CricketMode.standard,
      );
      expect(decision.targetLabel, isNot('T20'));
      expect(decision.targetLabel, 'T19');
    });
  });

  group('bull saved for last', () {
    test('closes other open numbers before the bull', () {
      const brain = CricketBrain();
      final firstDecision = brain.nextAim(
        numbers: const [20, 25],
        myMarks: const {20: 0, 25: 0},
        opponentMarks: const [
          {20: 0, 25: 0}
        ],
        myPoints: 0,
        opponentPoints: const [0],
        mode: CricketMode.standard,
      );
      expect(firstDecision.targetLabel, 'T20');

      // Once 20 is closed, the bull is all that's left.
      final secondDecision = brain.nextAim(
        numbers: const [20, 25],
        myMarks: const {20: 3, 25: 0},
        opponentMarks: const [
          {20: 3, 25: 0}
        ],
        myPoints: 0,
        opponentPoints: const [0],
        mode: CricketMode.standard,
      );
      expect(secondDecision.targetLabel, 'Bull');
    });
  });

  group('custom strategy', () {
    test('a low pointPriority prefers closing even when behind', () {
      String targetFor(double pointPriority) => CricketBrain(
            strategy: CricketStrategy(pointPriority: pointPriority),
          )
              .nextAim(
                numbers: const [20, 19],
                myMarks: const {20: 3, 19: 0},
                opponentMarks: const [
                  {20: 1, 19: 0}
                ],
                myPoints: 0,
                opponentPoints: const [50], // behind by 50
                mode: CricketMode.standard,
              )
              .targetLabel;

      expect(targetFor(0.5), 'T20'); // scores
      expect(targetFor(0.1), 'T19'); // closes
    });

    test('bullLast: false lets the bull be picked first', () {
      final brain =
          CricketBrain(strategy: const CricketStrategy(bullLast: false));
      final decision = brain.nextAim(
        numbers: const [20, 25],
        myMarks: const {20: 0, 25: 0},
        opponentMarks: const [
          {20: 0, 25: 0}
        ],
        myPoints: 0,
        opponentPoints: const [0],
        mode: CricketMode.standard,
      );
      expect(decision.targetLabel, 'Bull');
    });
  });

  group('cutthroat mode inverts ahead/behind', () {
    test('lower points means ahead, so the default strategy closes', () {
      const brain = CricketBrain();
      final decision = brain.nextAim(
        numbers: const [20, 19],
        myMarks: const {20: 3, 19: 0},
        opponentMarks: const [
          {20: 1, 19: 0}
        ],
        myPoints: 10,
        opponentPoints: const [50], // I have fewer points - ahead in cutthroat
        mode: CricketMode.cutthroat,
      );
      expect(decision.targetLabel, 'T19');
    });
  });

  group('aim points are real board positions', () {
    test('every decision resolves back to its own target label', () {
      const brain = CricketBrain();
      final decision = brain.nextAim(
        numbers: const [20, 19, 25],
        myMarks: const {20: 0, 19: 0, 25: 0},
        opponentMarks: const [
          {20: 0, 19: 0, 25: 0}
        ],
        myPoints: 0,
        opponentPoints: const [0],
        mode: CricketMode.standard,
      );
      final hit = BoardGeometry.segmentAt(decision.aimPoint);
      final relabelled = BoardGeometry.segmentAt(
          BoardGeometry.aimPointFor(decision.targetLabel));
      expect(hit.segment, relabelled.segment);
      expect(hit.multiplier, relabelled.multiplier);
    });
  });
}
