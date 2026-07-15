/// A specific bed on the board: one of the 20 trebles, 20 doubles, 20
/// singles, or either bull. Lets a bot character say "I aim for T19" as a
/// typed value instead of a magic string.
///
/// [label] gives the same short text the checkout chart already uses
/// ("T20", "D16", "5", "Bull", "25" - see checkouts.dart), so
/// `BoardGeometry.aimPointFor` can read either without a separate parser.
class Segment {
  const Segment._(this.number, this.multiplier);

  /// 1-20 for the numbered wedges, or 25 for either bull.
  final int number;

  /// 1 = single, 2 = double (the inner bull counts as a double for
  /// checkout purposes), 3 = treble.
  final int multiplier;

  static Segment treble(int number) => Segment._(number, 3);
  static Segment double(int number) => Segment._(number, 2);
  static Segment single(int number) => Segment._(number, 1);

  /// The 50. Finishes a double-out leg, same as any other double.
  static const bull = Segment._(25, 2);

  /// The 25.
  static const outerBull = Segment._(25, 1);

  /// The default scoring bed almost every player aims for.
  static const t20 = Segment._(20, 3);

  String get label {
    if (this == bull) return 'Bull';
    if (this == outerBull) return '25';
    const prefixes = {1: '', 2: 'D', 3: 'T'};
    return '${prefixes[multiplier]}$number';
  }

  @override
  bool operator ==(Object other) =>
      other is Segment &&
      other.number == number &&
      other.multiplier == multiplier;

  @override
  int get hashCode => Object.hash(number, multiplier);

  @override
  String toString() => 'Segment($label)';
}
