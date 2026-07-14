import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/match_record.dart';
import '../models/player.dart';
import '../services/players_provider.dart';
import '../services/stats/cricket_stats.dart';
import '../services/stats/game_labels.dart';
import '../services/stats/half_it_stats.dart';
import '../services/stats/overall_stats.dart';
import '../services/stats/round_the_clock_stats.dart';
import '../services/stats/stats_filter.dart';
import '../services/stats/x01_stats.dart';
import '../services/storage_service.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/bar_chart_card.dart';
import '../widgets/line_chart_card.dart';
import '../widgets/stat_tile.dart';
import '../widgets/stats_filter_bar.dart';
import 'heatmap_screen.dart';
import 'match_history_screen.dart';

/// Per-player statistics, computed live from raw match history every time
/// this screen loads - nothing here is a stored aggregate.
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
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
    // Default to the first player once the roster has loaded, same pattern
    // as every game's config screen.
    if (_selectedPlayer == null && players.isNotEmpty) {
      _selectedPlayer = players.first;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: players.isEmpty
          ? Center(
              child: Text('Add a player to see stats', style: AppTypography.body),
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

    final byGame = <String, List<MatchRecord>>{};
    for (final match in matches) {
      byGame.putIfAbsent(match.gameName, () => []).add(match);
    }

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
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.history),
                  label: const Text('Match history'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MatchHistoryScreen()),
                  ),
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.grid_on),
                  label: const Text('Heatmap'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HeatmapScreen()),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.lg),
          _SectionHeader('Overview'),
          _OverviewSection(player: player, matches: matches),
          if (byGame['x01'] case final x01Matches?) ...[
            const SizedBox(height: SpacingTokens.lg),
            _SectionHeader('X01'),
            _X01Section(player: player, matches: x01Matches),
          ],
          if (byGame['cricket'] case final cricketMatches?) ...[
            const SizedBox(height: SpacingTokens.lg),
            _SectionHeader('Cricket'),
            _CricketSection(player: player, matches: cricketMatches),
          ],
          if (byGame['round_the_clock'] case final rtcMatches?) ...[
            const SizedBox(height: SpacingTokens.lg),
            _SectionHeader('Round the Clock'),
            _RoundTheClockSection(player: player, matches: rtcMatches),
          ],
          if (byGame['halfit'] case final halfItMatches?) ...[
            const SizedBox(height: SpacingTokens.lg),
            _SectionHeader('Half It'),
            _HalfItSection(player: player, matches: halfItMatches),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
      child: Text(title.toUpperCase(), style: AppTypography.label),
    );
  }
}

/// A simple wrapping grid of StatTiles - every section uses this shape.
class _TileGrid extends StatelessWidget {
  const _TileGrid(this.tiles);

  final List<StatTile> tiles;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: SpacingTokens.sm,
      runSpacing: SpacingTokens.sm,
      children: [
        for (final tile in tiles)
          SizedBox(width: SizeTokens.statTileWidth, child: tile),
      ],
    );
  }
}

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({required this.player, required this.matches});

  final Player player;
  final List<MatchRecord> matches;

  @override
  Widget build(BuildContext context) {
    final stats = OverallStats.compute(player, matches);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TileGrid([
          StatTile(label: 'Matches played', value: '${stats.matchesPlayed}'),
          StatTile(label: 'Record', value: '${stats.wins}W - ${stats.losses}L'),
          StatTile(
              label: 'Win rate',
              value: stats.winRate == null
                  ? null
                  : '${stats.winRate!.toStringAsFixed(0)}%'),
          StatTile(
              label: 'Favourite spot',
              value: stats.favouriteSpot == null
                  ? null
                  : _segmentLabel(stats.favouriteSpot!)),
        ]),
        for (final entry in stats.headlineSeries.entries) ...[
          const SizedBox(height: SpacingTokens.sm),
          LineChartCard(
            title: '${gameLabel(entry.key)} trend',
            points: entry.value,
          ),
        ],
      ],
    );
  }
}

