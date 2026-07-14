import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';

import '../models/darts_game.dart';
import '../models/game_event.dart';
import 'settings_provider.dart';

/// Speaks [GameEvent]s out loud. This is the only place in the app that
/// knows flutter_tts exists - it doesn't know any game's rules, it just
/// reads out whichever [GameEvent.message] arrives. A play screen wires
/// one up by calling [listenTo] with its live game (see any play screen's
/// `initState`/`dispose`); nothing in `lib/games/` imports this file, so
/// scoring logic behaves identically whether the announcer is on, off, or
/// deleted outright.
class AnnouncerService {
  AnnouncerService(this._settings) {
    // Best-effort: some environments (widget tests, a device with no TTS
    // engine installed) have no platform implementation to talk to.
    _tts.setSpeechRate(0.5).catchError((_) {});
  }

  final SettingsProvider _settings;
  final FlutterTts _tts = FlutterTts();
  StreamSubscription<GameEvent>? _subscription;

  /// Starts announcing events from [game]. Safe to call again (e.g. for a
  /// rematch's new game instance) - it drops the previous subscription
  /// first.
  void listenTo(DartsGame game) {
    _subscription?.cancel();
    _subscription = game.events.listen(_announce);
  }

  /// Stops announcing. Call this from the play screen's `dispose`.
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _announce(GameEvent event) async {
    if (!_settings.soundEnabled) return;
    try {
      // Stop first so a fast checkout-then-match-won pair doesn't queue
      // up and read out both, one after the other after play has moved on.
      await _tts.stop();
      await _tts.speak(event.message);
    } catch (_) {
      // No TTS engine available - fail silently rather than crash play.
    }
  }

  void dispose() {
    _subscription?.cancel();
    _tts.stop();
  }
}
