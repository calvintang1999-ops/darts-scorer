import 'package:flutter/material.dart';

import '../theme/typography.dart';

/// A big score with an optional small label above it. Used anywhere a
/// score needs to be readable from across the room.
class ScoreDisplay extends StatelessWidget {
  const ScoreDisplay({
    super.key,
    required this.value,
    this.label,
    this.huge = false,
    this.color,
  });

  final String value;
  final String? label;

  /// True for the current player's main score (largest size).
  final bool huge;

  /// Defaults to the theme's normal text colour.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? Theme.of(context).colorScheme.onSurface;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Text(
            label!.toUpperCase(),
            style: AppTypography.label.copyWith(
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
        // FittedBox shrinks very wide values (e.g. "501") to fit narrow
        // player cards instead of overflowing.
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: (huge ? AppTypography.scoreHuge : AppTypography.scoreLarge)
                .copyWith(color: textColor),
          ),
        ),
      ],
    );
  }
}
