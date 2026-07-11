import 'package:flutter/material.dart';

import '../models/dart_position.dart';
import '../models/player.dart';
import '../models/throw.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';

/// The shared manual score-entry pad, used by every game mode.
///
/// Flow: optionally tap Double/Treble, then tap a number. Bull, 25 and
/// Miss are single taps. Emits a [Throw] with `source: manual` and
/// `landingPosition: null` - the game owning the screen applies its own
/// rules to it (the pad knows nothing about X01, busts, etc.).
class SegmentInputPad extends StatefulWidget {
  const SegmentInputPad({
    super.key,
    required this.player,
    required this.gameId,
    required this.onThrow,
    this.enabled = true,
  });

  /// Who is throwing right now - stamped onto each emitted Throw.
  final Player player;
  final String gameId;
  final void Function(Throw dartThrow) onThrow;

  /// Disabled while e.g. the game is finished.
  final bool enabled;

  @override
  State<SegmentInputPad> createState() => _SegmentInputPadState();
}

class _SegmentInputPadState extends State<SegmentInputPad> {
  /// 1 = single (no modifier), 2 = double armed, 3 = treble armed.
  int _multiplier = 1;

  void _emit(int segment, int multiplier) {
    widget.onThrow(Throw(
      player: widget.player,
      actualSegment: segment,
      multiplier: multiplier,
      gameId: widget.gameId,
      source: ThrowSource.manual,
      landingPosition: null, // manual entry never has a position
    ));
    // Modifiers are one-shot: after the dart is entered, drop back to single.
    setState(() => _multiplier = 1);
  }

  void _tapNumber(int segment) => _emit(segment, _multiplier);

  void _toggleModifier(int value) {
    // Tapping the active modifier again disarms it.
    setState(() => _multiplier = _multiplier == value ? 1 : value);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Widget padButton({
      required String text,
      required VoidCallback onPressed,
      bool selected = false,
    }) {
      return Padding(
        padding: const EdgeInsets.all(SpacingTokens.xs / 2),
        child: SizedBox(
          // Every pad key is at least the play tap-target size, because
          // the app is used standing at the board.
          height: SizeTokens.playTapTarget,
          child: FilledButton.tonal(
            onPressed: widget.enabled ? onPressed : null,
            style: FilledButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(
                  SizeTokens.playTapTarget, SizeTokens.playTapTarget),
              backgroundColor:
                  selected ? scheme.primary : scheme.surfaceContainerHigh,
              foregroundColor:
                  selected ? scheme.onPrimary : scheme.onSurface,
              textStyle: AppTypography.button,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(RadiusTokens.sm),
              ),
            ),
            child: Text(text),
          ),
        ),
      );
    }

    // 1-20 in a 5-wide grid, then a modifier/special row underneath.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var row = 0; row < 4; row++)
          Row(
            children: [
              for (var col = 0; col < 5; col++)
                Expanded(
                  child: padButton(
                    text: '${row * 5 + col + 1}',
                    onPressed: () => _tapNumber(row * 5 + col + 1),
                  ),
                ),
            ],
          ),
        Row(
          children: [
            Expanded(
              child: padButton(
                text: 'DOUBLE',
                selected: _multiplier == 2,
                onPressed: () => _toggleModifier(2),
              ),
            ),
            Expanded(
              child: padButton(
                text: 'TREBLE',
                selected: _multiplier == 3,
                onPressed: () => _toggleModifier(3),
              ),
            ),
          ],
        ),
        Row(
          children: [
            // Bull taps ignore any armed modifier: there is no treble bull,
            // and the ring itself decides single (25) vs double (50).
            Expanded(
              child: padButton(
                text: '25',
                onPressed: () => _emit(bullSegment, 1),
              ),
            ),
            Expanded(
              child: padButton(
                text: 'BULL',
                onPressed: () => _emit(bullSegment, 2),
              ),
            ),
            Expanded(
              child: padButton(
                text: 'MISS',
                onPressed: () => _emit(missSegment, 1),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
