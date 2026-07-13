import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../models/player.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// The on-device SQLite database. Opened lazily (see [_openConnection]) so
/// just constructing this class - e.g. at app startup - never blocks on
/// disk or platform-channel work; the file is only touched the first time
/// a query actually runs.
@DriftDatabase(tables: [Players, Matches, MatchPlayers, Turns, Throws])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Bump this and add a step to [migration] whenever a table changes
  /// shape. See the class doc on [migration] for how that works.
  @override
  int get schemaVersion => 1;

  /// Drift calls exactly one of these the first time the app runs against
  /// a given database file:
  /// - [MigrationStrategy.onCreate] fires on a brand new file. It always
  ///   builds today's schema directly - it never replays old migrations.
  /// - [MigrationStrategy.onUpgrade] fires on a device that already has an
  ///   older database file, and steps it forward version by version.
  ///
  /// Right now there's only ever been one schema (version 1), so there is
  /// nothing to upgrade from yet - `onUpgrade` will gain steps as the
  /// schema evolves.
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedDefaultPlayer();
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
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'darts.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
