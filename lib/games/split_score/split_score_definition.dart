import 'package:flutter/material.dart';

import '../../models/game_definition.dart';

/// Placeholder registry entry - see cricket_definition.dart for the pattern.
final splitScoreDefinition = GameDefinition(
  id: 'split_score',
  name: 'Split Score',
  description: 'Hit the target each round or your score is halved.',
  icon: Icons.call_split,
  comingSoon: true,
);
