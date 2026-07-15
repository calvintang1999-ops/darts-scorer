import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/player.dart';
import '../../services/bot_profiles_provider.dart';
import '../../services/players_provider.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/app_button.dart';
import '../../widgets/player_and_bot_picker.dart';
import 'round_the_clock_config.dart';
import 'round_the_clock_game.dart';
import 'round_the_clock_play_screen.dart';

/// Options screen for Round the Clock. Every control starts on the
/// standard default (1-20 plus both bulls, doubles/trebles advance,
/// starting at 1), so quick-starting a game is just "open this screen,
/// tap Start".
class RoundTheClockConfigScreen extends StatefulWidget {
  const RoundTheClockConfigScreen({super.key});

  @override
  State<RoundTheClockConfigScreen> createState() =>
      _RoundTheClockConfigScreenState();
}

class _RoundTheClockConfigScreenState
    extends State<RoundTheClockConfigScreen> {
  static const _maxPlayers = 8;
  static const _minStartingTarget = 1;
  static const _maxStartingTarget = 20;

  // Selected player ids, in the order they were picked = throwing order.
  final List<String> _selectedIds = [];
  bool _selectionInitialised = false;
  final _newPlayerController = TextEditingController();

  RoundTheClockSequence _sequence = RoundTheClockSequence.plusBothBulls;
  RoundTheClockMultiplierRule _multiplierRule =
      RoundTheClockMultiplierRule.multiplierAdvances;
  int _startingTarget = 1;

  @override
  void dispose() {
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

  void _start(List<Player> selectedPlayers) {
    final config = RoundTheClockConfig(
      sequence: _sequence,
      multiplierRule: _multiplierRule,
      startingTarget: _startingTarget,
    );
    final game = RoundTheClockGame(players: selectedPlayers, config: config);
    // pushReplacement so Back from the game returns to Home, not here.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => RoundTheClockPlayScreen(game: game)),
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

    final canStart = selectedPlayers.isNotEmpty;

    Widget sectionTitle(String text) => Padding(
          padding: const EdgeInsets.only(
              top: SpacingTokens.lg, bottom: SpacingTokens.sm),
          child: Text(text.toUpperCase(), style: AppTypography.label),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Round the Clock setup')),
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
          sectionTitle('Sequence'),
          SegmentedButton<RoundTheClockSequence>(
            segments: const [
              ButtonSegment(
                  value: RoundTheClockSequence.numbersOnly,
                  label: Text('1-20 only')),
              ButtonSegment(
                  value: RoundTheClockSequence.plusOuterBull,
                  label: Text('+ Outer bull')),
              ButtonSegment(
                  value: RoundTheClockSequence.plusBothBulls,
                  label: Text('+ Both bulls')),
            ],
            selected: {_sequence},
            onSelectionChanged: (s) => setState(() => _sequence = s.first),
          ),
          sectionTitle('Multiplier rule'),
          SegmentedButton<RoundTheClockMultiplierRule>(
            segments: const [
              ButtonSegment(
                  value: RoundTheClockMultiplierRule.multiplierAdvances,
                  label: Text('Doubles/trebles advance')),
              ButtonSegment(
                  value: RoundTheClockMultiplierRule.singlesOnly,
                  label: Text('Singles only')),
            ],
            selected: {_multiplierRule},
            onSelectionChanged: (s) =>
                setState(() => _multiplierRule = s.first),
          ),
          sectionTitle('Starting number'),
          _CounterRow(
            label: 'Start at',
            value: _startingTarget,
            min: _minStartingTarget,
            max: _maxStartingTarget,
            onChanged: (v) => setState(() => _startingTarget = v),
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

/// A labelled value with +/- steppers, clamped to [min, max].
class _CounterRow extends StatelessWidget {
  const _CounterRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: AppTypography.body)),
        IconButton.filledTonal(
          onPressed: value > min ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove),
        ),
        SizedBox(
          width: SizeTokens.buttonHeight,
          child: Text('$value',
              textAlign: TextAlign.center, style: AppTypography.button),
        ),
        IconButton.filledTonal(
          onPressed: value < max ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
