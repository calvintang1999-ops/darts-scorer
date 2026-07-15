import '../../models/dart_position.dart';
import '../../models/player.dart';
import '../../models/throw.dart';
import 'throw_context.dart';

/// A bot's "hand": given where it means to throw, decides where the dart
/// actually lands. This is an interface, not a concrete class, so future
/// arms (fatigue, pressure on checkouts, left/right-handed bias) slot in
/// without any brain ever changing.
///
/// [player] and [gameId] aren't part of the brain's decision - they're just
/// the bookkeeping every [Throw] needs to carry, so the arm is handed them
/// alongside the aim point rather than working them out itself.
abstract class BotArm {
  Throw throwDart(
    DartPosition aimPoint,
    ThrowContext context, {
    required Player player,
    required String gameId,
  });
}
