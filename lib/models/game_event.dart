import 'player.dart';

/// What kind of announcer-worthy moment just happened. Kept separate from
/// [GameEvent.message] so a future listener (or a different voice style)
/// could react to the kind alone without parsing text.
enum GameEventKind {
  /// A turn (up to 3 darts) just finished during ordinary play.
  visit,

  /// A player has just finished a leg/game with a valid finishing dart.
  checkout,

  /// The whole match has been won.
  matchWon,
}

/// One announcer-worthy moment. Games build the [message] themselves in
/// their own scoring language (X01 says "you require 170"; Cricket says
/// "two marks on twenty") and emit it via [DartsGame.emitEvent] - see that
/// file for why this keeps scoring code decoupled from the announcer.
class GameEvent {
  const GameEvent({
    required this.kind,
    required this.player,
    required this.message,
  });

  final GameEventKind kind;
  final Player player;
  final String message;
}
