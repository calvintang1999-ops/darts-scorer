import 'package:flutter/material.dart';

/// Named text styles. Fonts are the platform default for now (fontFamily
/// left unset) - placeholders until visual references arrive. Colours are
/// deliberately NOT set here; widgets get colour from the active
/// ColorScheme so light/dark both work.
abstract final class AppTypography {
  /// The current player's remaining score - must be readable from 2-3
  /// metres away, hence the enormous size.
  static const TextStyle scoreHuge = TextStyle(
    fontSize: 96,
    fontWeight: FontWeight.w800,
    height: 1.0,
    fontFeatures: [FontFeature.tabularFigures()], // digits don't jiggle
  );

  /// Other players' scores and secondary score displays.
  static const TextStyle scoreLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1.0,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Small captions above/below scores ("LEGS", "AVG", player names in
  /// compact spots).
  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
  );

  /// Ordinary running text.
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  /// Text on buttons, including the number pad.
  static const TextStyle button = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
  );
}
