import 'dart:math' as math;

import '../../models/darts_game.dart';
import '../../models/game_event.dart';
import '../../models/player.dart';
import '../../models/throw.dart';
import 'halfit_config.dart';

/// DartCounter-style "Half It": players work through an ordered list of
/// targets, one per round, everyone throwing at the same target before
/// the round advances. Hit the round's target and the qualifying darts'
/// face value is added to your running score; miss it and your score is
/// halved (rounded down). Highest score after the last round (always
/// the bull) wins.
class HalfItGame extends DartsGame {
  HalfItGame({
    required super.players,
    required this.config,
    math.Random? random,
  }) : targets = _buildTargets(config, random ?? math.Random()) {
    scores = List.filled(players.length, config.startingScore);
    _beginTurn();
  }

  final HalfItConfig config;

  /// The ordered targets for this match, one per round - built once at
  /// construction. A randomized match is shuffled here, not re-rolled
  /// each round.
  final List<HalfItTarget> targets;

  /// Running score per player, same order as [players].
  late List<int> scores;

  /// Index into [targets] of the round currently being played.
  int currentRoundIndex = 0;

  /// Darts thrown so far this turn (0-3). A target only ever evaluates a
  /// full completed turn - see the class doc on [HalfItTarget].
  List<Throw> currentTurnThrows = [];

  /// True once the current player's most recent turn missed and halved
  /// their score - a hook for a "HALVED!"-style callout in the UI.
  bool wasHalvedThisRound = false;

  Player? _winner;

  /// One-line feedback for the UI ("Alice scores 60!", "Alice wins!").
  /// Cleared on the next dart.
  String? statusMessage;

  /// Undo works by snapshotting the entire game state before every dart
  /// and restoring the previous snapshot - see x01_game.dart for why.
  final List<_HalfItSnapshot> _snapshots = [];

  /// The target the whole table is throwing at this round.
  HalfItTarget get currentTarget => targets[currentRoundIndex];

  @override
  bool get isFinished => _winner != null;

  @override
  Player? get winner => _winner;

  @override
  bool get canUndo => _snapshots.isNotEmpty;

  int get dartsLeftInTurn => 3 - currentTurnThrows.length;

  @override
  void scoreThrow(Throw dartThrow) {
    if (isFinished) return;
    _snapshots.add(_takeSnapshot());
    statusMessage = null;
    // The flag from the previous turn lives until the first dart of the
    // next one, so the UI has a chance to see it before it's cleared -
    // same deferred-reset pattern as Cricket's closedThreeThisTurn.
    if (currentTurnThrows.isEmpty) wasHalvedThisRound = false;

    currentTurnThrows.add(dartThrow);

    // A full turn always ends the round, but some targets (e.g. hitting
    // an exact score) can be unambiguously decided sooner - no point
    // asking for darts that can't change the outcome.
    if (currentTurnThrows.length >= 3 ||
        currentTarget.isEarlyHit(currentTurnThrows)) {
      _evaluateTurn();
    }
    notifyListeners();
  }

  @override
  void undo() {
    if (_snapshots.isEmpty) return;
    _restoreSnapshot(_snapshots.removeLast());
    notifyListeners();
  }

  void _evaluateTurn() {
    final playerIndex = currentPlayerIndex;
    final darts = List<Throw>.of(currentTurnThrows);
    final result = currentTarget.evaluate(darts);
    final name = players[playerIndex].name;

    final scoreBefore = scores[playerIndex];
    int scoreAfter;
    if (result.hit) {
      scoreAfter = scoreBefore + result.points;
      statusMessage = '$name scores ${result.points}!';
    } else {
      scoreAfter = scoreBefore ~/ 2;
      wasHalvedThisRound = true;
      statusMessage = '$name missed - halved to $scoreAfter';
    }
    scores[playerIndex] = scoreAfter;

    // Only the deciding (3rd) dart carries the round's net effect on the
    // score - the first two score nothing on their own, same idea as
    // X01's bust dart carrying the whole turn's reversion.
    final lastThrow = currentTurnThrows.removeLast();
    currentTurnThrows.add(
        lastThrow.copyWith(resultingScoreDelta: scoreAfter - scoreBefore));

    emitEvent(GameEventKind.visit, players[playerIndex], statusMessage!);
    _finishTurn();

    if (_isLastTurnOfMatch(playerIndex)) {
      _finishMatch();
    } else {
      _advanceToNextPlayerOrRound();
    }
  }

