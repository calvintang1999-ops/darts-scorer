import 'package:flutter/material.dart';

import '../models/bot_profile.dart';
import '../models/player.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';

/// The shared "who's playing" picker every game's config screen uses:
/// human players from the roster, tap-to-add-in-throwing-order, plus any
/// preset (or future custom) bot. A bot chip shows its name, target
/// average, and measured checkout % so picking one is an informed choice.
///
/// This widget only renders the picker - it doesn't own selection state or
/// enforce the max-players limit, so the parent screen's existing
/// `_selectedIds` + `_togglePlayer` pattern is unchanged.
class PlayerAndBotPicker extends StatelessWidget {
  const PlayerAndBotPicker({
    super.key,
    required this.roster,
    required this.botProfiles,
    required this.selectedIds,
    required this.onToggle,
    required this.maxPlayers,
    required this.newPlayerController,
    required this.onAddPlayer,
  });

  final List<Player> roster;
  final List<BotProfile> botProfiles;

  /// Ids already picked, in tap (= throwing) order. May contain roster
  /// player ids or bot profile ids.
  final List<String> selectedIds;

  /// Called with whichever id (human or bot) was tapped.
  final ValueChanged<String> onToggle;

  final int maxPlayers;
  final TextEditingController newPlayerController;
  final VoidCallback onAddPlayer;

  @override
  Widget build(BuildContext context) {
    Widget sectionTitle(String text) => Padding(
          padding: const EdgeInsets.only(
              top: SpacingTokens.lg, bottom: SpacingTokens.sm),
          child: Text(text.toUpperCase(), style: AppTypography.label),
        );

    String orderedLabel(String id, String name) {
      final index = selectedIds.indexOf(id);
      return index == -1 ? name : '${index + 1}. $name';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle('Players (1-$maxPlayers, tap in throwing order)'),
        Wrap(
          spacing: SpacingTokens.sm,
          runSpacing: SpacingTokens.sm,
          children: [
            for (final player in roster)
              FilterChip(
                label: Text(orderedLabel(player.id, player.name)),
                selected: selectedIds.contains(player.id),
                onSelected: (_) => onToggle(player.id),
              ),
          ],
        ),
        const SizedBox(height: SpacingTokens.sm),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: newPlayerController,
                decoration: const InputDecoration(
                  labelText: 'New player name',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => onAddPlayer(),
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            IconButton.filledTonal(
              onPressed: onAddPlayer,
              icon: const Icon(Icons.person_add),
            ),
          ],
        ),
        if (botProfiles.isNotEmpty) ...[
          sectionTitle('Bots'),
          Wrap(
            spacing: SpacingTokens.sm,
            runSpacing: SpacingTokens.sm,
            children: [
              for (final bot in botProfiles)
                FilterChip(
                  avatar: const Icon(Icons.smart_toy, size: 18),
                  label: Text(orderedLabel(
                    bot.id,
                    '${bot.name} · avg ${bot.targetAverage.round()} · '
                    '~${bot.measuredCheckoutPercent.round()}% checkout',
                  )),
                  selected: selectedIds.contains(bot.id),
                  onSelected: (_) => onToggle(bot.id),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Resolves an id from [PlayerAndBotPicker.selectedIds] to a real [Player]:
/// a roster lookup, or a fresh bot-backed one if it matches a profile
/// instead. Null if it matches neither (defensive only - shouldn't happen).
Player? resolvePlayerOrBot(
  String id,
  List<Player> roster,
  List<BotProfile> botProfiles,
) {
  for (final player in roster) {
    if (player.id == id) return player;
  }
  for (final profile in botProfiles) {
    if (profile.id == id) return Player.bot(profile);
  }
  return null;
}
