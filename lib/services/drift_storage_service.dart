import 'dart:convert';

import 'package:drift/drift.dart' show OrderingTerm, Value;
import 'package:meta/meta.dart';

import '../models/dart_position.dart';
import '../models/match_record.dart';
import '../models/player.dart';
import '../models/throw.dart';
import 'database/app_database.dart';
import 'storage_service.dart';

/// The real on-device implementation of [StorageService], backed by SQLite
/// via drift. Every method here just translates between our domain classes
/// (Player, MatchRecord, Turn, Throw) and drift's generated table rows -
/// no game or screen code needs to know this class exists.
class DriftStorageService implements StorageService {
  DriftStorageService() : _db = AppDatabase();

  /// Lets tests pass in an [AppDatabase] backed by an in-memory database
  /// (see [AppDatabase.forTesting]) instead of a real file on disk.
  @visibleForTesting
  DriftStorageService.forTesting(AppDatabase db) : _db = db;

  final AppDatabase _db;

  @override
  Future<void> savePlayers(List<Player> players) async {
    await _db.transaction(() async {
      // The caller always sends the full roster, so anyone missing from it
      // was deleted and should be removed here too.
      if (players.isEmpty) {
        await _db.delete(_db.players).go();
      } else {
        final keepIds = players.map((p) => p.id).toList();
        await (_db.delete(_db.players)..where((t) => t.id.isNotIn(keepIds)))
            .go();
      }
      for (final player in players) {
        await _db.into(_db.players).insertOnConflictUpdate(
              PlayersCompanion.insert(
                id: player.id,
                name: player.name,
                createdAt: player.createdAt,
              ),
            );
      }
    });
  }

  @override
  Future<List<Player>> loadPlayers() async {
    final rows = await _db.select(_db.players).get();
    return rows.map(_playerFromRow).toList();
  }

  @override
  Future<void> saveMatch(MatchRecord match) async {
    await _db.transaction(() async {
      await _db.into(_db.matches).insertOnConflictUpdate(
            MatchesCompanion.insert(
              id: match.gameId,
              gameName: match.gameName,
              winnerId: Value(match.winnerId),
              winnerName: Value(_winnerName(match)),
              finishedAt: match.finishedAt,
              configJson: Value(
                  match.config == null ? null : jsonEncode(match.config)),
            ),
          );

      for (var i = 0; i < match.players.length; i++) {
        final player = match.players[i];
        await _db.into(_db.matchPlayers).insertOnConflictUpdate(
              MatchPlayersCompanion.insert(
                matchId: match.gameId,
                playerId: player.id,
                playerName: player.name,
                orderIndex: i,
              ),
            );
      }

      for (var turnIndex = 0; turnIndex < match.turnHistory.length; turnIndex++) {
        final turn = match.turnHistory[turnIndex];
        final turnId = await _db.into(_db.turns).insert(
              TurnsCompanion.insert(
                matchId: match.gameId,
                playerId: turn.player.id,
                playerName: turn.player.name,
                orderIndex: turnIndex,
                legNumber: Value(turn.legNumber),
                setNumber: Value(turn.setNumber),
              ),
            );

        for (final dartThrow in turn.throws) {
          final landing = dartThrow.landingPosition;
          await _db.into(_db.throws).insert(
                ThrowsCompanion.insert(
                  turnId: turnId,
                  timestamp: dartThrow.timestamp,
                  actualSegment: dartThrow.actualSegment,
                  multiplier: dartThrow.multiplier,
                  resultingScoreDelta: dartThrow.resultingScoreDelta,
                  gameId: dartThrow.gameId,
                  source: dartThrow.source.name,
                  landingRadius: Value(landing?.radiusNormalised),
                  landingAngleDegrees: Value(landing?.angleDegrees),
                  landingCoordVersion:
                      Value(landing?.boardCoordinateSystemVersion),
                  intendedTarget: Value(dartThrow.intendedTarget),
                ),
              );
        }
      }
    });
  }

  @override
  Future<List<MatchRecord>> loadMatchHistory() async {
    // Known players are looked up by id so reconstructed history uses their
    // real profile where possible; a deleted player falls back to the name
    // snapshot stored on the match/turn rows themselves.
    final playerLookup = {for (final p in await loadPlayers()) p.id: p};

    final matchRows = await _db.select(_db.matches).get();
    final records = <MatchRecord>[];
    for (final matchRow in matchRows) {
      final playerRows = await (_db.select(_db.matchPlayers)
            ..where((t) => t.matchId.equals(matchRow.id))
            ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
          .get();
      final players = playerRows
          .map((r) => playerLookup[r.playerId] ??
              _fallbackPlayer(r.playerId, r.playerName, matchRow.finishedAt))
          .toList();

      final turnRows = await (_db.select(_db.turns)
            ..where((t) => t.matchId.equals(matchRow.id))
            ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
          .get();
      final turns = <Turn>[];
      for (final turnRow in turnRows) {
        final turnPlayer = playerLookup[turnRow.playerId] ??
            _fallbackPlayer(
                turnRow.playerId, turnRow.playerName, matchRow.finishedAt);
        final throwRows = await (_db.select(_db.throws)
              ..where((t) => t.turnId.equals(turnRow.id))
              ..orderBy([(t) => OrderingTerm.asc(t.id)]))
            .get();
        turns.add(Turn(
          player: turnPlayer,
          throws: throwRows.map((r) => _throwFromRow(r, turnPlayer)).toList(),
          legNumber: turnRow.legNumber,
          setNumber: turnRow.setNumber,
        ));
      }

      records.add(MatchRecord(
        gameId: matchRow.id,
        gameName: matchRow.gameName,
        players: players,
        turnHistory: turns,
        winnerId: matchRow.winnerId,
        finishedAt: matchRow.finishedAt,
        config: matchRow.configJson == null
            ? null
            : jsonDecode(matchRow.configJson!) as Map<String, Object?>,
      ));
    }
    return records;
  }

  Player _playerFromRow(PlayerRow row) =>
      Player(id: row.id, name: row.name, createdAt: row.createdAt);

  /// Rebuilds a Player for someone who no longer exists in the roster, from
  /// the name snapshot stored alongside the match. createdAt is meaningless
  /// here (the real value wasn't kept), so it falls back to the match date.
  Player _fallbackPlayer(String id, String name, DateTime matchFinishedAt) =>
      Player(id: id, name: name, createdAt: matchFinishedAt);

  Throw _throwFromRow(ThrowRow row, Player player) {
    DartPosition? landingPosition;
    if (row.landingRadius != null &&
        row.landingAngleDegrees != null &&
        row.landingCoordVersion != null) {
      landingPosition = DartPosition(
        radiusNormalised: row.landingRadius!,
        angleDegrees: row.landingAngleDegrees!,
        boardCoordinateSystemVersion: row.landingCoordVersion!,
      );
    }
    return Throw(
      player: player,
      actualSegment: row.actualSegment,
      multiplier: row.multiplier,
      gameId: row.gameId,
      source: ThrowSource.values.byName(row.source),
      resultingScoreDelta: row.resultingScoreDelta,
      landingPosition: landingPosition,
      intendedTarget: row.intendedTarget,
      timestamp: row.timestamp,
    );
  }

  String? _winnerName(MatchRecord match) {
    if (match.winnerId == null) return null;
    for (final player in match.players) {
      if (player.id == match.winnerId) return player.name;
    }
    return null;
  }
}
