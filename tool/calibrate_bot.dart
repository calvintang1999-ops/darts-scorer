import 'dart:io';
import 'dart:math';

import 'package:darts/games/x01/x01_brain.dart';
import 'package:darts/games/x01/x01_config.dart';
import 'package:darts/games/x01/x01_game.dart';
import 'package:darts/models/player.dart';
import 'package:darts/services/bot/gaussian_arm.dart';
import 'package:darts/services/bot/throw_context.dart';

/// Standalone dev tool (not shipped in the app) that calibrates the 8
/// preset bots. For each target 3-dart average, it binary-searches the
/// GaussianArm sigma (throw accuracy, in mm) that produces it, simulating
/// full 501 legs with a single bot player (X01Brain default strategy +
/// GaussianArm) each time. It also measures the checkout percentage that
/// sigma produces, since that's what real players see as "how good is this
/// bot" alongside its average.
///
/// This imports X01Game, which (like every DartsGame) is a ChangeNotifier
/// and so pulls in package:flutter - and `dart:ui` only resolves inside the
/// Flutter test/run harness, not plain `dart run`. So despite living under
/// tool/, this has to be launched via the Flutter test runner:
///   flutter test tool/calibrate_bot.dart
/// Optional env var overrides legs-per-evaluation, for a quick sanity run:
///   CALIBRATION_LEGS=200 flutter test tool/calibrate_bot.dart
void main() {
  final legsEnv = Platform.environment['CALIBRATION_LEGS'];
  final legsPerEvaluation = legsEnv != null ? int.parse(legsEnv) : 5000;

  const presets = [
    (name: 'Rookie Ray', targetAverage: 35.0),
    (name: 'Steady Steve', targetAverage: 45.0),
    (name: 'Lucky Lou', targetAverage: 55.0),
    (name: 'Sharp Sam', targetAverage: 65.0),
    (name: 'Bullseye Bex', targetAverage: 75.0),
    (name: 'Cool Hand Cody', targetAverage: 85.0),
    (name: 'The Professor', targetAverage: 95.0),
    (name: 'The Governor', targetAverage: 105.0),
  ];

  stdout.writeln('name,targetAverage,sigmaMm,measuredAverage,checkoutPercent');
  final results = <_CalibrationResult>[];
  for (final preset in presets) {
    final result = _calibrate(preset.targetAverage, legsPerEvaluation);
    results.add(result);
    stdout.writeln(
      '${preset.name},${preset.targetAverage},'
      '${result.sigmaMm.toStringAsFixed(2)},'
      '${result.average.toStringAsFixed(2)},'
      '${result.checkoutPercent.toStringAsFixed(2)}',
    );
  }

  stdout.writeln();
  stdout.writeln('-- lib/services/bot/bot_calibration_constants.dart body --');
  for (var i = 0; i < presets.length; i++) {
    final preset = presets[i];
    final result = results[i];
    stdout.writeln(
      "  BotCalibrationPreset(name: '${preset.name}', "
      'targetAverage: ${preset.targetAverage}, '
      'sigmaMm: ${result.sigmaMm.toStringAsFixed(2)}, '
      'measuredCheckoutPercent: ${result.checkoutPercent.toStringAsFixed(2)}),',
    );
  }
}

class _CalibrationResult {
  _CalibrationResult(this.sigmaMm, this.average, this.checkoutPercent);
  final double sigmaMm;
  final double average;
  final double checkoutPercent;
}

class _LegStats {
  _LegStats(this.average, this.checkoutPercent);
  final double average;
  final double checkoutPercent;
}

/// Binary search over sigma: a smaller sigma (more accurate) always
/// produces a higher average, so the relationship is monotonic and binary
/// search applies directly.
_CalibrationResult _calibrate(double targetAverage, int legsPerEvaluation) {
  var lo = 3.0; // very accurate
  var hi = 130.0; // very wild

  _LegStats stats = _simulateLegs(
    sigmaMm: hi,
    legs: legsPerEvaluation,
    seed: 0,
  );
  var sigma = hi;

  for (var iteration = 1; iteration <= 20; iteration++) {
    sigma = (lo + hi) / 2;
    stats = _simulateLegs(
      sigmaMm: sigma,
      legs: legsPerEvaluation,
      seed: iteration,
    );
    if ((stats.average - targetAverage).abs() <= 0.5) break;
    if (stats.average > targetAverage) {
      lo = sigma; // too accurate - loosen up
    } else {
      hi = sigma; // too wild - tighten up
    }
  }

  return _CalibrationResult(sigma, stats.average, stats.checkoutPercent);
}

/// Plays [legs] full solo 501 legs (double-out, straight-in) with a bot
/// using [sigmaMm] accuracy, and reports its 3-dart average and checkout %.
_LegStats _simulateLegs({
  required double sigmaMm,
  required int legs,
  required int seed,
}) {
  final random = Random(seed);
  const brain = X01Brain();
  final arm = GaussianArm(sigmaMm: sigmaMm, random: random);

  // Mirrors lib/services/stats/x01_stats.dart's threeDartAverage exactly:
  // per-visit net score (-sum(resultingScoreDelta)), not raw dart face
  // value. That matters because a busted visit reverts the score, so its
  // resultingScoreDelta cancels the darts thrown before the bust back to
  // net 0 - counting raw face value instead would over-credit bots that
  // bust often (i.e. the less accurate ones), skewing the calibration.
  var totalPoints = 0;
  var totalDarts = 0;
  var checkoutAttempts = 0;
  var checkoutSuccesses = 0;

  for (var leg = 0; leg < legs; leg++) {
    final bot = Player.create('Bot');
    final game = X01Game(players: [bot], config: const X01Config());
    var dartIndexInMatch = 0;

    while (!game.isFinished) {
      final decision = brain.nextAim(
        remainingScore: game.scores[0],
        dartsLeftInTurn: game.dartsLeftInTurn,
      );
      final context = ThrowContext.forAim(
        decision.aimPoint,
        isCheckoutAttempt: decision.isCheckoutAttempt,
        dartIndexInTurn: 3 - game.dartsLeftInTurn,
        dartIndexInMatch: dartIndexInMatch,
      );
      final result = arm.throwDart(
        decision.aimPoint,
        context,
        player: bot,
        gameId: game.gameId,
      );

      dartIndexInMatch++;
      if (decision.isCheckoutAttempt) checkoutAttempts++;

      game.applyThrow(result);

      if (decision.isCheckoutAttempt && game.isFinished) {
        checkoutSuccesses++;
      }
    }

    for (final turn in game.turnHistory) {
      final visitScore =
          -turn.throws.fold<int>(0, (sum, d) => sum + d.resultingScoreDelta);
      totalPoints += visitScore;
      totalDarts += turn.throws.length;
    }
  }

  final average = totalDarts == 0 ? 0.0 : (totalPoints / totalDarts) * 3;
  final checkoutPercent =
      checkoutAttempts == 0 ? 0.0 : (checkoutSuccesses / checkoutAttempts) * 100;
  return _LegStats(average, checkoutPercent);
}
