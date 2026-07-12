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

  // A single-round game whose target is 18 - used throughout as a
  // "deliberately miss/hit" fixture for the core halving mechanic.
  HalfItGame singleRoundGame({int startingScore = 20, int players = 1}) =>
      HalfItGame(
        players: players == 1 ? [p0] : [p0, p1],
        config: HalfItConfig(
          startingScore: startingScore,
          sequenceType: HalfItSequenceType.fixed,
          fixedSequence: const [NumberTarget(18)],
        ),
      );

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

  group('Core halving mechanic', () {
    test('starting score is the configured value (default 20)', () {
      final game = HalfItGame(players: [p0], config: const HalfItConfig());
      expect(game.scores[0], 20);
    });

    test('a custom starting score is respected', () {
      final game = HalfItGame(
        players: [p0, p1],
        config: const HalfItConfig(startingScore: 50),
      );
      expect(game.scores, [50, 50]);
    });

    test('missing entirely halves the score, rounded down', () {
      // 41 -> 20 (not 21): floor(41/2), the classic "off by one" case.
      final fortyOne = singleRoundGame(startingScore: 41);
      throwDart(fortyOne, p0, 5, 1);
      throwDart(fortyOne, p0, 5, 1);
      throwDart(fortyOne, p0, 5, 1);
      expect(fortyOne.scores[0], 20);

      final twenty = singleRoundGame(startingScore: 20);
      throwDart(twenty, p0, 5, 1);
      throwDart(twenty, p0, 5, 1);
      throwDart(twenty, p0, 5, 1);
      expect(twenty.scores[0], 10);

      final one = singleRoundGame(startingScore: 1);
      throwDart(one, p0, 5, 1);
      throwDart(one, p0, 5, 1);
      throwDart(one, p0, 5, 1);
      expect(one.scores[0], 0);

      final zero = singleRoundGame(startingScore: 0);
      throwDart(zero, p0, 5, 1);
      throwDart(zero, p0, 5, 1);
      throwDart(zero, p0, 5, 1);
      expect(zero.scores[0], 0);
      expect(zero.wasHalvedThisRound, isTrue);
    });

    test('at least one hit avoids halving entirely', () {
      final game = singleRoundGame();
      throwDart(game, p0, 18, 1); // hits the target once
      throwDart(game, p0, 5, 1); // 2 dead darts
      throwDart(game, p0, 5, 1);
      expect(game.scores[0], 20 + 18); // added, not halved
      expect(game.wasHalvedThisRound, isFalse);
    });

    test('wasHalvedThisRound is true after a miss and false after a hit',
        () {
      final missed = singleRoundGame();
      throwDart(missed, p0, 5, 1);
      throwDart(missed, p0, 5, 1);
      throwDart(missed, p0, 5, 1);
      expect(missed.wasHalvedThisRound, isTrue);

      final hit = singleRoundGame();
      throwDart(hit, p0, 18, 3);
      throwDart(hit, p0, 5, 1);
      throwDart(hit, p0, 5, 1);
      expect(hit.wasHalvedThisRound, isFalse);
    });
  });

  group('NumberTarget', () {
    test('single, double, and treble score at face value', () {
      const target = NumberTarget(18);
      expect(target.evaluate([dart(p0, 18, 1)]).points, 18);
      expect(target.evaluate([dart(p0, 18, 2)]).points, 36);
      expect(target.evaluate([dart(p0, 18, 3)]).points, 54);
    });

    test('darts on other numbers score 0 and alone do not hit', () {
      const target = NumberTarget(18);
      final result = target
          .evaluate([dart(p0, 5, 1), dart(p0, 6, 1), dart(p0, 7, 1)]);
      expect(result.hit, isFalse);
      expect(result.points, 0);
    });

    test('multiple qualifying darts stack', () {
      const target = NumberTarget(18);
      final result = target
          .evaluate([dart(p0, 18, 1), dart(p0, 18, 1), dart(p0, 5, 1)]);
      expect(result.hit, isTrue);
      expect(result.points, 36);
    });
  });

  group('AnyDoubleTarget and AnyTrebleTarget', () {
    test('any double qualifies at face value', () {
      const target = AnyDoubleTarget();
      expect(target.evaluate([dart(p0, 20, 2)]).points, 40);
      expect(target.evaluate([dart(p0, 7, 2)]).points, 14);
    });

    test('singles and trebles do not qualify as a double', () {
      const target = AnyDoubleTarget();
      expect(target.evaluate([dart(p0, 20, 1)]).hit, isFalse);
      expect(target.evaluate([dart(p0, 20, 3)]).hit, isFalse);
    });

    test('the inner bull (25 x 2 = 50) qualifies as a double', () {
      const target = AnyDoubleTarget();
      final result = target.evaluate([dart(p0, bullSegment, 2)]);
      expect(result.hit, isTrue);
      expect(result.points, 50);
    });

    test('any treble qualifies at face value', () {
      const target = AnyTrebleTarget();
      expect(target.evaluate([dart(p0, 20, 3)]).points, 60);
      expect(target.evaluate([dart(p0, 5, 3)]).points, 15);
    });
  });

  group('BullseyeTarget', () {
    test('both outer (25) and inner (50) bull qualify at face value', () {
      const target = BullseyeTarget();
      expect(target.evaluate([dart(p0, bullSegment, 1)]).points, 25);
      expect(target.evaluate([dart(p0, bullSegment, 2)]).points, 50);
    });
  });

  group('ExactScoreTarget', () {
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

    test('missing the exact score halves the running score in a full game',
        () {
      final game = HalfItGame(
        players: [p0],
        config: const HalfItConfig(
          sequenceType: HalfItSequenceType.fixed,
          fixedSequence: [ExactScoreTarget(41)],
        ),
      );
      throwDart(game, p0, 20, 1);
      throwDart(game, p0, 20, 1);
      throwDart(game, p0, 2, 1); // 42, one over - misses
      expect(game.scores[0], 10); // 20 halved
    });
  });

  group('ScoreAtLeastTarget (65+)', () {
    test('hits at or above the threshold and scores the total', () {
      const target = ScoreAtLeastTarget(65);
      final darts = [dart(p0, 20, 3), dart(p0, 20, 1), dart(p0, 5, 1)];
      final result = target.evaluate(darts); // 60 + 20 + 5 = 85
      expect(result.hit, isTrue);
      expect(result.points, 85);
    });

    test('misses below the threshold and scores nothing', () {
      const target = ScoreAtLeastTarget(65);
      final darts = [dart(p0, 20, 3), dart(p0, 4, 1), dart(p0, missSegment, 1)];
      final result = target.evaluate(darts); // 60 + 4 + 0 = 64
      expect(result.hit, isFalse);
      expect(result.points, 0);
    });
  });

  group('ScoreAtMostOnBoardTarget (<=10)', () {
    test('all 3 darts must be on the board and total <=10', () {
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
  });

  group('ThreeColoursTarget', () {
    test('requires one of each: black single, white single, a red-or-green '
        'segment', () {
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
  });

  group('ThreeInSameBedTarget', () {
    test('requires all three darts on the same wedge, any ring', () {
      const target = ThreeInSameBedTarget();

      final sameWedge = [dart(p0, 20, 1), dart(p0, 20, 3), dart(p0, 20, 2)];
      final result = target.evaluate(sameWedge);
      expect(result.hit, isTrue);
      expect(result.points, 20 + 60 + 40);

      final mixed = [dart(p0, 20, 1), dart(p0, 20, 1), dart(p0, 19, 1)];
      expect(target.evaluate(mixed).hit, isFalse);
    });
  });

  group('BlackWhiteBlackTarget', () {
    test('black-white-black in order hits and scores the total', () {
      const target = BlackWhiteBlackTarget();
      final inOrder = [dart(p0, 20, 1), dart(p0, 1, 1), dart(p0, 18, 1)];
      final result = target.evaluate(inOrder);
      expect(result.hit, isTrue);
      expect(result.points, 20 + 1 + 18);
    });

    test('order matters - white-black-black does not hit', () {
      const target = BlackWhiteBlackTarget();
      final wrongOrder = [dart(p0, 1, 1), dart(p0, 20, 1), dart(p0, 18, 1)];
      expect(target.evaluate(wrongOrder).hit, isFalse);
    });

    test('order matters - white-black-white (WBW) does not hit', () {
      const target = BlackWhiteBlackTarget();
      final wbw = [dart(p0, 1, 1), dart(p0, 20, 1), dart(p0, 1, 1)];
      expect(target.evaluate(wbw).hit, isFalse);
    });
  });

  group('Game progression', () {
    test('advances to the next target after a full round', () {
      final game = HalfItGame(
        players: [p0],
        config: const HalfItConfig(
          sequenceType: HalfItSequenceType.fixed,
          fixedSequence: [NumberTarget(18), NumberTarget(19)],
        ),
      );
      expect((game.currentTarget as NumberTarget).number, 18);

      throwDart(game, p0, 18, 1);
      throwDart(game, p0, 18, 1);
      throwDart(game, p0, 18, 1);

      expect((game.currentTarget as NumberTarget).number, 19);
      expect(game.currentRoundIndex, 1);
    });

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

    test('ties are broken deterministically in favour of the earlier '
        'player in throwing order', () {
      // _finishMatch only replaces its leading candidate on a STRICTLY
      // greater score, so on an exact tie the earlier player keeps the
      // win - documented here so the behaviour can't regress silently.
      final game = HalfItGame(
        players: [p0, p1],
        config: const HalfItConfig(
          sequenceType: HalfItSequenceType.fixed,
          fixedSequence: [NumberTarget(18)],
        ),
      );
      throwDart(game, p0, 5, 1);
      throwDart(game, p0, 5, 1);
      throwDart(game, p0, 5, 1);
      throwDart(game, p1, 5, 1);
      throwDart(game, p1, 5, 1);
      throwDart(game, p1, 5, 1);

      expect(game.scores, [10, 10]); // tied
      expect(game.isFinished, isTrue);
      expect(game.winner, p0); // earlier player wins the tie
    });
  });

  group('Undo', () {
    test('canUndo is false at the start of a game', () {
      final game = HalfItGame(players: [p0], config: const HalfItConfig());
      expect(game.canUndo, isFalse);
    });

    test('undo restores score, current target index, halved flag, and '
        'current player index exactly', () {
      final game = HalfItGame(
        players: [p0, p1],
        config: const HalfItConfig(
          sequenceType: HalfItSequenceType.fixed,
          fixedSequence: [NumberTarget(18), NumberTarget(19)],
        ),
      );
      throwDart(game, p0, 18, 1);
      throwDart(game, p0, 18, 1);
      throwDart(game, p0, 18, 1); // P0 hits, round 0 -> P1's turn
      throwDart(game, p1, 5, 1);
      throwDart(game, p1, 5, 1);

      final scoreBefore = List.of(game.scores);
      final roundBefore = game.currentRoundIndex;
      final playerBefore = game.currentPlayerIndex;
      expect(game.wasHalvedThisRound, isFalse);

      throwDart(game, p1, 5, 1); // P1 misses -> halved, round advances

      expect(game.scores[1], isNot(scoreBefore[1]));
      expect(game.currentRoundIndex, isNot(roundBefore));
      expect(game.wasHalvedThisRound, isTrue);
      expect(game.currentPlayerIndex, isNot(playerBefore));

      game.undo();

      expect(game.scores, scoreBefore);
      expect(game.currentRoundIndex, roundBefore);
      expect(game.wasHalvedThisRound, isFalse);
      expect(game.currentPlayerIndex, playerBefore);
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

  group('target pool and sequence building', () {
    test('the bull is excluded from the random pool', () {
      expect(
        halfItTargetPool.any((t) => t is BullseyeTarget),
        isFalse,
      );
    });

    test('the random pool only draws numbers 15-20', () {
      final numberTargets =
          halfItTargetPool.whereType<NumberTarget>().toList();
      expect(numberTargets.map((t) => t.number).toSet(), {15, 16, 17, 18, 19, 20});
    });

    test('a fixed sequence uses exactly that sequence', () {
      const sequence = [
        NumberTarget(18),
        AnyDoubleTarget(),
        BullseyeTarget(),
      ];
      final game = HalfItGame(
        players: [p0],
        config: const HalfItConfig(
          sequenceType: HalfItSequenceType.fixed,
          fixedSequence: sequence,
        ),
      );
      expect(game.targets, sequence);
    });

    test('the default randomized config has exactly 10 rounds ending with '
        'the bull', () {
      final game = HalfItGame(
        players: [p0],
        config: const HalfItConfig(),
        random: Random(42),
      );
      expect(game.targets.length, 10);
      expect(game.targets.last, isA<BullseyeTarget>());
      expect(game.targets.sublist(0, 9).any((t) => t is BullseyeTarget),
          isFalse);
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
