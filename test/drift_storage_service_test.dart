import 'package:darts/models/dart_position.dart';
import 'package:darts/models/match_record.dart';
import 'package:darts/models/player.dart';
import 'package:darts/models/throw.dart';
import 'package:darts/services/database/app_database.dart';
import 'package:darts/services/drift_storage_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DriftStorageService storage;

  // A fresh in-memory database per test, so nothing on disk and no shared
  // state between tests - same idea as InMemoryStorageService, but this
  // exercises the real SQL schema, migrations, and drift queries.
  setUp(() {
    storage = DriftStorageService.forTesting(
      AppDatabase.forTesting(NativeDatabase.memory()),
    );
  });

  test('seeds one default player named Calvin on first use', () async {
    final players = await storage.loadPlayers();
    expect(players, hasLength(1));
    expect(players.single.name, 'Calvin');
  });

  test('savePlayers replaces the whole roster, including deletions',
      () async {
    final alice = Player.create('Alice');
    final bob = Player.create('Bob');
    await storage.savePlayers([alice, bob]);

    var loaded = await storage.loadPlayers();
    expect(loaded.map((p) => p.name), containsAll(['Alice', 'Bob']));
    expect(loaded.map((p) => p.name), isNot(contains('Calvin')));

    await storage.savePlayers([alice]);
    loaded = await storage.loadPlayers();
    expect(loaded.map((p) => p.name), ['Alice']);
  });

  test(
      'saveMatch/loadMatchHistory round-trips legs, throws, and '
      'intendedTarget', () async {
    final alice = Player.create('Alice');
    final bob = Player.create('Bob');

    final leg1Turn = Turn(
      player: alice,
      legNumber: 1,
      setNumber: 1,
      throws: [
        Throw(
          player: alice,
          actualSegment: 20,
          multiplier: 3,
          gameId: 'match-1',
          resultingScoreDelta: -60,
          landingPosition:
              const DartPosition(radiusNormalised: 0.6, angleDegrees: 10),
        ),
      ],
    );
    final leg2Turn = Turn(
      player: bob,
      legNumber: 2,
      setNumber: 1,
      throws: [
        Throw(
          player: bob,
          actualSegment: 7,
          multiplier: 1,
          gameId: 'match-1',
          resultingScoreDelta: 1,
          intendedTarget: 7,
        ),
      ],
    );

    final match = MatchRecord(
      gameId: 'match-1',
      gameName: 'round_the_clock',
      players: [alice, bob],
      turnHistory: [leg1Turn, leg2Turn],
      winnerId: bob.id,
      config: const {'startingTarget': 1, 'sequence': 'plusBothBulls'},
    );

    await storage.saveMatch(match);
    final history = await storage.loadMatchHistory();

    expect(history, hasLength(1));
    final loaded = history.single;
    expect(loaded.gameId, 'match-1');
    expect(loaded.gameName, 'round_the_clock');
    expect(loaded.winnerId, bob.id);
    expect(loaded.players.map((p) => p.name), ['Alice', 'Bob']);

    expect(loaded.turnHistory, hasLength(2));
    expect(loaded.turnHistory[0].legNumber, 1);
    expect(loaded.turnHistory[0].setNumber, 1);
    expect(loaded.turnHistory[1].legNumber, 2);

    final firstThrow = loaded.turnHistory[0].throws.single;
    expect(firstThrow.actualSegment, 20);
    expect(firstThrow.multiplier, 3);
    expect(firstThrow.resultingScoreDelta, -60);
    expect(firstThrow.intendedTarget, isNull);
    expect(firstThrow.landingPosition!.radiusNormalised, closeTo(0.6, 1e-9));
    expect(firstThrow.landingPosition!.angleDegrees, closeTo(10, 1e-9));
    expect(firstThrow.landingPosition!.boardCoordinateSystemVersion,
        DartPosition.currentCoordinateSystemVersion);

    final secondThrow = loaded.turnHistory[1].throws.single;
    expect(secondThrow.intendedTarget, 7);
    expect(secondThrow.landingPosition, isNull);

    expect(loaded.config, {'startingTarget': 1, 'sequence': 'plusBothBulls'});
  });

  test('a match saved without a config snapshot loads with config null',
      () async {
    final alice = Player.create('Alice');
    final match = MatchRecord(
      gameId: 'match-3',
      gameName: 'cricket',
      players: [alice],
      turnHistory: const [],
      winnerId: null,
    );
    await storage.saveMatch(match);

    final loaded =
        (await storage.loadMatchHistory()).singleWhere((m) => m.gameId == 'match-3');
    expect(loaded.config, isNull);
  });

  test('a deleted player does not break their saved match history',
      () async {
    final alice = Player.create('Alice');
    await storage.savePlayers([alice]);

    final match = MatchRecord(
      gameId: 'match-2',
      gameName: 'x01',
      players: [alice],
      turnHistory: [
        Turn(player: alice, throws: [
          Throw(
            player: alice,
            actualSegment: 19,
            multiplier: 1,
            gameId: 'match-2',
          ),
        ]),
      ],
      winnerId: alice.id,
    );
    await storage.saveMatch(match);

    // Alice is deleted from the roster entirely...
    await storage.savePlayers([]);

    // ...but her match is still readable, with her name preserved.
    final history = await storage.loadMatchHistory();
    final loaded = history.singleWhere((m) => m.gameId == 'match-2');
    expect(loaded.players.single.name, 'Alice');
    expect(loaded.turnHistory.single.player.name, 'Alice');
  });

  group('bot profiles', () {
    test('seeds the 8 presets on first use, all marked isPreset', () async {
      final profiles = await storage.loadBotProfiles();
      expect(profiles, hasLength(8));
      expect(profiles.every((p) => p.isPreset), true);
      expect(profiles.map((p) => p.name), contains('Bot 35'));
      expect(profiles.map((p) => p.name), contains('World Class (105)'));
    });

    test('a bot match participant round-trips with its botProfileId',
        () async {
      final profile = (await storage.loadBotProfiles()).first;
      final human = Player.create('Alice');
      final bot = Player(
        id: 'bot-instance-1',
        name: profile.name,
        botProfileId: profile.id,
      );

      final match = MatchRecord(
        gameId: 'match-bot-1',
        gameName: 'x01',
        players: [human, bot],
        turnHistory: [
          Turn(player: bot, throws: [
            Throw(
              player: bot,
              actualSegment: 20,
              multiplier: 3,
              gameId: 'match-bot-1',
              source: ThrowSource.bot,
              intendedTarget: 20,
            ),
          ]),
        ],
        winnerId: bot.id,
      );
      await storage.saveMatch(match);

      final loaded = (await storage.loadMatchHistory())
          .singleWhere((m) => m.gameId == 'match-bot-1');
      final loadedBot = loaded.players.singleWhere((p) => p.id == bot.id);
      final loadedHuman = loaded.players.singleWhere((p) => p.id == human.id);

      expect(loadedBot.botProfileId, profile.id);
      expect(loadedHuman.botProfileId, isNull);
    });
  });
}
