import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/players_provider.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';

/// Manage the roster of players: create new ones, remove old ones.
/// Choosing who plays a particular match happens on each game's setup
/// screen; this screen owns the underlying list.
class PlayerSelectScreen extends StatefulWidget {
  const PlayerSelectScreen({super.key});

  @override
  State<PlayerSelectScreen> createState() => _PlayerSelectScreenState();
}

class _PlayerSelectScreenState extends State<PlayerSelectScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _add(PlayersProvider provider) {
    provider.addPlayer(_nameController.text);
    _nameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlayersProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Players')),
      body: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'New player name',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _add(provider),
                  ),
                ),
                const SizedBox(width: SpacingTokens.sm),
                IconButton.filledTonal(
                  onPressed: () => _add(provider),
                  icon: const Icon(Icons.person_add),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.md),
            Expanded(
              child: ListView(
                children: [
                  for (final player in provider.players)
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(player.name, style: AppTypography.body),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Remove ${player.name}',
                        onPressed: () => provider.removePlayer(player),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
