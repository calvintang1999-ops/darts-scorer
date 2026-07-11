import '../../models/darts_game.dart';
import '../../models/player.dart';
import '../../models/throw.dart';
import 'checkouts.dart';
import 'x01_config.dart';

/// Full X01 (301/501/701...) rules: in/out rules, busts, legs and sets.
/// This is the reference implementation other games can crib from.
class X01Game extends DartsGame {
  X01Game({required super.players, required this.config}) {
    _startLeg(startingPlayerIndex: 0);
  }

  final X01Config config;

  /// Remaining score per player (same order as [players]).
  late List<int> scores;

  /// Whether each player has satisfied the in-rule this leg. With an
  /// "open" in-rule everyone starts opened.
  late List<bool> opened;

  late List<int> legsWon = List.filled(players.length, 0);
  late List<int> setsWon = List.filled(players.length, 0);

  /// Darts thrown so far in the current turn (0-3).
  List<Throw> currentTurnThrows = [];

  /// The current player's score when their turn began - a bust reverts
  /// to this value.
  late int startOfTurnScore;

  /// Who threw first this leg. Rotates each leg so nobody always goes first.
  int _legStartPlayerIndex = 0;

  Player? _winner;

  /// One-line feedback for the UI ("Bust! ...", "Alice wins the leg!").
  /// Cleared on the next dart.
  String? statusMessage;

  /// Undo works by snapshotting the entire game state before every dart
  /// and restoring the previous snapshot. Slightly memory-hungry but
  /// simple, impossible to get subtly wrong, and it naturally handles
  /// undoing across busts, turn changes, and even leg/set wins.
  final List<_X01Snapshot> _snapshots = [];

  @override
  bool get isFinished => _winner != null;

  @override
  Player? get winner => _winner;

  @override
  bool get canUndo => _snapshots.isNotEmpty;

  int get dartsLeftInTurn => 3 - currentTurnThrows.length;

  /// The suggested finish for the current player, e.g. "T20 T20 Bull".
  /// Null when there isn't one (score too high, wrong out-rule, or not
  /// enough darts left this turn). Checkout tables assume double-out.
  String? get checkoutSuggestion {
    if (isFinished || config.outRule != X01OutRule.double) return null;
    if (!opened[currentPlayerIndex]) return null;
    return suggestCheckout(scores[currentPlayerIndex], dartsLeftInTurn);
  }

