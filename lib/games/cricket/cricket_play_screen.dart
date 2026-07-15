import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/dart_position.dart';
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
import '../../services/stats/cricket_stats.dart';
import '../../services/storage_service.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/app_button.dart';
import '../../widgets/match_summary_card.dart';
import '../../widgets/quit_game_scope.dart';
import '../../widgets/rotate_board_dialog.dart';
import '../../widgets/score_display.dart';
import '../../widgets/segment_input_pad.dart';
import '../../widgets/stat_tile.dart';
import 'cricket_brain.dart';
import 'cricket_config.dart';
import 'cricket_game.dart';

/// The live Cricket scoreboard + input pad. Pass-and-play: the device is
/// handed around and the highlighted column shows whose throw it is.
class CricketPlayScreen extends StatefulWidget {
  const CricketPlayScreen({super.key, required this.game});

  final CricketGame game;

  @override
  State<CricketPlayScreen> createState() => _CricketPlayScreenState();
}

class _CricketPlayScreenState extends State<CricketPlayScreen> {
  bool _matchSaved = false;
  // Read once in initState and cached: context.read in dispose() isn't
  // safe, since by then the widget may already be detached from the tree.
  late final AnnouncerService _announcer;
  late final DartCounterService _dartCounter;
  late final BotTurnScreenController _botTurns;

  // One shared brain (all presets use the default strategy) and one arm
  // per bot participant (accuracy - sigma - can differ preset to preset).
  final _brain = const CricketBrain();
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
    final myMarks = {for (final n in game.numbers) n: game.marks[n]![playerIndex]};
    final opponentMarks = [
      for (var i = 0; i < game.players.length; i++)
        if (i != playerIndex)
          {for (final n in game.numbers) n: game.marks[n]![i]}
    ];
    final opponentPoints = [
      for (var i = 0; i < game.players.length; i++)
        if (i != playerIndex) game.scores[i]
    ];

