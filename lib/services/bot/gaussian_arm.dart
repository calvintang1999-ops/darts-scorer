import 'dart:math' as math;

import '../../models/dart_position.dart';
import '../../models/player.dart';
import '../../models/throw.dart';
import 'bot_arm.dart';
import 'throw_context.dart';

/// The Phase 3 bot arm: independent Gaussian ("normal distribution") noise
/// on the x and y axes, in millimetres. A small [sigmaMm] means a tight,
/// accurate thrower; a large one means a wild, beginner-level one. This is
/// the standard way to simulate human dart-throwing error - real players'
/// misses cluster tightly around where they aimed and thin out smoothly
/// the further away you look, which is exactly what a Gaussian describes.
class GaussianArm implements BotArm {
  GaussianArm({required this.sigmaMm, required this.random});

  /// Standard deviation of the miss distance on each axis, in mm. Larger =
  /// less accurate.
  final double sigmaMm;

  /// Injected so tests (and the calibration script) can seed it for
  /// reproducible throws.
  final math.Random random;

  @override
  Throw throwDart(
    DartPosition aimPoint,
    ThrowContext context, {
    required Player player,
    required String gameId,
  }) {
    // Future arms may read context here - this one only cares about sigma.
    final aimMm = aimPoint.toCartesianMm();
    final landingMm = (
      xMm: aimMm.xMm + _nextGaussianSample() * sigmaMm,
      yMm: aimMm.yMm + _nextGaussianSample() * sigmaMm,
    );
    final landingPosition =
        DartPosition.fromCartesianMm(landingMm.xMm, landingMm.yMm);
    final hit = BoardGeometry.segmentAt(landingPosition);

    return Throw(
      player: player,
      actualSegment: hit.segment,
      multiplier: hit.multiplier,
      gameId: gameId,
      source: ThrowSource.bot,
      landingPosition: landingPosition,
      // The bot always knows what it meant to hit, unlike manual entry.
      intendedTarget: BoardGeometry.segmentAt(aimPoint).segment,
    );
  }

  /// One sample from a standard normal distribution (mean 0, variance 1),
  /// via the Box-Muller transform. `dart:math`'s Random only gives uniform
  /// samples, so this turns two of those into one Gaussian one.
  double _nextGaussianSample() {
    final u1 = 1.0 - random.nextDouble(); // (0, 1] - avoids log(0)
    final u2 = random.nextDouble();
    return math.sqrt(-2.0 * math.log(u1)) * math.cos(2.0 * math.pi * u2);
  }
}
