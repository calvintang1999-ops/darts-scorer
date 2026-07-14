import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/match_record.dart';
import '../../services/announcer_service.dart';
import '../../services/dart_counter_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/rotate_board_dialog.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/app_button.dart';
import '../../widgets/player_card.dart';
import '../../widgets/quit_game_scope.dart';
import '../../widgets/segment_input_pad.dart';
import 'x01_game.dart';

/// The live X01 scoreboard + input pad. Pass-and-play: the device is
/// handed around and the highlighted card shows whose throw it is.
class X01PlayScreen extends StatefulWidget {
  const X01PlayScreen({super.key, required this.game});

  final X01Game game;

  @override
  State<X01PlayScreen> createState() => _X01PlayScreenState();
}

class _X01PlayScreenState extends State<X01PlayScreen> {
  final _playersScrollController = ScrollController();
  bool _matchSaved = false;
  // Read once in initState and cached: context.read in dispose() isn't
  // safe, since by then the widget may already be detached from the tree.
  late final AnnouncerService _announcer;
  late final DartCounterService _dartCounter;

  @override
  void initState() {
    super.initState();
    widget.game.addListener(_onGameChanged);
    _announcer = context.read<AnnouncerService>()..listenTo(widget.game);
    _dartCounter = context.read<DartCounterService>()
      ..listenTo(widget.game, onRotateReminderDue: _showRotateReminder);
  }

  @override
  void dispose() {
    widget.game.removeListener(_onGameChanged);
    _announcer.stopListening();
    _dartCounter.stopListening();
    _playersScrollController.dispose();
    super.dispose();
  }

  void _showRotateReminder() {
    if (!mounted) return;
    showRotateBoardDialog(context);
  }

  void _onGameChanged() {
    _scrollToCurrentPlayer();
    _saveIfFinished();
  }

  /// Keeps the active player's card in view when there are more players
  /// than fit on screen.
  void _scrollToCurrentPlayer() {
    if (!_playersScrollController.hasClients) return;
    final offset =
        widget.game.currentPlayerIndex * SizeTokens.playerCardWidth;
    _playersScrollController.animateTo(
      offset.clamp(0, _playersScrollController.position.maxScrollExtent),
      duration: DurationTokens.medium,
      curve: Curves.easeOut,
    );
  }

  void _saveIfFinished() {
    final game = widget.game;
    if (!game.isFinished) {
      // If the win was undone, allow saving again on the next win.
      _matchSaved = false;
      return;
    }
    if (_matchSaved) return;
    _matchSaved = true;
    // Fire-and-forget: recording history must never block play.
    context.read<StorageService>().saveMatch(MatchRecord(
          gameId: game.gameId,
          gameName: 'x01',
          players: game.players,
          turnHistory: List.of(game.turnHistory),
          winnerId: game.winner?.id,
          config: {
            'startingScore': game.config.startingScore,
            'outRule': game.config.outRule.name,
          },
        ));
  }

