import 'package:flutter/widgets.dart';

import '../../models/darts_game.dart';
import '../../models/throw.dart';
import 'bot_turn_driver.dart';

/// Wires a [BotTurnDriver] into a play screen's lifecycle. Every play
/// screen constructs one of these in `initState` and calls [dispose] from
/// its own `dispose` - that's the entire integration surface, so the same
/// kickoff/cancel logic isn't duplicated across X01/Cricket/Half It/Round
/// the Clock's play screens.
///
/// Two kickoff points cover every case: right after the first frame
/// (handles a match that opens on a bot's turn), and whenever the game
/// changes (handles a human finishing their turn and handing off to a
/// bot). [BotTurnDriver.playPendingBotTurns] is itself a safe no-op if
/// it's not currently a bot's turn or a run is already in progress, so
/// both call sites can fire freely without double-driving anything.
class BotTurnScreenController {
  BotTurnScreenController({
    required DartsGame game,
    required bool Function() isCurrentPlayerBot,
    required Throw Function() buildNextThrow,
  }) : _driver = BotTurnDriver(
          game: game,
          isCurrentPlayerBot: isCurrentPlayerBot,
          buildNextThrow: buildNextThrow,
        ) {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _driver.playPendingBotTurns());
  }

  final BotTurnDriver _driver;

  /// Call this from the screen's own `game.addListener` callback.
  void onGameChanged() {
    if (!_driver.isRunning) {
      // Scheduled rather than called inline: the listener fires from
      // inside notifyListeners, and applyThrow-ing a bot's first dart
      // synchronously from there would be a re-entrant call into the game
      // while it's still notifying about the previous one.
      Future.microtask(_driver.playPendingBotTurns);
    }
  }

  /// Call this from the screen's own `dispose`.
  void dispose() => _driver.cancel();
}
