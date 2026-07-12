import 'package:darts/games/cricket/cricket_config.dart';
import 'package:darts/games/cricket/cricket_game.dart';
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

  CricketGame newGame({CricketMode mode = CricketMode.standard}) =>
      CricketGame(players: [p0, p1], config: CricketConfig(mode: mode));

  void throwDart(CricketGame game, Player player, int segment, int multiplier) {
    game.applyThrow(Throw(
      player: player,
      actualSegment: segment,
      multiplier: multiplier,
      gameId: game.gameId,
    ));
  }

  test('closing a number scores nothing, hitting it again scores points', () {
    final game = newGame();
    // P0 closes 20 with three singles - no points yet.
    throwDart(game, p0, 20, 1);
    throwDart(game, p0, 20, 1);
    throwDart(game, p0, 20, 1);
    expect(game.marks[20]![0], 3);
    expect(game.scores[0], 0);

    // P1's turn: three misses elsewhere so 20 stays open for P1.
    throwDart(game, p1, 5, 1);
    throwDart(game, p1, 5, 1);
    throwDart(game, p1, 5, 1);

    // P0 hits 20 again - now scores because P1 hasn't closed it.
    throwDart(game, p0, 20, 1);
    expect(game.scores[0], 20);
  });

  test('closing with excess marks scores the excess immediately', () {
    final game = newGame();
    // P0 gets 2 marks on 19 first.
    throwDart(game, p0, 19, 1);
    throwDart(game, p0, 19, 1);
    throwDart(game, p0, 5, 1); // filler dart, ends turn

    throwDart(game, p1, 5, 1);
    throwDart(game, p1, 5, 1);
    throwDart(game, p1, 5, 1);

    // A treble closes the last mark and scores 2 marks' worth of excess.
    throwDart(game, p0, 19, 3);
    expect(game.marks[19]![0], 3);
    expect(game.scores[0], 2 * 19);
  });

  test('cutthroat routes points to opponents, not the thrower', () {
    final game = newGame(mode: CricketMode.cutthroat);
    throwDart(game, p0, 20, 1);
    throwDart(game, p0, 20, 1);
    throwDart(game, p0, 20, 1);

    throwDart(game, p1, 5, 1);
    throwDart(game, p1, 5, 1);
    throwDart(game, p1, 5, 1);

    throwDart(game, p0, 20, 1);
    expect(game.scores[1], 20);
    expect(game.scores[0], 0);
  });

  test('winner must not be behind on points when all numbers are closed', () {
    // A 2-number match (20 and 19) keeps this scenario short: turns are
    // always 3 darts, and a match win is checked after every single dart.
    final game = CricketGame(
      players: [p0, p1],
      config: const CricketConfig(lowNumber: 19, includeBull: false),
    );

    // Throws apply to whoever's turn it is (players[0] = P0 goes first),
    // regardless of the Player passed on the Throw - same as X01.

    // P0's turn: close 20 and bank 40 excess points (two singles then a
    // treble - the treble supplies 2 marks' worth of excess once closed).
    throwDart(game, p0, 20, 1);
    throwDart(game, p0, 20, 1);
    throwDart(game, p0, 20, 3);
    expect(game.scores[0], 40);

    // P1's turn: close 20 too, with three singles - exactly closes it,
    // no excess.
    throwDart(game, p1, 20, 1);
    throwDart(game, p1, 20, 1);
    throwDart(game, p1, 20, 1);
    expect(game.scores[1], 0);

    // P0's turn: a dead turn that doesn't touch 19, so it's still open
    // for P0 when P1 closes it next.
    throwDart(game, p0, 5, 1);
    throwDart(game, p0, 5, 1);
    throwDart(game, p0, 5, 1);

    // P1's turn: close the last number (19) with three singles - no
    // excess, so P1 has closed everything but is still behind 0-40.
    throwDart(game, p1, 19, 1);
    throwDart(game, p1, 19, 1);
    throwDart(game, p1, 19, 1);
    expect(game.marks[19]![1], 3);
    expect(game.isFinished, isFalse);

    // P0's turn: another dead turn.
    throwDart(game, p0, 5, 1);
    throwDart(game, p0, 5, 1);
    throwDart(game, p0, 5, 1);

    // P1's turn: 19 is closed for P1 but still open for P0, so a treble
    // scores 57 excess points - enough to pull ahead and win outright.
    throwDart(game, p1, 19, 3);
    expect(game.scores[1], 57);
    expect(game.isFinished, isTrue);
    expect(game.winner, p1);
  });

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

  test('closedThreeThisTurn fires only when a number is closed within the turn',
      () {
    final game = newGame();
    expect(game.closedThreeThisTurn, isFalse);

    throwDart(game, p0, 20, 1);
    throwDart(game, p0, 20, 1);
    expect(game.closedThreeThisTurn, isFalse);

    throwDart(game, p0, 20, 1); // 3rd single closes 20 within this turn
    expect(game.closedThreeThisTurn, isTrue);
  });

  test('cutthroat win also respects the not-behind check', () {
    final game = CricketGame(
      players: [p0, p1],
      config: const CricketConfig(
        lowNumber: 19,
        includeBull: false,
        mode: CricketMode.cutthroat,
      ),
    );

    // P0's turn: close 19 with no excess - 20 stays open for P0.
    throwDart(game, p0, 19, 1);
    throwDart(game, p0, 19, 1);
    throwDart(game, p0, 19, 1);

    // P1's turn: close 20 and pile 40 excess points onto P0 (cutthroat -
    // the scorer's own total doesn't move).
    throwDart(game, p1, 20, 1);
    throwDart(game, p1, 20, 1);
    throwDart(game, p1, 20, 3);
    expect(game.scores[0], 40);
    expect(game.scores[1], 0);

    // P0's turn: close 20 too, with no excess - P0 has now closed
    // everything but is behind 40-0, so this isn't a win yet.
    throwDart(game, p0, 20, 1);
    throwDart(game, p0, 20, 1);
    throwDart(game, p0, 20, 1);
    expect(game.isFinished, isFalse);

    // P1's turn: a dead turn that leaves 19 open for P1.
    throwDart(game, p1, 5, 1);
    throwDart(game, p1, 5, 1);
    throwDart(game, p1, 5, 1);

    // P0's turn: 19 is closed for P0 but open for P1, so a treble piles
    // 57 points onto P1 - enough that P0 is no longer behind, so P0 wins.
    throwDart(game, p0, 19, 3);
    expect(game.scores[1], 57);
    expect(game.isFinished, isTrue);
    expect(game.winner, p0);
  });
}
