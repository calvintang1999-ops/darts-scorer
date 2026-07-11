import 'package:flutter/material.dart';

import '../../models/game_definition.dart';
import 'x01_config.dart';
import 'x01_config_screen.dart';
import 'x01_game.dart';

/// Registry entry for X01 - see lib/games/registry.dart.
final x01Definition = GameDefinition(
  id: 'x01',
  name: 'X01',
  description: 'Classic 301 / 501 / 701. Race from your starting score '
      'to exactly zero.',
  icon: Icons.adjust,
  buildConfigScreen: (context) => const X01ConfigScreen(),
  createGame: (config, players) =>
      X01Game(players: players, config: config as X01Config),
);
