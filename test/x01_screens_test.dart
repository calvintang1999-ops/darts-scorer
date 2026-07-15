import 'package:darts/games/x01/x01_config.dart';
import 'package:darts/games/x01/x01_game.dart';
import 'package:darts/games/x01/x01_play_screen.dart';
import 'package:darts/main.dart';
import 'package:darts/models/player.dart';
import 'package:darts/services/announcer_service.dart';
import 'package:darts/services/bot_profiles_provider.dart';
import 'package:darts/models/throw.dart';
import 'package:darts/services/dart_counter_service.dart';
import 'package:darts/services/settings_provider.dart';
import 'package:darts/services/storage_service.dart';
import 'package:darts/theme/tokens.dart';
import 'package:darts/widgets/match_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  Future<void> startGame(WidgetTester tester) async {
    await tester.pumpWidget(DartsApp(storage: InMemoryStorageService()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('X01'));
    await tester.pumpAndSettle();
    expect(find.text('X01 setup'), findsOneWidget);

    // X01's form has more sections than Cricket's, plus the bot picker
    // section, so the Start button starts out below the ListView's
    // mounted+cache area - scroll to it.
    await tester.dragUntilVisible(
      find.text('Start game'),
      find.byType(ListView),
      const Offset(0, -200),
    );
    await tester.tap(find.text('Start game'));
    await tester.pumpAndSettle();
  }

  testWidgets('leaving a fresh game skips the quit confirmation',
      (tester) async {
    await startGame(tester);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    // No progress yet, so back navigates straight to Home with no dialog.
    expect(find.text('Quit game?'), findsNothing);
    expect(find.text('X01 setup'), findsNothing);
    expect(find.byType(AppBar), findsOneWidget); // Home's app bar
  });

  testWidgets(
      'leaving a game in progress asks for confirmation before quitting',
      (tester) async {
    await startGame(tester);

    // The pad's number keys are FilledButton.tonal widgets - the
    // scoreboard also shows numbers (the remaining score), so tapping
    // must target the pad button specifically.
    await tester.tap(find.widgetWithText(FilledButton, '20'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Quit game?'), findsOneWidget);
    expect(find.text('Your progress will be lost.'), findsOneWidget);

    // Cancel: dialog closes, still on the play screen.
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Quit game?'), findsNothing);
    expect(find.textContaining('to throw'), findsOneWidget);

    // Try again and actually quit this time.
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quit'));
    await tester.pumpAndSettle();
    expect(find.textContaining('to throw'), findsNothing);
  });

  testWidgets('play screen renders without overflow in landscape',
      (tester) async {
    await startGame(tester);

    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(800, 400));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('play screen renders without overflow in portrait',
      (tester) async {
    await startGame(tester);

    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(400, 800));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // A shorter portrait phone - the scoreboard + status bar + pad
    // easily exceed 600px of usable height, so this is the real stress
    // case (it caught a pre-existing overflow: the pad's fixed-size tap
    // targets didn't fit under a bare Spacer).
    await tester.binding.setSurfaceSize(const Size(400, 600));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('winner panel shows a per-player match summary without overflow',
      (tester) async {
    // Bypassing Home/config screens: a starting score of 2 with single-out
    // means the very first dart wins, which is the fastest way to reach
    // the winner panel. The provider set mirrors DartsApp's, since
    // X01PlayScreen reads AnnouncerService/DartCounterService/
    // BotProfilesProvider in initState.
    await tester.pumpWidget(MaterialApp(
      home: MultiProvider(
        providers: [
          Provider<StorageService>.value(value: InMemoryStorageService()),
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          Provider<AnnouncerService>(
            create: (ctx) => AnnouncerService(ctx.read<SettingsProvider>()),
            dispose: (_, service) => service.dispose(),
          ),
          ChangeNotifierProvider(create: (_) => DartCounterService()),
          ChangeNotifierProvider(
              create: (ctx) =>
                  BotProfilesProvider(ctx.read<StorageService>())),
        ],
        child: X01PlayScreen(
          game: X01Game(
            players: [Player.create('Alice'), Player.create('Bob')],
            config:
                const X01Config(startingScore: 2, outRule: X01OutRule.single),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, '2'));
    await tester.pumpAndSettle();

    expect(find.text('Alice wins!'), findsOneWidget);
    // One stat-tile block per player - the scoreboard above also shows
    // each name once, so this checks the summary specifically rather
    // than counting name occurrences.
    expect(
      find.descendant(
          of: find.byType(MatchSummaryCard), matching: find.text('ALICE')),
      findsOneWidget,
    );
    expect(
      find.descendant(
          of: find.byType(MatchSummaryCard), matching: find.text('BOB')),
      findsOneWidget,
    );
    expect(find.text('3-DART AVG'), findsNWidgets(2));
    expect(tester.takeException(), isNull);

    // A short phone screen is the real stress case for the extra content
    // the summary card adds below the winner text.
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(400, 600));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'a bot plays its whole turn automatically, then hands off to the human',
      (tester) async {
    final storage = InMemoryStorageService();
    final profiles = await storage.loadBotProfiles();
    final bot = Player.bot(
        profiles.firstWhere((p) => p.name == 'The Governor'));
    final human = Player.create('Human');

    // Same provider set as the "winner panel" test above - X01PlayScreen
    // reads all of these in initState.
    await tester.pumpWidget(MaterialApp(
      home: MultiProvider(
        providers: [
          Provider<StorageService>.value(value: storage),
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          Provider<AnnouncerService>(
            create: (ctx) => AnnouncerService(ctx.read<SettingsProvider>()),
            dispose: (_, service) => service.dispose(),
          ),
          ChangeNotifierProvider(create: (_) => DartCounterService()),
          // Seeded synchronously (not the async-loading constructor) so
          // the profile is already there for the first frame's bot-turn
          // kickoff - in real use the config screen's own load always
          // finishes before a bot can be picked in the first place.
          ChangeNotifierProvider(
              create: (_) => BotProfilesProvider.withProfiles(profiles)),
        ],
        child: X01PlayScreen(
          game: X01Game(players: [bot, human], config: const X01Config()),
        ),
      ),
    ));
    // Lets the post-frame kickoff fire, then pumps through the pacing
    // delay between each bot dart.
    await tester.pumpAndSettle();
    for (var i = 0; i < 4; i++) {
      await tester.pump(DurationTokens.botThrowPacing);
    }
    await tester.pumpAndSettle();

    final game =
        tester.widget<X01PlayScreen>(find.byType(X01PlayScreen)).game;
    expect(game.turnHistory, hasLength(1));
    expect(game.turnHistory.single.throws, hasLength(3));
    expect(
        game.turnHistory.single.throws
            .every((t) => t.source == ThrowSource.bot),
        true);
    expect(
        game.turnHistory.single.throws
            .every((t) => t.intendedTarget != null),
        true);
    expect(game.currentPlayerIndex, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'in a 3-player mixed match, a bot turn hands off to the correct '
      'next human, not back to the first', (tester) async {
    final storage = InMemoryStorageService();
    final profiles = await storage.loadBotProfiles();
    final bot = Player.bot(
        profiles.firstWhere((p) => p.name == 'The Governor'));
    final human1 = Player.create('Human One');
    final human2 = Player.create('Human Two');

    await tester.pumpWidget(MaterialApp(
      home: MultiProvider(
        providers: [
          Provider<StorageService>.value(value: storage),
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          Provider<AnnouncerService>(
            create: (ctx) => AnnouncerService(ctx.read<SettingsProvider>()),
            dispose: (_, service) => service.dispose(),
          ),
          ChangeNotifierProvider(create: (_) => DartCounterService()),
          ChangeNotifierProvider(
              create: (_) => BotProfilesProvider.withProfiles(profiles)),
        ],
        child: X01PlayScreen(
          // Bot sits between two humans - the required "any player order"
          // case, not just "bot first" or "bot last".
          game: X01Game(
            players: [human1, bot, human2],
            config: const X01Config(),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // Human One's full turn - no bot kickoff should fire while it's a
    // human's turn.
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.widgetWithText(FilledButton, 'MISS'));
      await tester.pumpAndSettle();
    }

    // The bot's turn now kicks off automatically - pump through its
    // pacing delay between darts.
    for (var i = 0; i < 4; i++) {
      await tester.pump(DurationTokens.botThrowPacing);
    }
    await tester.pumpAndSettle();

    final game =
        tester.widget<X01PlayScreen>(find.byType(X01PlayScreen)).game;
    expect(game.turnHistory, hasLength(2));
    expect(game.turnHistory[0].player.id, human1.id);
    expect(game.turnHistory[1].player.id, bot.id);
    expect(
        game.turnHistory[1].throws
            .every((t) => t.source == ThrowSource.bot),
        true);
    // Handed off to the second human, not back to the first.
    expect(game.currentPlayerIndex, 2);
    expect(game.currentPlayer.id, human2.id);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'quitting mid-bot-turn (while a dart is still pending) does not throw',
      (tester) async {
    final storage = InMemoryStorageService();
    final profiles = await storage.loadBotProfiles();
    final bot = Player.bot(
        profiles.firstWhere((p) => p.name == 'The Governor'));
    final human = Player.create('Human');

    await tester.pumpWidget(MaterialApp(
      home: MultiProvider(
        providers: [
          Provider<StorageService>.value(value: storage),
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          Provider<AnnouncerService>(
            create: (ctx) => AnnouncerService(ctx.read<SettingsProvider>()),
            dispose: (_, service) => service.dispose(),
          ),
          ChangeNotifierProvider(create: (_) => DartCounterService()),
          ChangeNotifierProvider(
              create: (_) => BotProfilesProvider.withProfiles(profiles)),
        ],
        child: X01PlayScreen(
          game: X01Game(players: [bot, human], config: const X01Config()),
        ),
      ),
    ));
    // Settles the first dart, then leaves the driver awaiting its pacing
    // delay before the second one - the realistic "user hits Back while
    // the bot is mid-turn" moment.
    await tester.pumpAndSettle();

    // Tear the play screen down (and its BotTurnScreenController with it)
    // while that delay is still pending.
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    expect(tester.takeException(), isNull);

    // Let the pending delay actually elapse - if cancel() hadn't stopped
    // the loop, this is where a post-dispose applyThrow would surface.
    await tester.pump(DurationTokens.botThrowPacing);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'picking a bot on the config screen produces a bot participant in '
      'the started game', (tester) async {
    await tester.pumpWidget(DartsApp(storage: InMemoryStorageService()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('X01'));
    await tester.pumpAndSettle();
    expect(find.text('X01 setup'), findsOneWidget);

    await tester.ensureVisible(find.textContaining('The Governor'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('The Governor'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Start game'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start game'));
    await tester.pumpAndSettle();

    final game =
        tester.widget<X01PlayScreen>(find.byType(X01PlayScreen)).game;
    expect(game.players.any((p) => p.botProfileId != null), isTrue);
    expect(tester.takeException(), isNull);
  });
}
