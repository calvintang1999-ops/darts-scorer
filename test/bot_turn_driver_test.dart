import 'package:darts/models/bot_profile.dart';
import 'package:darts/models/darts_game.dart';
import 'package:darts/models/player.dart';
import 'package:darts/models/throw.dart';
import 'package:darts/services/bot/bot_turn_driver.dart';
import 'package:flutter_test/flutter_test.dart';

/// A bare-bones DartsGame test double: `scoreThrow` just records the dart
/// and notifies. Everything else (turn/player advancement, finishing) is
/// driven directly by the test via [currentPlayerIndex]/[finish], the same
/// way a real game's rules would.
class _FakeGame extends DartsGame {
  _FakeGame({required super.players});

  final List<Throw> applied = [];
  bool _finished = false;
  Player? _winner;

  void finish(Player winner) {
    _finished = true;
    _winner = winner;
  }

  @override
  void scoreThrow(Throw dartThrow) {
    applied.add(dartThrow);
    notifyListeners();
  }

  @override
  void undo() {}

  @override
  bool get canUndo => false;

  @override
  bool get isFinished => _finished;

  @override
  Player? get winner => _winner;
}

Throw _dart(Player player, String gameId) => Throw(
      player: player,
      actualSegment: 20,
      multiplier: 1,
      gameId: gameId,
      source: ThrowSource.bot,
    );

void main() {
  late Player botA;
  late Player botB;
  late Player human;
  late _FakeGame game;

  setUp(() {
    botA = Player.bot(BotProfile(
      id: 'bot-a',
      name: 'Bot A',
      sigmaMm: 10,
      targetAverage: 80,
      measuredCheckoutPercent: 40,
      isPreset: true,
    ));
    botB = Player.bot(BotProfile(
      id: 'bot-b',
      name: 'Bot B',
      sigmaMm: 10,
      targetAverage: 80,
      measuredCheckoutPercent: 40,
      isPreset: true,
    ));
    human = Player.create('Human');
    game = _FakeGame(players: [botA, botB, human]);
  });

  test('does nothing when it is not currently a bot\'s turn', () async {
    final driver = BotTurnDriver(
      game: game,
      isCurrentPlayerBot: () => false,
      buildNextThrow: () => throw StateError('should not be called'),
    );

    await driver.playPendingBotTurns();

    expect(game.applied, isEmpty);
    expect(driver.isRunning, false);
  });

  test('plays through consecutive bot turns in one call, stopping at a human',
      () async {
    // Script: bot A throws 3 darts (turn ends, moves to bot B), bot B
    // throws 1 dart then hands off to the human. isCurrentPlayerBot
    // reflects "currentPlayerIndex" the same way a real play screen would
    // derive it from game.currentPlayer.botProfileId.
    game.currentPlayerIndex = 0; // botA
    var dartsThrownByA = 0;
    var dartsThrownByB = 0;

    final driver = BotTurnDriver(
      game: game,
      isCurrentPlayerBot: () => game.currentPlayerIndex != 2, // not human
      buildNextThrow: () {
        if (game.currentPlayerIndex == 0) {
          dartsThrownByA++;
          if (dartsThrownByA == 3) game.currentPlayerIndex = 1;
          return _dart(botA, game.gameId);
        } else {
          dartsThrownByB++;
          if (dartsThrownByB == 1) game.currentPlayerIndex = 2; // to human
          return _dart(botB, game.gameId);
        }
      },
    );

    await driver.playPendingBotTurns();

    expect(game.applied, hasLength(4)); // 3 from A, 1 from B
    expect(game.currentPlayerIndex, 2); // stopped at the human
    expect(driver.isRunning, false);
  });

  test('stops when the game finishes mid-turn', () async {
    game.currentPlayerIndex = 0;
    var count = 0;

    final driver = BotTurnDriver(
      game: game,
      isCurrentPlayerBot: () => true,
      buildNextThrow: () {
        count++;
        if (count == 2) game.finish(botA);
        return _dart(botA, game.gameId);
      },
    );

    await driver.playPendingBotTurns();

    expect(game.applied, hasLength(2));
    expect(game.isFinished, true);
  });

  test('cancel stops the loop before it plays every remaining dart',
      () async {
    game.currentPlayerIndex = 0;
    late BotTurnDriver driver;
    var count = 0;

    driver = BotTurnDriver(
      game: game,
      isCurrentPlayerBot: () => true,
      buildNextThrow: () {
        count++;
        if (count == 1) driver.cancel();
        return _dart(botA, game.gameId);
      },
    );

    await driver.playPendingBotTurns();

    // The dart already in flight when cancel() was called still lands,
    // but the pacing delay afterwards should stop the loop from throwing
    // a second one.
    expect(game.applied, hasLength(1));
  });

  test('a second concurrent call is a no-op while one is already running',
      () async {
    game.currentPlayerIndex = 0;
    var count = 0;

    final driver = BotTurnDriver(
      game: game,
      isCurrentPlayerBot: () => count < 2,
      buildNextThrow: () {
        count++;
        return _dart(botA, game.gameId);
      },
    );

    final first = driver.playPendingBotTurns();
    final second = driver.playPendingBotTurns(); // should return immediately
    await Future.wait([first, second]);

    expect(game.applied, hasLength(2));
  });
}
