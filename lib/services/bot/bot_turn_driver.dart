import '../../models/darts_game.dart';
import '../../models/throw.dart';
import '../../theme/tokens.dart';

/// Plays out a bot's turn (and, if the next player is also a bot, keeps
/// going straight into theirs too) through the exact same
/// `DartsGame.applyThrow` path a human uses - one dart at a time, with a
/// short pacing delay between darts so a human watching can follow along.
///
/// This is deliberately game-agnostic: it doesn't know X01 from Cricket,
/// it just repeatedly asks [buildNextThrow] for the next dart and applies
/// it. Each play screen supplies that callback wired to its own game's
/// specific BotBrain + BotArm.
class BotTurnDriver {
  BotTurnDriver({
    required this.game,
    required this.isCurrentPlayerBot,
    required this.buildNextThrow,
  });

  final DartsGame game;

  /// Whether whoever's up right now is a bot. Checked before every dart,
  /// so the loop naturally stops the moment play reaches a human, and
  /// naturally continues if it reaches a *different* bot.
  final bool Function() isCurrentPlayerBot;

  /// Decides and throws the next dart (via that game's brain + arm),
  /// without applying it - this driver owns applying it, so the pacing
  /// delay always sits in exactly one place.
  final Throw Function() buildNextThrow;

  bool _cancelled = false;
  bool _running = false;

  bool get isRunning => _running;

  /// Stops the loop after its current dart (e.g. the play screen is being
  /// torn down). Safe to call any time, including when nothing is running.
  void cancel() => _cancelled = true;

  /// Runs every consecutive bot turn starting right now, stopping when
  /// play reaches a human, the match finishes, or [cancel] is called.
  /// Safe to call repeatedly (e.g. from a listener that fires on every
  /// dart) - it's a no-op if a run is already in progress or it's not
  /// currently a bot's turn.
  Future<void> playPendingBotTurns() async {
    if (_running || _cancelled) return;
    if (!isCurrentPlayerBot()) return;

    _running = true;
    try {
      while (!_cancelled && !game.isFinished && isCurrentPlayerBot()) {
        game.applyThrow(buildNextThrow());
        if (_cancelled || game.isFinished || !isCurrentPlayerBot()) break;
        await Future.delayed(DurationTokens.botThrowPacing);
      }
    } finally {
      _running = false;
    }
  }
}
