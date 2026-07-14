import 'package:darts/games/x01/x01_config.dart';
import 'package:darts/games/x01/x01_game.dart';
import 'package:darts/models/match_record.dart';
import 'package:darts/models/player.dart';
import 'package:darts/models/throw.dart';
import 'package:darts/services/database/app_database.dart';
import 'package:darts/services/drift_storage_service.dart';
import 'package:darts/services/stats/x01_stats.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// This is the one test in the suite that doesn't hand-build Turn/Throw
/// fixtures - those unit tests encode the same assumptions the calculators
/// read back, so they can't catch a divergence between what X01Game
/// actually produces and what X01Stats expects. This test drives a real
/// X01Game (including a genuine bust), saves it through the real drift
/// storage stack exactly as x01_play_screen.dart does, reloads it, and
/// only then runs the calculator - engine to database to stats, for real.
void main() {
  test('a real X01 leg (with a bust) round-trips through storage into '
      'correct stats', () async {
    final alice = Player.create('Alice');
    final bob = Player.create('Bob');
    const config = X01Config(startingScore: 41, outRule: X01OutRule.double);
    final game = X01Game(players: [alice, bob], config: config);

    void throwDart(int segment, int multiplier) {
      game.applyThrow(Throw(
        player: game.currentPlayer,
        actualSegment: segment,
        multiplier: multiplier,
        gameId: game.gameId,
      ));
    }

    // Alice: T20 on 41 remaining - a genuine bust (41 - 60 < 0). Reverts
    // to 41 and ends her turn immediately.
    throwDart(20, 3);
    expect(game.currentPlayer.id, bob.id);

    // Bob: three harmless darts to complete his turn and hand it back.
    throwDart(1, 1);
    throwDart(1, 1);
    throwDart(1, 1);
    expect(game.currentPlayer.id, alice.id);

    // Alice: single 9 (41 -> 32), then D16 (32 -> 0) - a real double-out win.
    throwDart(9, 1);
    throwDart(16, 2);
    expect(game.isFinished, isTrue);
    expect(game.winner!.id, alice.id);

    // Exactly how x01_play_screen.dart builds the record on a real win.
    final match = MatchRecord(
      gameId: game.gameId,
      gameName: 'x01',
      players: game.players,
      turnHistory: List.of(game.turnHistory),
      winnerId: game.winner?.id,
      config: {
        'startingScore': game.config.startingScore,
        'outRule': game.config.outRule.name,
      },
    );

    final storage = DriftStorageService.forTesting(
      AppDatabase.forTesting(NativeDatabase.memory()),
    );
    await storage.saveMatch(match);
    final loaded = (await storage.loadMatchHistory())
        .singleWhere((m) => m.gameId == game.gameId);

    final stats = X01Stats.compute(alice, [loaded]);

    // 3 darts total (1 busted + 2 to check out), 41 points that counted
    // (the bust contributes 0): 41 / 3 * 3 = 41 exactly.
    expect(stats.threeDartAverage, closeTo(41, 1e-9));
    expect(stats.firstNineAverage, closeTo(41, 1e-9));
    // 2 checkout rounds (both visits started from 41, which is
    // checkoutable): the bust visit missed, the second visit converted.
    expect(stats.checkoutPercentage, closeTo(50, 1e-9));
    // 1 double landed (the winning D16) out of 3 darts thrown across
    // those two checkout rounds.
    expect(stats.doublesHitRate, closeTo(100 / 3, 1e-9));
    expect(stats.highestCheckout, 41);
    expect(stats.bestLegDarts, 3);
    expect(stats.worstLegDarts, 3);
  });
}
