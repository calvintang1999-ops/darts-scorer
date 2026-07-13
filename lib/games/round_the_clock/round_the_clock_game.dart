import '../../models/darts_game.dart';
import '../../models/player.dart';
import '../../models/throw.dart';
import 'round_the_clock_config.dart';

/// Full Round the Clock rules: each player works through the same ordered
/// sequence of stops (see [RoundTheClockConfig.stops]), starting at the
/// first one. Hitting your current target advances you; how far depends
/// on [RoundTheClockConfig.multiplierRule] - but that bonus can only ever
/// carry you up to the bull, never through it (see [_bullStartIndex]).
/// First to complete the whole sequence wins.
class RoundTheClockGame extends DartsGame {
  RoundTheClockGame({required super.players, required this.config})
      : stops = config.stops {
    currentIndex = List.filled(players.length, 0);
    _bullStartIndex =
        stops.indexWhere((s) => s.requiredMultiplier != null);
  }

  final RoundTheClockConfig config;

  /// The shared stop sequence every player works through - only where
  /// each player currently stands in it ([currentIndex]) differs.
  final List<RoundTheClockStop> stops;

  /// Index of the first bull stop in [stops], or -1 if this match has no
  /// bull (numbers-only sequence). A skip-ahead from a numbered wedge is
  /// capped here - it can land you on the bull's doorstep, never past it.
  late final int _bullStartIndex;

  /// Index into [stops] of the next stop each player needs to hit, same
  /// order as [players]. Reaching [stops.length] means they're done.
  late List<int> currentIndex;

  /// Darts thrown so far in the current turn (0-3).
  List<Throw> currentTurnThrows = [];

  /// How many stops the current player has advanced so far this turn -
  /// a UI hook for a "+3!" style animation. Stays visible until the
  /// first dart of the next turn (see the comment in applyThrow), same
  /// deferred-reset pattern as Cricket's closedThreeThisTurn.
  int advancedStepsThisTurn = 0;

  Player? _winner;

  /// One-line feedback for the UI ("Alice wins the match!"). Cleared on
  /// the next dart.
  String? statusMessage;

  /// Undo works by snapshotting the entire game state before every dart
  /// and restoring the previous snapshot - see x01_game.dart for why.
  final List<_RoundTheClockSnapshot> _snapshots = [];

  @override
  bool get isFinished => _winner != null;

  @override
  Player? get winner => _winner;

  @override
  bool get canUndo => _snapshots.isNotEmpty;

  int get dartsLeftInTurn => 3 - currentTurnThrows.length;

  /// Total stops in the sequence - the denominator for a progress bar.
  int get sequenceLength => stops.length;

  /// How far through the sequence a player has got (0..[sequenceLength]) -
  /// the numerator for a progress bar.
  int currentPosition(int playerIndex) => currentIndex[playerIndex];

  /// Progress fraction (0.0-1.0), for a progress bar.
  double progress(int playerIndex) =>
      currentPosition(playerIndex) / sequenceLength;

  /// Human label for a player's current target, e.g. "7", "Bull", "50" -
  /// or null once they've completed the whole sequence.
  String? currentTargetLabel(int playerIndex) {
    final index = currentIndex[playerIndex];
    return index < stops.length ? stops[index].label : null;
  }