  bool _isLastTurnOfMatch(int playerIndex) =>
      currentRoundIndex == targets.length - 1 &&
      playerIndex == players.length - 1;

  void _finishMatch() {
    // Highest score wins; ties go to whoever's first in throwing order -
    // simple and deterministic, since the rules don't call out a tiebreak.
    var bestIndex = 0;
    for (var i = 1; i < players.length; i++) {
      if (scores[i] > scores[bestIndex]) bestIndex = i;
    }
    _winner = players[bestIndex];
    statusMessage = '${players[bestIndex].name} wins!';
    emitEvent(GameEventKind.matchWon, players[bestIndex], statusMessage!);
  }

  void _finishTurn() {
    turnHistory.add(
        Turn(player: players[currentPlayerIndex], throws: currentTurnThrows));
    currentTurnThrows = [];
  }

  void _advanceToNextPlayerOrRound() {
    final nextPlayerIndex = (currentPlayerIndex + 1) % players.length;
    // Wrapping back to the first player means everyone's had a turn at
    // the current target, so it's time for the next round.
    if (nextPlayerIndex == 0) currentRoundIndex++;
    currentPlayerIndex = nextPlayerIndex;
    _beginTurn();
  }

  void _beginTurn() {
    currentTurnThrows = [];
    // wasHalvedThisRound is deliberately NOT cleared here - see the
    // comment at the top of applyThrow.
  }

  _HalfItSnapshot _takeSnapshot() => _HalfItSnapshot(
        scores: List.of(scores),
        currentRoundIndex: currentRoundIndex,
        currentTurnThrows: List.of(currentTurnThrows),
        currentPlayerIndex: currentPlayerIndex,
        wasHalvedThisRound: wasHalvedThisRound,
        turnHistoryLength: turnHistory.length,
        winner: _winner,
        statusMessage: statusMessage,
      );

  void _restoreSnapshot(_HalfItSnapshot s) {
    scores = List.of(s.scores);
    currentRoundIndex = s.currentRoundIndex;
    currentTurnThrows = List.of(s.currentTurnThrows);
    currentPlayerIndex = s.currentPlayerIndex;
    wasHalvedThisRound = s.wasHalvedThisRound;
    // Throws never leave history on their own, so undoing just means
    // trimming it back to its old length.
    turnHistory.removeRange(s.turnHistoryLength, turnHistory.length);
    _winner = s.winner;
    statusMessage = s.statusMessage;
  }

  static List<HalfItTarget> _buildTargets(
      HalfItConfig config, math.Random random) {
    if (config.sequenceType == HalfItSequenceType.fixed) {
      return List.of(config.fixedSequence!);
    }
    final shuffled = List<HalfItTarget>.of(halfItTargetPool)
      ..shuffle(random);
    final randomRounds = config.roundCount - 1; // bull fills the last round
    return [
      for (var i = 0; i < randomRounds; i++) shuffled[i % shuffled.length],
      const BullseyeTarget(),
    ];
  }
}

/// A frozen copy of every piece of mutable Half It state, for undo.
class _HalfItSnapshot {
  _HalfItSnapshot({
    required this.scores,
    required this.currentRoundIndex,
    required this.currentTurnThrows,
    required this.currentPlayerIndex,
    required this.wasHalvedThisRound,
    required this.turnHistoryLength,
    required this.winner,
    required this.statusMessage,
  });

  final List<int> scores;
  final int currentRoundIndex;
  final List<Throw> currentTurnThrows;
  final int currentPlayerIndex;
  final bool wasHalvedThisRound;
  final int turnHistoryLength;
  final Player? winner;
  final String? statusMessage;
}
