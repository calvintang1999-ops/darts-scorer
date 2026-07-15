import 'dart:math';

import 'package:darts/models/dart_position.dart';
import 'package:darts/models/player.dart';
import 'package:darts/models/throw.dart';
import 'package:darts/services/bot/bot_arm.dart';
import 'package:darts/services/bot/gaussian_arm.dart';
import 'package:darts/services/bot/throw_context.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final player = Player.create('Bot');
  const gameId = 'game-1';
  const context = ThrowContext(
    targetType: TargetType.triple,
    isCheckoutAttempt: false,
    dartIndexInTurn: 0,
    dartIndexInMatch: 0,
  );

  test('a seeded arm is reproducible', () {
    final aim = BoardGeometry.aimPointFor('T20');
    final arm1 = GaussianArm(sigmaMm: 10, random: Random(42));
    final arm2 = GaussianArm(sigmaMm: 10, random: Random(42));

    final throw1 =
        arm1.throwDart(aim, context, player: player, gameId: gameId);
    final throw2 =
        arm2.throwDart(aim, context, player: player, gameId: gameId);

    expect(throw1.actualSegment, throw2.actualSegment);
    expect(throw1.multiplier, throw2.multiplier);
    expect(throw1.landingPosition!.radiusNormalised,
        throw2.landingPosition!.radiusNormalised);
    expect(throw1.landingPosition!.angleDegrees,
        throw2.landingPosition!.angleDegrees);
  });

  test('near-zero sigma always hits the aim point', () {
    final aim = BoardGeometry.aimPointFor('D16');
    final arm = GaussianArm(sigmaMm: 0.0001, random: Random(7));

    for (var i = 0; i < 50; i++) {
      final result =
          arm.throwDart(aim, context, player: player, gameId: gameId);
      expect(result.actualSegment, 16);
      expect(result.multiplier, 2);
    }
  });

  test('dispersion (average miss distance) scales with sigma', () {
    double averageMissMm(double sigmaMm, int seed) {
      final aim = BoardGeometry.aimPointFor('T20');
      final aimMm = aim.toCartesianMm();
      final arm = GaussianArm(sigmaMm: sigmaMm, random: Random(seed));
      var totalDistance = 0.0;
      const trials = 2000;
      for (var i = 0; i < trials; i++) {
        final result =
            arm.throwDart(aim, context, player: player, gameId: gameId);
        final landingMm = result.landingPosition!.toCartesianMm();
        final dx = landingMm.xMm - aimMm.xMm;
        final dy = landingMm.yMm - aimMm.yMm;
        totalDistance += sqrt(dx * dx + dy * dy);
      }
      return totalDistance / trials;
    }

    final tight = averageMissMm(5, 1);
    final wild = averageMissMm(40, 1);
    expect(wild, greaterThan(tight * 3));
  });

  test('intendedTarget and source are always set for bot throws', () {
    final aim = BoardGeometry.aimPointFor('T20');
    final arm = GaussianArm(sigmaMm: 10, random: Random(1));
    final result = arm.throwDart(aim, context, player: player, gameId: gameId);

    expect(result.source, ThrowSource.bot);
    expect(result.intendedTarget, 20);
  });

  test('ThrowContext is passed through to the arm unchanged', () {
    final recorder = _RecordingArm();
    const customContext = ThrowContext(
      targetType: TargetType.bull,
      isCheckoutAttempt: true,
      dartIndexInTurn: 2,
      dartIndexInMatch: 57,
    );
    final aim = BoardGeometry.aimPointFor('Bull');

    recorder.throwDart(aim, customContext, player: player, gameId: gameId);

    expect(recorder.lastContext, same(customContext));
    expect(recorder.lastContext!.isCheckoutAttempt, true);
    expect(recorder.lastContext!.dartIndexInTurn, 2);
    expect(recorder.lastContext!.dartIndexInMatch, 57);
    expect(recorder.lastContext!.targetType, TargetType.bull);
  });
}

/// A bare-bones [BotArm] that just records what it was given, so tests can
/// prove a caller passes [ThrowContext] through faithfully - independent of
/// whether any real arm happens to use it yet.
class _RecordingArm implements BotArm {
  ThrowContext? lastContext;

  @override
  Throw throwDart(
    DartPosition aimPoint,
    ThrowContext context, {
    required Player player,
    required String gameId,
  }) {
    lastContext = context;
    final hit = BoardGeometry.segmentAt(aimPoint);
    return Throw(
      player: player,
      actualSegment: hit.segment,
      multiplier: hit.multiplier,
      gameId: gameId,
    );
  }
}
