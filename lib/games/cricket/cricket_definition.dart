import 'package:flutter/material.dart';

import '../../models/game_definition.dart';

/// Placeholder registry entry. When Cricket is built, its game class,
/// config, and screens will live in this folder and this definition gets
/// `buildConfigScreen` / `createGame` wired up - nothing else changes.
final cricketDefinition = GameDefinition(
  id: 'cricket',
  name: 'Cricket',
  description: 'Close out 15-20 and the bull before your opponents.',
  icon: Icons.sports_cricket,
  comingSoon: true,
);
