import 'package:darts/games/round_the_clock/round_the_clock_config.dart';
import 'package:darts/games/round_the_clock/round_the_clock_game.dart';
import 'package:darts/games/round_the_clock/round_the_clock_play_screen.dart';
import 'package:darts/main.dart';
import 'package:darts/models/player.dart';
import 'package:darts/models/throw.dart';
import 'package:darts/services/announcer_service.dart';
import 'package:darts/services/bot_profiles_provider.dart';
import 'package:darts/services/dart_counter_service.dart';
import 'package:darts/services/settings_provider.dart';
import 'package:darts/services/storage_service.dart';
import 'package:darts/theme/tokens.dart';
import 'package:darts/widgets/player_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  Future<void> startGame(WidgetTester tester) async {
    await tester.pumpWidget(DartsApp(storage: InMemoryStorageService()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Round the Clock'));
    await tester.pumpAndSettle();
    expect(find.text('Round the Clock setup'), findsOneWidget);

    // This setup screen has more sections than the others (sequence,
    // multiplier rule, starting number), so the Start button can start
    // off out of the ListView's build range - scroll it into view first.
    await tester.dragUntilVisible(
      find.text('Start game'),
      find.byType(ListView),
      const Offset(0, -200),
    );
    await tester.tap(find.text('Start game'));
    await tester.pumpAndSettle();
  }

  // The pad's number/modifier keys are FilledButton.tonal widgets - the
  // scoreboard also shows the current target as text, so tapping must
  // target the pad button specifically.
  Future<void> tapPadKey(WidgetTester tester, String text) async {
    await tester.tap(find.widgetWithText(FilledButton, text));
    await tester.pumpAndSettle();
  }

  // The pad also has a number key for every possible target label, so a
  // bare find.text() can't tell "the target changed" from "the pad still
  // has that button" - this scopes the search to the player's own card.
  Finder onPlayerCard(String text) => find.descendant(
        of: find.byType(PlayerCard),
        matching: find.text(text),
      );

  testWidgets(
      'Round the Clock config screen starts a game with no setup needed',
      (tester) async {
    await startGame(tester);

    expect(find.textContaining('to throw'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'BULL'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'TREBLE'), findsOneWidget);
    // Fresh game: the player's card shows the default starting target, 1.
    expect(onPlayerCard('1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hitting the target advances it, and undo reverts that',
      (tester) async {
    await startGame(tester);

    // Single 1 advances the only player's target from 1 to 2. (The just-
    // thrown dart's own label also reads "1" on the card's turn-darts
    // row, so we only assert the new target shows up - not that "1"
    // vanished entirely.)
    await tapPadKey(tester, '1');
    expect(onPlayerCard('2'), findsOneWidget);
    expect(tester.takeException(), isNull);

    final undoButton = find.ancestor(
      of: find.byIcon(Icons.undo),
      matching: find.byType(IconButton),
    );
    expect(tester.widget<IconButton>(undoButton).onPressed, isNotNull);
    await tester.tap(undoButton);
    await tester.pumpAndSettle();
    expect(onPlayerCard('1'), findsOneWidget);
    expect(onPlayerCard('2'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'config screen renders without overflow at phone width '
      '(3-segment sequence picker)', (tester) async {
    await tester.pumpWidget(DartsApp(storage: InMemoryStorageService()));
    await tester.pumpAndSettle();

    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(400, 800));
    await tester.pumpAndSettle();

    // Home's game list is a plain ListView too - at this narrower width
    // cards take more vertical space, so scroll "Round the Clock" (the
    // last entry) into the build range before tapping it.
    await tester.dragUntilVisible(
      find.text('Round the Clock'),
      find.byType(ListView),
      const Offset(0, -200),
    );
    await tester.tap(find.text('Round the Clock'));
    await tester.pumpAndSettle();
    expect(find.text('Round the Clock setup'), findsOneWidget);
    expect(tester.takeException(), isNull);
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

    await tester.binding.setSurfaceSize(const Size(400, 600));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('leaving a fresh game skips the quit confirmation',
      (tester) async {
    await startGame(tester);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Quit game?'), findsNothing);
    expect(find.text('Round the Clock setup'), findsNothing);
    expect(find.byType(AppBar), findsOneWidget); // Home's app bar
  });

  testWidgets(
      'leaving a game in progress asks for confirmation before quitting',
      (tester) async {
    await startGame(tester);
    await tapPadKey(tester, 'MISS'); // some progress to lose

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Quit game?'), findsOneWidget);
    expect(find.text('Your progress will be lost.'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Quit game?'), findsNothing);
    expect(find.textContaining('to throw'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quit'));
    await tester.pumpAndSettle();
    expect(find.textContaining('to throw'), findsNothing);
  });

  testWidgets(
      'a bot plays its whole turn automatically, then hands off to the human',
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
        child: RoundTheClockPlayScreen(
          game: RoundTheClockGame(
            players: [bot, human],
            config: const RoundTheClockConfig(),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    for (var i = 0; i < 4; i++) {
      await tester.pump(DurationTokens.botThrowPacing);
    }
    await tester.pumpAndSettle();

    final game = tester
        .widget<RoundTheClockPlayScreen>(find.byType(RoundTheClockPlayScreen))
        .game;
    expect(game.turnHistory, hasLength(1));
    expect(game.turnHistory.single.throws, hasLength(3));
    expect(
        game.turnHistory.single.throws
            .every((t) => t.source == ThrowSource.bot),
        true);
    expect(game.currentPlayerIndex, 1);
    expect(tester.takeException(), isNull);
  });
}
