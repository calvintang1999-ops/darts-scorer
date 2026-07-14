import 'dart:async';

import 'package:flutter/foundation.dart';

import 'game_event.dart';
import 'player.dart';
import 'throw.dart';
import 'unique_id.dart';

/// The base class every game mode extends (X01 now; Cricket, Shanghai,
/// training routines, etc. later).
///
/// It is a [ChangeNotifier] so play screens can watch it with Provider:
/// subclasses call [notifyListeners] after every state change and the UI
/// rebuilds automatically.
///
/// The base class owns the parts every darts game shares - who is playing,
/// whose turn it is, and the full history of completed turns. Rules
/// (scoring, busts, winning) live entirely in subclasses via [applyThrow]
/// and [undo].
abstract class DartsGame extends ChangeNotifier {
  DartsGame({required this.players, String? gameId})
      : gameId = gameId ?? generateLocalId();

  /// Identifies this match; stamped onto every Throw.
  final String gameId;

  /// Play order is the order of this list.
  final List<Player> players;

  /// Every completed turn, oldest first. Subclasses append to this as
  /// turns finish. This is the raw material for the stats phase.
  final List<Turn> turnHistory = [];

  /// Index into [players] of whoever is throwing now.
  int currentPlayerIndex = 0;

  Player get currentPlayer => players[currentPlayerIndex];

  /// Announcer-worthy moments - a finished visit, a checkout, a match win.
  /// [notifyListeners] fires on every state change so the UI can redraw;
  /// this stream fires only on these specific moments, worded by whichever
  /// game emits them. The voice announcer is the only intended listener,
  /// and it lives entirely outside this class - subclasses just describe
  /// what happened via [emitEvent] and never import or know about it.
  Stream<GameEvent> get events => _eventsController.stream;
  final _eventsController = StreamController<GameEvent>.broadcast();

  /// Subclasses call this right after a visit/checkout/win to describe it
  /// in their own scoring language.
  @protected
  void emitEvent(GameEventKind kind, Player player, String message) {
    _eventsController.add(GameEvent(kind: kind, player: player, message: message));
  }

  /// Fires exactly once for every dart thrown, in every game, regardless
  /// of what it scored or which game is being played. This is the hook for
  /// features that care about raw dart count but nothing about any one
  /// game's rules - currently just the lifetime dart counter that reminds
  /// you to rotate the board every so many darts.
  Stream<void> get dartThrown => _dartThrownController.stream;
  final _dartThrownController = StreamController<void>.broadcast();

  @override
  void dispose() {
    _eventsController.close();
    _dartThrownController.close();
    super.dispose();
  }

  /// Every play screen calls this once per dart. It fires [dartThrown] and
  /// then hands off to [scoreThrow], which is where each game's actual
  /// rules live - that split is what lets a cross-game feature (the dart
  /// counter) hook in centrally instead of every game remembering to
  /// report it.
  void applyThrow(Throw dartThrow) {
    _dartThrownController.add(null);
    scoreThrow(dartThrow);
  }

  /// Game-specific scoring rules. Implementations should fill in the
  /// throw's `resultingScoreDelta`, update scores, handle turn changes,
  /// and call [notifyListeners].
  @protected
  void scoreThrow(Throw dartThrow);

  /// Undo the most recent dart, even across turn boundaries.
  void undo();

  /// Whether there is anything to undo (used to enable/disable the button).
  bool get canUndo;

  /// True once the match has been won.
  bool get isFinished;

  /// The winner, or null while the game is still going.
  Player? get winner;
}
