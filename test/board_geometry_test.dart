import 'package:darts/models/dart_position.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('aimPointFor / segmentAt round trip', () {
    for (var n = 1; n <= 20; n++) {
      test('T$n resolves back to treble $n', () {
        final hit = BoardGeometry.segmentAt(BoardGeometry.aimPointFor('T$n'));
        expect(hit.segment, n);
        expect(hit.multiplier, 3);
      });

      test('D$n resolves back to double $n', () {
        final hit = BoardGeometry.segmentAt(BoardGeometry.aimPointFor('D$n'));
        expect(hit.segment, n);
        expect(hit.multiplier, 2);
      });

      test('$n resolves back to single $n', () {
        final hit = BoardGeometry.segmentAt(BoardGeometry.aimPointFor('$n'));
        expect(hit.segment, n);
        expect(hit.multiplier, 1);
      });
    }

    test('Bull resolves back to the inner bull (50)', () {
      final hit = BoardGeometry.segmentAt(BoardGeometry.aimPointFor('Bull'));
      expect(hit.segment, bullSegment);
      expect(hit.multiplier, 2);
    });

    test('25 resolves back to the outer bull', () {
      final hit = BoardGeometry.segmentAt(BoardGeometry.aimPointFor('25'));
      expect(hit.segment, bullSegment);
      expect(hit.multiplier, 1);
    });
  });

  group('ring boundaries', () {
    test('exactly on the inner bull wire counts as the inner bull', () {
      const pos =
          DartPosition(radiusNormalised: BoardGeometry.innerBullRadius, angleDegrees: 0);
      final hit = pos.toSegment();
      expect(hit.segment, bullSegment);
      expect(hit.multiplier, 2);
    });

    test('just outside the inner bull wire counts as the outer bull', () {
      const pos = DartPosition(
          radiusNormalised: BoardGeometry.innerBullRadius + 0.0001,
          angleDegrees: 0);
      final hit = pos.toSegment();
      expect(hit.segment, bullSegment);
      expect(hit.multiplier, 1);
    });

    test('exactly on the outer bull wire counts as the outer bull', () {
      const pos = DartPosition(
          radiusNormalised: BoardGeometry.outerBullRadius, angleDegrees: 0);
      final hit = pos.toSegment();
      expect(hit.segment, bullSegment);
      expect(hit.multiplier, 1);
    });

    test('just outside the outer bull wire counts as a single', () {
      const pos = DartPosition(
          radiusNormalised: BoardGeometry.outerBullRadius + 0.0001,
          angleDegrees: 0);
      final hit = pos.toSegment();
      expect(hit.segment, 20); // angle 0 is the 20 wedge
      expect(hit.multiplier, 1);
    });

    test('exactly on the treble ring inner/outer wires counts as treble', () {
      const inner = DartPosition(
          radiusNormalised: BoardGeometry.trebleInnerRadius, angleDegrees: 0);
      const outer = DartPosition(
          radiusNormalised: BoardGeometry.trebleOuterRadius, angleDegrees: 0);
      expect(inner.toSegment().multiplier, 3);
      expect(outer.toSegment().multiplier, 3);
    });

    test('just inside/outside the treble ring counts as single', () {
      const justInside = DartPosition(
          radiusNormalised: BoardGeometry.trebleInnerRadius - 0.0001,
          angleDegrees: 0);
      const justOutside = DartPosition(
          radiusNormalised: BoardGeometry.trebleOuterRadius + 0.0001,
          angleDegrees: 0);
      expect(justInside.toSegment().multiplier, 1);
      expect(justOutside.toSegment().multiplier, 1);
    });

    test('exactly on the double ring inner/outer wires counts as double', () {
      const inner = DartPosition(
          radiusNormalised: BoardGeometry.doubleInnerRadius, angleDegrees: 0);
      const outer = DartPosition(
          radiusNormalised: BoardGeometry.doubleOuterRadius, angleDegrees: 0);
      expect(inner.toSegment().multiplier, 2);
      expect(outer.toSegment().multiplier, 2);
    });

    test('just outside the double wire is a miss', () {
      const pos = DartPosition(
          radiusNormalised: BoardGeometry.doubleOuterRadius + 0.0001,
          angleDegrees: 0);
      final hit = pos.toSegment();
      expect(hit.segment, missSegment);
    });

    test('wedge boundary lands on the correct neighbour, not a coin flip', () {
      // The 20 wedge (index 0) spans -9..+9 degrees. Just past +9 must be
      // the next wedge clockwise, which is 1.
      const justInside = DartPosition(
          radiusNormalised: BoardGeometry.trebleOuterRadius, angleDegrees: 8.999);
      const justOutside = DartPosition(
          radiusNormalised: BoardGeometry.trebleOuterRadius, angleDegrees: 9.001);
      expect(justInside.toSegment().segment, 20);
      expect(justOutside.toSegment().segment, 1);
    });
  });

  group('Cartesian mm conversion', () {
    test('round-trips through mm and back to the same normalised position', () {
      const original =
          DartPosition(radiusNormalised: 0.6, angleDegrees: 123.0);
      final mm = original.toCartesianMm();
      final rebuilt = DartPosition.fromCartesianMm(mm.xMm, mm.yMm);
      expect(rebuilt.radiusNormalised, closeTo(original.radiusNormalised, 1e-9));
      expect(rebuilt.angleDegrees, closeTo(original.angleDegrees, 1e-9));
    });

    test('straight up (angle 0) is due north in mm, i.e. x = 0', () {
      const pos = DartPosition(radiusNormalised: 1.0, angleDegrees: 0);
      final mm = pos.toCartesianMm();
      expect(mm.xMm, closeTo(0, 1e-9));
      expect(mm.yMm, closeTo(BoardGeometry.mmPerNormalisedUnit, 1e-9));
    });

    test('90 degrees (due east) is x = radius, y = 0', () {
      const pos = DartPosition(radiusNormalised: 1.0, angleDegrees: 90);
      final mm = pos.toCartesianMm();
      expect(mm.xMm, closeTo(BoardGeometry.mmPerNormalisedUnit, 1e-9));
      expect(mm.yMm, closeTo(0, 1e-9));
    });
  });
}
