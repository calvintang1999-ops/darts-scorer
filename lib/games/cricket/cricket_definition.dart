import 'package:flutter/material.dart';

import '../../models/game_definition.dart';
import 'cricket_config.dart';
import 'cricket_config_screen.dart';
import 'cricket_game.dart';

/// Registry entry for Cricket - see lib/games/registry.dart.
final cricketDefinition = GameDefinition(
  id: 'cricket',
  name: 'Cricket',
  description: 'Close out 15-20 and the bull before your opponents.',
  icon: Icons.sports_cricket,
  buildConfigScreen: (context) => const CricketConfigScreen(),
  createGame: (config, players) =>
      CricketGame(players: players, config: config as CricketConfig),
);
