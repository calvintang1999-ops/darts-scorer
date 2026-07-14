import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/match_record.dart';
import '../../services/announcer_service.dart';
import '../../services/storage_service.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/app_button.dart';
import '../../widgets/player_card.dart';
import '../../widgets/quit_game_scope.dart';
import '../../widgets/segment_input_pad.dart';
import 'halfit_game.dart';

/// The live Half It scoreboard + input pad. Pass-and-play: the device is
/// handed around and the highlighted card shows whose throw it is.
class HalfItPlayScreen extends StatefulWidget {
  const HalfItPlayScreen({super.key, required this.game});

  final HalfItGame game;

  @override
  State<HalfItPlayScreen> createState() => _HalfItPlayScreenState();
}

class _HalfItPlayScreenState extends State<HalfItPlayScreen> {
  final _playersScrollController = ScrollController();
  bool _matchSaved = false;
  // Read once in initState and cached: context.read in dispose() isn't
  // safe, since by then the widget may already be detached from the tree.
  late final AnnouncerService _announcer;

  @override
  void initState() {
    super.initState();
    widget.game.addListener(_onGameChanged);
    _announcer = context.read<AnnouncerService>()..listenTo(widget.game);
  }

  @override
  void dispose() {
    widget.game.removeListener(_onGameChanged);
    _announcer.stopListening();
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
          gameName: 'halfit',
          players: game.players,
          turnHistory: List.of(game.turnHistory),
          winnerId: game.winner?.id,
          config: {'startingScore': game.config.startingScore},
        ));
  }

  void _rematch() {
    final old = widget.game;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => HalfItPlayScreen(
        game: HalfItGame(players: old.players, config: old.config),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    // ChangeNotifierProvider.value + watch: the whole screen rebuilds
    // whenever the game calls notifyListeners().
    return ChangeNotifierProvider.value(
      value: widget.game,
      child: Consumer<HalfItGame>(
        builder: (context, game, _) {
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
                ),
              ),
            ),
          );

          // The round's target on its own banner, big enough to read from
          // the oche - the app bar title alone is too small and too easy
          // to truncate on a narrow phone. Round progress lives here too
          // instead of repeating on every player's card.
          final topContent = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!game.isFinished) _TargetBanner(game: game),
              scoreboard,
            ],
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
                    ? 'Half It'
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
                      // Landscape: banner across the top, scores on the
                      // left, pad on the right.
                      return Column(
                        children: [
                          if (!game.isFinished) _TargetBanner(game: game),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(child: scoreboard),
                                Expanded(
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.all(
                                        SpacingTokens.sm),
                                    child: inputArea,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                    // Portrait: banner + scores above, pad pinned to the
                    // bottom where thumbs can reach it on a normal phone.
                    // The ConstrainedBox + scroll view combination means
                    // a screen too short to fit both scrolls instead of
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
                                topContent,
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

/// The current round's target, on its own banner - big enough to read
/// standing back from the board, not buried in the app bar title.
class _TargetBanner extends StatelessWidget {
  const _TargetBanner({required this.game});

  final HalfItGame game;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      color: scheme.primaryContainer,
      padding: const EdgeInsets.symmetric(
          vertical: SpacingTokens.sm, horizontal: SpacingTokens.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'ROUND ${game.currentRoundIndex + 1} OF ${game.targets.length}',
            style: AppTypography.label.copyWith(
              color: scheme.onPrimaryContainer.withValues(alpha: 0.7),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              game.currentTarget.label,
              style: AppTypography.scoreLarge
                  .copyWith(color: scheme.onPrimaryContainer),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// One line between scoreboard and pad: the round's result takes
/// priority (in red when the score was halved), otherwise darts left.
class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.game});

  final HalfItGame game;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    String text;
    Color color;
    if (game.statusMessage != null) {
      text = game.statusMessage!;
      color = game.wasHalvedThisRound ? ColorTokens.danger : scheme.primary;
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

  final HalfItGame game;
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
