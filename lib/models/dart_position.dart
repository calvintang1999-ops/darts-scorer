import 'dart:math' as math;

/// Standard dartboard geometry in one place, so every part of the app
/// (and the future camera scorer) agrees on where the rings and segments are.
///
/// All radii are *normalised*: 0.0 is the exact centre of the board and
/// 1.0 is the outer wire of the double ring. The real-world measurements
/// (in mm, from the centre of a regulation board) are divided by 170mm,
/// which is the centre-to-outer-double-wire distance.
abstract final class BoardGeometry {
  /// Outer edge of the inner bull (the 50). 6.35mm on a real board.
  static const double innerBullRadius = 6.35 / 170.0;

  /// Outer edge of the outer bull (the 25). 15.9mm on a real board.
  static const double outerBullRadius = 15.9 / 170.0;

  /// Inner and outer edges of the treble ring. 99mm-107mm on a real board.
  static const double trebleInnerRadius = 99.0 / 170.0;
  static const double trebleOuterRadius = 107.0 / 170.0;

  /// Inner and outer edges of the double ring. 162mm-170mm on a real board.
  static const double doubleInnerRadius = 162.0 / 170.0;
  static const double doubleOuterRadius = 1.0;

  /// Segment numbers in clockwise order starting from the top (12 o'clock).
  /// The 20 sits at the top of every regulation board.
  static const List<int> segmentsClockwiseFromTop = [
    20, 1, 18, 4, 13, 6, 10, 15, 2, 17, 3, 19, 7, 16, 8, 11, 14, 9, 12, 5,
  ];

  /// Each of the 20 wedges spans 18 degrees (360 / 20).
  static const double degreesPerSegment = 360.0 / 20.0;
}

/// The segment value used for the bull. Outer bull = 25 x 1, inner bull
/// (the 50) = 25 x 2. Treating the inner bull as "double 25" matches the
/// official rule that the bull can finish a double-out game.
const int bullSegment = 25;

/// The segment value used for a miss (dart missed the scoring area entirely).
const int missSegment = 0;

/// A dart's physical colour on a standard board. Singles alternate black
/// and white wedge-by-wedge; the double/treble ring above a black wedge
/// is red, above a white wedge is green. Used by games that care about
/// board colour (e.g. Half It's "3 Colours" round) - never by scoring,
/// which only ever reads segment + multiplier.
enum DartColour { black, white, red, green }

/// Works out a dart's colour from the segment it hit and its multiplier.
/// Null for a miss (nothing was hit, so there's no colour). No colour
/// data is stored on [Throw] - callers derive it on demand from
/// `actualSegment` + `multiplier`, same as scoring does.
DartColour? dartColour(int segment, int multiplier) {
  if (segment == missSegment) return null;
  if (segment == bullSegment) {
    // Inner bull (the 50) is red, outer bull (the 25) is green.
    return multiplier == 2 ? DartColour.red : DartColour.green;
  }
  final wedgeIndex = BoardGeometry.segmentsClockwiseFromTop.indexOf(segment);
  if (wedgeIndex == -1) return null; // not a real segment - defensive only
  final isBlackWedge = wedgeIndex.isEven;
  if (multiplier == 1) {
    return isBlackWedge ? DartColour.black : DartColour.white;
  }
  return isBlackWedge ? DartColour.red : DartColour.green;
}

/// What a dart position resolves to: a segment number and a multiplier.
class SegmentHit {
  const SegmentHit(this.segment, this.multiplier);

  /// 1-20 for the numbered wedges, [bullSegment] (25), or [missSegment] (0).
  final int segment;

  /// 1 = single, 2 = double, 3 = treble.
  final int multiplier;
}

/// A normalised landing point on the dartboard, in polar coordinates.
///
/// This exists for the camera-scoring phase and for position-based stats
/// (heatmaps). Scoring logic NEVER reads this class - games score from
/// `Throw.actualSegment` + `Throw.multiplier` only, so manual entries
/// (which have no position) and camera entries behave identically.
class DartPosition {
  const DartPosition({
    required this.radiusNormalised,
    required this.angleDegrees,
    this.boardCoordinateSystemVersion = currentCoordinateSystemVersion,
  });

  /// Bump this if we ever change how coordinates are defined (e.g. a new
  /// normalisation), so old stored positions aren't silently misread.
  static const int currentCoordinateSystemVersion = 1;

  /// 0.0 at the centre of the board, 1.0 at the outer double wire.
  /// Values above 1.0 mean the dart landed outside the scoring area.
  final double radiusNormalised;

  /// 0-360, measured clockwise from the top of the board (12 o'clock).
  final double angleDegrees;

  /// The coordinate-system version this position was recorded under.
  final int boardCoordinateSystemVersion;

  Map<String, Object?> toJson() => {
        'radiusNormalised': radiusNormalised,
        'angleDegrees': angleDegrees,
        'boardCoordinateSystemVersion': boardCoordinateSystemVersion,
      };

  /// Works out which segment and ring this position lands in.
  SegmentHit toSegment() {
    if (radiusNormalised <= BoardGeometry.innerBullRadius) {
      return const SegmentHit(bullSegment, 2); // inner bull = 50
    }
    if (radiusNormalised <= BoardGeometry.outerBullRadius) {
      return const SegmentHit(bullSegment, 1); // outer bull = 25
    }
    if (radiusNormalised > BoardGeometry.doubleOuterRadius) {
      return const SegmentHit(missSegment, 1); // off the board
    }

    // Which wedge? The 20 wedge is centred on 0 degrees, so it spans
    // -9 to +9. Shifting by half a wedge lets simple division find the index.
    final shifted =
        (angleDegrees + BoardGeometry.degreesPerSegment / 2) % 360.0;
    final index = (shifted / BoardGeometry.degreesPerSegment).floor();
    final segment = BoardGeometry.segmentsClockwiseFromTop[index];

    if (radiusNormalised >= BoardGeometry.trebleInnerRadius &&
        radiusNormalised <= BoardGeometry.trebleOuterRadius) {
      return SegmentHit(segment, 3);
    }
    if (radiusNormalised >= BoardGeometry.doubleInnerRadius) {
      return SegmentHit(segment, 2);
    }
    return SegmentHit(segment, 1);
  }

  /// Convenience for future camera code: build a position from x/y offsets
  /// (already normalised so the double wire is at distance 1.0).
  factory DartPosition.fromCartesian(double x, double y) {
    final radius = math.sqrt(x * x + y * y);
    // atan2 gives the angle from the positive x-axis, counter-clockwise.
    // We want degrees clockwise from the top, so convert.
    final angleFromTop = (math.atan2(x, y) * 180.0 / math.pi + 360.0) % 360.0;
    return DartPosition(radiusNormalised: radius, angleDegrees: angleFromTop);
  }
}
