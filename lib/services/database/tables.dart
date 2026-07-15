import 'package:drift/drift.dart';

/// Known players. Mirrors [Player] in lib/models/player.dart.
///
/// Named PlayerRow (via @DataClassName) because drift would otherwise
/// generate its own `Player` class here, clashing with our domain model's.
/// Same reasoning on Matches/Turns/Throws below.
@DataClassName('PlayerRow')
class Players extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// One finished match. Mirrors [MatchRecord] in lib/models/match_record.dart.
///
/// No enforced foreign key to [Players]: a player can be deleted after
/// playing matches, and match history must keep working when that happens.
/// [winnerName] is a snapshot taken at save time for the same reason.
@DataClassName('MatchRow')
class Matches extends Table {
  TextColumn get id => text()(); // Throw.gameId / DartsGame.gameId
  TextColumn get gameName => text()(); // registry id, e.g. "x01"
  TextColumn get winnerId => text().nullable()();
  TextColumn get winnerName => text().nullable()();
  DateTimeColumn get finishedAt => dateTime()();

  /// A snapshot of the small handful of config values (e.g. X01's
  /// startingScore/outRule, Cricket's lowNumber/includeBull) needed to
  /// correctly interpret this match's throws for stats later - added in
  /// schema version 3. Stored as a JSON object, not parsed columns, since
  /// each game needs different fields. This is provenance data (like
  /// gameName), not a computed aggregate - nothing here is ever a stat
  /// itself. Null for matches saved before this column existed; stats
  /// calculators fall back to that game's own config defaults then.
  TextColumn get configJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// The full roster a match started with, in throwing order. Kept separate
/// from [Turns] because a player can be in a match without ever getting a
/// turn (e.g. the match was abandoned immediately).
@DataClassName('MatchPlayerRow')
class MatchPlayers extends Table {
  TextColumn get matchId => text()();
  TextColumn get playerId => text()();
  TextColumn get playerName => text()(); // snapshot, see Matches doc comment
  IntColumn get orderIndex => integer()();

  /// Set when this participant was a bot rather than a human, pointing at
  /// the BotProfile it was played with - added in schema version 4. Null
  /// for every human participant. playerId/playerName still hold the bot's
  /// id/name the same as a human's, so existing lookups keep working
  /// unchanged; this column only adds the ability to tell bots apart from
  /// humans and find which profile a bot match was played against.
  TextColumn get botProfileId => text().nullable()();

  @override
  Set<Column> get primaryKey => {matchId, orderIndex};
}

/// One player's visit to the oche. Mirrors [Turn] in lib/models/throw.dart.
@DataClassName('TurnRow')
class Turns extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get matchId => text()();
  TextColumn get playerId => text()();
  TextColumn get playerName => text()(); // snapshot, see Matches doc comment
  IntColumn get orderIndex => integer()(); // order within the match

  /// Which leg/set this turn belongs to. Only X01 ever uses more than 1 -
  /// every other game is single-leg, single-set.
  IntColumn get legNumber => integer().withDefault(const Constant(1))();
  IntColumn get setNumber => integer().withDefault(const Constant(1))();
}

/// A single dart. Mirrors [Throw] in lib/models/throw.dart - this table is
/// the source of truth; nothing computed (scores, averages, win counts) is
/// ever stored here or anywhere else.
@DataClassName('ThrowRow')
class Throws extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get turnId => integer()();
  DateTimeColumn get timestamp => dateTime()();
  IntColumn get actualSegment => integer()();
  IntColumn get multiplier => integer()();
  IntColumn get resultingScoreDelta => integer()();
  TextColumn get gameId => text()();

  /// Stored as the enum's name (e.g. "manual"), not its index - so
  /// reordering the ThrowSource enum later can never silently misread old
  /// rows. Same reasoning as DartPosition.boardCoordinateSystemVersion.
  TextColumn get source => text()();

  /// Flattened DartPosition (landingPosition on Throw). Always null for
  /// manual entry. Kept as plain columns rather than a JSON blob.
  RealColumn get landingRadius => real().nullable()();
  RealColumn get landingAngleDegrees => real().nullable()();
  IntColumn get landingCoordVersion => integer().nullable()();

  /// Mirrors Throw.intendedTarget - added in schema version 2. Null
  /// everywhere except Round the Clock, which fills it in with the
  /// player's target at the moment they threw.
  IntColumn get intendedTarget => integer().nullable()();
}

/// A saved bot character (see lib/models/bot_profile.dart), added in schema
/// version 4. The 8 presets are seeded once, on first run of this version -
/// see AppDatabase._seedBotProfiles - and are never deleted; custom
/// profiles (future career mode) are ordinary rows with isPreset = false.
@DataClassName('BotProfileRow')
class BotProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get sigmaMm => real()();
  RealColumn get targetAverage => real()();
  RealColumn get measuredCheckoutPercent => real()();
  BoolColumn get isPreset => boolean()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
