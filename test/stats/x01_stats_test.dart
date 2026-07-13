import 'package:darts/models/match_record.dart';
import 'package:darts/models/player.dart';
import 'package:darts/models/throw.dart';
import 'package:darts/services/stats/x01_stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Player alice;
  late Player bob;

  setUp(() {
    alice = Player.create('Alice');
    bob = Player.create('Bob');
  });

  // A minimal helper: build one dart with the multiplier/segment given and
  // a resultingScoreDelta that matches how X01Game would have computed it
  // (negative = scored normally, 0 = didn't count, positive = bust revert).
  Throw dart(Player p, int segment, int multiplier, int delta,
          {String gameId = 'm'}) =>
      Throw(
        player: p,
        actualSegment: segment,
        multiplier: multiplier,
        gameId: gameId,
        resultingScoreDelta: delta,
      );

  test('no matches gives the empty/no-data result', () {
    final stats = X01Stats.compute(alice, const []);
    expect(stats, X01Stats.empty);
  });

  test('checkout stats, averages, and best/worst leg across two matches',
      () {
    // Match 1: Alice wins leg 1 (startingScore 41) in one visit of two
    // darts - single 9 (41->32, not a checkout multiplier), then D16
    // (32->0, a checkout multiplier and the winning dart).
    final match1 = MatchRecord(
      gameId: 'm1',
      gameName: 'x01',
      players: [alice, bob],
      winnerId: alice.id,
      config: const {'startingScore': 41, 'outRule': 'double'},
      turnHistory: [
        Turn(player: alice, throws: [
          dart(alice, 9, 1, -9, gameId: 'm1'),
          dart(alice, 16, 2, -32, gameId: 'm1'),
        ]),
      ],
    );

    // Match 2: Alice loses leg 1 (same startingScore 41) - she has two
    // checkout-round visits but misses the double both times; Bob's last
    // turn wins it (its own darts don't matter for Alice's stats).
    final match2 = MatchRecord(
      gameId: 'm2',
      gameName: 'x01',
      players: [alice, bob],
      winnerId: bob.id,
      config: const {'startingScore': 41, 'outRule': 'double'},
      turnHistory: [
        Turn(player: alice, throws: [dart(alice, 9, 1, -9, gameId: 'm2')]),
        Turn(player: bob, throws: [dart(bob, 20, 3, -60, gameId: 'm2')]),
        Turn(player: alice, throws: [dart(alice, 16, 1, -16, gameId: 'm2')]),
        Turn(player: bob, throws: [dart(bob, 20, 2, -40, gameId: 'm2')]),
      ],
    );

    final stats = X01Stats.compute(alice, [match1, match2]);

    expect(stats.matchesPlayed, 2);
    // Visit scores: 41 (m1's only visit), 9, 16 (m1's two visits) = 66
    // points over 4 darts.
    expect(stats.threeDartAverage, closeTo(66 / 4 * 3, 1e-9));
    // First nine: leg 1 = 41 pts / 2 darts * 3 = 61.5; leg 2 = 25 pts / 2
    // darts * 3 = 37.5; averaged across the 2 legs = 49.5.
    expect(stats.firstNineAverage, closeTo(49.5, 1e-9));

    // 3 checkout rounds total (m1's winning visit, m2's two missed
    // visits), 1 converted.
    expect(stats.checkoutPercentage, closeTo(100 / 3, 1e-9));
    // 4 darts thrown across those checkout rounds, 1 landed on a double.
    expect(stats.doublesHitRate, closeTo(25, 1e-9));
    expect(stats.highestCheckout, 41);
    expect(stats.bestLegDarts, 2);
    expect(stats.worstLegDarts, 2);

    expect(stats.oneHundredPlusVisits, 0);
    expect(stats.oneFortyPlusVisits, 0);
    expect(stats.oneEightyVisits, 0);
    expect(stats.visitScoreBuckets['0-40'], 2); // the two 9/16 visits
    expect(stats.visitScoreBuckets['41-60'], 1); // the 41 visit
  });

  test('a busted visit scores 0, not its face value', () {
    // Remaining 20, throws T20 (60) on the first dart of the turn - way
    // over, busts. Since it's the turn's first dart, X01Game's revert
    // (newScore = startOfTurnScore) nets to a delta of exactly 0 - the
    // score ends the visit exactly where it started.
    final match = MatchRecord(
      gameId: 'm3',
      gameName: 'x01',
      players: [alice],
      winnerId: null,
      config: const {'startingScore': 20, 'outRule': 'double'},
      turnHistory: [
        Turn(player: alice, throws: [dart(alice, 20, 3, 0, gameId: 'm3')]),
      ],
    );

    final stats = X01Stats.compute(alice, [match]);

    expect(stats.threeDartAverage, 0);
    expect(stats.oneEightyVisits, 0);
    expect(stats.visitScoreBuckets['0-40'], 1);
  });

  test('abandoned matches (no winner) are excluded from leg stats but not '
      'from the average', () {
    final match = MatchRecord(
      gameId: 'm4',
      gameName: 'x01',
      players: [alice],
      winnerId: null, // quit mid-leg
      config: const {'startingScore': 501, 'outRule': 'double'},
      turnHistory: [
        Turn(player: alice, throws: [dart(alice, 20, 3, -60, gameId: 'm4')]),
      ],
    );

    final stats = X01Stats.compute(alice, [match]);

    expect(stats.threeDartAverage, closeTo(60 / 1 * 3, 1e-9));
    expect(stats.checkoutPercentage, isNull);
    expect(stats.bestLegDarts, isNull);
    expect(stats.worstLegDarts, isNull);
  });

  test('single-out has no doubles concept but still tracks best/worst leg',
      () {
    final match = MatchRecord(
      gameId: 'm5',
      gameName: 'x01',
      players: [alice],
      winnerId: alice.id,
      config: const {'startingScore': 3, 'outRule': 'single'},
      turnHistory: [
        Turn(player: alice, throws: [dart(alice, 3, 1, -3, gameId: 'm5')]),
      ],
    );

    final stats = X01Stats.compute(alice, [match]);

    expect(stats.checkoutPercentage, isNull);
    expect(stats.doublesHitRate, isNull);
    expect(stats.highestCheckout, isNull);
    expect(stats.bestLegDarts, 1);
    expect(stats.worstLegDarts, 1);
  });

  test('a match saved before config snapshots existed falls back to X01 '
      'defaults', () {
    final match = MatchRecord(
      gameId: 'm6',
      gameName: 'x01',
      players: [alice],
      winnerId: alice.id,
      config: null,
      turnHistory: [
        // If startingScore didn't default to 501, this first visit
        // (leaving 40) would land on the wrong remaining score and the
        // second visit wouldn't read as a checkout round at all.
        Turn(player: alice, throws: [dart(alice, 20, 1, -461, gameId: 'm6')]),
        Turn(player: alice, throws: [dart(alice, 20, 2, -40, gameId: 'm6')]),
      ],
    );

    final stats = X01Stats.compute(alice, [match]);

    // Defaults are startingScore 501 / outRule double, so the second
    // visit (remaining 40, a double) is a checkout round and converts it.
    expect(stats.checkoutPercentage, 100);
    expect(stats.highestCheckout, 40);
  });
}
