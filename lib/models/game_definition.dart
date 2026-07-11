import 'package:flutter/widgets.dart';

import 'darts_game.dart';
import 'game_config.dart';
import 'player.dart';

/// Everything the shell needs to know about a game mode, in one object.
///
/// The home screen renders whatever is in the registry, so adding a new
/// game means: create a folder under lib/games/, build a GameDefinition,
/// and add one line to lib/games/registry.dart. Nothing else changes.
class GameDefinition {
  const GameDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.comingSoon = false,
    this.buildConfigScreen,
    this.createGame,
  });

  final String id;
  final String name;
  final String description;
  final IconData icon;

  /// Stub games show a "coming soon" badge and can't be started.
  final bool comingSoon;

  /// Builds the screen where the player picks options and starts the game.
  /// Null for coming-soon stubs.
  final Widget Function(BuildContext context)? buildConfigScreen;

  /// Creates a fresh game instance from a config + players. The config
  /// screen normally calls this itself, but exposing it here lets future
  /// features (e.g. "rematch" or scheduled training) start games generically.
  final DartsGame Function(GameConfig config, List<Player> players)?
      createGame;
}
