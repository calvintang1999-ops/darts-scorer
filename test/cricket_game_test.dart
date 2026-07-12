import 'package:darts/games/cricket/cricket_config.dart';
import 'package:darts/games/cricket/cricket_game.dart';
import 'package:darts/models/player.dart';
import 'package:darts/models/throw.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Player p0;
  late Player p1;
  late Player p2;

  setUp(() {
    p0 = Player.create('P0');
    p1 = Player.create('P1');
    p2 = Player.create('P2');
  });

  CricketGame newGame({CricketMode mode = CricketMode.standard}) =>
      CricketGame(players: [p0, p1], config: CricketConfig(mode: mode));

  // Throws always apply to whoever's turn it actually is (players[0]
  // goes first), regardless of which Player is passed here - same as
  // X01. The player argument just labels the dart for readability.
  void throwDart(CricketGame game, Player player, int segment, int multiplier) {
    game.applyThrow(Throw(
      player: player,
      actualSegment: segment,
      multiplier: multiplier,
      gameId: game.gameId,
    ));
  }

  group('Closing behaviour', () {
    test('a treble on an unhit number closes it in one dart', () {
      final game = newGame();
      throwDart(game, p0, 20, 3);
      expect(game.marks[20]![0], 3);
      expect(game.scores[0], 0); // exactly closes it - no excess to score
    });

    test('a double on a number with 1 existing mark closes it with no '
        'overflow', () {
      final game = newGame();
      throwDart(game, p0, 20, 1); // 1 mark
      throwDart(game, p0, 20, 2); // +2 marks = 3 exactly, no overflow
      expect(game.marks[20]![0], 3);
      expect(game.scores[0], 0);
    });

    test('a double on a number with 2 existing marks closes it and scores '
        '1x the number', () {
      final game = newGame();
      throwDart(game, p0, 20, 1); // 1 mark
      throwDart(game, p0, 20, 1); // 2 marks
      throwDart(game, p0, 20, 2); // closes with 1 mark overflow -> scores 20
      expect(game.marks[20]![0], 3);
      expect(game.scores[0], 20);
    });

    test('hitting a number that is not in play does nothing', () {
      final game = newGame(); // default config: 15-20 plus bull
      throwDart(game, p0, 12, 3); // 12 isn't a valid target
      expect(game.scores[0], 0);
      expect(game.scores[1], 0);
      expect(game.marks.containsKey(12), isFalse);
    });
  });

  group('Standard scoring', () {
    test('points score only when at least one opponent has not closed the '
        'number', () {
      final game = newGame();
      throwDart(game, p0, 20, 3); // closes 20, opponent P1 still open
      throwDart(game, p0, 20, 1); // excess - P1 hasn't closed it, scores
      expect(game.scores[0], 20);
    });

    test('points do not score when every opponent has already closed the '
        'number', () {
      final game = newGame();
      // P0 closes 20.
      throwDart(game, p0, 20, 1);
      throwDart(game, p0, 20, 1);
      throwDart(game, p0, 20, 1);
      // P1 closes 20 too - now nobody has it open any more.
      throwDart(game, p1, 20, 1);
      throwDart(game, p1, 20, 1);
      throwDart(game, p1, 20, 1);

      // P0 hits 20 again - a dead dart, since every player has closed it.
      throwDart(game, p0, 20, 1);
      expect(game.scores[0], 0);
    });

    test('points score to the thrower', () {
      final game = newGame();
      throwDart(game, p0, 20, 3); // closes 20
      throwDart(game, p0, 20, 1); // excess
      expect(game.scores[0], 20);
      expect(game.scores[1], 0);
    });
  });

  group('Cutthroat scoring', () {
    test('points land on every opponent who has not closed the number', () {
      final game = CricketGame(
        players: [p0, p1, p2],
        config: const CricketConfig(mode: CricketMode.cutthroat),
      );

      // P0 closes 20.
      throwDart(game, p0, 20, 1);
      throwDart(game, p0, 20, 1);
      throwDart(game, p0, 20, 1);
      // P1 closes 20 too - P1 is now immune to points on this number.
      throwDart(game, p1, 20, 1);
      throwDart(game, p1, 20, 1);
      throwDart(game, p1, 20, 1);
      // P2's turn: leaves 20 untouched, so it's still open for P2.
      throwDart(game, p2, 5, 1);
      throwDart(game, p2, 5, 1);
      throwDart(game, p2, 5, 1);

      // P0 hits 20 again with a treble - 3 excess marks' worth of points
      // pile onto P2 (still open) but not P1 (already closed).
      throwDart(game, p0, 20, 3);
      expect(game.scores[2], 60);
    });

    test('points do not land on opponents who have already closed the '
        'number', () {
      final game = CricketGame(
        players: [p0, p1, p2],
        config: const CricketConfig(mode: CricketMode.cutthroat),
      );

      throwDart(game, p0, 20, 1);
      throwDart(game, p0, 20, 1);
      throwDart(game, p0, 20, 1);
      throwDart(game, p1, 20, 1);
      throwDart(game, p1, 20, 1);
      throwDart(game, p1, 20, 1); // P1 also closed - immune from now on
      throwDart(game, p2, 5, 1);
      throwDart(game, p2, 5, 1);
      throwDart(game, p2, 5, 1);

      throwDart(game, p0, 20, 3);
      expect(game.scores[1], 0);
    });

    test('points do not add to the throwers own score', () {
      final game = CricketGame(
        players: [p0, p1, p2],
        config: const CricketConfig(mode: CricketMode.cutthroat),
      );

      throwDart(game, p0, 20, 1);
      throwDart(game, p0, 20, 1);
      throwDart(game, p0, 20, 1);
      throwDart(game, p1, 20, 1);
      throwDart(game, p1, 20, 1);
      throwDart(game, p1, 20, 1);
      throwDart(game, p2, 5, 1);
      throwDart(game, p2, 5, 1);
      throwDart(game, p2, 5, 1);

      throwDart(game, p0, 20, 3);
      expect(game.scores[0], 0);
    });

    test('a closed number is immune to cutthroat points for everyone', () {
      final game = newGame(mode: CricketMode.cutthroat);
      // P0 closes 20.
      throwDart(game, p0, 20, 1);
      throwDart(game, p0, 20, 1);
      throwDart(game, p0, 20, 1);
      // P1 closes 20 too - fully closed now.
      throwDart(game, p1, 20, 1);
      throwDart(game, p1, 20, 1);
      throwDart(game, p1, 20, 1);

      // P0 hits 20 again - a dead dart, same as in standard mode.
      throwDart(game, p0, 20, 1);
      expect(game.scores[0], 0);
      expect(game.scores[1], 0);
    });
  });

  group('Win condition', () {
    test('you cannot win while behind on points (standard)', () {
      // A 2-number match (20 and 19) keeps this scenario short: turns
      // are always 3 darts, and a match win is checked after every dart.
      final game = CricketGame(
        players: [p0, p1],
        config: const CricketConfig(lowNumber: 19, includeBull: false),
      );

      // P0's turn: close 20 and bank 40 excess points (two singles then
      // a treble - the treble supplies 2 marks' worth of excess).
      throwDart(game, p0, 20, 1);
      throwDart(game, p0, 20, 1);
      throwDart(game, p0, 20, 3);
      expect(game.scores[0], 40);

      // P1's turn: close 20 too, with three singles - no excess.
      throwDart(game, p1, 20, 1);
      throwDart(game, p1, 20, 1);
      throwDart(game, p1, 20, 1);

      // P0's turn: a dead turn that doesn't touch 19.
      throwDart(game, p0, 5, 1);
      throwDart(game, p0, 5, 1);
      throwDart(game, p0, 5, 1);

      // P1's turn: close the last number (19) with no excess - P1 has
      // now closed everything but is still behind 0-40.
      throwDart(game, p1, 19, 1);
      throwDart(game, p1, 19, 1);
      throwDart(game, p1, 19, 1);
      expect(game.marks[19]![1], 3);
      expect(game.isFinished, isFalse); // closed everything, but behind

      // P0's turn: another dead turn.
      throwDart(game, p0, 5, 1);
      throwDart(game, p0, 5, 1);
      throwDart(game, p0, 5, 1);

      // P1's turn: 19 is closed for P1 but still open for P0, so a
      // treble scores enough excess to pull ahead and win outright.
      throwDart(game, p1, 19, 3);
      expect(game.isFinished, isTrue);
      expect(game.winner, p1);
    });

    test('you cannot win while numerically ahead on points in cutthroat '
        'mode', () {
      // Cutthroat inverts scoring: a HIGHER score is worse, since points
      // land on you when you haven't closed a number opponents have.
      final game = CricketGame(
        players: [p0, p1],
        config: const CricketConfig(
          lowNumber: 19,
          includeBull: false,
          mode: CricketMode.cutthroat,
        ),
      );

      // P0 closes 19 with no excess - 20 stays open for P0.
      throwDart(game, p0, 19, 1);
      throwDart(game, p0, 19, 1);
      throwDart(game, p0, 19, 1);

      // P1 closes 20 and piles 40 excess points onto P0 (cutthroat - the
      // scorer's own total never moves).
      throwDart(game, p1, 20, 1);
      throwDart(game, p1, 20, 1);
      throwDart(game, p1, 20, 3);
      expect(game.scores[0], 40);
      expect(game.scores[1], 0);

      // P0 closes 20 too, with no excess - P0 has now closed everything
      // but is numerically ahead (40 > 0), which is bad in cutthroat.
      throwDart(game, p0, 20, 1);
      throwDart(game, p0, 20, 1);
      throwDart(game, p0, 20, 1);

      expect(game.isFinished, isFalse);
    });

    test('closing everything while winning or tied on points finishes the '
        'match', () {
      final game = CricketGame(
        players: [p0, p1],
        config: const CricketConfig(lowNumber: 19, includeBull: false),
      );

      // Nobody scores any excess anywhere - everyone stays tied at 0.
      throwDart(game, p0, 20, 1);
      throwDart(game, p0, 20, 1);
      throwDart(game, p0, 20, 1);
      throwDart(game, p1, 20, 1);
      throwDart(game, p1, 20, 1);
      throwDart(game, p1, 20, 1);

      // P0 closes the last number too, tied 0-0 with P1 - closing
      // everything while merely tied (not strictly ahead) should still
      // win.
      throwDart(game, p0, 19, 1);
      throwDart(game, p0, 19, 1);
      throwDart(game, p0, 19, 1);

      expect(game.isFinished, isTrue);
      expect(game.winner, p0);
      expect(game.scores[0], 0);
      expect(game.scores[1], 0);
    });
  });

  group('Turn and UI-hook behaviour', () {
    test('closedThreeThisTurn fires only when a number is closed within '
        'the turn', () {
      final game = newGame();
      expect(game.closedThreeThisTurn, isFalse);

      throwDart(game, p0, 20, 1);
      throwDart(game, p0, 20, 1);
      expect(game.closedThreeThisTurn, isFalse);

      throwDart(game, p0, 20, 1); // 3rd single closes 20 within this turn
      expect(game.closedThreeThisTurn, isTrue);
    });

    test('closedThisTurn counts numbers closed this turn and resets once '
        'the next turn starts', () {
      final game = newGame();
      expect(game.closedThisTurn, 0);

      throwDart(game, p0, 20, 3); // closes 20 - 1st this turn
      expect(game.closedThisTurn, 1);
      throwDart(game, p0, 19, 3); // closes 19 - 2nd this turn
      expect(game.closedThisTurn, 2);
      throwDart(game, p0, 18, 3); // closes 18 - 3rd, ends P0's turn
      expect(game.closedThisTurn, 3);

      // P1's turn starts fresh - the count has reset.
      throwDart(game, p1, 5, 1); // a dead dart, just to observe the reset
      expect(game.closedThisTurn, 0);
    });

    test('three numbers closed in one turn triggers the White Horse flag '
        'and status message', () {
      final game = newGame();
      expect(game.whiteHorse, isFalse);

      throwDart(game, p0, 20, 3); // closes 20
      expect(game.whiteHorse, isFalse);

      throwDart(game, p0, 19, 3); // closes 19 - two numbers so far
      expect(game.whiteHorse, isFalse);

      throwDart(game, p0, 18, 3); // closes 18 - three numbers this turn
      expect(game.whiteHorse, isTrue);
      expect(game.statusMessage, contains('White Horse'));
    });
  });

  group('Undo', () {
    test('undo reverts a single dart, including its marks', () {
      final game = newGame();
      throwDart(game, p0, 20, 3);
      expect(game.marks[20]![0], 3);
      expect(game.canUndo, isTrue);

      game.undo();
      expect(game.marks[20]![0], 0);
      expect(game.currentTurnThrows, isEmpty);
      expect(game.canUndo, isFalse);
    });

    test('undo walks back across a turn boundary', () {
      final game = newGame();
      throwDart(game, p0, 20, 1);
      throwDart(game, p0, 20, 1);
      throwDart(game, p0, 20, 1); // 3rd dart ends P0's turn
      expect(game.currentPlayerIndex, 1);
      expect(game.currentTurnThrows, isEmpty);

      game.undo();
      expect(game.currentPlayerIndex, 0);
      expect(game.currentTurnThrows.length, 2);
      expect(game.marks[20]![0], 2);
    });

    test('undo restores marks, scores, current player index, and status '
        'message exactly', () {
      final game = CricketGame(
        players: [p0, p1],
        config: const CricketConfig(lowNumber: 19, includeBull: false),
      );

      throwDart(game, p0, 20, 1);
      throwDart(game, p0, 20, 1);
      throwDart(game, p0, 20, 1);
      throwDart(game, p1, 20, 1);
      throwDart(game, p1, 20, 1);
      throwDart(game, p1, 20, 1);
      throwDart(game, p0, 19, 1);
      throwDart(game, p0, 19, 1);

      // Snapshot state right before the winning dart.
      final marksBefore = game.marks[19]![0];
      final scoresBefore = List.of(game.scores);
      final playerIndexBefore = game.currentPlayerIndex;
      expect(game.statusMessage, isNull);

      throwDart(game, p0, 19, 1); // closes 19 - P0 wins, tied 0-0
      expect(game.isFinished, isTrue);
      expect(game.statusMessage, isNotNull);

      game.undo();

      expect(game.isFinished, isFalse);
      expect(game.marks[19]![0], marksBefore);
      expect(game.scores, scoresBefore);
      expect(game.currentPlayerIndex, playerIndexBefore);
      expect(game.statusMessage, isNull);
    });

    test('canUndo is false at the start of a game and true after any dart',
        () {
      final game = newGame();
      expect(game.canUndo, isFalse);

      throwDart(game, p0, 5, 1);
      expect(game.canUndo, isTrue);
    });
  });

  group('Config variants', () {
    test('lowNumber 10 includes 10 as a valid target', () {
      final game = CricketGame(
        players: [p0, p1],
        config: const CricketConfig(lowNumber: 10),
      );
      expect(game.numbers.contains(10), isTrue);

      throwDart(game, p0, 10, 3); // treble 10 should close it
      expect(game.marks[10]![0], 3);
    });

    test('includeBull false excludes 25 and does not require it to win',
        () {
      final game = CricketGame(
        players: [p0, p1],
        config: const CricketConfig(lowNumber: 19, includeBull: false),
      );
      expect(game.numbers.contains(25), isFalse);

      // Hitting the bull has no effect since it's not in play.
      throwDart(game, p0, 25, 1);
      expect(game.scores[0], 0);
      expect(game.marks.containsKey(25), isFalse);
      game.undo(); // revert that dead dart to keep the turn clean

      // Closing everything else (20 and 19 only) still wins, without
      // ever touching the bull.
      throwDart(game, p0, 20, 1);
      throwDart(game, p0, 20, 1);
      throwDart(game, p0, 20, 1);
      throwDart(game, p1, 20, 1);
      throwDart(game, p1, 20, 1);
      throwDart(game, p1, 20, 1);
      throwDart(game, p0, 19, 1);
      throwDart(game, p0, 19, 1);
      throwDart(game, p0, 19, 1);

      expect(game.isFinished, isTrue);
      expect(game.winner, p0);
    });
  });
}
