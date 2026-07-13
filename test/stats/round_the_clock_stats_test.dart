import 'package:darts/models/match_record.dart';
import 'package:darts/models/player.dart';
import 'package:darts/models/throw.dart';
import 'package:darts/services/stats/round_the_clock_stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Player alice;

  setUp(() {
    alice = Player.create('Alice');
  });

  // resultingScoreDelta on a Round the Clock dart is how many stops it
  // advanced (0 = miss, >0 = hit) - see RoundTheClockGame.applyThrow.
  Throw dartAt(int target, {required bool hit}) => Throw(
        player: alice,
        actualSegment: target,
        multiplier: 1,
        gameId: 'm',
        intendedTarget: target,
        resultingScoreDelta: hit ? 1 : 0,
      );

  test('no matches gives the empty/no-data result', () {
    final stats = RoundTheClockStats.compute(alice, const []);
    expect(stats, RoundTheClockStats.empty);
  });

  test('overall hit rate and favourite/worst number need a minimum sample',
      () {
    final match = MatchRecord(
      gameId: 'm1',
      gameName: 'round_the_clock',
      players: [alice],
      winnerId: alice.id,
      turnHistory: [
        // Target 1: 3 attempts, 3 hits - 100%.
        Turn(player: alice, throws: [
          dartAt(1, hit: true),
          dartAt(1, hit: true),
          dartAt(1, hit: true),
        ]),
        // Target 2: 3 attempts, 1 hit - ~33%.
        Turn(player: alice, throws: [
          dartAt(2, hit: false),
          dartAt(2, hit: false),
          dartAt(2, hit: true),
        ]),
        // Target 3: only 1 attempt, a miss - excluded from ranking (below
        // the minimum sample size) even though its raw rate (0%) would
        // otherwise "win" worst number.
        Turn(player: alice, throws: [dartAt(3, hit: false)]),
      ],
    );

    final stats = RoundTheClockStats.compute(alice, [match]);

    expect(stats.matchesPlayed, 1);
    // 4 hits out of 7 attempts.
    expect(stats.overallHitRate, closeTo(4 / 7 * 100, 1e-9));
    expect(stats.favouriteNumber, 1);
    expect(stats.worstNumber, 2);
    expect(stats.hitRateByTarget[1], (3, 3));
    expect(stats.hitRateByTarget[2], (1, 3));
    expect(stats.hitRateByTarget[3], (0, 1));
  });

  test('darts with no intendedTarget (other game modes) are ignored', () {
    final match = MatchRecord(
      gameId: 'm2',
      gameName: 'round_the_clock',
      players: [alice],
      winnerId: alice.id,
      turnHistory: [
        Turn(player: alice, throws: [
          Throw(player: alice, actualSegment: 5, multiplier: 1, gameId: 'm2'),
        ]),
      ],
    );

    final stats = RoundTheClockStats.compute(alice, [match]);

    expect(stats.overallHitRate, isNull);
  });
}
