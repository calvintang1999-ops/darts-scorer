import '../models/game_definition.dart';
import 'cricket/cricket_definition.dart';
import 'round_the_clock/round_the_clock_definition.dart';
import 'split_score/split_score_definition.dart';
import 'x01/x01_definition.dart';

/// The single list of every game the app knows about. The home screen
/// renders this directly, so adding a game = one new folder under
/// lib/games/ + one line here.
final List<GameDefinition> gameRegistry = [
  x01Definition,
  cricketDefinition,
  splitScoreDefinition,
  roundTheClockDefinition,
];
