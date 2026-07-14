import 'package:darts/games/x01/x01_config.dart';
import 'package:darts/games/x01/x01_game.dart';
import 'package:darts/games/x01/x01_play_screen.dart';
import 'package:darts/main.dart';
import 'package:darts/models/player.dart';
import 'package:darts/services/announcer_service.dart';
import 'package:darts/services/dart_counter_service.dart';
import 'package:darts/services/settings_provider.dart';
import 'package:darts/services/storage_service.dart';
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

    // X01's form has more sections than Cricket's, so the Start button
    // starts out below the ListView's mounted+cache area - scroll to it.
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
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
    // X01PlayScreen reads AnnouncerService/DartCounterService in initState.
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
}
