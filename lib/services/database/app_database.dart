import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../models/player.dart';
import '../../models/unique_id.dart';
import '../bot/bot_calibration_constants.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// The on-device SQLite database. Opened lazily (see [_openConnection]) so
/// just constructing this class - e.g. at app startup - never blocks on
/// disk or platform-channel work; the file is only touched the first time
/// a query actually runs.
@DriftDatabase(
    tables: [Players, Matches, MatchPlayers, Turns, Throws, BotProfiles])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Lets tests point this at an in-memory database (see
  /// `NativeDatabase.memory()`) instead of a real file on disk.
  @visibleForTesting
  AppDatabase.forTesting(super.executor);

  /// Bump this and add a step to [migration] whenever a table changes
  /// shape. See the class doc on [migration] for how that works.
  ///
  /// Version 2 added Throws.intendedTarget. Version 3 added
  /// Matches.configJson. Version 4 added the BotProfiles table and
  /// MatchPlayers.botProfileId (Phase 3, the bot opponent).
  @override
  int get schemaVersion => 4;

  /// Drift calls exactly one of these the first time the app runs against
  /// a given database file:
  /// - [MigrationStrategy.onCreate] fires on a brand new file. It always
  ///   builds today's schema directly - it never replays old migrations.
  /// - [MigrationStrategy.onUpgrade] fires on a device that already has an
  ///   older database file, and steps it forward version by version. `from`
  ///   is the version that file was last opened with; `to` is
  ///   [schemaVersion]. Each `if` below is one step in that staircase, so a
  ///   database several versions behind runs every step in order.
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedDefaultPlayer();
          await _seedBotProfiles();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(throws, throws.intendedTarget);
          }
          if (from < 3) {
            await m.addColumn(matches, matches.configJson);
          }
          if (from < 4) {
            await m.createTable(botProfiles);
            await m.addColumn(matchPlayers, matchPlayers.botProfileId);
            await _seedBotProfiles();
          }
        },
      );

  /// One default player so a fresh install can quick-start without any
  /// setup. Deleting it (like any other player) is permanent - this only
  /// ever runs once, when the database file is first created.
  Future<void> _seedDefaultPlayer() async {
    final calvin = Player.create('Calvin');
    await into(players).insert(PlayersCompanion.insert(
      id: calvin.id,
      name: calvin.name,
      createdAt: calvin.createdAt,
    ));
  }

  /// Seeds the 8 preset bots ("Bot 35" .. "World Class (105)") - runs once,
  /// either when the database is first created or when an existing
  /// database upgrades into version 4. Presets are never deleted, so this
  /// never needs to run again after that.
  Future<void> _seedBotProfiles() async {
    final now = DateTime.now();
    for (final preset in botCalibrationPresets) {
      await into(botProfiles).insert(BotProfilesCompanion.insert(
        id: generateLocalId(),
        name: preset.name,
        sigmaMm: preset.sigmaMm,
        targetAverage: preset.targetAverage,
        measuredCheckoutPercent: preset.measuredCheckoutPercent,
        isPreset: true,
        createdAt: now,
      ));
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'darts.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
