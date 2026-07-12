import 'package:darts/main.dart';
import 'package:darts/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