  void _rematch() {
    final old = widget.game;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => X01PlayScreen(
        game: X01Game(players: old.players, config: old.config),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    // ChangeNotifierProvider.value + watch: the whole screen rebuilds
    // whenever the game calls notifyListeners().
    return ChangeNotifierProvider.value(
      value: widget.game,
      child: Consumer<X01Game>(
        builder: (context, game, _) {
          final showLegsSets =
              game.config.legsPerSet > 1 || game.config.setsToWin > 1;

          final scoreboard = SizedBox(
            height: SizeTokens.playerCardWidth * 1.2,
            child: ListView.builder(
              controller: _playersScrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.sm),
              itemCount: game.players.length,
              itemBuilder: (context, i) => SizedBox(
                width: SizeTokens.playerCardWidth,
                child: PlayerCard(
                  name: game.players[i].name,
                  score: '${game.scores[i]}',
                  isActive: i == game.currentPlayerIndex && !game.isFinished,
                  turnDarts: i == game.currentPlayerIndex
                      ? [for (final t in game.currentTurnThrows) t.label]
                      : const [],
                  detail: showLegsSets
                      ? 'Legs ${game.legsWon[i]} · Sets ${game.setsWon[i]}'
                      : null,
                ),
              ),
            ),
          );

          final inputArea = game.isFinished
              ? _WinnerPanel(game: game, onRematch: _rematch)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StatusBar(game: game),
                    SegmentInputPad(
                      player: game.currentPlayer,
                      gameId: game.gameId,
                      onThrow: game.applyThrow,
                    ),
                  ],
                );

          // Nothing to lose by leaving a fresh game or one already won.
          final confirmBeforeLeaving = !game.isFinished &&
              (game.turnHistory.isNotEmpty ||
                  game.currentTurnThrows.isNotEmpty);

          return QuitGameScope(
            confirmBeforeLeaving: confirmBeforeLeaving,
            child: Scaffold(
              appBar: AppBar(
                title: Text('${game.config.startingScore} · '
                    '${game.currentPlayer.name} to throw'),
                actions: [
                  // Undo lives in the app bar so it is ALWAYS on screen,
                  // in both orientations, even on the winner panel.
                  IconButton(
                    onPressed: game.canUndo ? game.undo : null,
                    icon: const Icon(Icons.undo),
                    tooltip: 'Undo last dart',
                  ),
                ],
              ),
              body: SafeArea(
                child: OrientationBuilder(
                  builder: (context, orientation) {
                    if (orientation == Orientation.landscape) {
                      // Landscape: scores on the left, pad on the right.
                      return Row(
                        children: [
                          Expanded(child: scoreboard),
                          Expanded(
                            child: SingleChildScrollView(
                              padding:
                                  const EdgeInsets.all(SpacingTokens.sm),
                              child: inputArea,
                            ),
                          ),
                        ],
                      );
                    }
                    // Portrait: scores above, pad pinned to the bottom
                    // where thumbs can reach it on a normal phone. The
                    // ConstrainedBox + scroll view combination means a
                    // screen too short to fit both scrolls instead of
                    // overflowing, without giving up the bottom-pinned
                    // layout on every screen tall enough to not need it.
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                minHeight: constraints.maxHeight),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                scoreboard,
                                Padding(
                                  padding:
                                      const EdgeInsets.all(SpacingTokens.sm),
                                  child: inputArea,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// One line between scoreboard and pad: bust/leg messages take priority,
/// otherwise the checkout suggestion, otherwise darts remaining.
class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.game});

  final X01Game game;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final checkout = game.checkoutSuggestion;

    String text;
    Color color;
    if (game.statusMessage != null) {
      text = game.statusMessage!;
      color = game.statusMessage!.startsWith('Bust')
          ? ColorTokens.danger
          : scheme.primary;
    } else if (checkout != null) {
      text = 'Checkout: $checkout';
      color = scheme.primary;
    } else {
      text = '${game.dartsLeftInTurn} dart'
          '${game.dartsLeftInTurn == 1 ? '' : 's'} left';
      color = scheme.onSurfaceVariant;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
      child: Text(
        text,
        style: AppTypography.button.copyWith(color: color),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Shown in place of the input pad once the match is over.
class _WinnerPanel extends StatelessWidget {
  const _WinnerPanel({required this.game, required this.onRematch});

  final X01Game game;
  final VoidCallback onRematch;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.emoji_events,
            size: SizeTokens.playTapTarget, color: scheme.primary),
        Text(
          '${game.winner?.name} wins!',
          style: AppTypography.scoreLarge.copyWith(color: scheme.primary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: SpacingTokens.lg),
        AppButton(
            label: 'Rematch', icon: Icons.replay, onPressed: onRematch),
        const SizedBox(height: SpacingTokens.sm),
        AppButton(
          label: 'Back to games',
          icon: Icons.home,
          filled: false,
          onPressed: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ],
    );
  }
}
