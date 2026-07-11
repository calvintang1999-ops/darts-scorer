import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/settings_provider.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';

/// App settings. Theme mode is fully wired; sound is a placeholder for
/// the voice-announcer phase.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(SpacingTokens.md),
        children: [
          Text('THEME', style: AppTypography.label),
          const SizedBox(height: SpacingTokens.sm),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('System'),
                  icon: Icon(Icons.brightness_auto)),
              ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode)),
              ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode)),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (selection) =>
                settings.setThemeMode(selection.first),
          ),
          const SizedBox(height: SpacingTokens.lg),
          SwitchListTile(
            title: Text('Sound effects', style: AppTypography.body),
            subtitle: Text('Coming with the voice announcer',
                style: AppTypography.label),
            value: settings.soundEnabled,
            onChanged: settings.setSoundEnabled,
          ),
        ],
      ),
    );
  }
}