    final decision = _brain.nextAim(
      numbers: game.numbers,
      myMarks: myMarks,
      opponentMarks: opponentMarks,
      myPoints: game.scores[playerIndex],
      opponentPoints: opponentPoints,
      mode: game.config.mode,
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

  void _showRotateReminder() {
    if (!mounted) return;
    showRotateBoardDialog(context);
  }

  void _onGameChanged() {
    _botTurns.onGameChanged();
    _saveIfFinished();
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
      builder: (_) => CricketPlayScreen(
        game: CricketGame(players: old.players, config: old.config),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    // ChangeNotifierProvider.value + watch: the whole screen rebuilds
    // whenever the game calls notifyListeners().
    return ChangeNotifierProvider.value(
      value: widget.game,
      child: Consumer<CricketGame>(
        builder: (context, game, _) {
          // Scrollable both ways: horizontally for many players, and
          // vertically too since landscape phones don't have room for
          // every number row otherwise.
          final board = SingleChildScrollView(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
              child: _CricketBoard(game: game),
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
                title: Text(
                  '${game.config.mode == CricketMode.cutthroat ? 'Cutthroat' : 'Cricket'} '
                  '· ${game.currentPlayer.name} to throw',
                ),
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
                      // Landscape: board on the left, pad on the right.
                      return Row(
                        children: [
                          Expanded(child: board),
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
                    // Portrait: board above, pad pinned to the bottom
                    // where thumbs can reach it. The pad renders at its
                    // natural size so every key stays fully tappable;
                    // the board gets whatever's left and scrolls
                    // internally if a seven-number board doesn't fit a
                    // short phone screen.
                    return Column(
                      children: [
                        Expanded(child: board),
                        Padding(
                          padding: const EdgeInsets.all(SpacingTokens.sm),
                          child: inputArea,
                        ),
                      ],
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

/// The numbers-by-players grid: one row per number, one column per player,
/// marks shown as the classic cricket glyphs (/, X, closed), points along
/// the bottom.
class _CricketBoard extends StatelessWidget {
  const _CricketBoard({required this.game});

  final CricketGame game;

  static const double _numberColumnWidth = 56;
  static const double _playerColumnWidth = 80;

  String _label(int number) => number == bullSegment ? 'BULL' : '$number';

  String _markGlyph(int marks) {
    switch (marks) {
      case 0:
        return '';
      case 1:
        return '/';
      case 2:
        return 'X';
      default:
        return '⊗'; // closed - circled X
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Widget cell({
      required Widget child,
      required bool isActive,
    }) {
      return Container(
        color: isActive ? scheme.primaryContainer : null,
        padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
        alignment: Alignment.center,
        child: child,
      );
    }

    Widget headerCell(int playerIndex) {
      final isActive =
          playerIndex == game.currentPlayerIndex && !game.isFinished;
      return SizedBox(
        width: _playerColumnWidth,
        child: cell(
          isActive: isActive,
          child: Text(
            game.players[playerIndex].name.toUpperCase(),
            style: AppTypography.label.copyWith(
              color: isActive ? scheme.onPrimaryContainer : scheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    Widget markCell(int number, int playerIndex) {
      final isActive =
          playerIndex == game.currentPlayerIndex && !game.isFinished;
      return SizedBox(
        width: _playerColumnWidth,
        child: cell(
          isActive: isActive,
          child: Text(
            _markGlyph(game.marks[number]![playerIndex]),
            style: AppTypography.button.copyWith(
              color: isActive ? scheme.onPrimaryContainer : scheme.onSurface,
            ),
          ),
        ),
      );
    }

    Widget scoreCell(int playerIndex) {
      final isActive =
          playerIndex == game.currentPlayerIndex && !game.isFinished;
      return SizedBox(
        width: _playerColumnWidth,
        child: cell(
          isActive: isActive,
          child: ScoreDisplay(
            value: '${game.scores[playerIndex]}',
            color: isActive ? scheme.onPrimaryContainer : scheme.onSurface,
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: _numberColumnWidth),
            for (var i = 0; i < game.players.length; i++) headerCell(i),
          ],
        ),
        for (final number in game.numbers)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: _numberColumnWidth,
                child: Text(
                  _label(number),
                  textAlign: TextAlign.center,
                  style: AppTypography.body,
                ),
              ),
              for (var i = 0; i < game.players.length; i++)
                markCell(number, i),
            ],
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: _numberColumnWidth),
            for (var i = 0; i < game.players.length; i++) scoreCell(i),
          ],
        ),
      ],
    );
  }
}

/// The same match-record shape saved to storage, built fresh (and not
/// persisted) whenever the winner panel wants it for its stat tiles - one
/// definition, used both places, so they can never drift apart.
MatchRecord _buildMatchRecord(CricketGame game) => MatchRecord(
      gameId: game.gameId,
      gameName: 'cricket',
      players: game.players,
      turnHistory: List.of(game.turnHistory),
      winnerId: game.winner?.id,
      config: {
        'lowNumber': game.config.lowNumber,
        'includeBull': game.config.includeBull,
      },
    );

/// One line between board and pad: the match-win / White Horse message
/// (both set on the model) takes priority, then the plain closed-number
/// celebration, otherwise darts remaining this turn.
class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.game});

  final CricketGame game;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    String text;
    Color color;
    if (game.statusMessage != null) {
      text = game.statusMessage!;
      color = scheme.primary;
    } else if (game.closedThreeThisTurn) {
      text = 'Closed!';
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

  final CricketGame game;
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
              tiles: _cricketSummaryTiles(player, record),
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

/// This match's headline Cricket numbers for one player - reuses the same
/// calculator the Stats tab uses, just fed a single-match list.
List<StatTile> _cricketSummaryTiles(Player player, MatchRecord record) {
  final stats = CricketStats.compute(player, [record]);
  return [
    StatTile(
      label: 'Marks per round',
      value: stats.marksPerRound?.toStringAsFixed(1),
    ),
    StatTile(
      label: 'Most marks in a round',
      value: stats.mostMarksInRound?.toString(),
    ),
    StatTile(
      label: 'Bulls per round',
      value: stats.bullsPerRound?.toStringAsFixed(1),
    ),
  ];
}
