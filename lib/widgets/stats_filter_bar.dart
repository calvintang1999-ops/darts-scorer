import 'package:flutter/material.dart';

import '../models/player.dart';
import '../services/stats/stats_filter.dart';
import '../theme/tokens.dart';

/// Player + game-type + date-range picker, shared by the Stats and Match
/// History screens. A plain controlled widget - the parent screen owns
/// the actual filter state and passes it back down.
class StatsFilterBar extends StatelessWidget {
  const StatsFilterBar({
    super.key,
    required this.players,
    required this.selectedPlayer,
    required this.onPlayerChanged,
    required this.selectedGameName,
    required this.onGameNameChanged,
    required this.range,
    required this.onRangeChanged,
  });

  final List<Player> players;
  final Player? selectedPlayer;
  final ValueChanged<Player?> onPlayerChanged;

  /// Null means "every game type".
  final String? selectedGameName;
  final ValueChanged<String?> onGameNameChanged;

  final DateRange? range;
  final ValueChanged<DateRange?> onRangeChanged;

  /// The four game types stats are computed for - deliberately not the
  /// full game registry, which also lists not-yet-playable stubs.
  static const _gameOptions = <(String?, String)>[
    (null, 'All games'),
    ('x01', 'X01'),
    ('cricket', 'Cricket'),
    ('round_the_clock', 'Round the Clock'),
    ('halfit', 'Half It'),
  ];

  Future<void> _pickRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      initialDateRange:
          range == null ? null : DateTimeRange(start: range!.start, end: range!.end),
    );
    if (picked != null) {
      onRangeChanged(DateRange(start: picked.start, end: picked.end));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (players.isNotEmpty)
          DropdownButton<Player>(
            value: selectedPlayer,
            isExpanded: true,
            items: [
              for (final player in players)
                DropdownMenuItem(value: player, child: Text(player.name)),
            ],
            onChanged: onPlayerChanged,
          ),
        const SizedBox(height: SpacingTokens.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final (gameName, label) in _gameOptions)
                Padding(
                  padding: const EdgeInsets.only(right: SpacingTokens.xs),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: selectedGameName == gameName,
                    onSelected: (_) => onGameNameChanged(gameName),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: SpacingTokens.sm),
        Row(
          children: [
            TextButton.icon(
              onPressed: () => _pickRange(context),
              icon: const Icon(Icons.date_range),
              label: Text(range == null
                  ? 'All time'
                  : '${_format(range!.start)} - ${_format(range!.end)}'),
            ),
            if (range != null)
              IconButton(
                icon: const Icon(Icons.clear),
                tooltip: 'Clear date range',
                onPressed: () => onRangeChanged(null),
              ),
          ],
        ),
      ],
    );
  }

  static String _format(DateTime date) =>
      '${date.month}/${date.day}/${date.year}';
}
