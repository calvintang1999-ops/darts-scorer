import 'package:flutter/material.dart';

import '../models/game_definition.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';

/// One entry on the home screen's game list, rendered from a
/// GameDefinition out of the registry.
class GameCard extends StatelessWidget {
  const GameCard({super.key, required this.definition, required this.onTap});

  final GameDefinition definition;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dimmed = definition.comingSoon;
    return Card(
      clipBehavior: Clip.antiAlias, // keeps the ripple inside the corners
      child: InkWell(
        onTap: onTap,
        child: Opacity(
          opacity: dimmed ? 0.5 : 1.0,
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.md),
            child: Row(
              children: [
                Icon(definition.icon, size: SizeTokens.playTapTarget / 2,
                    color: scheme.primary),
                const SizedBox(width: SpacingTokens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(definition.name,
                          style: AppTypography.button
                              .copyWith(color: scheme.onSurface)),
                      const SizedBox(height: SpacingTokens.xs),
                      Text(definition.description,
                          style: AppTypography.body
                              .copyWith(color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                if (definition.comingSoon)
                  Chip(label: Text('Soon', style: AppTypography.label)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
