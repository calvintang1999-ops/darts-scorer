import 'package:flutter/material.dart';

import '../../models/game_definition.dart';
import 'cricket_config.dart';
import 'cricket_game.dart';

/// Registry entry for Cricket. The rules are fully implemented (see
/// cricket_game.dart), but there's no config/play screen yet, so it still
/// shows as "coming soon" on the home screen until that UI is built.
final cricketDefinition = GameDefinition(
  id: 'cricket',
  name: 'Cricket',
  description: 'Close out 15-20 and the bull before your opponents.',
  icon: Icons.sports_cricket,
  comingSoon: true,
  createGame: (config, players) =>
      CricketGame(players: players, config: config as CricketConfig),
);
