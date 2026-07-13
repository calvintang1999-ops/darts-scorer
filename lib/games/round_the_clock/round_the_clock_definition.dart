import 'package:flutter/material.dart';

import '../../models/game_definition.dart';
import 'round_the_clock_config.dart';
import 'round_the_clock_config_screen.dart';
import 'round_the_clock_game.dart';

/// Registry entry for Round the Clock - see lib/games/registry.dart.
final roundTheClockDefinition = GameDefinition(
  id: 'round_the_clock',
  name: 'Round the Clock',
  description: 'Hit 1 through 20 in order, then the bull.',
  icon: Icons.schedule,
  buildConfigScreen: (context) => const RoundTheClockConfigScreen(),
  createGame: (config, players) => RoundTheClockGame(
      players: players, config: config as RoundTheClockConfig),
);
