import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/darts_game.dart';

/// Counts every dart thrown across every game, for as long as the app is
/// installed - not per-match, so it lives outside any one [DartsGame].
/// Real dartboards wear unevenly (20 and its neighbours take the most
/// hits), so every [reminderInterval] darts we tell the UI it's time to
/// suggest rotating the board.
class DartCounterService extends ChangeNotifier {
  DartCounterService() {
    _load();
  }

  static const _totalKey = 'lifetime_darts_thrown';

  /// How many darts between rotate-the-board reminders.
  static const reminderInterval = 1000;

  int _totalThrown = 0;
  int get totalThrown => _totalThrown;

  StreamSubscription<void>? _subscription;

  /// Starts counting darts thrown in [game]. [onRotateReminderDue] fires
  /// synchronously the instant the running total hits a multiple of
  /// [reminderInterval] - the caller (a play screen, which has a
  /// BuildContext) is responsible for actually showing something.
  void listenTo(DartsGame game, {required VoidCallback onRotateReminderDue}) {
    _subscription?.cancel();
    _subscription = game.dartThrown.listen((_) {
      _totalThrown++;
      notifyListeners();
      _save();
      if (_totalThrown % reminderInterval == 0) onRotateReminderDue();
    });
  }

  /// Stops counting. Call this from the play screen's `dispose`.
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _totalThrown = prefs.getInt(_totalKey) ?? 0;
      notifyListeners();
    } catch (_) {
      // No platform plugin available (e.g. some test environments) -
      // just start counting from zero for this session.
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_totalKey, _totalThrown);
    } catch (_) {
      // Best effort - counting still works for the rest of this session.
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
