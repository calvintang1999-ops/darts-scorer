import 'package:darts/games/halfit/halfit_config.dart';
import 'package:darts/games/halfit/halfit_game.dart';
import 'package:darts/games/halfit/halfit_play_screen.dart';
import 'package:darts/main.dart';
import 'package:darts/models/player.dart';
import 'package:darts/models/throw.dart';
import 'package:darts/services/announcer_service.dart';
import 'package:darts/services/bot_profiles_provider.dart';
import 'package:darts/services/dart_counter_service.dart';
import 'package:darts/services/settings_provider.dart';
import 'package:darts/services/storage_service.dart';
import 'package:darts/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  Future<void> startGame(WidgetTester tester) async {
    await tester.pumpWidget(DartsApp(storage: InMemoryStorageService()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Half It'));
    await tester.pumpAndSettle();
    expect(find.text('Half It setup'), findsOneWidget);

    // The bot picker section can push the Start button out of the
    // ListView's build range on a short test surface - scroll it into view.
    await tester.dragUntilVisible(
      find.text('Start game'),
      find.byType(ListView),
      const Offset(0, -200),
    );
    await tester.tap(find.text('Start game'));
    await tester.pumpAndSettle();
  }

  // The pad's number/modifier keys are FilledButton.tonal widgets - the
  // scoreboard also shows numbers (running score), so tapping must
  // target the pad button specifically.
  Future<void> tapPadKey(WidgetTester tester, String text) async {
    await tester.tap(find.widgetWithText(FilledButton, text));
    await tester.pumpAndSettle();
  }

  testWidgets('Half It config screen starts a game with no setup needed',
      (tester) async {
    await startGame(tester);

    expect(find.textContaining('to throw'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'BULL'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'TREBLE'), findsOneWidget);
    // Fresh game: everyone starts at the configured starting score (20).
    expect(find.text('20'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'the current target is shown on its own banner, not just the title',
      (tester) async {
    await startGame(tester);

    final game =
        tester.widget<HalfItPlayScreen>(find.byType(HalfItPlayScreen)).game;

    // The banner shows round progress and the target's own label as a
    // standalone, prominent element.
    expect(find.text('ROUND 1 OF 10'), findsOneWidget);
    expect(find.text(game.currentTarget.label), findsOneWidget);
    // The app bar title no longer duplicates the target label - just
    // whose throw it is.
    expect(find.text('${game.currentPlayer.name} to throw'), findsOneWidget);
  });

  testWidgets('throwing a full turn updates the score and undo reverts it',
      (tester) async {
    await startGame(tester);

    // Whatever the first round's target is, missing it entirely with 3
    // off-board darts halves the starting score from 20 to 10.
    await tapPadKey(tester, 'MISS');
    await tapPadKey(tester, 'MISS');
    await tapPadKey(tester, 'MISS');
    expect(find.text('10'), findsWidgets);
    expect(tester.takeException(), isNull);

    final undoButton = find.ancestor(
      of: find.byIcon(Icons.undo),
      matching: find.byType(IconButton),
    );
    expect(tester.widget<IconButton>(undoButton).onPressed, isNotNull);
    await tester.tap(undoButton);
    await tester.pumpAndSettle();
    await tester.tap(undoButton);
    await tester.pumpAndSettle();
    await tester.tap(undoButton);
    await tester.pumpAndSettle();
    expect(find.text('20'), findsWidgets);
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
    expect(find.text('Half It setup'), findsNothing);
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
        child: HalfItPlayScreen(
          game: HalfItGame(
            players: [bot, human],
            // A single fixed NumberTarget round - deterministic, and
            // (unlike ExactScoreTarget etc.) never ends a turn early, so
            // this always throws exactly 3 darts.
            config: const HalfItConfig(
              sequenceType: HalfItSequenceType.fixed,
              fixedSequence: [NumberTarget(20)],
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    for (var i = 0; i < 4; i++) {
      await tester.pump(DurationTokens.botThrowPacing);
    }
    await tester.pumpAndSettle();

    final game =
        tester.widget<HalfItPlayScreen>(find.byType(HalfItPlayScreen)).game;
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
