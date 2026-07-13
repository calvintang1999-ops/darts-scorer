import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/match_record.dart';
import '../../services/storage_service.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/app_button.dart';
import '../../widgets/player_card.dart';
import '../../widgets/quit_game_scope.dart';
import '../../widgets/segment_input_pad.dart';
import 'round_the_clock_game.dart';

/// The live Round the Clock scoreboard + input pad. Pass-and-play: the
/// device is handed around and the highlighted card shows whose throw it
/// is. Unlike X01/Cricket/Half It, every player has their own target and
/// their own progress through the sequence, so that lives on each
/// player's own card rather than in a single shared banner.
class RoundTheClockPlayScreen extends StatefulWidget {
  const RoundTheClockPlayScreen({super.key, required this.game});

  final RoundTheClockGame game;

  @override
  State<RoundTheClockPlayScreen> createState() =>
      _RoundTheClockPlayScreenState();
}

class _RoundTheClockPlayScreenState extends State<RoundTheClockPlayScreen> {
  final _playersScrollController = ScrollController();
  bool _matchSaved = false;

  @override
  void initState() {
    super.initState();
    widget.game.addListener(_onGameChanged);
  }

  @override
  void dispose() {
    widget.game.removeListener(_onGameChanged);
    _playersScrollController.dispose();
    super.dispose();
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
          gameName: 'round_the_clock',
          players: game.players,
          turnHistory: List.of(game.turnHistory),
          winnerId: game.winner?.id,
          config: {
            'sequence': game.config.sequence.name,
            'multiplierRule': game.config.multiplierRule.name,
            'startingTarget': game.config.startingTarget,
          },
        ));
  }

  void _rematch() {
    final old = widget.game;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => RoundTheClockPlayScreen(
        game: RoundTheClockGame(players: old.players, config: old.config),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    // ChangeNotifierProvider.value + watch: the whole screen rebuilds
    // whenever the game calls notifyListeners().
    return ChangeNotifierProvider.value(
      value: widget.game,
      child: Consumer<RoundTheClockGame>(
        builder: (context, game, _) {
          final scoreboard = SizedBox(
            height: SizeTokens.playerCardWidth * 1.2,
            child: ListView.builder(
              controller: _playersScrollController,
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
              itemCount: game.players.length,
              itemBuilder: (context, i) => SizedBox(
                width: SizeTokens.playerCardWidth,
                child: PlayerCard(
                  name: game.players[i].name,
                  score: game.currentTargetLabel(i) ?? 'DONE',
                  progress: game.progress(i),
                  isActive: i == game.currentPlayerIndex && !game.isFinished,
                  turnDarts: i == game.currentPlayerIndex
                      ? [for (final t in game.currentTurnThrows) t.label]
                      : const [],
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
                title: Text(game.isFinished
                    ? 'Round the Clock'
                    : '${game.currentPlayer.name} to throw'),
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
                    // where thumbs can reach it. The ConstrainedBox +
                    // scroll view combination means a screen too short to
                    // fit both scrolls instead of overflowing, without
                    // giving up the bottom-pinned layout on every screen
                    // tall enough to not need it.
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

/// One line between scoreboard and pad: the match-win message takes
/// priority, then a transient "advanced!" callout, otherwise darts left.
class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.game});

  final RoundTheClockGame game;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    String text;
    Color color;
    if (game.statusMessage != null) {
      text = game.statusMessage!;
      color = scheme.primary;
    } else if (game.advancedStepsThisTurn > 0) {
      text = 'Advanced ${game.advancedStepsThisTurn}!';
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

  final RoundTheClockGame game;
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
