import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/player.dart';
import '../../services/bot_profiles_provider.dart';
import '../../services/players_provider.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/app_button.dart';
import '../../widgets/player_and_bot_picker.dart';
import 'cricket_config.dart';
import 'cricket_game.dart';
import 'cricket_play_screen.dart';

/// Options screen for Cricket. Every control starts on the standard
/// default (15-20 plus bull, standard scoring), so quick-starting a game
/// is just "open this screen, tap Start".
class CricketConfigScreen extends StatefulWidget {
  const CricketConfigScreen({super.key});

  @override
  State<CricketConfigScreen> createState() => _CricketConfigScreenState();
}

class _CricketConfigScreenState extends State<CricketConfigScreen> {
  static const _maxPlayers = 8;
  static const _minLowNumber = 10;
  static const _maxLowNumber = 20;

  // Selected player ids, in the order they were picked = throwing order.
  final List<String> _selectedIds = [];
  bool _selectionInitialised = false;
  final _newPlayerController = TextEditingController();

  int _lowNumber = 15;
  bool _includeBull = true;
  CricketMode _mode = CricketMode.standard;

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
    final config = CricketConfig(
      lowNumber: _lowNumber,
      includeBull: _includeBull,
      mode: _mode,
    );
    final game = CricketGame(players: selectedPlayers, config: config);
    // pushReplacement so Back from the game returns to Home, not here.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => CricketPlayScreen(game: game)),
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
      appBar: AppBar(title: const Text('Cricket setup')),
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
          sectionTitle('Numbers'),
          _CounterRow(
            label: 'From',
            value: _lowNumber,
            min: _minLowNumber,
            max: _maxLowNumber,
            onChanged: (v) => setState(() => _lowNumber = v),
          ),
          Text(
            '$_lowNumber to 20${_includeBull ? ' plus bull' : ''}',
            style: AppTypography.body,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Include bull (25)'),
            value: _includeBull,
            onChanged: (v) => setState(() => _includeBull = v),
          ),
          sectionTitle('Mode'),
          SegmentedButton<CricketMode>(
            segments: const [
              ButtonSegment(
                  value: CricketMode.standard, label: Text('Standard')),
              ButtonSegment(
                  value: CricketMode.cutthroat, label: Text('Cutthroat')),
            ],
            selected: {_mode},
            onSelectionChanged: (s) => setState(() => _mode = s.first),
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
