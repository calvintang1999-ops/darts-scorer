import 'package:darts/models/match_record.dart';
import 'package:darts/models/player.dart';
import 'package:darts/models/throw.dart';
import 'package:darts/services/stats/cricket_stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Player alice;

  setUp(() {
    alice = Player.create('Alice');
  });

  Throw dart(int segment, int multiplier) => Throw(
        player: alice,
        actualSegment: segment,
        multiplier: multiplier,
        gameId: 'm',
      );

  test('no matches gives the empty/no-data result', () {
    final stats = CricketStats.compute(alice, const []);
    expect(stats, CricketStats.empty);
  });

  test('marks per round, most in a round, threshold counts, bulls per round',
      () {
    final match = MatchRecord(
      gameId: 'm1',
      gameName: 'cricket',
      players: [alice],
      winnerId: alice.id,
      config: const {'lowNumber': 15, 'includeBull': true},
      turnHistory: [
        Turn(player: alice, throws: [
          dart(20, 3), // 3 marks
          dart(19, 3), // 3 marks
          dart(5, 1), // not a cricket number here - 0 marks
        ]), // round 1: 6 marks
        Turn(player: alice, throws: [
          dart(25, 2), // bull, double - 2 marks, 2 bulls
          dart(20, 1), // 1 mark
          dart(14, 1), // below lowNumber 15 - 0 marks
        ]), // round 2: 3 marks
      ],
    );

    final stats = CricketStats.compute(alice, [match]);

    expect(stats.matchesPlayed, 1);
    expect(stats.marksPerRound, closeTo(4.5, 1e-9)); // 9 marks / 2 rounds
    expect(stats.mostMarksInRound, 6);
    expect(stats.fivePlusRounds, 1);
    expect(stats.sixPlusRounds, 1);
    expect(stats.sevenPlusRounds, 0);
    expect(stats.bullsPerRound, closeTo(1.0, 1e-9)); // 2 bulls / 2 rounds
  });

  test('lowNumber from the config snapshot changes what counts as a mark',
      () {
    final match = MatchRecord(
      gameId: 'm2',
      gameName: 'cricket',
      players: [alice],
      winnerId: alice.id,
      config: const {'lowNumber': 10, 'includeBull': false},
      turnHistory: [
        Turn(player: alice, throws: [dart(14, 1)]), // counts now
      ],
    );

    final stats = CricketStats.compute(alice, [match]);

    expect(stats.marksPerRound, 1);
  });

  test('a match saved before config snapshots existed falls back to '
      'Cricket defaults (lowNumber 15, bull included)', () {
    final match = MatchRecord(
      gameId: 'm3',
      gameName: 'cricket',
      players: [alice],
      winnerId: alice.id,
      config: null,
      turnHistory: [
        Turn(player: alice, throws: [dart(14, 1), dart(25, 1)]),
      ],
    );

    final stats = CricketStats.compute(alice, [match]);

    // 14 is below the default lowNumber (15) so it shouldn't count; the
    // bull is included by default so it should.
    expect(stats.marksPerRound, 1);
  });
}
