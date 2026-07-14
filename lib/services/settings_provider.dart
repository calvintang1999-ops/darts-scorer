import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide user settings. Theme mode isn't persisted (it's a rarely
/// changed dev-time convenience so far); the sound toggle is, since the
/// voice announcer should stay off (or on) across app restarts.
///
/// Settings are simple device-local preferences, not match data, so they
/// go through shared_preferences directly rather than [StorageService] -
/// that interface is for players and match history, and keeping settings
/// out of it means they don't end up in the JSON backup export.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider() {
    _loadSoundSetting();
  }

  static const _soundEnabledKey = 'sound_enabled';

  ThemeMode _themeMode = ThemeMode.system;
  bool _soundEnabled = true;

  ThemeMode get themeMode => _themeMode;
  bool get soundEnabled => _soundEnabled;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    notifyListeners();
    _saveSoundSetting(enabled);
  }

  Future<void> _loadSoundSetting() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getBool(_soundEnabledKey);
      if (stored != null) {
        _soundEnabled = stored;
        notifyListeners();
      }
    } catch (_) {
      // No platform plugin available (e.g. some test environments) -
      // just keep the default.
    }
  }

  Future<void> _saveSoundSetting(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_soundEnabledKey, enabled);
    } catch (_) {
      // Best effort - the toggle still works for the rest of this session.
    }
  }
}