class _X01Section extends StatelessWidget {
  const _X01Section({required this.player, required this.matches});

  final Player player;
  final List<MatchRecord> matches;

  @override
  Widget build(BuildContext context) {
    final stats = X01Stats.compute(player, matches);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TileGrid([
          StatTile(label: '3-dart average', value: _fmt1(stats.threeDartAverage)),
          StatTile(label: 'First 9 average', value: _fmt1(stats.firstNineAverage)),
          StatTile(label: 'Checkout %', value: _fmtPct(stats.checkoutPercentage)),
          StatTile(label: 'Doubles hit rate', value: _fmtPct(stats.doublesHitRate)),
          StatTile(
              label: 'Highest checkout',
              value: stats.highestCheckout?.toString()),
          StatTile(label: '100+ visits', value: '${stats.oneHundredPlusVisits}'),
          StatTile(label: '140+ visits', value: '${stats.oneFortyPlusVisits}'),
          StatTile(label: '180s', value: '${stats.oneEightyVisits}'),
          StatTile(
              label: 'Best leg (darts)', value: stats.bestLegDarts?.toString()),
          StatTile(
              label: 'Worst leg (darts)', value: stats.worstLegDarts?.toString()),
        ]),
        const SizedBox(height: SpacingTokens.sm),
        BarChartCard(
            title: 'Score per visit', buckets: stats.visitScoreBuckets),
      ],
    );
  }
}

class _CricketSection extends StatelessWidget {
  const _CricketSection({required this.player, required this.matches});

  final Player player;
  final List<MatchRecord> matches;

  @override
  Widget build(BuildContext context) {
    final stats = CricketStats.compute(player, matches);
    return _TileGrid([
      StatTile(label: 'Marks per round', value: _fmt1(stats.marksPerRound)),
      StatTile(
          label: 'Most marks in a round',
          value: stats.mostMarksInRound?.toString()),
      StatTile(label: '5+ mark rounds', value: '${stats.fivePlusRounds}'),
      StatTile(label: '6+ mark rounds', value: '${stats.sixPlusRounds}'),
      StatTile(label: '7+ mark rounds', value: '${stats.sevenPlusRounds}'),
      StatTile(label: 'Bulls per round', value: _fmt1(stats.bullsPerRound)),
    ]);
  }
}

class _RoundTheClockSection extends StatelessWidget {
  const _RoundTheClockSection({required this.player, required this.matches});

  final Player player;
  final List<MatchRecord> matches;

  @override
  Widget build(BuildContext context) {
    final stats = RoundTheClockStats.compute(player, matches);
    return _TileGrid([
      StatTile(label: 'Overall hit rate', value: _fmtPct(stats.overallHitRate)),
      StatTile(
          label: 'Favourite number',
          value: stats.favouriteNumber == null
              ? null
              : _segmentLabel(stats.favouriteNumber!)),
      StatTile(
          label: 'Worst number',
          value: stats.worstNumber == null
              ? null
              : _segmentLabel(stats.worstNumber!)),
    ]);
  }
}

class _HalfItSection extends StatelessWidget {
  const _HalfItSection({required this.player, required this.matches});

  final Player player;
  final List<MatchRecord> matches;

  @override
  Widget build(BuildContext context) {
    final stats = HalfItStats.compute(player, matches);
    return _TileGrid([
      StatTile(
          label: 'Average total score', value: _fmt1(stats.averageTotalScore)),
      StatTile(label: 'Best game', value: stats.bestGameScore?.toString()),
      StatTile(
          label: 'Most survived rounds',
          value: stats.mostSurvivedRounds?.toString()),
    ]);
  }
}

String? _fmt1(double? value) => value?.toStringAsFixed(1);

String? _fmtPct(double? value) =>
    value == null ? null : '${value.toStringAsFixed(1)}%';

String _segmentLabel(int segment) => segment == 25 ? 'Bull' : '$segment';
