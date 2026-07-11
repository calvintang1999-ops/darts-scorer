import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// The app's standard big button. Screens use this instead of styling
/// ElevatedButton/FilledButton themselves, so a restyle only touches here.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.filled = true,
  });

  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final IconData? icon;

  /// Filled = primary action; outlined-ish tonal = secondary.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon),
              const SizedBox(width: SpacingTokens.sm),
              Text(label),
            ],
          );
    return filled
        ? FilledButton(onPressed: onPressed, child: child)
        : FilledButton.tonal(onPressed: onPressed, child: child);
  }
}
