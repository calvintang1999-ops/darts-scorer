import 'dart:math' as math;

import '../../models/darts_game.dart';
import '../../models/player.dart';
import '../../models/throw.dart';
import 'cricket_config.dart';

/// Full Cricket rules: standard or cutthroat scoring, a configurable
/// number range, and an optional bull. Closing a number takes three
/// marks - a single counts one, a double two, a treble three.
class CricketGame extends DartsGame {
  CricketGame({required super.players, required this.config}) {
    numbers = config.numbers;
    marks = {for (final n in numbers) n: List.filled(players.length, 0)};
    scores = List.filled(players.length, 0);
    _beginTurn();
  }

  final CricketConfig config;

  /// The numbers that must be closed this match, e.g. [20, 19, ..., 15, 25].
  late List<int> numbers;

  /// Marks per number per player (0-3; 3 = closed). Keyed by segment
  /// number (25 for the bull), each list indexed the same order as
  /// [players]. Exposed for a future DartsLive-style board display.
  late Map<int, List<int>> marks;

  /// Points scored so far, same order as [players].
  late List<int> scores;

  /// Darts thrown so far in the current turn (0-3).
  List<Throw> currentTurnThrows = [];

  /// True once the current player has closed a number using only marks
  /// from this turn - a hook for a "GREAT!"-style celebration in the UI.
  bool closedThreeThisTurn = false;

  /// True once the current player has closed three different numbers in
  /// this turn - the classic "White Horse". A bigger hook than
  /// [closedThreeThisTurn], which only needs one number closed.
  bool whiteHorse = false;

  /// Marks snapshot from the start of the current turn, used to work out
  /// [closedThreeThisTurn].
  late Map<int, List<int>> _startOfTurnMarks;

  /// Distinct numbers the current player has newly closed so far this
  /// turn, used to work out [whiteHorse].
  Set<int> _numbersClosedThisTurn = {};

  Player? _winner;

  /// One-line feedback for the UI ("Alice wins the match!"). Cleared on
  /// the next dart.
  String? statusMessage;

  /// Undo works by snapshotting the entire game state before every dart
  /// and restoring the previous snapshot - see x01_game.dart for why.
  final List<_CricketSnapshot> _snapshots = [];

  @override
  bool get isFinished => _winner != null;

  @override
  Player? get winner => _winner;

  @override
  bool get canUndo => _snapshots.isNotEmpty;

  int get dartsLeftInTurn => 3 - currentTurnThrows.length;

  /// How many distinct numbers the current player has closed so far this
  /// turn - the count backing [whiteHorse] (which just checks this hits
  /// 3), exposed on its own for a UI that wants "2 of 3" style feedback.
  int get closedThisTurn => _numbersClosedThisTurn.length;

  @override
  void applyThrow(Throw dartThrow) {
    if (isFinished) return;
    _snapshots.add(_takeSnapshot());
    statusMessage = null;
    // The flags from a previous turn's closing dart live until the first
    // dart of the next turn, so the UI has a chance to see them - see the
    // comment on _beginTurn.
    if (currentTurnThrows.isEmpty) {
      closedThreeThisTurn = false;
      whiteHorse = false;
      _numbersClosedThisTurn = {};
    }

    final playerIndex = currentPlayerIndex;
    final segment = dartThrow.actualSegment;
    final multiplier = dartThrow.multiplier;

    var scoreDelta = 0;
    if (numbers.contains(segment)) {
      final numberMarks = marks[segment]!;
      final before = numberMarks[playerIndex];
      final added = before >= 3 ? 0 : math.min(multiplier, 3 - before);
      numberMarks[playerIndex] = before + added;
      final excess = multiplier - added;

      // Excess marks only score once the number is closed for the
      // thrower AND at least one opponent still has it open - hitting a
      // number everyone has already closed is a dead dart.
      if (numberMarks[playerIndex] == 3 && excess > 0) {
        final stillOpenOpponents = [
          for (var i = 0; i < players.length; i++)
            if (i != playerIndex && numberMarks[i] < 3) i
        ];
        if (stillOpenOpponents.isNotEmpty) {
          final points = excess * segment;
          if (config.mode == CricketMode.standard) {
            scores[playerIndex] += points;
          } else {
            // Cutthroat: points are piled onto opponents who haven't
            // closed this number yet, not scored for yourself.
            for (final i in stillOpenOpponents) {
              scores[i] += points;
            }
          }
          // Points this dart generated, even in cutthroat where they
          // landed on opponents rather than the thrower - later stats
          // need to see that the dart scored, not just who it credited.
          scoreDelta = points;
        }
      }

      if (numberMarks[playerIndex] - _startOfTurnMarks[segment]![playerIndex] >=
          3) {
        closedThreeThisTurn = true;
      }

      // A White Horse needs three *different* numbers closed this turn,
      // so only count a number the moment it newly reaches 3 marks.
      if (before < 3 && numberMarks[playerIndex] == 3) {
        _numbersClosedThisTurn.add(segment);
        if (_numbersClosedThisTurn.length >= 3) {
          whiteHorse = true;
          statusMessage =
              '${players[playerIndex].name} - White Horse! Three numbers '
              'closed this turn.';
        }
      }
    }

    currentTurnThrows
        .add(dartThrow.copyWith(resultingScoreDelta: scoreDelta));

    if (_hasWon(playerIndex)) {
      _winner = players[playerIndex];
      statusMessage = '${players[playerIndex].name} wins the match!';
      _finishTurn();
    } else if (currentTurnThrows.length >= 3) {
      _finishTurn();
      _advanceToNextPlayer();
    }
    notifyListeners();
  }

