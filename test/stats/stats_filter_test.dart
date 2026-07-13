import 'package:darts/models/match_record.dart';
import 'package:darts/models/player.dart';
import 'package:darts/services/stats/stats_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Player alice;
  late Player bob;

  setUp(() {
    alice = Player.create('Alice');
    bob = Player.create('Bob');
  });

  MatchRecord match({
    required String id,
    required String gameName,
    required List<Player> players,
    required DateTime finishedAt,
  }) =>
      MatchRecord(
        gameId: id,
        gameName: gameName,
        players: players,
        turnHistory: const [],
        winnerId: null,
        finishedAt: finishedAt,
      );

  test('excludes matches the player wasn\'t in', () {
    final aliceMatch = match(
        id: 'm1', gameName: 'x01', players: [alice], finishedAt: DateTime(2026, 1, 1));
    final bobMatch = match(
        id: 'm2', gameName: 'x01', players: [bob], finishedAt: DateTime(2026, 1, 1));

    final result = matchesForPlayer(alice, [aliceMatch, bobMatch]);

    expect(result, [aliceMatch]);
  });

  test('filters by game name and date range, sorts newest first', () {
    final x01Jan = match(
        id: 'm1', gameName: 'x01', players: [alice], finishedAt: DateTime(2026, 1, 10));
    final x01Feb = match(
        id: 'm2', gameName: 'x01', players: [alice], finishedAt: DateTime(2026, 2, 10));
    final cricketJan = match(
        id: 'm3', gameName: 'cricket', players: [alice], finishedAt: DateTime(2026, 1, 15));

    final result = matchesForPlayer(
      alice,
      [x01Jan, x01Feb, cricketJan],
      gameName: 'x01',
      range: DateRange(start: DateTime(2026, 1, 1), end: DateTime(2026, 1, 31)),
    );

    expect(result, [x01Jan]);
  });
}
