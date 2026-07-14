import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../services/settings_provider.dart';
import '../services/storage_service.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/app_button.dart';

/// App settings. Theme mode is fully wired; sound is a placeholder for
/// the voice-announcer phase.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  /// Gathers every player and match (via the same StorageService methods
  /// everything else uses - no separate export code path), writes them to
  /// a JSON file, and hands it to the OS share sheet so the user picks
  /// where it goes (Drive, email, Files, ...).
  Future<void> _backup(BuildContext context) async {
    final storage = context.read<StorageService>();
    final players = await storage.loadPlayers();
    final matches = await storage.loadMatchHistory();

    final data = {
      'exportedAt': DateTime.now().toIso8601String(),
      'players': [for (final player in players) player.toJson()],
      'matches': [for (final match in matches) match.toJson()],
    };
    final json = const JsonEncoder.withIndent('  ').convert(data);

    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, 'darts_backup.json'));
    await file.writeAsString(json);

    if (!context.mounted) return;
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], subject: 'Darts backup'),
    );
  }

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
          const SizedBox(height: SpacingTokens.lg),
          Text('BACKUP', style: AppTypography.label),
          const SizedBox(height: SpacingTokens.sm),
          Text(
            'Share every player and match as a JSON file - handy before '
            'reinstalling the app or switching phones.',
            style: AppTypography.body,
          ),
          const SizedBox(height: SpacingTokens.sm),
          AppButton(
            label: 'Back up data',
            icon: Icons.ios_share,
            filled: false,
            onPressed: () => _backup(context),
          ),
        ],
      ),
    );
  }
}
