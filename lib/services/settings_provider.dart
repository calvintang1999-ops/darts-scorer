import 'package:flutter/material.dart';

/// App-wide user settings. Only theme mode actually does anything yet;
/// the sound toggle is a placeholder for the voice announcer phase.
class SettingsProvider extends ChangeNotifier {
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
  }
}
