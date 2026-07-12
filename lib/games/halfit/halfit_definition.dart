import 'package:flutter/material.dart';

import '../../models/game_definition.dart';
import 'halfit_config.dart';
import 'halfit_config_screen.dart';
import 'halfit_game.dart';

/// Registry entry for Half It - see lib/games/registry.dart.
final halfItDefinition = GameDefinition(
  id: 'halfit',
  name: 'Half It',
  description: 'Hit each round\'s target or watch your score get halved.',
  icon: Icons.exposure,
  buildConfigScreen: (context) => const HalfItConfigScreen(),
  createGame: (config, players) =>
      HalfItGame(players: players, config: config as HalfItConfig),
);
