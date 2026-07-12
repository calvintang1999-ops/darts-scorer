import 'package:darts/main.dart';
import 'package:darts/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> startGame(WidgetTester tester) async {
    await tester.pumpWidget(DartsApp(storage: InMemoryStorageService()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Half It'));
    await tester.pumpAndSettle();
    expect(find.text('Half It setup'), findsOneWidget);

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
}
