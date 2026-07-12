import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/player.dart';
import '../../services/players_provider.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/app_button.dart';
import 'halfit_config.dart';
import 'halfit_game.dart';
import 'halfit_play_screen.dart';

/// Options screen for Half It. Every control starts on the standard
/// default (randomized, 10 rounds, starting score 20), so quick-starting
/// a game is just "open this screen, tap Start".
///
/// Only the randomized sequence is exposed here - a fixed, user-picked
/// sequence is fully supported by [HalfItConfig] and [HalfItGame], but
/// picking individual targets needs a dedicated list-builder UI that's
/// out of scope for this first pass.
class HalfItConfigScreen extends StatefulWidget {
  const HalfItConfigScreen({super.key});

  @override
  State<HalfItConfigScreen> createState() => _HalfItConfigScreenState();
}

class _HalfItConfigScreenState extends State<HalfItConfigScreen> {
  static const _maxPlayers = 8;
  static const _minRoundCount = 1;
  static const _maxRoundCount = 20;
  static const _minStartingScore = 1;
  static const _maxStartingScore = 100;

  // Selected player ids, in the order they were picked = throwing order.
  final List<String> _selectedIds = [];
  bool _selectionInitialised = false;
  final _newPlayerController = TextEditingController();

  int _roundCount = 10;
  int _startingScore = 20;

  @override
  void dispose() {
    _newPlayerController.dispose();
    super.dispose();
  }

  void _togglePlayer(Player player) {
    setState(() {
      if (_selectedIds.contains(player.id)) {
        _selectedIds.remove(player.id);
      } else if (_selectedIds.length < _maxPlayers) {
        _selectedIds.add(player.id);
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
    final config = HalfItConfig(
      roundCount: _roundCount,
      startingScore: _startingScore,
    );
    final game = HalfItGame(players: selectedPlayers, config: config);
    // pushReplacement so Back from the game returns to Home, not here.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HalfItPlayScreen(game: game)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playersProvider = context.watch<PlayersProvider>();
    final roster = playersProvider.players;

    // Preselect the first roster player once it has loaded, so a fresh
    // install can quick-start without touching anything.
    if (!_selectionInitialised && roster.isNotEmpty) {
      _selectedIds.add(roster.first.id);
      _selectionInitialised = true;
    }

    // Resolve ids -> players, keeping the tap order (= throwing order).
    final selectedPlayers = _selectedIds
        .map((id) => roster.where((p) => p.id == id).firstOrNull)
        .whereType<Player>()
        .toList();

    final canStart = selectedPlayers.isNotEmpty;

    Widget sectionTitle(String text) => Padding(
          padding: const EdgeInsets.only(
              top: SpacingTokens.lg, bottom: SpacingTokens.sm),
          child: Text(text.toUpperCase(), style: AppTypography.label),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Half It setup')),
      body: ListView(
        padding: const EdgeInsets.all(SpacingTokens.md),
        children: [
          sectionTitle('Players (1-8, tap in throwing order)'),
          Wrap(
            spacing: SpacingTokens.sm,
            runSpacing: SpacingTokens.sm,
            children: [
              for (final player in roster)
                FilterChip(
                  label: Text(
                    _selectedIds.contains(player.id)
                        // Show throwing order on selected chips.
                        ? '${_selectedIds.indexOf(player.id) + 1}. ${player.name}'
                        : player.name,
                  ),
                  selected: _selectedIds.contains(player.id),
                  onSelected: (_) => _togglePlayer(player),
                ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newPlayerController,
                  decoration: const InputDecoration(
                    labelText: 'New player name',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _addPlayer(playersProvider),
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              IconButton.filledTonal(
                onPressed: () => _addPlayer(playersProvider),
                icon: const Icon(Icons.person_add),
              ),
            ],
          ),
          sectionTitle('Rounds'),
          _CounterRow(
            label: 'Rounds (bull is always last)',
            value: _roundCount,
            min: _minRoundCount,
            max: _maxRoundCount,
            onChanged: (v) => setState(() => _roundCount = v),
          ),
          sectionTitle('Starting score'),
          _CounterRow(
            label: 'Starting score',
            value: _startingScore,
            min: _minStartingScore,
            max: _maxStartingScore,
            onChanged: (v) => setState(() => _startingScore = v),
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
