@Tags(['slow'])
library;

import 'dart:math';

import 'package:darts/games/x01/x01_brain.dart';
import 'package:darts/games/x01/x01_config.dart';
import 'package:darts/games/x01/x01_game.dart';
import 'package:darts/models/player.dart';
import 'package:darts/services/bot/bot_calibration_constants.dart';
import 'package:darts/services/bot/gaussian_arm.dart';
import 'package:darts/services/bot/throw_context.dart';
import 'package:flutter_test/flutter_test.dart';

/// A whole-stack regression guard: simulates real matches (X01Brain +
/// GaussianArm + X01Game, exactly the path a real bot match takes) between
/// two calibrated presets and checks the better one actually wins more.
/// If this ever fails, something in the geometry/arm/brain/calibration
/// chain has broken, even though every piece's own unit tests still pass.
///
/// Tagged 'slow' - not because 200 legs is actually slow (it isn't; a leg
/// is a handful of milliseconds), but so a future, heavier version of this
/// guard can be excluded from a fast local loop with
/// `flutter test --exclude-tags=slow` without needing a second tag added.
void main() {
  test('World Class (105) beats Bot 45 in a strong majority of 200 legs', () {
    final weak =
        botCalibrationPresets.firstWhere((p) => p.name == 'Bot 45');
    final strong = botCalibrationPresets
        .firstWhere((p) => p.name == 'World Class (105)');

    const brain = X01Brain();
    // Seeded so this can never flake.
    final weakArm = GaussianArm(sigmaMm: weak.sigmaMm, random: Random(101));
    final strongArm =
        GaussianArm(sigmaMm: strong.sigmaMm, random: Random(202));

    var weakWins = 0;
    var strongWins = 0;
    const legs = 200;

    for (var leg = 0; leg < legs; leg++) {
      final weakPlayer = Player.create('Weak');
      final strongPlayer = Player.create('Strong');
      // Alternate who throws first each leg, so a first-dart advantage
      // can't tilt the result either way.
      final players =
          leg.isEven ? [weakPlayer, strongPlayer] : [strongPlayer, weakPlayer];
      final game = X01Game(players: players, config: const X01Config());

      while (!game.isFinished) {
        final isWeaksTurn = game.currentPlayer.id == weakPlayer.id;
        final arm = isWeaksTurn ? weakArm : strongArm;
        final decision = brain.nextAim(
          remainingScore: game.scores[game.currentPlayerIndex],
          dartsLeftInTurn: game.dartsLeftInTurn,
        );
        final context = ThrowContext.forAim(
          decision.aimPoint,
          isCheckoutAttempt: decision.isCheckoutAttempt,
          dartIndexInTurn: game.currentTurnThrows.length,
          dartIndexInMatch: 0,
        );
        final dart = arm.throwDart(
          decision.aimPoint,
          context,
          player: game.currentPlayer,
          gameId: game.gameId,
        );
        game.applyThrow(dart);
      }

      if (game.winner!.id == weakPlayer.id) {
        weakWins++;
      } else {
        strongWins++;
      }
    }

    expect(weakWins + strongWins, legs);
    // "Strong majority": at least 70% - comfortably clear of chance while
    // leaving room for the inherent variance of a stochastic simulation.
    expect(strongWins, greaterThan((legs * 0.7).round()));
  });
}
