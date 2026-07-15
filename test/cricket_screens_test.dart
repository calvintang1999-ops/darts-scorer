import 'package:darts/games/cricket/cricket_config.dart';
import 'package:darts/games/cricket/cricket_game.dart';
import 'package:darts/games/cricket/cricket_play_screen.dart';
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
  Future<void> startGame(WidgetTester tester, {bool cutthroat = false}) async {
    await tester.pumpWidget(DartsApp(storage: InMemoryStorageService()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cricket'));
    await tester.pumpAndSettle();
    expect(find.text('Cricket setup'), findsOneWidget);

    if (cutthroat) {
      // The bot picker section can push this below the ListView's
      // mounted+cache area - scroll it into view first.
      await tester.dragUntilVisible(
        find.text('Cutthroat'),
        find.byType(ListView),
        const Offset(0, -200),
      );
      await tester.tap(find.text('Cutthroat'));
      await tester.pumpAndSettle();
    }

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
  // board also shows plain number/BULL text, so tapping must target the
  // pad button specifically to avoid ambiguous finders.
  Future<void> tapPadKey(WidgetTester tester, String text) async {
    await tester.tap(find.widgetWithText(FilledButton, text));
    await tester.pumpAndSettle();
  }

  testWidgets('Cricket config screen starts a game with no setup needed',
      (tester) async {
    await startGame(tester);

    // Play screen is up: app bar shows whose throw it is, board and pad
    // are both on screen with no layout overflow.
    expect(find.textContaining('to throw'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'BULL'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'TREBLE'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('throwing darts updates the board and undo reverts them',
      (tester) async {
    await startGame(tester);

    // Arm treble, then hit 20 - should close it with no excess.
    await tapPadKey(tester, 'TREBLE');
    await tapPadKey(tester, '20');
    expect(find.text('⊗'), findsOneWidget);
    expect(tester.takeException(), isNull);

    final undoButton = find.ancestor(
      of: find.byIcon(Icons.undo),
      matching: find.byType(IconButton),
    );
    expect(tester.widget<IconButton>(undoButton).onPressed, isNotNull);
    await tester.tap(undoButton);
    await tester.pumpAndSettle();
    expect(find.text('⊗'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cutthroat mode can be selected and started', (tester) async {
    await startGame(tester, cutthroat: true);

    expect(find.textContaining('Cutthroat'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('play screen renders without overflow in landscape',
      (tester) async {
    // Reach the play screen at the default surface size first - the
    // config screen's button is otherwise below the visible+cache area
    // of a very short ListView and never gets mounted.
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

    // A shorter portrait phone - the board + status bar + pad easily
    // exceed 600px of usable height, so this is the real stress case.
    await tester.binding.setSurfaceSize(const Size(400, 600));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('leaving a fresh game skips the quit confirmation',
      (tester) async {
    await startGame(tester);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    // No progress yet, so back navigates straight to Home with no dialog.
    expect(find.text('Quit game?'), findsNothing);
    expect(find.text('Cricket setup'), findsNothing);
    expect(find.byType(AppBar), findsOneWidget); // Home's app bar
  });

  testWidgets(
      'leaving a game in progress asks for confirmation before quitting',
      (tester) async {
    await startGame(tester);
    await tapPadKey(tester, '20'); // some progress to lose

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Quit game?'), findsOneWidget);
    expect(
        find.text('Your progress will be lost.'), findsOneWidget);

    // Cancel: dialog closes, still on the play screen with the mark kept.
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
        child: CricketPlayScreen(
          game: CricketGame(
            players: [bot, human],
            config: const CricketConfig(),
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
        tester.widget<CricketPlayScreen>(find.byType(CricketPlayScreen)).game;
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
