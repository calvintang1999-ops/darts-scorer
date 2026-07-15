import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/match_record.dart';
import '../../models/player.dart';
import '../../models/throw.dart';
import '../../services/announcer_service.dart';
import '../../services/bot/bot_arm.dart';
import '../../services/bot/bot_turn_screen_controller.dart';
import '../../services/bot/gaussian_arm.dart';
import '../../services/bot/throw_context.dart';
import '../../services/bot_profiles_provider.dart';
import '../../services/dart_counter_service.dart';
import '../../services/stats/round_the_clock_stats.dart';
import '../../services/storage_service.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/app_button.dart';
import '../../widgets/match_summary_card.dart';
import '../../widgets/player_card.dart';
import '../../widgets/quit_game_scope.dart';
import '../../widgets/rotate_board_dialog.dart';
import '../../widgets/segment_input_pad.dart';
import '../../widgets/stat_tile.dart';
import 'round_the_clock_brain.dart';
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
  // Read once in initState and cached: context.read in dispose() isn't
  // safe, since by then the widget may already be detached from the tree.
  late final AnnouncerService _announcer;
  late final DartCounterService _dartCounter;
  late final BotTurnScreenController _botTurns;

  // One shared brain (there's no strategy to tune here) and one arm per
  // bot participant (accuracy - sigma - can differ preset to preset).
  final _brain = const RoundTheClockBrain();
  final Map<String, BotArm> _arms = {};
  int _dartsThrownInMatch = 0;

  @override
  void initState() {
    super.initState();
    widget.game.addListener(_onGameChanged);
    _announcer = context.read<AnnouncerService>()..listenTo(widget.game);
    _dartCounter = context.read<DartCounterService>()
      ..listenTo(widget.game, onRotateReminderDue: _showRotateReminder);
    _buildBotArms();
    _botTurns = BotTurnScreenController(
      game: widget.game,
      isCurrentPlayerBot: () => widget.game.currentPlayer.botProfileId != null,
      buildNextThrow: _buildNextBotThrow,
    );
  }

  @override
  void dispose() {
    _botTurns.dispose();
    widget.game.removeListener(_onGameChanged);
    _announcer.stopListening();
    _dartCounter.stopListening();
    _playersScrollController.dispose();
    super.dispose();
  }

  /// One [GaussianArm] per bot participant, built once from that bot's
  /// profile (for its sigma) - looked up by botProfileId, not player id,
  /// since BotProfilesProvider only knows about profiles, not this
  /// match's participants.
  void _buildBotArms() {
    final profiles = context.read<BotProfilesProvider>().profiles;
    for (final player in widget.game.players) {
      final profileId = player.botProfileId;
      if (profileId == null) continue;
      final profile = profiles.where((p) => p.id == profileId).firstOrNull;
      if (profile == null) continue;
      _arms[player.id] = GaussianArm(sigmaMm: profile.sigmaMm, random: Random());
    }
  }

  Throw _buildNextBotThrow() {
    final game = widget.game;
    final playerIndex = game.currentPlayerIndex;
    final player = game.currentPlayer;
    final stop = game.stops[game.currentIndex[playerIndex]];
    final decision = _brain.nextAim(
      stop: stop,
      multiplierRule: game.config.multiplierRule,
    );
    final throwContext = ThrowContext.forAim(
      decision.aimPoint,
      isCheckoutAttempt: decision.isCheckoutAttempt,
      dartIndexInTurn: game.currentTurnThrows.length,
      dartIndexInMatch: _dartsThrownInMatch++,
    );
    return _arms[player.id]!.throwDart(decision.aimPoint, throwContext,
        player: player, gameId: game.gameId);
  }

  void _onGameChanged() {
    _botTurns.onGameChanged();
    _scrollToCurrentPlayer();
    _saveIfFinished();
  }

  void _showRotateReminder() {
    if (!mounted) return;
    showRotateBoardDialog(context);
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
    context.read<StorageService>().saveMatch(_buildMatchRecord(game));
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
                      enabled: game.currentPlayer.botProfileId == null,
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

/// The same match-record shape saved to storage, built fresh (and not
/// persisted) whenever the winner panel wants it for its stat tiles - one
/// definition, used both places, so they can never drift apart.
MatchRecord _buildMatchRecord(RoundTheClockGame game) => MatchRecord(
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
    );

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
    // This match isn't in storage yet at first build (the save happens in
    // a listener callback), so the record used for stats is built fresh
    // here rather than read back - see _buildMatchRecord's doc comment.
    final record = _buildMatchRecord(game);
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
        MatchSummaryCard(sections: [
          for (final player in game.players)
            PlayerMatchSummary(
              playerName: player.name,
              tiles: _roundTheClockSummaryTiles(player, record),
            ),
        ]),
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

/// This match's headline Round the Clock numbers for one player - reuses
/// the same calculator the Stats tab uses, just fed a single-match list.
List<StatTile> _roundTheClockSummaryTiles(Player player, MatchRecord record) {
  final stats = RoundTheClockStats.compute(player, [record]);
  return [
    StatTile(
      label: 'Hit rate',
      value: stats.overallHitRate == null
          ? null
          : '${stats.overallHitRate!.toStringAsFixed(0)}%',
    ),
    StatTile(
      label: 'Favourite number',
      value: stats.favouriteNumber == null
          ? null
          : (stats.favouriteNumber == 25 ? 'Bull' : '${stats.favouriteNumber}'),
    ),
  ];
}
