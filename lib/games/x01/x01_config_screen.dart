import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/player.dart';
import '../../services/bot_profiles_provider.dart';
import '../../services/players_provider.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/app_button.dart';
import '../../widgets/player_and_bot_picker.dart';
import 'x01_config.dart';
import 'x01_game.dart';
import 'x01_play_screen.dart';

/// Options screen for X01. Every control starts on the standard default
/// (501, straight in, double out, single leg), so quick-starting a game is
/// just "open this screen, tap Start".
class X01ConfigScreen extends StatefulWidget {
  const X01ConfigScreen({super.key});

  @override
  State<X01ConfigScreen> createState() => _X01ConfigScreenState();
}

class _X01ConfigScreenState extends State<X01ConfigScreen> {
  static const _presetScores = [301, 501, 701];
  static const _maxPlayers = 8;

  // Selected player ids, in the order they were picked = throwing order.
  final List<String> _selectedIds = [];
  bool _selectionInitialised = false;

  int _startingScore = 501;
  bool _customScore = false;
  final _customScoreController = TextEditingController();
  final _newPlayerController = TextEditingController();

  X01InRule _inRule = X01InRule.open;
  X01OutRule _outRule = X01OutRule.double;
  int _legsPerSet = 1;
  int _setsToWin = 1;

  @override
  void dispose() {
    _customScoreController.dispose();
    _newPlayerController.dispose();
    super.dispose();
  }

  void _toggleId(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else if (_selectedIds.length < _maxPlayers) {
        _selectedIds.add(id);
      }
    });
  }

  void _addPlayer(PlayersProvider provider) {
    final name = _newPlayerController.text.trim();
    if (name.isEmpty) return;
    provider.addPlayer(name);
    _newPlayerController.clear();
  }

  int? get _effectiveScore {
    if (!_customScore) return _startingScore;
    final parsed = int.tryParse(_customScoreController.text);
    // Custom scores must end in 01 by convention? No - any value >= 2 works,
    // but 2+ keeps the game finishable under every out-rule.
    return (parsed != null && parsed >= 2) ? parsed : null;
  }

  void _start(List<Player> selectedPlayers) {
    final config = X01Config(
      startingScore: _effectiveScore!,
      inRule: _inRule,
      outRule: _outRule,
      legsPerSet: _legsPerSet,
      setsToWin: _setsToWin,
    );
    final game = X01Game(players: selectedPlayers, config: config);
    // pushReplacement so Back from the game returns to Home, not here.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => X01PlayScreen(game: game)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playersProvider = context.watch<PlayersProvider>();
    final roster = playersProvider.players;
    final botProfiles = context.watch<BotProfilesProvider>().profiles;

    // Preselect the first roster player once it has loaded, so a fresh
    // install can quick-start without touching anything.
    if (!_selectionInitialised && roster.isNotEmpty) {
      _selectedIds.add(roster.first.id);
      _selectionInitialised = true;
    }

    // Resolve ids -> players (human or bot), keeping tap order (=
    // throwing order).
    final selectedPlayers = _selectedIds
        .map((id) => resolvePlayerOrBot(id, roster, botProfiles))
        .whereType<Player>()
        .toList();

    final canStart = selectedPlayers.isNotEmpty && _effectiveScore != null;

    Widget sectionTitle(String text) => Padding(
          padding: const EdgeInsets.only(
              top: SpacingTokens.lg, bottom: SpacingTokens.sm),
          child: Text(text.toUpperCase(), style: AppTypography.label),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('X01 setup')),
      body: ListView(
        padding: const EdgeInsets.all(SpacingTokens.md),
        children: [
          PlayerAndBotPicker(
            roster: roster,
            botProfiles: botProfiles,
            selectedIds: _selectedIds,
            onToggle: _toggleId,
            maxPlayers: _maxPlayers,
            newPlayerController: _newPlayerController,
            onAddPlayer: () => _addPlayer(playersProvider),
          ),
          sectionTitle('Starting score'),
          SegmentedButton<int>(
            // 0 stands in for "custom" in the segmented control.
            segments: [
              for (final score in _presetScores)
                ButtonSegment(value: score, label: Text('$score')),
              const ButtonSegment(value: 0, label: Text('Custom')),
            ],
            selected: {_customScore ? 0 : _startingScore},
            onSelectionChanged: (selection) {
              setState(() {
                if (selection.first == 0) {
                  _customScore = true;
                } else {
                  _customScore = false;
                  _startingScore = selection.first;
                }
              });
            },
          ),
          if (_customScore)
            Padding(
              padding: const EdgeInsets.only(top: SpacingTokens.sm),
              child: TextField(
                controller: _customScoreController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Custom starting score',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          sectionTitle('In rule (how a leg starts)'),
          SegmentedButton<X01InRule>(
            segments: const [
              ButtonSegment(value: X01InRule.open, label: Text('Open')),
              ButtonSegment(value: X01InRule.double, label: Text('Double')),
              ButtonSegment(value: X01InRule.master, label: Text('Master')),
            ],
            selected: {_inRule},
            onSelectionChanged: (s) => setState(() => _inRule = s.first),
          ),
          sectionTitle('Out rule (how a leg is won)'),
          SegmentedButton<X01OutRule>(
            segments: const [
              ButtonSegment(value: X01OutRule.single, label: Text('Single')),
              ButtonSegment(value: X01OutRule.double, label: Text('Double')),
              ButtonSegment(value: X01OutRule.master, label: Text('Master')),
            ],
            selected: {_outRule},
            onSelectionChanged: (s) => setState(() => _outRule = s.first),
          ),
          sectionTitle('Match length'),
          _CounterRow(
            label: 'Legs per set',
            value: _legsPerSet,
            onChanged: (v) => setState(() => _legsPerSet = v),
          ),
          _CounterRow(
            label: 'Sets to win',
            value: _setsToWin,
            onChanged: (v) => setState(() => _setsToWin = v),
          ),
          const SizedBox(height: SpacingTokens.xl),
          AppButton(
            label: 'Start game',
            icon: Icons.play_arrow,
            onPressed: canStart ? () => _start(selectedPlayers) : null,
          ),
          const SizedBox(height: SpacingTokens.xl),
        ],
      ),
    );
  }
}

/// A labelled value with +/- steppers, clamped to 1 or more.
class _CounterRow extends StatelessWidget {
  const _CounterRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: AppTypography.body)),
        IconButton.filledTonal(
          onPressed: value > 1 ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove),
        ),
        SizedBox(
          width: SizeTokens.buttonHeight,
          child: Text('$value',
              textAlign: TextAlign.center, style: AppTypography.button),
        ),
        IconButton.filledTonal(
          onPressed: () => onChanged(value + 1),
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
