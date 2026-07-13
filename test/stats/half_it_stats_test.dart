import 'package:darts/models/match_record.dart';
import 'package:darts/models/player.dart';
import 'package:darts/models/throw.dart';
import 'package:darts/services/stats/half_it_stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Player alice;

  setUp(() {
    alice = Player.create('Alice');
  });

  // Only the last dart of a Half It turn carries a nonzero
  // resultingScoreDelta - see HalfItGame._evaluateTurn. Earlier darts in
  // the turn are 0, matching real turns.
  Turn roundTurn(int delta, {int dartsBeforeDecider = 2}) => Turn(
        player: alice,
        throws: [
          for (var i = 0; i < dartsBeforeDecider; i++)
            Throw(player: alice, actualSegment: 5, multiplier: 1, gameId: 'm'),
          Throw(
            player: alice,
            actualSegment: 20,
            multiplier: 1,
            gameId: 'm',
            resultingScoreDelta: delta,
          ),
        ],
      );

  test('no matches gives the empty/no-data result', () {
    final stats = HalfItStats.compute(alice, const []);
    expect(stats, HalfItStats.empty);
  });

  test('final score, best game, and most survived rounds across matches',
      () {
    final match1 = MatchRecord(
      gameId: 'm1',
      gameName: 'halfit',
      players: [alice],
      winnerId: alice.id,
      config: const {'startingScore': 20},
      turnHistory: [
        roundTurn(20), // 20 -> 40, survived
        roundTurn(-20), // 40 -> 20, halved
      ],
    );
    final match2 = MatchRecord(
      gameId: 'm2',
      gameName: 'halfit',
      players: [alice],
      winnerId: alice.id,
      config: const {'startingScore': 20},
      turnHistory: [
        roundTurn(30), // 20 -> 50, survived
        roundTurn(50), // 50 -> 100, survived
      ],
    );

    final stats = HalfItStats.compute(alice, [match1, match2]);

    expect(stats.matchesPlayed, 2);
    // match1 final = 20; match2 final = 100; average = 60.
    expect(stats.averageTotalScore, closeTo(60, 1e-9));
    expect(stats.bestGameScore, 100);
    expect(stats.mostSurvivedRounds, 2); // match2: both rounds survived
  });

  test('a match saved before config snapshots existed falls back to the '
      'default starting score of 20', () {
    final match = MatchRecord(
      gameId: 'm3',
      gameName: 'halfit',
      players: [alice],
      winnerId: alice.id,
      config: null,
      turnHistory: [roundTurn(10)],
    );

    final stats = HalfItStats.compute(alice, [match]);

    expect(stats.bestGameScore, 30); // 20 default + 10
  });
}
