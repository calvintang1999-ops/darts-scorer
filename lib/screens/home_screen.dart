import 'package:flutter/material.dart';

import '../games/registry.dart';
import '../models/game_definition.dart';
import '../theme/tokens.dart';
import '../widgets/game_card.dart';
import 'player_select_screen.dart';
import 'settings_screen.dart';

/// The landing screen: the list of games, rendered straight from the
/// registry. It has no knowledge of any specific game.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openGame(BuildContext context, GameDefinition definition) {
    if (definition.comingSoon || definition.buildConfigScreen == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${definition.name} is coming soon!')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: definition.buildConfigScreen!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Darts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: 'Players',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PlayerSelectScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(SpacingTokens.md),
        children: [
          for (final definition in gameRegistry)
            GameCard(
              definition: definition,
              onTap: () => _openGame(context, definition),
            ),
        ],
      ),
    );
  }
}
