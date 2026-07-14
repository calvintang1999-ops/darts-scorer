import 'dart_position.dart';
import 'player.dart';

/// Where a throw's data came from. Recorded on every throw so the future
/// camera phase can be evaluated against human input.
enum ThrowSource {
  /// Entered by hand on the number pad.
  manual,

  /// Detected automatically by the camera (Phase 4).
  camera,

  /// The camera detected one thing but a human corrected it. Logging these
  /// separately gives us training/tuning data for the camera model.
  corrected,
}

/// A single dart. This is the atom of the whole app - every game mode,
/// stat, and future camera feature is built out of Throws.
class Throw {
  Throw({
    required this.player,
    required this.actualSegment,
    required this.multiplier,
    required this.gameId,
    this.source = ThrowSource.manual,
    this.resultingScoreDelta = 0,
    this.landingPosition,
    this.intendedTarget,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  final DateTime timestamp;
  final Player player;

  /// What the dart actually hit: 1-20, [bullSegment] (25), or
  /// [missSegment] (0) for a miss.
  final int actualSegment;

  /// 1 = single, 2 = double (inner bull is 25 x 2), 3 = treble.
  final int multiplier;

  /// The net change this dart made to the player's game state, filled in by
  /// the game's `applyThrow` (the input pad doesn't know the rules, so it
  /// leaves this at 0). For X01 this is the change to the remaining score:
  /// usually negative, and positive on a bust dart because the score jumps
  /// back up to its start-of-turn value.
  final int resultingScoreDelta;

  /// Which match this throw belongs to.
  final String gameId;

  final ThrowSource source;

  /// Where the dart physically landed. Always null for manual entry; the
  /// camera phase will populate it. Scoring NEVER reads this - it is
  /// enrichment data for stats and camera tuning only.
  final DartPosition? landingPosition;

  /// What the player was aiming at, if known (e.g. a checkout suggestion
  /// or training routine told them a target). Null when we can't know.
  final int? intendedTarget;

  /// Face value of the dart (e.g. treble 20 = 60). Rules like bust or
  /// double-in decide whether this actually counts - see resultingScoreDelta.
  int get scoredPoints => actualSegment * multiplier;

  /// A short human-readable label like "T20", "D16", "Bull", or "Miss".
  String get label {
    if (actualSegment == missSegment) return 'Miss';
    if (actualSegment == bullSegment) return multiplier == 2 ? 'Bull' : '25';
    const prefixes = {1: '', 2: 'D', 3: 'T'};
    return '${prefixes[multiplier]}$actualSegment';
  }

  Throw copyWith({int? resultingScoreDelta, int? intendedTarget}) => Throw(
        timestamp: timestamp,
        player: player,
        actualSegment: actualSegment,
        multiplier: multiplier,
        gameId: gameId,
        source: source,
        resultingScoreDelta: resultingScoreDelta ?? this.resultingScoreDelta,
        landingPosition: landingPosition,
        intendedTarget: intendedTarget ?? this.intendedTarget,
      );

  Map<String, Object?> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'playerId': player.id,
        'playerName': player.name,
        'actualSegment': actualSegment,
        'multiplier': multiplier,
        'resultingScoreDelta': resultingScoreDelta,
        'gameId': gameId,
        'source': source.name,
        'landingPosition': landingPosition?.toJson(),
        'intendedTarget': intendedTarget,
      };
}

/// One player's visit to the oche: up to 3 throws.
class Turn {
  Turn({
    required this.player,
    required this.throws,
    this.legNumber = 1,
    this.setNumber = 1,
  });

  final Player player;
  final List<Throw> throws;

  /// Which leg/set this turn belongs to. Only X01 ever has more than one of
  /// each - every other game mode is single-leg, single-set, so it never
  /// passes these and both stay at their default of 1.
  final int legNumber;
  final int setNumber;

  Map<String, Object?> toJson() => {
        'playerId': player.id,
        'playerName': player.name,
        'legNumber': legNumber,
        'setNumber': setNumber,
        'throws': [for (final t in throws) t.toJson()],
      };
}
