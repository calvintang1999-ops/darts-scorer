import 'package:darts/games/x01/x01_config.dart';
import 'package:darts/games/x01/x01_game.dart';
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

  // Throws always apply to whoever's turn it actually is (players[0] goes
  // first), regardless of which Player is passed here - same convention as
  // the Cricket tests.
  void throwDart(X01Game game, Player player, int segment, int multiplier) {
    game.applyThrow(Throw(
      player: player,
      actualSegment: segment,
      multiplier: multiplier,
      gameId: game.gameId,
    ));
  }

  group('Turn leg/set stamping', () {
    // legsPerSet: 1 means every leg win is also a set win, so this small
    // config lets a single dart (startingScore: 1, single out) finish a
    // whole leg - and a whole set - immediately.
    X01Game newGame() => X01Game(
          players: [p0, p1],
          config: const X01Config(
            startingScore: 1,
            outRule: X01OutRule.single,
            legsPerSet: 1,
            setsToWin: 2,
          ),
        );

    test('stamps each turn with its leg/set, resetting leg at a new set',
        () {
      final game = newGame();

      throwDart(game, p0, 1, 1); // p0 wins leg 1 = set 1
      throwDart(game, p1, 1, 1); // p1 wins leg 1 of set 2

      expect(game.turnHistory, hasLength(2));
      expect(game.turnHistory[0].legNumber, 1);
      expect(game.turnHistory[0].setNumber, 1);
      expect(game.turnHistory[1].legNumber, 1);
      expect(game.turnHistory[1].setNumber, 2);
    });

    test('undo across a leg win restores the leg/set counters', () {
      final game = newGame();

      throwDart(game, p0, 1, 1); // wins leg 1 = set 1, set 2 now begins
      expect(game.turnHistory.single.setNumber, 1);

      game.undo();
      expect(game.turnHistory, isEmpty);
      expect(game.scores[0], 1); // back to the start of leg 1

      // Throwing the same winning dart again should reproduce the exact
      // same leg/set stamp as before undo - proof the internal counters
      // were rolled back, not left pointing at set 2.
      throwDart(game, p0, 1, 1);
      expect(game.turnHistory.single.legNumber, 1);
      expect(game.turnHistory.single.setNumber, 1);
    });
  });
}
