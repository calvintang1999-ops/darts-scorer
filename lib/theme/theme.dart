import 'package:flutter/material.dart';

import 'tokens.dart';
import 'typography.dart';

/// Builds the app's ThemeData entirely from tokens. main.dart calls this
/// twice (light + dark) and SettingsProvider decides which one shows.
ThemeData buildAppTheme(Brightness brightness) {
  // ColorScheme.fromSeed derives a full accessible Material 3 palette
  // from the single seed token, for both brightnesses.
  final colorScheme = ColorScheme.fromSeed(
    seedColor: ColorTokens.seed,
    brightness: brightness,
  );

  return ThemeData(
    colorScheme: colorScheme,
    textTheme: ThemeData(brightness: brightness).textTheme.copyWith(
          bodyMedium: AppTypography.body,
          labelLarge: AppTypography.button,
        ),
    cardTheme: CardThemeData(
      elevation: ElevationTokens.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.md),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(SizeTokens.playTapTarget, SizeTokens.buttonHeight),
        textStyle: AppTypography.button,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.md),
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(SizeTokens.playTapTarget, SizeTokens.buttonHeight),
        textStyle: AppTypography.button,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.md),
        ),
      ),
    ),
  );
}
