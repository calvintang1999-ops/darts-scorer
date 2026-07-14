import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/match_record.dart';
import '../models/player.dart';
import '../services/players_provider.dart';
import '../services/stats/game_labels.dart';
import '../services/stats/stats_filter.dart';
import '../services/storage_service.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/stats_filter_bar.dart';
import 'match_detail_screen.dart';

/// A browsable, filterable list of a player's past matches. Tap one to
/// see its legs and every throw (MatchDetailScreen).
class MatchHistoryScreen extends StatefulWidget {
  const MatchHistoryScreen({super.key});

  @override
  State<MatchHistoryScreen> createState() => _MatchHistoryScreenState();
}

class _MatchHistoryScreenState extends State<MatchHistoryScreen> {
  Player? _selectedPlayer;
  String? _selectedGameName;
  DateRange? _range;

  List<MatchRecord>? _allMatches;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final matches = await context.read<StorageService>().loadMatchHistory();
    if (!mounted) return;
    setState(() => _allMatches = matches);
  }

  @override
  Widget build(BuildContext context) {
    final players = context.watch<PlayersProvider>().players;
    if (_selectedPlayer == null && players.isNotEmpty) {
      _selectedPlayer = players.first;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Match history')),
      body: players.isEmpty
          ? Center(
              child: Text('Add a player to see match history',
                  style: AppTypography.body),
            )
          : _allMatches == null
              ? const Center(child: CircularProgressIndicator())
              : _buildContent(players),
    );
  }

  Widget _buildContent(List<Player> players) {
    final player = _selectedPlayer!;
    final matches = matchesForPlayer(
      player,
      _allMatches!,
      gameName: _selectedGameName,
      range: _range,
    );

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(SpacingTokens.md),
        children: [
          StatsFilterBar(
            players: players,
            selectedPlayer: player,
            onPlayerChanged: (p) => setState(() => _selectedPlayer = p),
            selectedGameName: _selectedGameName,
            onGameNameChanged: (g) => setState(() => _selectedGameName = g),
            range: _range,
            onRangeChanged: (r) => setState(() => _range = r),
          ),
          const SizedBox(height: SpacingTokens.lg),
          if (matches.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xl),
              child: Center(
                child: Text('No matches yet', style: AppTypography.body),
              ),
            )
          else
            for (final match in matches) _MatchTile(player: player, match: match),
        ],
      ),
    );
  }
}

class _MatchTile extends StatelessWidget {
  const _MatchTile({required this.player, required this.match});

  final Player player;
  final MatchRecord match;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final opponents = match.players
        .where((p) => p.id != player.id)
        .map((p) => p.name)
        .join(', ');
    final result = match.winnerId == null
        ? 'Unfinished'
        : (match.winnerId == player.id ? 'Won' : 'Lost');

    return Card(
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.md),
      ),
      margin: const EdgeInsets.only(bottom: SpacingTokens.sm),
      child: ListTile(
        title: Text(gameLabel(match.gameName)),
        subtitle: Text(
          opponents.isEmpty
              ? formatMatchDate(match.finishedAt)
              : 'vs $opponents  ·  ${formatMatchDate(match.finishedAt)}',
        ),
        trailing: Text(
          result,
          style: AppTypography.label.copyWith(
            color: match.winnerId == null
                ? scheme.onSurfaceVariant
                : (match.winnerId == player.id ? scheme.primary : scheme.error),
          ),
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => MatchDetailScreen(match: match)),
        ),
      ),
    );
  }

}
