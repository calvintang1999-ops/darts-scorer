import 'dart:math';

import 'package:darts/games/halfit/halfit_config.dart';
import 'package:darts/games/halfit/halfit_game.dart';
import 'package:darts/models/dart_position.dart';
import 'package:darts/models/player.dart';
import 'package:darts/models/throw.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Player p0;
  late Player p1;

  setUp(() {
    p0 = Player.create('P0');
    p1 = Player.create('P1');
  });

  Throw dart(Player player, int segment, int multiplier, {String? gameId}) =>
      Throw(
        player: player,
        actualSegment: segment,
        multiplier: multiplier,
        gameId: gameId ?? 'test-game',
      );

  void throwDart(HalfItGame game, Player player, int segment, int multiplier) {
    game.applyThrow(dart(player, segment, multiplier, gameId: game.gameId));
  }

  group('dartColour', () {
    test('matches the standard board layout', () {
      // 20 is the first (index 0, even) wedge clockwise from the top.
      expect(dartColour(20, 1), DartColour.black);
      // 1 is the second (index 1, odd) wedge.
      expect(dartColour(1, 1), DartColour.white);
    });

    test('doubles and trebles are never black or white', () {
      expect(dartColour(20, 2), isNot(DartColour.black));
      expect(dartColour(20, 3), isNot(DartColour.black));
      expect(dartColour(20, 2), isNot(DartColour.white));
    });

    test('bull colours match the spec', () {
      expect(dartColour(bullSegment, 2), DartColour.red); // inner bull (50)
      expect(dartColour(bullSegment, 1), DartColour.green); // outer bull (25)
    });

    test('a miss has no colour', () {
      expect(dartColour(missSegment, 1), isNull);
    });
  });

  group('match flow', () {
    test('finishes after the last player throws the last round, highest '
        'score wins', () {
      final game = HalfItGame(
        players: [p0, p1],
        config: const HalfItConfig(
          sequenceType: HalfItSequenceType.fixed,
          fixedSequence: [NumberTarget(20), BullseyeTarget()],
        ),
      );

      // Round 0 (target: 20). P0 hits it three times for 60 -> 20+60=80.
      throwDart(game, p0, 20, 1);
      throwDart(game, p0, 20, 1);
      throwDart(game, p0, 20, 1);
      expect(game.scores[0], 80);

      // P1 misses entirely -> halved 20 -> 10.
      throwDart(game, p1, 5, 1);
      throwDart(game, p1, 5, 1);
      throwDart(game, p1, 5, 1);
      expect(game.scores[1], 10);
      expect(game.currentRoundIndex, 1); // round advanced after P1 wrapped

      // Round 1 (target: bull). P0 misses -> halved 80 -> 40.
      throwDart(game, p0, 5, 1);
      throwDart(game, p0, 5, 1);
      throwDart(game, p0, 5, 1);
      expect(game.scores[0], 40);
      expect(game.isFinished, isFalse);

      // P1 hits the outer bull once -> 10+25=35. This is the last turn
      // of the match (last round, last player).
      throwDart(game, p1, 25, 1);
      throwDart(game, p1, 5, 1);
      throwDart(game, p1, 5, 1);

      expect(game.turnHistory.length, 4);
      expect(game.isFinished, isTrue);
      expect(game.scores, [40, 35]);
      expect(game.winner, p0);
    });

    test('a miss halves the running score, rounded down', () {
      final game = HalfItGame(
        players: [p0],
        config: const HalfItConfig(
          sequenceType: HalfItSequenceType.fixed,
          fixedSequence: [NumberTarget(5), NumberTarget(1)],
        ),
      );

      // Hit 5 once (plus 2 filler darts on a dead number) -> 20+5=25.
      throwDart(game, p0, 5, 1);
      throwDart(game, p0, 3, 1);
      throwDart(game, p0, 3, 1);
      expect(game.scores[0], 25);

      // Miss entirely -> floor(25/2) = 12, not 13.
      throwDart(game, p0, 3, 1);
      throwDart(game, p0, 3, 1);
      throwDart(game, p0, 3, 1);
      expect(game.scores[0], 12);
      expect(game.wasHalvedThisRound, isTrue);
      expect(game.isFinished, isTrue); // was also the last round
      expect(game.winner, p0);
    });

    test('undo reverts across a round boundary, including the player and '
        'round index', () {
      final game = HalfItGame(
        players: [p0, p1],
        config: const HalfItConfig(
          sequenceType: HalfItSequenceType.fixed,
          fixedSequence: [NumberTarget(20), NumberTarget(1)],
        ),
      );

      throwDart(game, p0, 20, 1);
      throwDart(game, p0, 20, 1);
      throwDart(game, p0, 20, 1);

      throwDart(game, p1, 5, 1);
      throwDart(game, p1, 5, 1);
      // One dart left in P1's turn - about to cross the round boundary.
      expect(game.currentRoundIndex, 0);
      expect(game.currentPlayerIndex, 1);

      throwDart(game, p1, 5, 1); // 3rd dart: ends round 0, wraps to P0
      expect(game.currentRoundIndex, 1);
      expect(game.currentPlayerIndex, 0);
      expect(game.scores[1], 10); // halved

      game.undo();
      expect(game.currentRoundIndex, 0);
      expect(game.currentPlayerIndex, 1);
      expect(game.currentTurnThrows.length, 2);
      expect(game.scores[1], 20); // not yet halved
    });
  });

  group('individual targets', () {
    test('Black-White-Black is order-dependent', () {
      const target = BlackWhiteBlackTarget();

      final inOrder = [dart(p0, 20, 1), dart(p0, 1, 1), dart(p0, 18, 1)];
      final result = target.evaluate(inOrder);
      expect(result.hit, isTrue);
      expect(result.points, 20 + 1 + 18);

      final wrongOrder = [dart(p0, 1, 1), dart(p0, 20, 1), dart(p0, 18, 1)];
      expect(target.evaluate(wrongOrder).hit, isFalse);
    });

    test('Score <=10 is disqualified by a single off-board dart', () {
      const target = ScoreAtMostOnBoardTarget(10);

      final allOnBoard = [dart(p0, 5, 1), dart(p0, 3, 1), dart(p0, 2, 1)];
      final hit = target.evaluate(allOnBoard);
      expect(hit.hit, isTrue);
      expect(hit.points, 10);

      final oneOffBoard = [
        dart(p0, 5, 1),
        dart(p0, 3, 1),
        dart(p0, missSegment, 1),
      ];
      final miss = target.evaluate(oneOffBoard);
      expect(miss.hit, isFalse);
      expect(miss.points, 0);
    });

    test('exact score hits only on the boundary', () {
      const target = ExactScoreTarget(41);

      final exact = [dart(p0, 20, 1), dart(p0, 20, 1), dart(p0, 1, 1)];
      expect(target.evaluate(exact).hit, isTrue);
      expect(target.evaluate(exact).points, 41);

      final under = [dart(p0, 20, 1), dart(p0, 20, 1), dart(p0, missSegment, 1)];
      expect(target.evaluate(under).hit, isFalse);

      final over = [dart(p0, 20, 1), dart(p0, 20, 1), dart(p0, 2, 1)];
      expect(target.evaluate(over).hit, isFalse);
    });

    test('3 Colours requires one of each: black single, white single, a '
        'red-or-green segment', () {
      const target = ThreeColoursTarget();

      // 20 (black single), 1 (white single), D18 (a red ring hit).
      final hit = [dart(p0, 20, 1), dart(p0, 1, 1), dart(p0, 18, 2)];
      final result = target.evaluate(hit);
      expect(result.hit, isTrue);
      expect(result.points, 20 + 1 + 36);

      // The bull counts as the red-or-green dart too.
      final withOuterBull = [
        dart(p0, 20, 1),
        dart(p0, 1, 1),
        dart(p0, bullSegment, 1), // outer bull - green
      ];
      final outerResult = target.evaluate(withOuterBull);
      expect(outerResult.hit, isTrue);
      expect(outerResult.points, 20 + 1 + 25);

      final withDoubleBull = [
        dart(p0, 20, 1),
        dart(p0, 1, 1),
        dart(p0, bullSegment, 2), // inner/double bull - red
      ];
      final innerResult = target.evaluate(withDoubleBull);
      expect(innerResult.hit, isTrue);
      expect(innerResult.points, 20 + 1 + 50);

      // Three black singles: no white, no ring hit - a clear miss, and
      // pins that each colour must appear exactly once, not "at least".
      final allBlack = [dart(p0, 20, 1), dart(p0, 18, 1), dart(p0, 13, 1)];
      expect(target.evaluate(allBlack).hit, isFalse);
    });

    test('3 in a bed requires all three darts on the same wedge', () {
      const target = ThreeInSameBedTarget();

      final sameWedge = [dart(p0, 20, 1), dart(p0, 20, 3), dart(p0, 20, 2)];
      final result = target.evaluate(sameWedge);
      expect(result.hit, isTrue);
      expect(result.points, 20 + 60 + 40);

      final mixed = [dart(p0, 20, 1), dart(p0, 20, 1), dart(p0, 19, 1)];
      expect(target.evaluate(mixed).hit, isFalse);
    });

    test('Any Double and Any Treble exclude the bull', () {
      const doubleTarget = AnyDoubleTarget();
      const trebleTarget = AnyTrebleTarget();

      final darts = [
        dart(p0, 20, 2), // qualifies for double
        dart(p0, bullSegment, 2), // inner bull - does not qualify
        dart(p0, 5, 1),
      ];
      final doubleResult = doubleTarget.evaluate(darts);
      expect(doubleResult.hit, isTrue);
      expect(doubleResult.points, 40);

      expect(trebleTarget.evaluate(darts).hit, isFalse);
    });
  });

  group('target pool and sequence building', () {
    test('the bull is excluded from the random pool', () {
      expect(
        halfItTargetPool.any((t) => t is BullseyeTarget),
        isFalse,
      );
    });

    test('a randomized match always ends on the bull', () {
      final game = HalfItGame(
        players: [p0],
        config: const HalfItConfig(roundCount: 5),
        random: Random(42),
      );
      expect(game.targets.length, 5);
      expect(game.targets.last, isA<BullseyeTarget>());
      expect(game.targets.sublist(0, 4).any((t) => t is BullseyeTarget),
          isFalse);
    });

    test('the random pool only draws numbers 15-20', () {
      final numberTargets =
          halfItTargetPool.whereType<NumberTarget>().toList();
      expect(numberTargets.map((t) => t.number).toSet(), {15, 16, 17, 18, 19, 20});
    });
  });

  group('labels', () {
    test('number and score targets say what kind of target they are', () {
      expect(const NumberTarget(20).label, 'Target segment: 20');
      expect(const ExactScoreTarget(41).label, 'Target score: 41');
      expect(const ScoreAtLeastTarget(65).label, 'Target score: 65+');
      expect(const ScoreAtMostOnBoardTarget(10).label, 'Target score: ≤10');
    });
  });

  group('early hit', () {
    test('an exact score reached in fewer than 3 darts ends the turn '
        'immediately', () {
      final game = HalfItGame(
        players: [p0],
        config: const HalfItConfig(
          sequenceType: HalfItSequenceType.fixed,
          fixedSequence: [ExactScoreTarget(41)],
        ),
      );

      throwDart(game, p0, 13, 3); // T13 = 39
      expect(game.isFinished, isFalse);
      expect(game.currentTurnThrows.length, 1);

      throwDart(game, p0, 1, 2); // D1 = 2, total now exactly 41
      // The turn (and, with only 1 round, the match) ended after 2 darts
      // - no 3rd dart was needed or requested.
      expect(game.currentTurnThrows, isEmpty);
      expect(game.scores[0], 20 + 41);
      expect(game.isFinished, isTrue);
      expect(game.turnHistory.single.throws.length, 2);
    });

    test('an early hit mid-match advances to the next player, not just '
        'the end of the match', () {
      final game = HalfItGame(
        players: [p0, p1],
        config: const HalfItConfig(
          sequenceType: HalfItSequenceType.fixed,
          fixedSequence: [ExactScoreTarget(41), NumberTarget(20)],
        ),
      );

      throwDart(game, p0, 13, 3); // T13 = 39
      throwDart(game, p0, 1, 2); // D1 = 2, total exactly 41 - early hit
      expect(game.isFinished, isFalse);
      expect(game.currentPlayerIndex, 1); // moved on to P1
      expect(game.currentRoundIndex, 0); // still round 0 - P1 hasn't gone
      expect(game.scores[0], 20 + 41);
    });

    test('an exact score NOT yet reached after 2 darts keeps the turn open',
        () {
      final game = HalfItGame(
        players: [p0],
        config: const HalfItConfig(
          sequenceType: HalfItSequenceType.fixed,
          fixedSequence: [ExactScoreTarget(41)],
        ),
      );

      throwDart(game, p0, 5, 1); // 5, nowhere near 41
      throwDart(game, p0, 5, 1); // 10 total - still not 41
      expect(game.isFinished, isFalse);
      expect(game.currentTurnThrows.length, 2); // still waiting on dart 3

      throwDart(game, p0, 5, 1); // 15 total - misses on the 3rd dart
      expect(game.isFinished, isTrue);
      expect(game.scores[0], 20 ~/ 2);
    });
  });
}