  @override
  void applyThrow(Throw dartThrow) {
    if (isFinished) return;
    _snapshots.add(_takeSnapshot());
    statusMessage = null;

    final playerIndex = currentPlayerIndex;
    var points = dartThrow.scoredPoints;

    // In-rule: darts before the qualifying one score nothing. The
    // qualifying dart itself counts.
    if (!opened[playerIndex]) {
      if (_satisfiesInRule(dartThrow)) {
        opened[playerIndex] = true;
      } else {
        points = 0;
        statusMessage =
            'Needs a ${config.inRule == X01InRule.double ? "double" : "double or treble"} to start scoring';
      }
    }

    final scoreBefore = scores[playerIndex];
    final scoreAfter = scoreBefore - points;

    var bust = false;
    var legWon = false;
    if (opened[playerIndex]) {
      if (scoreAfter < 0) {
        bust = true; // went past zero
      } else if (scoreAfter == 0) {
        // Exactly zero only wins if the final dart satisfies the out-rule.
        if (_satisfiesOutRule(dartThrow)) {
          legWon = true;
        } else {
          bust = true;
        }
      } else if (scoreAfter == 1 && config.outRule != X01OutRule.single) {
        bust = true; // 1 is unreachable when you must finish on a double
      }
    }

    // A bust puts the score back where the turn started, wiping out any
    // earlier darts this turn.
    final newScore = bust ? startOfTurnScore : scoreAfter;
    scores[playerIndex] = newScore;
    if (bust) {
      statusMessage = 'Bust! Back to $startOfTurnScore';
    }

    // Record the dart with its real net effect on the remaining score
    // (negative = scored, positive = bust restored points).
    currentTurnThrows
        .add(dartThrow.copyWith(resultingScoreDelta: newScore - scoreBefore));

    if (legWon) {
      _finishTurn();
      _handleLegWin(playerIndex);
    } else if (bust || currentTurnThrows.length >= 3) {
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

  bool _satisfiesInRule(Throw dartThrow) {
    switch (config.inRule) {
      case X01InRule.open:
        return true;
      case X01InRule.double:
        return dartThrow.multiplier == 2; // includes the inner bull (25x2)
      case X01InRule.master:
        return dartThrow.multiplier >= 2;
    }
  }

  bool _satisfiesOutRule(Throw dartThrow) {
    switch (config.outRule) {
      case X01OutRule.single:
        return true;
      case X01OutRule.double:
        return dartThrow.multiplier == 2;
      case X01OutRule.master:
        return dartThrow.multiplier >= 2;
    }
  }

  /// Moves the finished turn into the shared history.
  void _finishTurn() {
    turnHistory.add(
        Turn(player: players[currentPlayerIndex], throws: currentTurnThrows));
    currentTurnThrows = [];
  }

  void _advanceToNextPlayer() {
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    startOfTurnScore = scores[currentPlayerIndex];
  }

  void _handleLegWin(int playerIndex) {
    final name = players[playerIndex].name;
    legsWon[playerIndex]++;
    statusMessage = '$name wins the leg!';

    if (legsWon[playerIndex] >= config.legsPerSet) {
      setsWon[playerIndex]++;
      // Legs reset for everyone at the start of a new set.
      legsWon = List.filled(players.length, 0);
      if (setsWon[playerIndex] >= config.setsToWin) {
        _winner = players[playerIndex];
        statusMessage = '$name wins the match!';
        return;
      }
      statusMessage = '$name wins the set!';
    }
    // Next leg: alternate who throws first.
    _legStartPlayerIndex = (_legStartPlayerIndex + 1) % players.length;
    _startLeg(startingPlayerIndex: _legStartPlayerIndex);
  }

  void _startLeg({required int startingPlayerIndex}) {
    scores = List.filled(players.length, config.startingScore);
    opened =
        List.filled(players.length, config.inRule == X01InRule.open);
    currentTurnThrows = [];
    currentPlayerIndex = startingPlayerIndex;
    startOfTurnScore = config.startingScore;
  }

  _X01Snapshot _takeSnapshot() => _X01Snapshot(
        scores: List.of(scores),
        opened: List.of(opened),
        legsWon: List.of(legsWon),
        setsWon: List.of(setsWon),
        currentTurnThrows: List.of(currentTurnThrows),
        currentPlayerIndex: currentPlayerIndex,
        startOfTurnScore: startOfTurnScore,
        legStartPlayerIndex: _legStartPlayerIndex,
        turnHistoryLength: turnHistory.length,
        winner: _winner,
        statusMessage: statusMessage,
      );

  void _restoreSnapshot(_X01Snapshot s) {
    scores = List.of(s.scores);
    opened = List.of(s.opened);
    legsWon = List.of(s.legsWon);
    setsWon = List.of(s.setsWon);
    currentTurnThrows = List.of(s.currentTurnThrows);
    currentPlayerIndex = s.currentPlayerIndex;
    startOfTurnScore = s.startOfTurnScore;
    _legStartPlayerIndex = s.legStartPlayerIndex;
    // Throws never leave history on their own, so undoing just means
    // trimming it back to its old length.
    turnHistory.removeRange(s.turnHistoryLength, turnHistory.length);
    _winner = s.winner;
    statusMessage = s.statusMessage;
  }
}

/// A frozen copy of every piece of mutable X01 state, for undo.
class _X01Snapshot {
  _X01Snapshot({
    required this.scores,
    required this.opened,
    required this.legsWon,
    required this.setsWon,
    required this.currentTurnThrows,
    required this.currentPlayerIndex,
    required this.startOfTurnScore,
    required this.legStartPlayerIndex,
    required this.turnHistoryLength,
    required this.winner,
    required this.statusMessage,
  });

  final List<int> scores;
  final List<bool> opened;
  final List<int> legsWon;
  final List<int> setsWon;
  final List<Throw> currentTurnThrows;
  final int currentPlayerIndex;
  final int startOfTurnScore;
  final int legStartPlayerIndex;
  final int turnHistoryLength;
  final Player? winner;
  final String? statusMessage;
}