  @override
  void undo() {
    if (_snapshots.isEmpty) return;
    _restoreSnapshot(_snapshots.removeLast());
    notifyListeners();
  }

  bool _hasWon(int playerIndex) {
    final closedAll = numbers.every((n) => marks[n]![playerIndex] == 3);
    if (!closedAll) return false;

    for (var i = 0; i < players.length; i++) {
      if (i == playerIndex) continue;
      // Standard: higher points win, so an opponent ahead of you means
      // you're behind. Cutthroat inverts this - lower points win.
      final behind = config.mode == CricketMode.standard
          ? scores[i] > scores[playerIndex]
          : scores[i] < scores[playerIndex];
      if (behind) return false;
    }
    return true;
  }

  void _finishTurn() {
    turnHistory.add(
        Turn(player: players[currentPlayerIndex], throws: currentTurnThrows));
    currentTurnThrows = [];
  }

  void _advanceToNextPlayer() {
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    _beginTurn();
  }

  void _beginTurn() {
    currentTurnThrows = [];
    _startOfTurnMarks = _copyMarks(marks);
    // closedThreeThisTurn is deliberately NOT cleared here: this runs
    // synchronously right after the dart that may have just set it true
    // (when that dart was also the turn's 3rd dart), and clearing it now
    // would erase the flag before the UI's notifyListeners callback ever
    // sees it. It's cleared instead at the top of the next dart.
  }

  Map<int, List<int>> _copyMarks(Map<int, List<int>> source) =>
      {for (final entry in source.entries) entry.key: List.of(entry.value)};

  _CricketSnapshot _takeSnapshot() => _CricketSnapshot(
        marks: _copyMarks(marks),
        scores: List.of(scores),
        currentTurnThrows: List.of(currentTurnThrows),
        currentPlayerIndex: currentPlayerIndex,
        startOfTurnMarks: _copyMarks(_startOfTurnMarks),
        closedThreeThisTurn: closedThreeThisTurn,
        whiteHorse: whiteHorse,
        numbersClosedThisTurn: Set.of(_numbersClosedThisTurn),
        turnHistoryLength: turnHistory.length,
        winner: _winner,
        statusMessage: statusMessage,
      );

  void _restoreSnapshot(_CricketSnapshot s) {
    marks = _copyMarks(s.marks);
    scores = List.of(s.scores);
    currentTurnThrows = List.of(s.currentTurnThrows);
    currentPlayerIndex = s.currentPlayerIndex;
    _startOfTurnMarks = _copyMarks(s.startOfTurnMarks);
    closedThreeThisTurn = s.closedThreeThisTurn;
    whiteHorse = s.whiteHorse;
    _numbersClosedThisTurn = Set.of(s.numbersClosedThisTurn);
    // Throws never leave history on their own, so undoing just means
    // trimming it back to its old length.
    turnHistory.removeRange(s.turnHistoryLength, turnHistory.length);
    _winner = s.winner;
    statusMessage = s.statusMessage;
  }
}

/// A frozen copy of every piece of mutable Cricket state, for undo.
class _CricketSnapshot {
  _CricketSnapshot({
    required this.marks,
    required this.scores,
    required this.currentTurnThrows,
    required this.currentPlayerIndex,
    required this.startOfTurnMarks,
    required this.closedThreeThisTurn,
    required this.whiteHorse,
    required this.numbersClosedThisTurn,
    required this.turnHistoryLength,
    required this.winner,
    required this.statusMessage,
  });

  final Map<int, List<int>> marks;
  final List<int> scores;
  final List<Throw> currentTurnThrows;
  final int currentPlayerIndex;
  final Map<int, List<int>> startOfTurnMarks;
  final bool closedThreeThisTurn;
  final bool whiteHorse;
  final Set<int> numbersClosedThisTurn;
  final int turnHistoryLength;
  final Player? winner;
  final String? statusMessage;
}
