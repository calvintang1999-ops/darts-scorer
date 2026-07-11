import 'package:flutter/material.dart';

import '../../models/game_definition.dart';

/// Placeholder registry entry - see cricket_definition.dart for the pattern.
final roundTheClockDefinition = GameDefinition(
  id: 'round_the_clock',
  name: 'Round the Clock',
  description: 'Hit 1 through 20 in order, then the bull.',
  icon: Icons.schedule,
  comingSoon: true,
);