  @override
  void applyThrow(Throw dartThrow) {
    if (isFinished) return;
    _snapshots.add(_takeSnapshot());
    statusMessage = null;
    // Like Cricket's closedThreeThisTurn, this is cleared at the START of
    // the next turn's first dart (not at turn-end) so the UI's
    // notifyListeners callback gets a chance to see it first.
    if (currentTurnThrows.isEmpty) advancedStepsThisTurn = 0;

    final playerIndex = currentPlayerIndex;
    final index = currentIndex[playerIndex];
    final movedBy = _stepsAdvanced(index, dartThrow);

    if (movedBy > 0) {
      currentIndex[playerIndex] = index + movedBy;
      advancedStepsThisTurn += movedBy;
    }

    // intendedTarget records what they were aiming at *before* this dart
    // moved them, not wherever they ended up.
    currentTurnThrows.add(dartThrow.copyWith(
      resultingScoreDelta: movedBy,
      intendedTarget: stops[index].segment,
    ));

    if (currentIndex[playerIndex] >= stops.length) {
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

  /// How many stops [dartThrow] moves a player forward from [index], 0 if
  /// it doesn't hit their current target at all.
  ///
  /// A numbered stop matches on segment alone, worth 1/2/3 stops for a
  /// single/double/treble (or always 1 in singles-only mode) - but that
  /// bonus is capped at [_bullStartIndex]: it can carry you up to the
  /// bull, never skip past or through it. A bull stop matches only its
  /// exact required ring (see [RoundTheClockStop.requiredMultiplier]) and
  /// is always worth exactly 1 stop - no bonus, no shortcuts.
  int _stepsAdvanced(int index, Throw dartThrow) {
    final stop = stops[index];
    if (dartThrow.actualSegment != stop.segment) return 0;

    if (stop.requiredMultiplier != null) {
      return dartThrow.multiplier == stop.requiredMultiplier ? 1 : 0;
    }

    final rawSteps = _advanceSteps(dartThrow.multiplier);
    if (rawSteps == 0) return 0;
    var newIndex = index + rawSteps;
    if (_bullStartIndex != -1 && newIndex > _bullStartIndex) {
      newIndex = _bullStartIndex;
    }
    if (newIndex > stops.length) newIndex = stops.length;
    return newIndex - index;
  }

  /// The raw multiplier bonus for a numbered stop, before any bull
  /// capping: a single is worth 1, a double 2, a treble 3. Singles-only
  /// mode: only an actual single counts (worth 1); a double or treble of
  /// the target doesn't advance you at all.
  int _advanceSteps(int multiplier) {
    if (config.multiplierRule == RoundTheClockMultiplierRule.singlesOnly) {
      return multiplier == 1 ? 1 : 0;
    }
    return multiplier;
  }

  void _finishTurn() {
    turnHistory.add(
        Turn(player: players[currentPlayerIndex], throws: currentTurnThrows));
    currentTurnThrows = [];
  }

  void _advanceToNextPlayer() {
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
  }

  _RoundTheClockSnapshot _takeSnapshot() => _RoundTheClockSnapshot(
        currentIndex: List.of(currentIndex),
        currentTurnThrows: List.of(currentTurnThrows),
        currentPlayerIndex: currentPlayerIndex,
        advancedStepsThisTurn: advancedStepsThisTurn,
        turnHistoryLength: turnHistory.length,
        winner: _winner,
        statusMessage: statusMessage,
      );

  void _restoreSnapshot(_RoundTheClockSnapshot s) {
    currentIndex = List.of(s.currentIndex);
    currentTurnThrows = List.of(s.currentTurnThrows);
    currentPlayerIndex = s.currentPlayerIndex;
    advancedStepsThisTurn = s.advancedStepsThisTurn;
    // Throws never leave history on their own, so undoing just means
    // trimming it back to its old length.
    turnHistory.removeRange(s.turnHistoryLength, turnHistory.length);
    _winner = s.winner;
    statusMessage = s.statusMessage;
  }
}

/// A frozen copy of every piece of mutable Round the Clock state, for undo.
class _RoundTheClockSnapshot {
  _RoundTheClockSnapshot({
    required this.currentIndex,
    required this.currentTurnThrows,
    required this.currentPlayerIndex,
    required this.advancedStepsThisTurn,
    required this.turnHistoryLength,
    required this.winner,
    required this.statusMessage,
  });

  final List<int> currentIndex;
  final List<Throw> currentTurnThrows;
  final int currentPlayerIndex;
  final int advancedStepsThisTurn;
  final int turnHistoryLength;
  final Player? winner;
  final String? statusMessage;
}
