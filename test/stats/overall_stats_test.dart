import 'package:darts/models/match_record.dart';
import 'package:darts/models/player.dart';
import 'package:darts/models/throw.dart';
import 'package:darts/services/stats/overall_stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Player alice;
  late Player bob;

  setUp(() {
    alice = Player.create('Alice');
    bob = Player.create('Bob');
  });

  Throw dart(int segment, int multiplier, {int delta = 0}) => Throw(
        player: alice,
        actualSegment: segment,
        multiplier: multiplier,
        gameId: 'm',
        resultingScoreDelta: delta,
      );

  test('no matches gives the empty/no-data result', () {
    final stats = OverallStats.compute(alice, const []);
    expect(stats, OverallStats.empty);
  });

  test('win/loss record excludes abandoned matches', () {
    final won = MatchRecord(
      gameId: 'm1',
      gameName: 'x01',
      players: [alice, bob],
      winnerId: alice.id,
      turnHistory: const [],
    );
    final lost = MatchRecord(
      gameId: 'm2',
      gameName: 'x01',
      players: [alice, bob],
      winnerId: bob.id,
      turnHistory: const [],
    );
    final abandoned = MatchRecord(
      gameId: 'm3',
      gameName: 'x01',
      players: [alice, bob],
      winnerId: null,
      turnHistory: const [],
    );

    final stats = OverallStats.compute(alice, [won, lost, abandoned]);

    expect(stats.matchesPlayed, 3); // still counted as "played"
    expect(stats.wins, 1);
    expect(stats.losses, 1);
    expect(stats.winRate, closeTo(50, 1e-9));
  });

  test('favourite spot is the most-hit segment, misses excluded', () {
    final match = MatchRecord(
      gameId: 'm1',
      gameName: 'x01',
      players: [alice],
      winnerId: alice.id,
      turnHistory: [
        Turn(player: alice, throws: [
          dart(20, 3),
          dart(20, 1),
          dart(0, 1), // miss - shouldn't count
        ]),
        Turn(player: alice, throws: [dart(19, 1)]),
      ],
    );

    final stats = OverallStats.compute(alice, [match]);

    expect(stats.favouriteSpot, 20);
  });

  test('headline series reuses each game\'s own calculator per match', () {
    final match1 = MatchRecord(
      gameId: 'm1',
      gameName: 'x01',
      players: [alice],
      winnerId: alice.id,
      finishedAt: DateTime(2026, 1, 1),
      turnHistory: [
        Turn(player: alice, throws: [dart(20, 3, delta: -60)]),
      ],
    );
    final match2 = MatchRecord(
      gameId: 'm2',
      gameName: 'x01',
      players: [alice],
      winnerId: alice.id,
      finishedAt: DateTime(2026, 1, 2),
      turnHistory: [
        Turn(player: alice, throws: [dart(19, 3, delta: -57)]),
      ],
    );

    final stats = OverallStats.compute(alice, [match2, match1]); // unsorted

    final series = stats.headlineSeries['x01']!;
    expect(series, hasLength(2));
    // Chronological order regardless of input order.
    expect(series[0].$1, DateTime(2026, 1, 1));
    expect(series[0].$2, closeTo(180, 1e-9)); // 60 pts / 1 dart * 3
    expect(series[1].$1, DateTime(2026, 1, 2));
    expect(series[1].$2, closeTo(171, 1e-9)); // 57 pts / 1 dart * 3
  });
}
